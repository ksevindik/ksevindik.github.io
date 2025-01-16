# Moving libraries of web apps into shared folder

If you plan to move repeating libraries that several of your web applications depend on to a shared folder of your 
application server, I would definitely say NO! to this request. One of my clients asked me about centralizing such 
repeating libraries into a shared folder. Actually, I had written another blog post in which I mentioned the problems 
that may arise, and I concluded that "it is much more preferable to keep application-specific classes or jars isolated 
in each web application’s private classpath." However, he insisted on seeing what will happen if we try to move them 
out...

I mentioned to him that the main problem arises with some libraries/frameworks located in a common/shared folder that 
need to load classes/resources which should be placed in web application-specific classpath locations, either 
`WEB-INF/classes`, or `WEB-INF/lib`. Unfortunately, due to the ClassLoader hierarchy in web containers, such 
libraries/frameworks could easily fail to load application-specific resources/classes located in web app-specific 
classpath locations.

Web containers use `ClassLoaders` as well as `WebAppClassLoaders`, whose behavior is a bit different from ordinary 
`ClassLoaders`, in order to load and serve web applications deployed. Each web application has its own `WebAppClassLoader`, 
and they first look at those app-specific locations (`WEB-INF/classes` and jars in `WEB-INF/lib`) to load required 
classes/resources. They consult their parent `ClassLoader` only after they fail to find them in those locations. Parent 
`ClassLoaders` show ordinary Java `ClassLoader` behavior. They first ask their parent, and only if their parent returns 
`null`, they will check their classpath locations. Parents will also never ask their children to resolve classes/resources.

In the end, we encountered several different parts that needed to load resources, located in `WEB-INF/classes` or 
`WEB-INF/lib` folders. One was Vaadin. It was located in the shared folder, but it tried to load an application-specific 
class derived from `com.vaadin.Application`. Another problem arose from the Hibernate and Ehcache pair. The 
`net.sf.ehcache.hibernate.EhCacheRegionFactory` class, which is in `ehcache-core.jar`, tried to load `ehcache.xml`, 
located in `WEB-INF/classes`. Actually, those libraries should have been more careful about loading/accessing such 
resources/classes. However, in reality, it is very easy to be hit by such a problem when you try to centralize common 
libraries into a shared folder. I consider that even one of the main obstacles for OSGI to become mainstream was such 
class loading issues and incompatibilities of libraries in OSGI environments.
