# Clean Up Your ThreadLocals

Forgetting to clean up `ThreadLocal` variables might really hurt you. Let’s see how. I have several integration tests with 
Spring WebFlow and JSF, and in one of them, I have a `setUp` method like this:

```java
@Before
 public void setUp() {
     RequestContextHolder.setRequestContext(new MockRequestContext());
 }
```

I just create a `MockRequestContext` and put it into `RequestContextHolder` so that WebFlow will think that it is a flow 
request. Everything was fine until I coded some other integration test using my own `AbstractJsfTests` class, which basically 
initializes `FacesContext` and executes the lifecycle in standalone mode. At the rendering phase, my test was failing with 
an exception.

```stacktrace
avax.servlet.ServletException: The current state 'mockState' of this flow 'mockFlow' is not a view state - view scope not accessible

java.lang.RuntimeException: javax.servlet.ServletException: The current state 'mockState' of this flow 'mockFlow' is not a view state - view scope not accessible
 at org.speedyframework.web.view.jsf.test.AbstractJsfTests.createDocumentFromUIViewRoot(AbstractJsfTests.java:333)
 at org.speedyframework.web.view.jsf.component.builder.PageBuilderTests.processPageContent(PageBuilderTests.java:53)
 at org.speedyframework.web.view.jsf.component.builder.PageBuilderTests.testHtmlContentWithBodyOnly(PageBuilderTests.java:60)
 Caused by: javax.servlet.ServletException: The current state 'mockState' of this flow 'mockFlow' is not a view state - view scope not accessible
 at org.speedyframework.web.view.jsf.test.ErrorPageWriter.throwException(ErrorPageWriter.java:401)
 at org.speedyframework.web.view.jsf.test.ErrorPageWriter.handleException(ErrorPageWriter.java:353)
 at org.speedyframework.web.view.jsf.test.AbstractJsfTests.handleLifecycleException(AbstractJsfTests.java:287)
 at org.speedyframework.web.view.jsf.test.AbstractJsfTests.executeFacesLifecycle(AbstractJsfTests.java:171)
 at org.speedyframework.web.view.jsf.test.AbstractJsfTests.createDocumentFromUIViewRoot(AbstractJsfTests.java:320)
 Caused by: java.lang.IllegalStateException: The current state 'mockState' of this flow 'mockFlow' is not a view state - view scope not accessible
 at org.springframework.webflow.test.MockFlowSession.getViewScope(MockFlowSession.java:99)
 at org.springframework.webflow.test.MockRequestContext.getViewScope(MockRequestContext.java:147)
 at org.springframework.faces.webflow.FlowViewStateManager.saveView(FlowViewStateManager.java:149)
 at org.apache.myfaces.application.jsp.JspViewHandlerImpl.renderView(JspViewHandlerImpl.java:396)
 at org.speedyframework.web.view.jsf.handler.SpeedyFacesViewHandler.renderView(SpeedyFacesViewHandler.java:163)
 at org.springframework.faces.webflow.FlowViewHandler.renderView(FlowViewHandler.java:91)
 at org.apache.shale.validator.faces.ValidatorViewHandler.renderView(ValidatorViewHandler.java:130)
 at org.ajax4jsf.application.ViewHandlerWrapper.renderView(ViewHandlerWrapper.java:100)
 at org.ajax4jsf.application.AjaxViewHandler.renderView(AjaxViewHandler.java:176)
 at org.apache.myfaces.lifecycle.RenderResponseExecutor.execute(RenderResponseExecutor.java:41)
 at org.apache.myfaces.lifecycle.LifecycleImpl.render(LifecycleImpl.java:140)
 at org.speedyframework.web.view.jsf.test.AbstractJsfTests.executeFacesLifecycle(AbstractJsfTests.java:169)
```

The exception was implying that WebFlow was in action during request processing. However, my test was creating a mock HTTP 
request that wasn’t triggering any flow execution. When I looked at `FlowViewStateManager.saveView(FlowViewStateManager.java:149)`, 
I realized that the `FlowViewStateManager` instance was thinking there was an active flow instance by first looking for a 
`RequestContext` instance bound to the current thread context and was finding one in it. But how could it have been possible 
if my request was a non-flow request? After all, `RequestControlContext` instances are only put into the current thread 
context by WebFlow during flow start or flow resume steps.

Then I searched my source code base for any other calls to `RequestContextHolder.setRequestContext(…)` and found the block 
above! Yeah, that was the case—two different tests were somehow executed in the same thread, and the first one, which 
created a `RequestContext` instance, was not cleaning up its `ThreadLocal` variable when finished. As a result, the other 
test was affected and failed because of this side effect. The solution was simple:

```java
@After
 public void tearDown() {
     RequestContextHolder.setRequestContext(null);
 }
```

Not cleaning up `ThreadLocal` variables is also a security threat for your application. Containers usually reuse threads 
to handle HTTP requests across different applications, and sensitive information put into the thread context by your 
application might be accessible when the thread used to process your request is used to handle some other request arriving 
at a different application. Hence, it is always a good practice to clean up the thread context at appropriate exit points 
in your application.
