# Moving FilterInvocation Definitions out of XML Files in Acegi

SpringSource has recently announced that they renamed `AcegiSecurity` as `SpringSecurity`, and are preparing for a major 
release which will be called `2.0`. Actually, its first milestone release is already available for download. According 
to Ben Alex, there are various enhancements to bean configurations and new features introduced such as hierarchical 
roles, etc.

After the latest news from Spring Security side, let’s return to my current issue. Spring Security, which is highly 
dependent on Servlet Filters, uses `FilterSecurityInterceptor` to protect web resources. We simply provide URL 
pattern – role mappings during bean configuration. For example;

```xml
<bean id="filterSecurityInterceptor" class="org.acegisecurity.intercept.web.FilterSecurityInterceptor">
    <property name="authenticationManager">
        <ref bean="authenticationManager" />
    </property>
    <property name="accessDecisionManager">
        <ref bean="accessDecisionManager" />
    </property>
    <property name="alwaysReauthenticate">
        <value>${security.auth.alwaysReauthenticate}</value>
    </property>
    <property name="objectDefinitionSource">
        <value>
        A.*index.*Z=ROLE_READER,ROLE_WRITER
        A.*reader.faces.*Z=ROLE_READER
        A.*writer.faces.*Z=ROLE_WRITER
        A.*Z=ROLE_ANONYMOUS,ROLE_READER,ROLE_WRITER
        </value>
    </property>
</bean>
```

`FilterSecurityInterceptor` has an `objectDefinitionSource` property to which we provide those URL pattern – role mappings. 
The type of `objectDefinitionSource` property is `FilterInvocationDefinitionSource`, and `AcegiSecurity` provides a default 
property editor (`FilterInvocationDefinitionSourceEditor`), which is located in the same package with 
`FilterInvocationDefinitionSource` class. Spring invokes property editors during application context startup and obtains 
target bean instances from some textual input in bean definition.

One of the limitations of the above approach is that it is difficult to package application context configurations with 
security enabled into separate deployment units and reuse them in several applications. One way to overcome this limitation 
would be to provide a default bean configuration of `FilterSecurityInterceptor` and override it in your application’s 
bean configuration and provide these mappings in that overriding bean definition.

Another limitation is that by defining URL pattern – role mappings in XML files, you won’t have any chance of adding new 
or changing existing mappings in `FilterInvocationDefinitionSource` bean. You have to restart your application context 
each time you make a change to those mappings, so that your changes to `objectDefinitionSource` property value can be 
read and a new `FilterInvocationDefinitionSource` bean is constructed again.

It would be very nice if we could externalize those mappings by moving them out of XML files. For example, we can create 
a `filterInvocationDefinitions.properties` file and put those mappings in it. By that way, we can place those bean 
configurations in a separate JAR and reuse them in other web applications. We also won’t need to override 
`filterSecurityInterceptor` bean to define application-specific mappings, but only make changes to the properties file. 
Moving `objectDefinitionSource` values out of XML alone won’t enable us to reload mappings during runtime, but it 
definitely opens up such a possibility. However, I will focus on the externalization process at the moment. Reloading 
URL – role mappings during runtime is another day’s issue.

In order to externalize mappings, we need a way to process that `filterInvocationDefinitions.properties` file and create 
a `FilterInvocationDefinitionSource` instance to inject into `filterSecurityInterceptor` bean. Yes, the answer is very 
simple: We can implement a `FactoryBean` which reads up properties file and creates a `FilterInvocationDefinitionSource` 
bean. For example;

```xml
<bean id="filterInvocationDefinitionSource" class="org.ems4j.security.intercept.web.ResourceFilterInvocationDefinitionSourceFactoryBean">
    <property name="filterInvocationDefinitions" value="classpath:/resources/filterInvocationDefinitions.properties" />
</bean>
```

`ResourceFilterInvocationDefinitionSourceFactoryBean` gets `filterInvocationDefinitions.properties` in the form of 
Spring’s `Resource` type, processes contents, and creates a `FilterInvocationDefinitionSource` bean. After such a 
`FactoryBean` configuration, our `filterSecurityInterceptor` bean’s `objectDefinitionSource` configuration needs to be 
changed slightly;

```xml
<property name="objectDefinitionSource">
    <ref local="filterInvocationDefinitionSource"/>
</property>
```

Let’s look at the inside of `ResourceFilterInvocationDefinitionSourceFactoryBean` closely. `Acegi` supports two different 
types of `FilterInvocationDefinitionSource`, namely `PathBasedFilterInvocationDefinitionMap` (for ant-style patterns in 
URLs) and `RegExpBasedFilterInvocationDefinitionMap` (for regular expression-enabled URLs) which is by default. Previously 
we could tell the property editor to instantiate `PathBased` version with `PATTERN_TYPE_APACHE_ANT` directive on top of 
our mappings. Another directive is `CONVERT_URL_TO_LOWERCASE_BEFORE_COMPARISON` to tell `Acegi` that we want to lowercase 
all URLs before doing any comparison during authorization of web resources. We can represent those two options as boolean 
in our `FactoryBean`.

```java
public class ResourceFilterInvocationDefinitionSourceFactoryBean extends AbstractFactoryBean {
	private boolean patternTypeApacheAnt = false;
	private boolean convertUrlToLowercaseBeforeComparison = false;
```

In `createInstance()` method of `FactoryBean`, we instantiate one of those types mentioned above and wrap it with 
`FilterInvocationDefinitionDecorator` which is also a subtype of `FilterInvocationDefinitionSource`, and is used for 
lowercase URL conversion.

```java
protected Object createInstance() throws Exception {
		BufferedReader reader = null;
		try {
			FilterInvocationDefinitionDecorator decorator = new FilterInvocationDefinitionDecorator(
			patternTypeApacheAnt ? new PathBasedFilterInvocationDefinitionMap() : new RegExpBasedFilterInvocationDefinitionMap());
			decorator.setConvertUrlToLowercaseBeforeComparison(this.convertUrlToLowercaseBeforeComparison);
			List mappings = new ArrayList();
			reader = new BufferedReader(new InputStreamReader(
			filterInvocationDefinitions.getInputStream(), "utf-8"));
			String line = reader.readLine();
			while (line != null) {
				String name = StringSplitUtils.substringBeforeLast(line, "=");
				String value = StringSplitUtils.substringAfterLast(line, "=");
```

We then read contents of `filterInvocationDefinitions.properties` line by line and create `FilterInvocationDefinitionSourceMapping` 
for each URL pattern-role list mapping. Roles are added into those mapping objects as `ConfigAttribute` elements.
It is important to read the properties file line by line because `Acegi` compares the current URL against URL patterns in 
the order of definition. Comparison stops at the first match.

```java
                FilterInvocationDefinitionSourceMapping mapping = new FilterInvocationDefinitionSourceMapping();
				mapping.setUrl(name);
				String[] tokens = StringUtils.commaDelimitedListToStringArray(value);
				for (int i = 0; i < tokens.length; i++) {
					mapping.addConfigAttribute(tokens[i].trim());
				}
				mappings.add(mapping);
				line = reader.readLine();
			}
			decorator.setMappings(mappings);
			return decorator.getDecorated();
		} finally {
			try {
				if (reader != null) reader.close();
			} catch (Exception ex) {
				// do nothing...
			}
		}
	}
}
```

In our case, we moved mappings into a file. It is equally possible to move them into a database as well. You can also 
provide a user interface to manage your protected web resources and their accessibilities.
