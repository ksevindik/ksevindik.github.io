# Uncaught Exception Handling in Java Server Faces
First, a brief flashback on how we can handle uncaught exceptions in web applications. As you're likely aware, there's a 
general exception/error trapping mechanism for servlet/JSP-based web applications. We simply add error-page definitions 
in the web.xml file for uncaught exceptions or HTTP status codes to display custom error pages to users, rather than 
displaying bare exception stack traces or HTTP status code pages. This mechanism applies to all JSP pages. If we want to 
override these definitions, we can always use the errorPage page directive in JSP pages to forward requests in case an 
uncaught exception occurs during request processing. The following lines illustrate these configurations:
```xml
<error-page>
    <exception-class>java.lang.Throwable</exception-class>
    <location>/error/generalErrorPage.jsp</location>
</error-page>

<error-page>
    <error-code>403</error-code>
    <location>/error/accessDeniedPage.jsp</location>
</error-page>
```
The above lines are excerpts from a web.xml file. These XML elements specify that in case of any uncaught exception during 
request processing, the request should be forwarded to the defined location. We can be more specific in exception types 
in error-page definitions. For example, if we define another error page for java.lang.NullPointerException, an uncaught 
exception will first be checked against that definition, as it is more specific than java.lang.Throwable type. If we want 
to forward the request to any other more specific error page, we can use the errorPage directive as follows:

In customer.jsp: It is better to define the isErrorPage="true" attribute in generalErrorPage.jsp to be able to access the 
implicit exception variable. By the way, that exception information is kept in the request with one of these two attributes: 
javax.servlet.jsp.jspException and javax.servlet.error.exception. Therefore, we can even access exception information without 
the need for the exception implicit variable. Setting isErrorPage="true" causes error forwarding not to work for JSF-enabled 
JavaServer Pages. For JSF, the above exception/error handling mechanism can be partly used, but we seek a more complete 
solution to catch and handle exceptions. It would be better to extend FacesServlet and catch any exception, log it, and 
finally forward it to a custom error page, but unfortunately, this is not possible as FacesServlet is declared final. A 
detailed search on the internet revealed that we could also extend default ActionListener and ViewHandler implementations 
and handle all exceptions while delegating necessary operations to their supertype implementations, respectively. We could, 
for example, extend the default ActionListener implementation and provide an action processing method implementation similar 
to the one below:
```java
public void processAction(ActionEvent event) {
    try {
        super.processAction(event);
    } catch (Exception e) {
        logger.error("Exception occured!",e);
        FacesContext context = FacesContext.getCurrentInstance();
        Context.getApplication().getNavigationHandler().handleNavigation(context, null, "error");
    }
}
```
then
```xml
<navigation-rule>
    <navigation-case>
        <from-outcome>error</from-outcome>
        <to-view-id>/error.jsp</to-view-id>
        <redirect />
    </navigation-case>
</navigation-rule>
```
We also add a navigation rule similar to the one above into faces-config.xml. Additionally, don't forget to define new 
action listeners and view handlers as the system's current handlers, again in faces-config.xml. Below is a sample 
implementation of a ViewHandler:
```java
try {
    super.renderView(context, viewToRender);
} catch (Exception e) {
    UIViewRoot errorViewRoot = createView(context, "/error.jsp");
    super.renderView(context, errorViewRoot);
}
```
Although we succeeded in making the ActionListener implementation work as expected, the view handler rendered an empty 
HTML page for error.jsp. I suspect that we're trying to make the Faces servlet stop the previous rendering process and 
start rendering error.jsp without resetting the Faces servlet's internal state back to a valid one. Another problem is 
that we most probably need to provide other custom handler or listener implementations for other parts of JSF, such as 
validation handling.

Our current solution employs aspects to surround the FacesServlet's service method with a try-catch block. We catch any 
exception, log it, and finally forward the current request to a custom error page. To achieve this, we used AspectJ's byte 
code weaving in JAR feature.

Below is an excerpt from our aspect:
```java
pointcut serviceMethod(ServletRequest request, ServletResponse response) :
	execution(public void FacesServlet.service(..)) && args(request,response);

void around(ServletRequest request, ServletResponse response) throws IOException, ServletException : serviceMethod(request,response) {
	try {
		proceed(request,response);
	} catch(Exception e) {
		Logger.error("Exception!",e);
		Request.getRequestDispatcher("/error.jsp").forward(request,response);
	}
}
```
In conclusion, it is evident that JSF relies heavily on the existing error-page mechanism for handling uncaught exceptions 
in JSP pages. However, this solution is far from complete. It would be much better if JavaServer Faces had a general, 
one-point configurable exception handling infrastructure. But it seems that, at least for version 1.0, this is not the case.