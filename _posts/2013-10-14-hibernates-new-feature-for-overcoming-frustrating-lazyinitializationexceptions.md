# Hibernate’s New Feature For Overcoming Frustrating LazyInitializationExceptions

For many years LazyInitializationExceptions have become most frustrating point of Hibernate. This exception occurs when 
you try to access an un-initialised lazy association of a detached entity. In general, entities become detached in three 
different ways;

- session close
- session clear
- session evict

You have to be sure that any lazy attributes you will access be initialised before those three cases happen. Otherwise 
you will come up with the infamous LazyInitializationException.

So what are the ways to get rid of that exception? There are several ways available in Hibernate and employed among the 
community;

- You can invoke `Hibernate.initialize(proxy)` on each lazy attribute before their owning entity becomes detached. 
- You have to access their specific properties such as ids before detachment such as `x.getLazySet().size()` or 
`x.getLazyManyToOneAssoc().getId()`.
- For web applications you can also employ `OpenSessionInViewFilter` which keeps session open until the end of view render 
process so that entities won’t become detached before those lazy attributes accessed.
- You can also reattach detached entities before accessing their lazy attributes using session `merge` or `lock` operations.

However, with Hibernate 4.1.6 a new feature is introduced to handle those lazy problems. When you enable 
`hibernate.enable_lazy_load_no_trans` property in `hibernate.properties` or in `hibernate.cfg.xml`, you will have no 
`LazyInitializationException` any more. It works for any sort of lazy associations not only many sided (1:M, N:M) but also 
one sided (1:1,:M:1) as well. So what does this property do? It simply signals Hibernate that it should open a new session 
if session which is set inside current un-initialised proxy is closed.

You should be aware that if you have any other open session which is also used to manage current transaction, this newly 
opened session will be different and it may not participate into the current transaction unless it is JTA. Because of this 
TX side effect you should be careful against possible side effects in your system.

Another important point is that this feature only works for proxies whose sessions are closed or their owning entity is 
evicted from the session. If the entity become detached with session clear then you will still have the lazy problem. 
According to code comments in Hibernate’s `AbstractPersistentCollection` class, Hibernate team aims to handle session 
clear in the next major release.
