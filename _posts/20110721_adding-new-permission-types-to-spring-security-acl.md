# Adding New Permission Types to Spring Security ACL

Domain object level security is probably the least used feature of Spring Security compared to URL-based and method-level 
security features for enterprise Java web applications. However, when you have a security requirement something like 
“I want to restrict some operations which are allowed for some roles based on criteria that can be obtained from domain 
objects passed into, or returned from those operations.” This could be something like that: “Save operation could be 
called by every `ROLE_USER`, but each user should only be allowed to save its own `User` object.”

ACL support provides some `Permission` objects, namely `READ`, `WRITE`, `CREATE`, `DELETE`, `ADMINISTRATION` based on bit 
masks, and you need to somehow associate related `Permission` objects and principals or roles with your domain objects on 
which you want to perform authorization checks. Later, your methods with, for example, `Pre/PostAuthorize` annotations, 
will be intercepted by `MethodSecurityInterceptor` and Spring Security will control if the current user or their assigned 
`GrantedAuthorities` has enough `Permissions` in order to execute that method or get its result.

One of my clients recently asked for ACL configuration in his project, and later he extended the requirement with the need 
of introducing new `Permission` types in addition to the default available types I listed above. In order to add new 
`Permission` types, you can just extend from the `BasePermission` class and define new instances for each of your `Permission` 
types like below;

```java
public class CustomPermission extends BasePermission {

	public static final Permission REPORT   = new CustomPermission(1<<5,'O');
	public static final Permission AUDIT    = new CustomPermission(1<<6,'T');

	protected CustomPermission(int mask) {
		super(mask);
	}

	protected CustomPermission(int mask, char code) {
		super(mask, code);
	}
}
```

After that, you need to make Spring Security ACL module aware of your new `Permission` objects. This is achieved by 
registering them to the `PermissionFactory` bean. Just extend from the `DefaultPermissionFactory` class, and call its 
available `registerPublicPermissions` method with the `Permission` class you defined new `Permission` objects as an input 
argument.

```java
public class CustomPermissionFactory extends DefaultPermissionFactory {
	public CustomPermissionFactory() {
		super();
		registerPublicPermissions(CustomPermission.class);
	}
}
```

Finally, you have to define your custom `PermissionFactory` as a bean in your `ApplicationContext` and inject it into 
`permissionEvaluator` and `lookupStrategy` beans of the ACL configuration.

```xml
<bean id="permissionEvaluator" class="org.springframework.security.acls.AclPermissionEvaluator">
    <constructor-arg ref="aclService"/>
    <property name="permissionFactory" ref="permissionFactory"/>
</bean>

<bean id="lookupStrategy" class="org.springframework.security.acls.jdbc.BasicLookupStrategy">
    ...
    <property name="permissionFactory" ref="permissionFactory"/>
</bean>

<bean id="permissionFactory" class="tr.com.harezmi.security.CustomPermissionFactory"/>
```

During registration, field names are stored as “permission name,” which can later be used in `Pre/PostAuthorize` 
annotations. For example;

```java
@PreAuthorize("hasPermission(#user,'report')")
public void report(User user) {
//...
}
```

`BasePermission` is based on integer bit masks; therefore, it can support up to 32 different kinds of permissions in a 
system, including 5 built-in permissions. If you need much more than this number, you can define the permission object 
based on completely different integer identifiers. In short, bit masking is not compulsory.

