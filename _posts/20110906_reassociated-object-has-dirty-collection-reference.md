# Reassociated object has dirty collection reference

This is something really weird Hibernate error you may come up in several situations. When I first googled around, I 
found some sites commenting the source of error as “trying to attach a transient entity with the session, or entity with 
a collection not in type of PersistentCollection etc.” However, none of those cases matches with mine. Let’s first review 
how this error occurs in code:

```java
Owner owner = new Owner();
Session session = sessionFactory.openSession();
session.save(owner);
session.close();
session = sessionFactory.openSession();
session.buildLockRequest(LockOptions.NONE).lock(owner);
```

I have two entities, `Owner` and `Pet`, which have 1:M association in between. I simply instantiate an `Owner` with 
auto-generated identity strategy, create a Hibernate `Session`, and save it. As I use HSQL, the save operation causes an 
immediate `INSERT` into DB. Then immediately close the session, open a new one, and lock the detached `Owner` instance.
At this point I got the following exception stack trace:

```stacktrace
org.hibernate.HibernateException: reassociated object has dirty collection reference
at org.hibernate.event.def.OnLockVisitor.processCollection(OnLockVisitor.java:71)
at org.hibernate.event.def.AbstractVisitor.processValue(AbstractVisitor.java:124)
at org.hibernate.event.def.AbstractVisitor.processValue(AbstractVisitor.java:84)
at org.hibernate.event.def.AbstractVisitor.processEntityPropertyValues(AbstractVisitor.java:78)
at org.hibernate.event.def.AbstractVisitor.process(AbstractVisitor.java:146)
at org.hibernate.event.def.AbstractReassociateEventListener.reassociate(AbstractReassociateEventListener.java:102)
at org.hibernate.event.def.DefaultLockEventListener.onLock(DefaultLockEventListener.java:82)
at org.hibernate.impl.SessionImpl.fireLock(SessionImpl.java:766)
at org.hibernate.impl.SessionImpl.fireLock(SessionImpl.java:758)
at org.hibernate.impl.SessionImpl.access$500(SessionImpl.java:148)
at org.hibernate.impl.SessionImpl$LockRequestImpl.lock(SessionImpl.java:2278)
...
```

When I closely inspect the source code in `OnLockVisitor.processCollection()` method, I saw that my `Owner` instance is 
attached successfully, and `Set` instance, mapping the 1:M association between `Owner-Pet`, is of type `PersistentSet`. 
Everything looked fine until coming to a point at which the snapshot, corresponding to the `PersistentSet` instance, is 
checked for validity. At this point, Hibernate was identifying that the snapshot instance was invalid because some of its 
attributes, key, role for example, were `NULL`!

It was obvious that at the point of the save operation, some part of `PersistentSet` is not initialized fully. When I put 
a `session.flush()` statement after the save operation and executed the code block again, the error just disappeared! When 
I inspected those attributes, which were uninitialized before, they were fully initialized this time.

The above code piece is actually only a test case. I actually came up with this error in a project where Spring declarative 
transaction management is active, and `HibernateTransactionManager` is used to manage transactions. As the save logic 
executed inside a transactional method, I had expected an immediate flush at the point of TX commit. However, when I 
checked log messages, there were no log messages indicating a flush operation after TX commit. When I returned back to 
the place where declarative transaction is configured for this operation, I noticed that there was a `readOnly=true` 
attribute in the TX definition!

As this attribute changes `FlushMode` to `MANUAL` in Hibernate, as long as we don’t call `session.flush()` explicitly, 
there will be no flush. As a result, code which first saves an entity in one session and then tries to attach it with 
another session will face the above error.

`readOnly=true` attribute is useful when we try to implement conversations together with Spring and Hibernate, however, 
in our case, the Session’s lifetime was bound till the end of the HTTP request. Obviously, it was mistakenly placed in 
this case. However, this error warns us that if we employ long-running Sessions and somehow evict an instance after saving 
it and then try to reattach it before flush, we will have the same error. Just keep it in your mind!
