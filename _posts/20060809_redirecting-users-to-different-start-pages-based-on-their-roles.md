# Redirecting Users to Different Start Pages based on Their Roles
In our project, there is a requirement such that some users may have to be redirected to different start pages based on 
roles assigned to them other than initially provided `defaultTargetUrl`. Actually, there is a similar discussion in Spring 
Framework’s forum, suggesting a solution to this issue with extending `AuthenticationProcessingFilter` and overriding its 
`successfulAuthentication(…)` method to change the current `targetUrl` value to one of admin pages if the current user 
has an admin role. Luke from Acegi Security Team had pointed out that such a requirement could have been more easily 
achieved if `getDefaultTargetUrl()` would have been overridden to return specific pages according to roles of the current 
user. We had also come to the same conclusion separately in order to provide this functionality in a more proper way. 
Unfortunately, `AbstractProcessingFilter` wasn’t making use of `defaultTargetUrl`’s accessor to get its value until 
release 1.0.1.

We have also designed a `PageRedirectDefinitionSource` similar to `FilterSecurityInterceptor`’s `ObjectDefinitionSource` 
mechanism so that our developers would be able to assign start pages to different roles and provide it as a list to 
`AuthenticationProcessingFilter`. Let’s give an example:

```xml
<property name="pageRedirectDefinitionSource">
    <value>
    ROLE_ADMIN,ROLE_DATA_PROCESSOR=create.jsp
    ROLE_DATA_READER=search.jsp
    </value>
</property>
```

In the above definition, it is stated that any user just authenticated to our system will be redirected to page `create.jsp` 
if he has one of `ROLE_ADMIN` or `ROLE_DATA_PROCESSOR` roles. He will be redirected to `search.jsp` if he has `ROLE_DATA_READER` 
role. Any other users who have roles other than those stated above will be redirected to `defaultTargetUrl` by default.

We have created a `PageRedirectDefinition` class to keep each role-page pair, and `PageRedirectDefinitionSource` class to 
list all of the definitions provided to `AuthenticationProcessingFilter` instance. You can see code blocks of them below.

```java
public class PageRedirectDefinition {
    private String roleName;
    private String pageName;

    public PageRedirectDefinition() {}

    public PageRedirectDefinition(String roleName, String pageName) {
        setRoleName(roleName);
        setPageName(pageName);
    }

    public String getRoleName() {
        return roleName;
    }
    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }

    public boolean equals(Object o) {
        return EqualsBuilder.reflectionEquals(this,o);
    }

    public int hashCode() {
        return HashCodeBuilder.reflectionHashCode(this);
    }
    public String getPageName() {
        return pageName;
    }
    public void setPageName(String pageName) {
        this.pageName = pageName;
    }
}
```

`PageRedirectDefinition` is simple data wrapper with accessors; it just keeps role, page name pair.

```java
public class PageRedirectDefinitionSource {
    private static final Log logger = LogFactory.getLog(PageRedirectDefinitionSource.class);
    private List definitionsList;

    public PageRedirectDefinition getDefinitionFor(GrantedAuthority[] authorities) {
        List roleList = new ArrayList();
        for (int i = 0; i < authorities.length; i++) {
            roleList.add(authorities§0202f71e06a85569bff2b0e56f63316b§.getAuthority());
        }
        for (Iterator iter = getDefinitionsList().iterator(); iter.hasNext();) {
            PageRedirectDefinition definition = (PageRedirectDefinition) iter.next();
            if(roleList.contains(definition.getRoleName())) {
                logger.debug("First matched PageRedirectDefinition :" + definition);
                return definition;
            }
        }
        return null;
    }
    public List getDefinitionsList() {
        return definitionsList;
    }
    public void setDefinitionsList(List definitionsList) {
        this.definitionsList = definitionsList;
    }
}
```

`PageRedirectDefinitionSource` is a little bit more complex; it provides a `getDefinitionFor(GrantedAuthority[] authorities)` 
method to lookup any matching definition for provided authorities as an input array. It looks for a first match in definition 
list, and returns that definition if there occurs any. Therefore, any user may have more than one role, and each one might 
be listed in more than one definition, but we will return only the first matching definition. The order of definition list 
is preserved as it is in spring beans definition file.

We have also created a property editor class, named as `PageRedirectDefinitionSourceEditor`, in order to process page 
redirect definition lists defined like url patterns as `ObjectDefinitionSource`. The syntax of our page redirect definition, 
however, is much simpler than `ObjectDefinitionSource`’s. There is no pattern matching, and so, only comma-separated list 
of role names, an equal sign and a page name on the right hand side of equality must be provided.

