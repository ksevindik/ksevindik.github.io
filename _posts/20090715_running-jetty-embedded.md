# Running Jetty Embedded
While I was playing with `JSFUnit`, I just needed to start a web container inside my tests. `Jetty` is very famous as 
being embeddable in standalone Java applications. Therefore, spots are directed onto Jetty's website, and I downloaded 
the latest stable version and started playing with it.

First, you need to add `servlet.jar`, `jetty.jar`, `jetty-util.jar`, and `start.jar` to your classpath to run Jetty.

After that, create a new `Server` instance and a `Connector` to answer HTTP requests from a specific port.
```java
Server server = new Server(); 
SelectChannelConnector connector=new SelectChannelConnector(); 
connector.setPort(Integer.getInteger("jetty.port",8088).intValue()); 
server.setConnectors(new Connector[]{connector});
```
`Connector` needs to call a `Handler` for each request received. Therefore, we need to create and add a `Handler` to the 
`Server` instance. `WebAppContext` is a special `Handler` instance to start your web application.

```java
WebAppContext webapp = new WebAppContext();
webapp.setParentLoaderPriority(true);
webapp.setContextPath("/myproject");
webapp.setWar("d:/work/projects/myproject/WebContent");
webapp.setDefaultsDescriptor("d:/work/projects/myproject/webdefault.xml");
server.setHandler(webapp);
```

`webdefault.xml` of Jetty can be found in its distribution bundle under the `etc` directory.

Finally, we can run our server;

```java
server.start();
```

If we want Jetty’s thread pool to be blocked until `LifeCycle` objects are stopped, then we just need to call the 
`Server`'s `join` method.

```java
server.join();
```

In order to stop your server when you are finished with it, call its `stop` method.

```java
server.stop();
```

That’s all...
