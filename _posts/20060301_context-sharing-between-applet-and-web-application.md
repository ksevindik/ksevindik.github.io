# Context Sharing Between Applet and Web Application
In our project, we need to provide some supporting GIS functionality via an `Applet` GUI to our web-based CRUD operations. 
Users, for example, may populate search criteria, entering input both from the web interface, like name pattern, date 
range, etc., and from `Applet` GUI, like selecting a specific region on a map, and then execute their queries and display 
results on both sides. That is, results will show up as rows in a data table on the web page, and as some funny icons on 
the `Applet`.

There is a need to coordinate user operations and share data entered on both sides during the execution of those scenarios. 
We decided to construct a server-side context sharing mechanism. Let’s take searching as an example:

When a user opens a search page in our web application, we automatically create a new context, bound to its user session. 
There are two tab views on the search web page, in one view, the user interacts with web components, and in the other view, 
the user interacts with the `Applet` GUI. They may enter some part of the search criteria from the web side and then switch 
to the `Applet` view to select the interested query region, and then switch back to the web view to execute the query with 
the prepared criteria. Both views make use of the context in the user session to prepare search criteria. More specifically, 
in the `Applet` view, the user selects the search region, the `Applet` gets the context and puts the selected region 
information into the context. Later, when the user switches back to the web view, the web view accesses the context and 
fetches this search region to use it as part of the search criteria and initiates the search. When results are fetched, 
they are also put into the context for the `Applet` view to be able to display them. Hence, results are shown in the web 
view as a normal HTML table, and when the user switches to the `Applet` view, they are fetched from the shared context 
and drawn as icons on a GIS map.

There are several important constructs to realize this architecture. First of all, there is a context service to let both 
views access the context and operate on it on the server side. Second, there is a need to enable `Applet-Web` application 
communication, and finally, keep the context alive between user requests, as user scenarios may span several web requests.

```java
public interface IGISContextService {
    public IGISContext createContext(int contextType);
    public void updateContext(IGISContext gisContext);
    public IGISContext getCurrentContext();
}
```

The context service is implemented as a normal Spring bean and made available as usual on the web side. However, we need 
to provide a mechanism to expose this service interface to our `Applet` client. We utilized Spring’s 
`HttpInvokerServiceExporter` to expose this service bean to the outside world.

```xml
<bean name="/gisContextService.spring" class="org.springframework.remoting.httpinvoker.HttpInvokerServiceExporter">
    <property name="service">
      <ref bean="gisContextService"/>
    </property>

    <property name="serviceInterface">
        <value>tbs.ortak.cbs.servis.IGISContextService</value>
    </property>
  </bean>
```

There was also one more problem on the `Applet` view side. As you may know, the exposed service is accessed in a stateless 
manner, that is, each time a client invokes methods, requests are executed in a different HTTP session. In our case, however, 
we need our client `Applet` to make all of its service method invocations over the same HTTP session because those invocations 
will act on the same context instance each time. We solved this issue by passing session id information as an applet 
initialization parameter and constructed HTTP invoker client proxy using this session id.

```html
<OBJECT ID="fviewer" name="fviewer" classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93" width="900" height="600" align="CENTER">
    <PARAM NAME=CODE                VALUE="tbs.ortak.cbs.fviewer.FViewerApplet">
    <PARAM NAME=CODEBASE            VALUE="http://localhost:8080/GISTestWebApp/fviewerlib">
    <PARAM NAME="type"              VALUE="$">
    <PARAM NAME="scriptable"        VALUE="false">
    <PARAM NAME="archive"           VALUE="tbs.cbs.fviewer.jar">
    <PARAM NAME="sessionId"         VALUE="<%= session.getId() %>">
    <PARAM NAME="serviceName"       VALUE="gisContextService.spring">
    <PARAM NAME="serviceUrlBase"    VALUE="http://localhost:8080/CbsTestWebApp/">
</OBJECT>
```
```java
private void createGISContextService() {
HttpInvokerProxyFactoryBean factoryBean = 
getHttpInvokerProxyFactoryBean();
        try {
        gisContextService = (IGISContextService)factoryBean.getObject();
    } catch (MalformedURLException e) {
        throw new RuntimeException(e);
    }
}

private HttpInvokerProxyFactoryBean getHttpInvokerProxyFactoryBean() throws MalformedURLException {

    HttpInvokerProxyFactoryBean factoryBean = 
new HttpInvokerProxyFactoryBean();
        
    String serviceUrl = getServiceUrl();
    factoryBean.setServiceUrl(serviceUrl);
    factoryBean.setServiceInterface(IGISContextService.class);
    factoryBean.afterPropertiesSet();
    return factoryBean;
}
    
private String getServiceUrl() {
    String url = paramServiceUrlBase + paramServiceName;
    url += (paramSessionId != null && paramSessionId.trim().length() > 0) ? 
                (";jsessionid=" + paramSessionId):"";
    return url;
}
```
The third problem was to keep the context alive across several web requests, and we achieved this with a Filter similar 
to Acegi Security Framework’s `HttpSessionContextIntegrationFilter` mechanism. When a request arrives, we take the context 
from the HTTP session and put it into a `ThreadLocal` variable, and make it available to our context service bean. Later, 
while the response returns, we take this context from the `ThreadLocal` variable and put it back into the HTTP session.

```java
public class ThreadLocalGISContextHolder implements IGISContextHolder {
    private static final ThreadLocal contextHolder = new ThreadLocal();
    private static final IGISContextHolder instance = new ThreadLocalGISContextHolder();

    private ThreadLocalGISContextHolder() {}

    public static IGISContextHolder getInstance() {
        return instance;
    }
    
    public IGISContext getContext() {
        Object obj = contextHolder.get();
        return obj != null ? (IGISContext)contextHolder.get():new NullGISContext();
    }
    
    public void setContext(IGISContext gisContext) {
        contextHolder.set(gisContext);
    }
}
```

In summary, this server-side context sharing mechanism enabled us to easily implement our scenarios, which need to collect 
user input from both sides, which are from different clients – one is a web page, and the other is an `Applet` client – and 
share resulting data between them.
