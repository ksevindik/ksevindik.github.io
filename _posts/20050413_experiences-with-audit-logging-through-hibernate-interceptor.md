# Experiences with Audit Logging through Hibernate Interceptor

In our current project, we make use of the Hibernate Interceptor to perform auditing and track operations performed with 
our domain objects. Initially, we simply followed the instructions in the Hibernate In Action book. Basically, the steps 
are as follows:

1. Declare an Auditable interface and define methods within it for the information you want to audit about your domain objects. Our domain objects should implement this interface if they are to be auditable.
2. Define an AuditLog class to represent audit log information about our create/update/delete operations.
3. Implement an AuditLogInterceptor to capture insert, update, and delete events performed with our auditable domain objects, using the onSave, onFlushDirty, and onDelete callback methods respectively.
4. Finally, create and insert AuditLog objects for each inserted, updated, and deleted domain object.
   
It is important not to use the original Hibernate session object in your Interceptor, as it is illegal to do so in the 
callback methods of the Interceptor. Therefore, we need to employ a new session to insert those AuditLog objects into our 
database.

So far, we have created an audit logging mechanism based on the above instructions, and it seemed to be working properly 
until we noticed that audit logs exist for operations that were involved in a rolled-back transaction. The original 
modified domain object is not in the database as it is rolled back, but its audit log exists in the log table! The reason 
for this is that, if you look at the code sample below for the AuditLogInterceptor, manipulated auditable domain objects 
are kept in three sets. On a postFlush method call, which occurs during transaction commit, we create and insert audit 
log records according to the contents of those sets, and finally, we clear the contents of those sets for a new turn. 
Unfortunately, postFlush is never called if a rollback occurs, hence the contents of the sets are not cleared. We 
resolved this situation by extending the HibernateTransactionManager and overriding its doRollback method, and clearing 
those contents by explicitly calling the reset method.

```java
public class AuditLogInterceptor implements Interceptor {
    ...
    
    private HashSet inserts  = new HashSet();
    private HashSet updates = new HashSet();
    private HashSet deletes = new HashSet();

    public boolean onFlushDirty(Object entity,...) throws CallbackException {
        if(entity instanceof Auditable) {
            updates.add(entity);
        }
        return false;
    }

    public boolean onSave(Object entity,...) throws CallbackException {
        if(entity instanceof Auditable) {
            inserts.add(entity);
        }
        return false;
    }

    public boolean onDelete(Object entity,...) throws CallbackException {
        if(entity instanceof Auditable) {
            deletes.add(entity);
        }
        return false;
    }

    public void postFlush(Iterator entities) {
        try {
            //perform inserting audit logs for entities those were enlisted in inserts, //updates, and deletes sets...
        } catch(Exception e) {
        } finally {
            //clear those inserts, deletes, and updates sets contents...
            reset();
        }
    }

    public void reset() {
        inserts.clear();
        updates.clear();
        deletes.clear();
    }
    
    ...
}
```

For the above implementation, there is another problem. We use Spring and Hibernate together, and let Spring manage 
transactions. In order to make the AuditLogInterceptor work, we have to set it either at the SessionFactory level or at 
the Session level. It is preferable to set it on LocalSessionFactoryBean or HibernateTransactionManager to avoid repeated 
configuration and provide consistent behavior in transactions. However, if we set the Interceptor on those objects, it 
must be a singleton according to Spring documentation. If it is a singleton, our insert, update, delete sets will be 
accessible through multiple threads, potentially in multiple transactions. This could lead to a condition where two 
different transactions populate audit information in those sets, and if one commits and the other rolls back, we might 
lose all of our audit log information belonging to the committing one.

We can solve this problem by introducing ThreadLocal. We simply create a ThreadLocal object that will keep those set 
instances separate for each different thread.

```java
public class AuditLogInterceptor implements Interceptor {
    ...
    
    class AuditSetWrapper {
        public HashSet inserts  = new HashSet();
        public HashSet updates = new HashSet();
        public HashSet deletes = new HashSet();
    }
    
    private ThreadLocal auditSetHolder = new ThreadLocal();
    ...
    
    private AuditSetWrapper getAuditSetWrapper() {
        Object o = auditSetHolder.get();
        if(o == null) {
            o = new AuditSetWrapper();
            auditSetHolder.set(o);
        }
        return (AuditSetWrapper)o;
    }
    ...
}
```

Then we access our insert, update, delete sets through that AuditSetWrapper object, and since it is distinct for each 
different thread context, we successfully isolate our audit log information for different concurrently running transactions.

Another problem with auditing through Interceptor is logging differences on updates. The onFlushDirty callback provides 
both the current and previous states of our domain objects, allowing us to easily create audit log records accordingly. 
Unfortunately, the onFlushDirty method provides this useful information only if our object loads and updates are performed 
in one single Hibernate session. If we use detached objects, we will not be able to obtain the previous state; it will 
simply be null.

Several solutions exist for this problem:

1. One is to employ Application Sessions (Long Sessions) instead of the Session per Request pattern, so our original session 
will be preserved over multiple requests.
2. Another option is to use the select-before-update property introduced in Hibernate 2.1, although it is simply useless for 
getting previous states (please refer to the following paragraph for an explanation).
3. Finally, we can implement a custom EntityPersister and keep track of the domain objects' states.
We currently opted for the second choice as it requires no additional coding overhead and no architectural change compared 
to the first choice. However, it introduces a performance overhead as Hibernate will first look at the database before 
each update.

**Update:**

_I want to apologize to those who have been misled by the above information. Select-before-update does not provide a 
solution for obtaining previous states of detached objects in the onFlushDirty callback. As far as I know, there is no 
straightforward solution for this in Hibernate 2.x, unless we use application sessions or implement our custom 
EntityPersister. Fortunately, in Hibernate 3.x, the merge operation helps us to load the previous state of an entity and 
merge its contents with the current entity. During the update process, the onFlushDirty and findDirty callbacks return 
correct previous state information because the merge operation loads the entity into the session. If we first merge our 
entities before updating them in our DAO or service methods, we can obtain the previous state information in the 
Hibernate Interceptor._
