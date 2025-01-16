# Reusing Persistent Token Mechanism of Spring Security

Spring Security Framework exists in my enterprise application development tool suite for ages. Over the years, it has 
evolved a lot and become a much more reusable and extendable framework for various security needs.

Recently, one of my clients came up with an interesting requirement. They are developing a mobile client for their 
enterprise web application and want to make their client communicate with the server side via REST-based web service 
calls. However, after login requests, they don’t want to continue providing credentials information for every subsequent 
request. Instead, they asked if a token could be used to indicate the client is already authenticated. That token would 
be generated during the authentication process, returned to the client, and the client will place it into further requests 
and so on. In order to improve security, they also asked about changing the token for each request so that in case another 
user obtains the token during the client-server interaction, the system should detect theft attempts immediately. Tokens 
will be valid for several weeks, and after that period, they will expire, and the user will be made to log in again.

After listening and discussing those requirements, instead of creating a brand-new solution, I thought about employing 
Spring Security Framework’s remember-me authentication. Remember-me authentication basically does the same token management 
task as well. During the form login process, the user tells the remember-me module to remember them when the browser is 
closed and reopened. That way, the user won’t be asked for credentials again and again. Spring Security handles this by 
using cookies. Remember-me authentication information is sent to the client after successful authentication and stored as 
a cookie in the client. When the user opens their browser and types in one of the application’s secure URLs in the location 
bar, Spring Security won’t redirect them to the login page but let the user access the requested page according to their 
granted authorities, of course. Spring Security’s remember-me service has two forms; one is `TokenBasedRememberMeServices` 
and the second is `PersistentTokenBasedRememberMeServices`. Both use the cookie mechanism, but the second one is more 
secure as it never sends username information to the client side and the token is regenerated for each subsequent request.

The main difference in our implementation was that we carried credentials and token information in HTTP request and response 
headers. Spring Security provides convenient methods in order to extract such information from the request and let us set 
the token into the response again instead of storing it in cookies.

```java
public class TokenBasedAuthenticationFilter extends
	UsernamePasswordAuthenticationFilter {

	protected String obtainPassword(HttpServletRequest request) {
		return request.getHeader(SPRING_SECURITY_FORM_PASSWORD_KEY);
	}

	protected String obtainUsername(HttpServletRequest request) {
		return request.getHeader(SPRING_SECURITY_FORM_USERNAME_KEY);
	}
}
```

Our `TokenBasedAuthenticationFilter` class extends from `UsernamePasswordAuthenticationFilter` and looks for credentials 
in HTTP request headers.

```xml
<bean id="authenticationProcessingFilter"   class="org.speedyframework.security.web.TokenBasedAuthenticationFilter">
    <property name="authenticationManager" ref="authenticationManager"/>
    <property name="rememberMeServices" ref="rememberMeServices"/>
    <property name="authenticationSuccessHandler" ref="authenticationSuccessHandler"/>
    <property name="authenticationFailureHandler" ref="authenticationFailureHandler"/>
    <property name="postOnly" value="false"/>
    <property name="allowSessionCreation" value="false"/>
</bean>

<bean id="authenticationSuccessHandler" class="org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler">
    <property name="defaultTargetUrl">
        <value>${defaultTargetUrl}</value>
    </property>
    <property name="alwaysUseDefaultTargetUrl" value="true"/>
</bean>

<bean id="authenticationFailureHandler" class="org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler">
    <property name="defaultFailureUrl">
        <value>${authenticationFailureUrl}</value>
    </property>
</bean>
```

As you see from the bean definition, we don’t allow session creation and also accept GET methods for HTTP requests. 
Therefore, we are able to handle the following call made using `RestTemplate`.

```java
RestTemplate restTemplate = new RestTemplate();
HttpHeaders requestHeaders = new HttpHeaders();
requestHeaders.set(UsernamePasswordAuthenticationFilter.SPRING_SECURITY_FORM_USERNAME_KEY, "user3");
requestHeaders.set(UsernamePasswordAuthenticationFilter.SPRING_SECURITY_FORM_PASSWORD_KEY, "user3");
requestHeaders.set(AbstractRememberMeServices.DEFAULT_PARAMETER, "true");

HttpEntity<?> requestEntity = new HttpEntity(requestHeaders);

HttpEntity response = restTemplate.exchange("http://localhost:8080/test-token/j_spring_security_check",
HttpMethod.GET, requestEntity, String.class);
```

On the server side, when authentication is performed, and when subsequent requests with the remember-me cookie are received, 
our `RememberMeServices` generates a token, puts it into the HTTP response, and extracts it from the request, etc., but 
instead of creating and processing a cookie, it uses headers in the process. Thanks to improvements in Spring Security 3, 
it was very easy to just override some specific methods in `RememberMeServices` classes and perform the necessary actions.

```java
public class RequestHeaderCheckingPersistentTokenBasedRememberMeServices extends PersistentTokenBasedRememberMeServices {
	public RequestHeaderCheckingPersistentTokenBasedRememberMeServices() throws Exception {
	    super();
	}

	protected boolean rememberMeRequested(HttpServletRequest request, String parameter) {
		String value = request.getHeader(DEFAULT_PARAMETER);
		return value != null && Boolean.parseBoolean(value)?Boolean.parseBoolean(value):super.rememberMeRequested(request, parameter);
	}

	protected String extractRememberMeCookie(HttpServletRequest request) {
		String cookieValue = request.getHeader(SPRING_SECURITY_REMEMBER_ME_COOKIE_KEY);
		return cookieValue;
	}

	protected void setCookie(String[] tokens, int maxAge, HttpServletRequest request, HttpServletResponse response) {
		String cookieValue = encodeCookie(tokens);
		response.setHeader(SPRING_SECURITY_REMEMBER_ME_COOKIE_KEY, cookieValue);
	}
}
```

```xml
<bean id="rememberMeServices" class="org.speedyframework.security.web.RequestHeaderCheckingPersistentTokenBasedRememberMeServices">
    <property name="key" value="${tokenBasedRememberMeServicesKey}"/>
    <property name="userDetailsService" ref="userDetailsService"/>
    <property name="tokenRepository" ref="tokenRepository"/>
</bean>

<bean id="tokenRepository" class="org.springframework.security.web.authentication.rememberme.JdbcTokenRepositoryImpl">
    <property name="createTableonstartup" value="false"/>
    <property name="dataSource" ref="dataSource"/>
</bean>
```

And we perform subsequent HTTP requests for secured URLs by placing the token into HTTP request headers as follows.

```java
String token = response.getHeaders().getFirst(AbstractRememberMeServices.SPRING_SECURITY_REMEMBER_ME_COOKIE_KEY);

requestHeaders = new HttpHeaders();
requestHeaders.set(AbstractRememberMeServices.SPRING_SECURITY_REMEMBER_ME_COOKIE_KEY, token);
requestEntity = new HttpEntity(requestHeaders);

response = restTemplate.exchange("http://localhost:8080/test-token/mvc/secure-url",
HttpMethod.GET, requestEntity, String.class);
```

I hope that example gives you a general idea about how the Spring Security Framework is flexible and extendable to handle 
such changes in enterprise security requirements. In our public and private trainings, we teach everything about the Spring 
Security Framework and discuss enterprise web application security requirements in detail. You can also contact us if you 
have hard-to-solve security problems either in general or specific to the Spring Security Framework.