```java
public class PageRedirectDefinitionSourceEditor extends PropertyEditorSupport {
    private static final Log logger = LogFactory.getLog(PageRedirectDefinitionSourceEditor.class);

    public void setAsText(String text) throws IllegalArgumentException {
        PageRedirectDefinitionSource definitionSource = new PageRedirectDefinitionSource();

        List definitionsList = new ArrayList();

        if(StringUtils.isNotEmpty(text)) {
            BufferedReader br = new BufferedReader(new StringReader(text));
            int counter = 0;
            String line;            
            while (true) {
                counter++;                
                try {
                    line = br.readLine();
                } catch (IOException ioe) {
                    throw new IllegalArgumentException(ioe.getMessage());
                }                   
                if (line == null) {
                    break;
                }                
                line = line.trim();                
                if (logger.isDebugEnabled()) {
                    logger.debug("Line " + counter + ": " + line);
                }                
                if (line.startsWith("//")) {
                    continue;
                }                
                if (line.lastIndexOf('=') == -1) {
                    continue;
                }
                // Tokenize the line into its name/value tokens
                int equalsPos = line.indexOf("=");
                String roleNamesString = line.substring(0,equalsPos);
                String pageName = line.substring(equalsPos + 1);
                if(StringUtils.isEmpty(pageName) || StringUtils.isEmpty(roleNamesString)) {
                    throw new IllegalArgumentException("Failed to parse a valid name/value pair from " + line);
                }
                if(logger.isDebugEnabled()) {
                    logger.debug("roleNamesString :" + roleNamesString);
                    logger.debug("pageName :" + pageName);
                }

                String[] roleName = org.springframework.util.StringUtils.delimitedListToStringArray(roleNamesString,",");

                for (int i = 0; i < roleName.length; i++) {
                    PageRedirectDefinition definition = new PageRedirectDefinition(roleName,pageName);
                    definitionsList.add(definition);
                }
            }
        }
        definitionSource.setDefinitionsList(definitionsList);
        setValue(definitionSource);
    }
}
```

We need to register `PageRedirectDefinitionSourceEditor` to our spring application context as following:

```xml
<bean id="customEditorConfigurer" class="org.springframework.beans.factory.config.CustomEditorConfigurer">
  <property name="customEditors">
   <map>
    <entry key="PageRedirectDefinitionSource">
     <bean class="PageRedirectDefinitionSourceEditor" />
    </entry>
   </map>
  </property>
 </bean>
```

We have finally come to the key part of our solution, which is making use of page redirect definitions in 
`AuthenticationProcessingFilter`, and return a page as `defaultTargetUrl` value if there is a matching role among the 
current user’s assigned roles. We basically extend `AuthenticationProcessingFilter`, and override `getDefaultTargetUrl()` 
method. What is important here is setting `alwaysUseDefaultTargetUrl` property value to true, otherwise Acegi will look 
for a `targetUrl` value in the current HttpSession, and if it finds one it will redirect our user to that page instead 
of the page assigned to our matching role.

```java
public class PageRedirectEnabledAuthenticationProcessingFilter extends AuthenticationProcessingFilter {
    private PageRedirectDefinitionSource pageRedirectDefinitionSource;

    public String getDefaultTargetUrl() {
        Authentication authResult = SecurityContextHolder.getContext().getAuthentication();
        PageRedirectDefinition definition = getPageRedirectDefinitionSource().getDefinitionFor(authResult.getAuthorities());
        String targetUrl = super.getDefaultTargetUrl();  
        if(definition != null) {
            if(logger.isDebugEnabled()) {
                logger.debug("PageRedirectDefinition found :" + definition);
            }
            targetUrl = "/" + definition.getPageName();
        } else {
            if(logger.isDebugEnabled()) {
                logger.debug("PageRedirectDefinition not found for authentication :" + authResult);
            }
        }
        logger.info("Default target url :" + targetUrl);
        return targetUrl;
    } 
    public PageRedirectDefinitionSource getPageRedirectDefinitionSource() {
        return pageRedirectDefinitionSource;
    } 
    public void setPageRedirectDefinitionSource(
        PageRedirectDefinitionSource pageRedirectDefinitionSource) {
        this.pageRedirectDefinitionSource = pageRedirectDefinitionSource;
    }
}
```

Let’s focus on what we do in `getDefaultTargetUrl()` method. We first fetch `Authentication` object from `SecurityContextHolder`.

```java
Authentication authResult = SecurityContextHolder.getContext().getAuthentication();
```

Then we look for a matching `PageRedirectDefinition` from `PageRedirectDefinitionSource` using our `Authentication`’s 
granted Authority objects.

```java
PageRedirectDefinition definition = getPageRedirectDefinitionSource().getDefinitionFor(authResult.getAuthorities());
```

If there is a definition we return its corresponding page as return value, otherwise, we will return use of `defaultTargetUrl` 
value returned from `super.getDefaultTargetUrl()` method.

Finally, let’s look at our spring bean definition of `AuthenticationProcessingFilter`.
```xml
<bean id="authenticationProcessingFilter" class="PageRedirectEnabledAuthenticationProcessingFilter" abstract="true">  
    <property name="authenticationManager">
        <ref bean="authenticationManager" />
    </property>
    <property name="defaultTargetUrl">
        <value>/index.jsp</value>
    </property><property name="alwaysUseDefaultTargetUrl">
        <value>true</value>
    </property>
    <property name="pageRedirectDefinitionSource">
        <value>
            ROLE_ADMIN,ROLE_DATA_PROCESSOR=create.jsp
            ROLE_DATA_READER=search.jsp
        </value>
    </property>
</bean>
```
In conclusion, I must say that Acegi Security Framework provides a great security infrastructure, which is both flexible 
and extendable. We have already overcome many tough security requirements in our enterprise project. With the help of 
Acegi they are just like butter and bread! A negative point in Acegi I must indicate is that when we were working on this 
issue, it seemed to me a little bit difficult to decorate concrete sub-classes of `AbstractProcessingFilter`. I personally 
rather make use of composition than inheritance for the above solution because nothing prevents us from utilizing this 
functionality in a place that employs one of `AbstractProcessingFilter`’s sub-classes other than `AuthenticationProcessingFilter`. 
I plan to write another article that analyzes this difficulty and shows an alternative to this inheritance solution.
