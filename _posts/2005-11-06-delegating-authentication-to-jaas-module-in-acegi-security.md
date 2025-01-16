# Delegating Authentication to JAAS Module in Acegi Security
We are currently using Acegi Security in our web project. At the moment, we employ its form-based authentication. In the 
future, we have to integrate our web application with an environment in which JAAS-based single sign-on mechanism will be 
used for authentication. As a first step, we tried to delegate authentication to a JAAS module using Acegi’s 
`JaasAuthenticationProvider`. The configuration process is very simple and is explained in the Acegi Reference Documentation.

There is an imbalance between JAAS and Acegi Security System. In JAAS, everything, even roles, is represented as principals, 
but in Acegi, there is an `Authentication` object, in which there exists one named principal corresponding simply to a 
username and multiple `GrantedAuthority` objects corresponding to roles. There must be a facility to map between JAAS 
Principal objects and Acegi `GrantedAuthority` objects. Acegi provides the `AuthorityGranter` interface for this mapping. 
`JaasAuthenticationProvider` passes each principal fetched from the login module to the `AuthorityGranter` object. The 
`AuthorityGranter` object inspects that principal object and returns a string as a role information if the current principal 
corresponds to a valid role. `JaasAuthenticationProvider` uses those role information and principal name to create 
`JaasGrantedAuthority` objects. Finally, the Acegi `Authentication` object consists of those `GrantedAuthority` objects.

We have implemented a derivation of a database-based JAAS authentication module from Tagish JAAS Login Modules and used 
a principal type similar to its `TypedPrincipal`. This contains information that specifies what type of principal it is, 
such as user or role. Our login module gets user information from the specified database location for authentication. 
This user information contains username, password, and its roles. Later, `JaasAuthenticationProvider` passes each 
principal into our `RoleNameBasedAuthorityGranter` implementation. `RoleNameBasedAuthorityGranter` checks if the passed 
principal represents a role of the current user. If it does, then it returns the role name string back to `JaasAuthenticationProvider`. 
Finally, `JaasAuthenticationProvider` uses that information to construct an `Authentication` object if authentication is 
successful.

One drawback of `JaasAuthenticationProvider` in the current Acegi distribution is that it isn’t able to cache authenticated 
user information. To remedy this problem, we have extended `JaasAuthenticationProvider` and added a `UserCache` object. 
Our `CachingJaasAuthenticationProvider` first looks into the user cache for user details and if it finds any, uses it to 
perform authentication; otherwise, it delegates authentication to its superclass. After successful authentication, it 
caches user details in case they are needed for successive queries.

I would like to mention, as a footnote, that there is a nice blog entry in Thomas Dudziak’s Weblog where he explains how 
to enable JAAS authentication and authorization for a Struts-based web application step by step. It is very easy to adapt 
it for other types of web applications too.

Finally, I appended the source code of our `RoleNameBasedAuthorityGranter`, `CachingJaasAuthenticationProvider`, and its 
Spring bean definition below for future reference:
```java
public class CachingJaasAuthenticationProvider extends
        JaasAuthenticationProvider {

    private UserCache userCache = new NullUserCache();
    
    public void setUserCache(UserCache userCache) {
        this.userCache = userCache;
    }
    
    public UserCache getUserCache() {
        return userCache;
    }
    
    public Authentication authenticate(Authentication auth)
            throws AuthenticationException {
        String username = "NONE_PROVIDED";
        
        if (auth.getPrincipal() != null) {
            username = auth.getPrincipal().toString();
        }

        if (auth.getPrincipal() instanceof UserDetails) {
            username = ((UserDetails) auth.getPrincipal()).getUsername();
        }

        boolean cacheWasUsed = true;
        UserDetails user = this.userCache.getUserFromCache(username);
        
        if(user != null && isPasswordCorrect(auth,user)) {
            publishSuccessEvent((UsernamePasswordAuthenticationToken)auth);
        } else {
            cacheWasUsed = false;
            
            auth = super.authenticate(auth);
            if(auth != null) {
                auth = createSuccessAuthentication(auth);
                user = (UserDetails)auth.getPrincipal();
                this.userCache.putUserInCache(user);
            }
        }
        
        return auth;
            
    }
    
    private Authentication createSuccessAuthentication(Authentication auth) {
  UserDetails userDetails = new JaasUser((String)auth.getPrincipal(),
auth.getCredentials().toString(),auth.getAuthorities());
        
        UsernamePasswordAuthenticationToken result = 
new UsernamePasswordAuthenticationToken(
                userDetails,auth.getCredentials(),auth.getAuthorities());
        
        return result;
    }
    
    private boolean isPasswordCorrect(
Authentication authentication, UserDetails user) {
        if(StringUtils.isNotEmpty(user.getPassword())) {
            return user.getPassword().equals(
authentication.getCredentials());
        }
        return false;
    }
}


public class RoleNameBasedAuthorityGranter implements AuthorityGranter {

    public String grant(Principal principal) {
        if(principal instanceof TypedPrincipal) {
            TypedPrincipal typedPrincipal = (TypedPrincipal)principal;
            if(typedPrincipal.getType() == TypedPrincipal.ROLE) {
                return principal.getName();
            }
        }
        return null;
    }

}
```
```xml
<bean id="jaasAuthenticationProvider" class="tbs.verisozlugu.guvenlik.jaas.CachingJaasAuthenticationProvider">
    <property name="loginConfig">
        <value>VeriSozlugu.login</value>
    </property>
    <property name="loginContextName">
        <value>VeriSozlugu</value>
    </property>
    <property name="callbackHandlers">
        <list>
            <bean class="net.sf.acegisecurity.providers.jaas.JaasNameCallbackHandler"/>
            <bean class="net.sf.acegisecurity.providers.jaas.JaasPasswordCallbackHandler"/>
        </list>
    </property>
    <property name="authorityGranters">
        <list>
            <bean class="tbs.verisozlugu.guvenlik.jaas.RoleNameBasedAuthorityGranter"/>
        </list>
    </property>
    <property name="userCache">
        <ref bean="userCache"/>
    </property>
</bean>
```