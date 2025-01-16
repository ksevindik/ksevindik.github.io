# Allowing roles without defining them in intercept-url element

Spring Security Framework has lots of authentication and authorization features, and almost all of them can be customized 
and extended according to your own needs. One of the common requests I come up with is that developers don’t want to 
explicitly define roles which have administrative privileges in intercept-url elements  like below;

```xml
<intercept-url pattern="/secured/*"  access="ROLE_ADMINISTRATOR,ROLE_USER,ROLE_EDITOR"/>
```

Instead, several of my clients asked if there is a way to allow users having those admin roles to access secured resources, 
be it url, method or domain objects without listing them as config attributes of those secured resources.

Authorization mechanism of Spring Security is built on top of Voter based AccessDecisionManager object. What does this 
“Voter based AccessDecisionManager” mean? It means that AccessDecisionManager object actually polls several registered 
Voter objects to ask if they allow, deny or abstain current Authentication to access secured object, and decide after 
responses from those Voter instances. Each Voter instance could support some of those secured objects and config attributes 
associated with them. If Voter instance doesn’t support secured resource type and config attribute it stays abstained. 
Otherwise it is asked to examine GrantedAuthority objects of current Authentication together with current secured resource 
and its config attributes. If any of GrantedAuthority objects matches with them, Voter votes to allow access. If there is 
no match then it votes to deny.

There are three different type of AccessDecisionManager implementations. ConsensusBased, AffirmativeBased and UnanimousBased. 
ConsensusBased concludes to allow access to resource if sum(allow votes) > sum(deny votes), AffirmativeBased concludes to 
allow if at least one allow vote exists, UnanimousBased on the other hand looks for all voters to say allow.

For role based authorization, Spring security provides one commonly used AccessDecisionVoter object which is called RoleVoter. 
It supports any secured object type, and config attributes starting with “ROLE_ ” prefix by default. Its vote method loops over 
config attributes and GrantedAuthority objects and try to find a matching GrantedAuthority among config attributes.

Let’s return back to our scenario now. In our requirement, developers don’t want to list admin roles as config attributes 
of secured resource but still users to be allowed if they have those roles. It’s very easy to satisfy this requirement with 
extending from RoleVoter class and override its vote method  like below;

```java
public int vote(Authentication authentication, Object object, Collection attributes) {
	int result = ACCESS_ABSTAIN;
	Collection authorities = authentication.getAuthorities();
	for(GrantedAuthority authority:authorities) {
		if(adminRoles.contains(authority.getAuthority())) {
			result = ACCESS_GRANTED;
			break;
		}
	}
	return result;
}
```

With the namespace support of Spring Security, an AffirmativeBased AccessDecisionManager bean defined with some Voter beans 
by default. Now we have a new custom Voter instance, and want it to be used during authorization process. In order to achieve 
that, we first need to define AccessDecisionManager beans by ourselves, and then refer it from and elements  like below;

```xml
<bean id="accessDecisionManager">
    <property name="decisionVoters">
        <list>
            <ref bean="roleVoter"/>
            <ref bean="authenticatedVoter"/>
            <ref bean="systemAdminRoleVoter"/>
        </list>
    </property>
</bean>

<bean id="roleVoter" class="org.springframework.security.access.vote.RoleVoter"/>

<bean id="authenticatedVoter" class="org.springframework.security.access.vote.AuthenticatedVoter"/>

<bean id="systemAdminRoleVoter" class="tr.com.harezmi.security.SystemAdminRoleVoter">
    <property name="adminRoles">
        <set>
            <value>ROLE_SYSTEM</value>
            <value>ROLE_SYSTEM_ADMIN</value>
        </set>
    </property>
</bean>

<http auto-config="true"
access-decision-manager-ref="accessDecisionManager">
...
    <intercept-url pattern="/secured/*" access="ROLE_USER,ROLE_EDITOR"/>
</http>

<global-method-security access-decision-manager-ref="accessDecisionManager">
...
</global-method-security>
```

One important thing here is that if you enable Pre/PostAuthorize annotations for your method and domain instance security 
needs then you also need to add another Voter instance of type PreInvocationAuthorizationVoter  as follows;

```xml
<bean id="preInvocationAuthorizationAdviceVoter" class="org.springframework.security.access.prepost.PreInvocationAuthorizationAdviceVoter">
    <constructor-arg ref="expressionBasedPreInvocationAdvice"/>
</bean>

<bean id="expressionBasedPreInvocationAdvice" class="org.springframework.security.access.expression.method.ExpressionBasedPreInvocationAdvice">
    <property name="expressionHandler" ref="expressionHandler"/>
</bean>

<bean id="expressionHandler" class="org.springframework.security.access.expression.method.DefaultMethodSecurityExpressionHandler">
...
</bean>
```

Unfortunately, PreInvocationAuthorizationVoter doesn’t recognize FilterInvocation as supported secured object type, and 
this causes exception while configuring FilterSecurityInterceptor bean in order to authorize url requests. In order to 
overcome this problem, we need to separately configure two AccessDecisionManager beans one for element and the other for 
element.

As a summary of this long thread, you probably have a good overview of Spring Security authorization mechanism, how it 
works, and how it is possible to customize for project specific needs. All those stuff might be looking a bit complex. 
Though, this is correct, flexibility always comes with the cost of extra complexity in any system. However, for many 
common requirements of enterprise Java web applications, Spring Security Framework is really easy to configure with its 
namespace support.

As Harezmi IT Solutions, we give two day Spring Security Framework training and introduce you with this great security 
framework and security concepts in general. With the help of such a training, your team will be able to implement security 
needs from the very beginning of your project, and security won’t be an after thought item any more. You can 
[ask](http://www.harezmi.com.tr/index.html#contact) for on site trainings and consultancy services as well.

