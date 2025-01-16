# How to Customize Dirty Check Mechanism of Hibernate During Flush

![](images/comparing.png)

Hibernate needs to identify which entities in the Session has been changed, in other words become dirty in the meantime, 
so that it can issue an update sql statement to reflect those changes into the database. The default mechanism to identify 
dirty entities is to compare each attribute one by one with the snapshot kept within the Session. However, this dirty 
checking process may take a significant amount of time if there are lots of entities already loaded in the Session, or 
number of attributes are as many within the processed entities. Often times, enterprise applications already have the 
knowledge of an entity’s dirtiness. For example, some entities might have been bound to the UI and any user interaction 
might be considered as a state change, and this might be tracked within the domain entity itself already. Therefore, it 
becomes unnecessary to perform dirty checking for such entities a second time.

We need a customization point for such cases, and luckily Hibernate provides us with three different mechanisms to customize 
dirty checking process. Let’s overview those one by one.

The first customization point is Hibernate’s old school Interceptor mechanism. Hibernate Interceptor API is used to hook 
into the execution of Session operations, and findDirty() is one of those such methods, which let us to determine whether 
the given entity is dirty or not.

```java
int[] findDirty(Object entity, Serializable id,
    Object[] currentState, Object[] previousState,
    String[] propertyNames,Type[] types);
```

Interceptor implementations might be configured and created either on SessionFactory or Session level as follows;

```xml
<hibernate-configuration>
    <session-factory>
        <property name="hibernate.session_factory.interceptor">x.y.CustomInterceptor1</property>
        <property name="hibernate.session_factory.session_scoped_interceptor">x.y.CustomInterceptor</property>
    </session-factory>
</hibernate-configuration>
```

Another way to customize dirty checking strategy is to make entity class to implement Hibernate’s SelfDirtinessTracker. 
This interfaces defines a contract for an entity to manage and track its own dirtiness state. Entity classes are free to 
implement this interface. Hibernate also makes entity classes to implement it when using byte code enhancement.

```java
public interface SelfDirtinessTracker {
    boolean $$_hibernate_hasDirtyAttributes();
    String[] $$_hibernate_getDirtyAttributes();
    void $$_hibernate_trackChange(String attributes);
    void $$_hibernate_clearDirtyAttributes();
    void $$_hibernate_suspendDirtyTracking(boolean suspend);
    CollectionTracker $$_hibernate_getCollectionTracker();
}
```

The third, and the last way is to implement CustomEntityDirtinessStrategy interface introduced by Hibernate recently.

```java
public interface CustomEntityDirtinessStrategy {
    public boolean canDirtyCheck(Object entity, EntityPersister persister, Session session);
    public boolean isDirty(Object entity, EntityPersister persister, Session session);
    public void resetDirty(Object entity, EntityPersister persister, Session session);
    public void findDirty(Object entity, EntityPersister persister, Session session, DirtyCheckContext dirtyCheckContext);
}
```

This interface allows applications to manage dirtiness information by themselves You need to register the implementation 
class in the hibernate.cfg.xml as follows.

```xml
<hibernate-configuration>
    <session-factory>
        <property name="hibernate.entity_dirtiness_strategy">x.y.CustomDirtinessStrategyImpl</property>
    </session-factory>
</hibernate-configuration>
```

As we all know, Hibernate developers warn us not to trigger flush frequently, as it is an expensive process, and its cost 
is highly comes from this dirty checking process. It is still a valid advice not to call flush frequently within your 
application, however, by means of those custom mechanisms we are able to improve dirty checking process quite easily.