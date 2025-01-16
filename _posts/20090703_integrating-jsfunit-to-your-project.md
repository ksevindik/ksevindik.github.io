# Integrating JSFUnit To Your Project
Actually I am not a big fan of in-container unit testing approaches. They have longer execution times, e.g. container and 
database startup, initialization times, etc. In addition, they create configuration complexity in terms of packaging of 
tests and deployment of application together with them. Anyway, recently I needed to examine `JSFUnit` solution more 
closely for some issue and integrated it into my project.

`JSFUnit` is based on `Cactus` in-container unit testing framework. Tests are run on server side and results can be 
examined through your browser. I had [presented](20050520_cactus-xor-mocks-or-cactus-and-mocks.md) about `Cactus` several 
years ago. I found that presentation in one of the 
dusty corners of my laptop. It was a nice nostalgia for me.

Anyway, `JSFUnit` has a really good [startup document](https://jsfunit.jboss.org/gettingstarted.html) on its site. I 
have totally followed their step-by-step guides and 
it almost worked. I had a stupid error while running my tests. The problem was because of `Spring WebFlow`’s `JSF 1.1` 
compatibility efforts. As you may know, `SWF2` has some `JSF` specific parts. Their `FlowFacesContext` implementation 
tries to understand if `getELContext()` method is available in the delegated `FacesContext` object, in that case 
`JSFUnitFacesContext` instance, via reflection. As `JSFUnit` supports `JSF 2.0`, trying to understand if that method is 
supported via class retrospection will cause `ClassNotFoundException`. Here is the stacktrace:

```
Caused by: java.lang.NoClassDefFoundError: javax/faces/context/ExceptionHandler 
at java.lang.Class.getDeclaredMethods0(Native Method) 
at java.lang.Class.privateGetDeclaredMethods(Class.java:2427) 
at java.lang.Class.getMethod0(Class.java:2670) 
at java.lang.Class.getMethod(Class.java:1603) 
at org.springframework.util.ClassUtils.getMethodIfAvailable(ClassUtils.java:549) 
at org.springframework.faces.webflow.FlowFacesContext.getELContext(FlowFacesContext.java:97) 
at org.speedyframework.web.view.jsf.util.JsfUtils.createValueExpression(JsfUtils.java:45) 
at org.speedyframework.web.view.jsf.component.ui.Label.(Label.java:32) 
at org.speedyframework.admin.pages.common.Login.afterPropertiesSet(Login.java:40) 
at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.invokeInitMethods(AbstractAutowireCapableBeanFactory.java:1369) 
at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.initializeBean(AbstractAutowireCapableBeanFactory.java:1335) 
... 
85 more 
Caused by: java.lang.ClassNotFoundException: javax.faces.context.ExceptionHandler 
at org.apache.catalina.loader.WebappClassLoader.loadClass(WebappClassLoader.java:1360) 
at org.apache.catalina.loader.WebappClassLoader.loadClass(WebappClassLoader.java:1206) 
at java.lang.ClassLoader.loadClassInternal(ClassLoader.java:319) 
... 96 more
```

Unfortunately, there is no clean solution for such a problem in the current Java classloading model. We still wait for 
developments to get matured enough in `OSGI` area for `JEE`. For the moment, we just need to add `JSF 2.0 API` jar to the 
classpath, even though we still use `MyFaces` implementation of `JSF 1.2`. After adding `jsf-api-2.0.jar` to the classpath, 
the problem is carried to somewhere else. This time, `JSF 2.0` classes were loaded before `JSF 1.2` classes because of 
Java class discovery mechanics. `Classloaders` process jars alphabetically, and classes with the same signatures in a 
different jar will get loaded before your actual classes. We just have to rename `jsf-api.jar` to come after `myfaces-api.jar` 
by putting `‘z-‘` in front of its name to solve this problem as well.

Another annoying part during `JSFUnit` integration was related to the oldness of `Cactus` Framework. It still depends on 
ages-old `JUnit 3.8.1`, and if you use `JUnit 4`, it won’t work. You need to add `JUnit 3.8.1` jars in your classpath. 
The same jar renaming approach can be followed in order for classes with the same signature in `JUnit4` jar to be 
discovered at first place.
