# Delegating Authentication to Web Services in Acegi

What I like most about Acegi Security Framework is its configurability and extensibility. I think those two features are 
very crucial for any framework to be successful. Recently, I have come across a requirement of authenticating users via 
a web service and giving more detailed authentication failure messages according to result codes returned from that service. 
Well, it is very easy to develop a custom authentication provider and inject it into the related part in Acegi Security 
Framework. Let’s look at the details.

First, we code our custom authentication provider. We need to query the web service by giving the social security number 
and user password as input. As a result of our query, we receive a return code. At the end of the authentication process, 
Acegi should fetch the user from our own database and use it as a UserDetails object during the rest of the authentication 
and authorization process. Acegi already provides `org.acegisecurity.providers.dao.DaoAuthenticationProvider`, in which 
it first retrieves the user with its `userDetailsService` object and then performs additional authentication in which 
encrypted password comparison occurs. Therefore, the order of retrieving the user from the database and querying 
authentication web service won’t matter in our case. Hence, we can extend `DaoAuthenticationProvider` and reuse most of 
its code. We only need to override its `additionalAuthenticationChecks` method to perform the web service query.

```java
protected void additionalAuthenticationChecks(UserDetails userDetails, 
		UsernamePasswordAuthenticationToken authentication) throws AuthenticationException {
	try {
		Kullanici kullaniciFromDB = (Kullanici) userDetails;
		//run your web service client code here to perform auth.
		//and check result code to throw AuthenticationExceptions
		//or do nothing if result code indicates success auth.
	} catch (RemoteException e) {
		throw new AuthenticationServiceException ("Problem with accessing ws endpoint :"
			+ getAuthServiceUrl(), e);
	}
}
```

After implementing our custom authentication provider, it is simply a matter of creating a Spring managed bean from it 
and injecting that bean into Acegi’s `ProviderManager` bean as a candidate provider.

```xml
<bean id="authenticationManager" class="org.acegisecurity.providers.ProviderManager">
    <property name="providers">
        <list>
            <ref bean="webServiceAuthenticationProvider" />
            <ref bean="anonymousAuthenticationProvider" />
            <ref bean="testingAuthenticationProvider" />
        </list>
    </property>
</bean>
```

What about displaying more detailed authentication failure messages? As you see above, we receive different return codes 
from the authentication web service and throw an appropriate `AuthenticationException` accordingly. Acegi provides us 
with the ability to map `AuthenticationExceptions` with different URLs. When authentication fails, it first checks for 
those exception mappings, and if it finds one, it redirects the application to that URL; otherwise, to the default failure 
URL.

We need to configure Acegi to search for those exception mappings and inject them into the `authenticationProcessingFilter` 
bean.

```xml
<bean id="exceptionMappings" class="org.springframework.beans.factory.config.PropertiesFactoryBean">
    <property name="location">
        <value>classpath:/resources/acegi.authExceptionMappings.properties</value>
    </property>
</bean>

<bean id="authenticationProcessingFilter" class="org.acegisecurity.ui.webapp.AuthenticationProcessingFilter">
    <property name="authenticationManager">
        <ref bean="authenticationManager" />
    </property>

    <property name="authenticationFailureUrl">
        <value>${security.auth.authenticationFailureUrl}</value>
    </property>

    <property name="defaultTargetUrl">
        <value>${security.auth.defaultTargetUrl}</value>
    </property>

    <property name="exceptionMappings">
        <ref local="exceptionMappings"/>
    </property>
</bean>
```

If we look at our `acegi.authExceptionMappings.properties`, as you see below, we give each different type of 
`AuthenticationException` a different URL. If Acegi cannot find a corresponding entry in this list, it will redirect the 
application to the `authenticationFailureUrl`, which is set into the `authenticationProcessingFilter` bean.

```properties
org.acegisecurity.concurrent.ConcurrentLoginException=/controller.faces?_flowId=login&loginError=true&cause=concurrentLogin
org.acegisecurity.AuthenticationServiceException=/controller.faces?_flowId=login&loginError=true&cause=authServiceException
org.acegisecurity.CredentialsExpiredException=/controller.faces?_flowId=login&loginError=true&cause=credentialsExpired
``
