# Running Jetty Embedded Continued

For some time ago, I had [mentioned](http://www.kenansevindik.com/running-jetty-embedded) running 
Jetty embedded. This time, while I am still running it embedded, I need to set 
the “WebContent” path from inside the classpath of the application. It will reside next to my test class. As I don’t want 
to couple my test case with the absolute path of the project, I first find a way to get the absolute path of my test case.

```java
String path = getClass().getResource(".").getPath();
```

The rest is very similar to my previous post… I just replaced `setWar()` with `setResourceBase()`, and `setDefaultDescriptor()` 
with `setDescriptor()`.

```java
webapp.setResourceBase(path + "/WebContent");
webapp.setDescriptor(path + "/WebContent/WEB-INF/web.xml");
```

BTW, another quick note is, in order to enable JSP support, you will need to copy jars in `lib/jsp-2.0` or `jsp-2.1` coming 
with Jetty dist.
