# Extending XDoclet Spring Module
XDoclet is a wonderful tool, and we extensively use it in our current project to generate Hibernate and Spring configuration 
files. Our aim is to maintain no configuration files apart from our source code. XDoclet’s help is invaluable in achieving 
this goal, but sometimes it requires modifications to align with that mission.

We have made several modifications to the XDoclet Spring Module, and I want to briefly explain those modifications to you.

One modification we made is to generate a property element with a value sub-element. This feature is already supported by 
the current module, but if we want to generate one that provides values to be processed by a Spring Property Editor, with 
each value on a separate line, it looks like this;

```xml
<property name="objectDefinitionSource">
    <value>
         \A/login.jsp\Z=ROLE_ANONYMOUS
         \A/logout.jsp\Z=ROLE_ANONYMOUS,ROLE_USER
         \A.*index.jsp\Z=ROLE_USER
    </value>
</property>
```
Then, we have to modify the spring_xml.xdt file and add the following:
```java
/**
 * @spring.bean id = "filterSecurityInterceptor"
 * @spring.property name = "objectDefinitionSource" value.list ="
 *                      \A/login.jsp\Z=ROLE_ ANONYMOUS |
 *                      \A/logout.jsp\Z=ROLE_ ANONYMOUS,ROLE_USER |
 *                      \A.*index.jsp\Z=ROLE_USER |
 *                    
 */
public class FilterSecurityInterceptor extends net.sf.acegisecurity.intercept.web.FilterSecurityInterceptor {
}
```
Another extension is to generate a property element with a list sub-element. Each child element of this list sub-element 
is again a ref sub-element.
```xml
<property name="providers">
    <list>
        <ref bean="passwordDaoAuthenticationProvider"/>
        <ref bean="testingAuthenticationProvider"/>
        <ref bean="anonymousAuthenticationProvider"/>
    </list>
</property>
```
To achieve this, we need to add the following lines:
```xml
<XDtClass:ifHasClassTag tagName="spring.property" paramName="list.ref">
    <list>
        <XDtClass:forAllClassTagTokens tagName="spring.property" paramName="list.ref">
            <ref bean="<XDtClass:currentToken/>"/>
        </XDtClass:forAllClassTagTokens>
    </list>
</XDtClass:ifHasClassTag>

<XDtMethod:ifHasMethodTag tagName="spring.property" paramName="list.ref">
    <list>
        <XDtMethod:forAllMethodTagTokens tagName="spring.property" paramName="list.ref">
            <ref bean="<XDtMethod:currentToken/>"/>
        </XDtMethod:forAllMethodTagTokens>
    </list>
</XDtMethod:ifHasMethodTag>
```
Its usage in our source code:
```java
/**
 * @spring.bean id = "authenticationManager"
 * @spring.property name = "providers" list.ref = "passwordDaoAuthenticationProvider,testingAuthenticationProvider,anonymousAuthenticationProvider"
 *
 */
public class ProviderManager extends net.sf.acegisecurity.providers.ProviderManager {
}
```
Our final modification is again for the property element. This time, it consists of a props sub-element. The props element, 
in turn, consists of one or more prop child elements, each having a key attribute and a text value. For example:
```xml
<property name="hibernateProperties">
    <props>
        <prop key="hibernate.dialect">
            net.sf.hibernate.dialect.Oracle9Dialect
        </prop>
        <prop key="hibernate.hbm2ddl.auto">update</prop>
        <prop key="hibernate.show_sql">true</prop>
    </props>
</property>

<XDtClass:ifHasClassTag tagName="spring.property.props">
<property name="<XDtClass:classTagValue tagName="spring.property.props" paramName="name"/>">
    <props>
        <XDtClass:forAllClassTags tagName="spring.property.prop">
        <prop key="<XDtClass:classTagValue tagName="spring.property.prop" paramName="key"/>">                                                               
            <XDtClass:classTagValue tagName="spring.property.prop" paramName="value"/>
        </prop>
        </XDtClass:forAllClassTags>
    </props>
</property>
</XDtClass:ifHasClassTag>

<XDtMethod:ifHasMethodTag tagName="spring.property.props">
<property name="<XDtMethod:methodTagValue tagName="spring.property.props" paramName="name"/>">
 <props>
     <XDtMethod:forAllMethodTags tagName="spring.property.prop">
        <prop key="<XDtMethod:methodTagValue tagName="spring.property.prop" paramName="key"/>">                                                                   
             <XDtMethod:methodTagValue tagName="spring.property.prop" paramName="value"/>
        </prop>
     </XDtMethod:forAllMethodTags>
 </props>
</property>
</XDtMethod:ifHasMethodTag>
```
And its usage in our source code:
```java
/**
 * @spring.bean id = "sessionFactory"
 * @spring.property.props name = "hibernateProperties"
 * @spring.property.prop key = "hibernate.dialect" value = "net.sf.hibernate.dialect.Oracle9Dialect"
 * @spring.property.prop key = "hibernate.hbm2ddl.auto" value = "update"
 * @spring.property.prop key = "hibernate.show_sql" value = "true"
 */
public class LocalSessionFactoryBean extends org.springframework.orm.hibernate.LocalSessionFactoryBean {
}
```
All of our extensions apply at both the class and method levels. In addition to those additions, we also modified the 
xtags.xml file. This file is necessary for code assist tools to provide suggestions inside code editors.

The following two attributes should be included within the property tag:
```xml
<parameter type="text">
    <name>list.ref</name>
    <usage-description>Comma-separated list of bean names</usage-description>
    <mandatory>false</mandatory>
</parameter>

<parameter type="text">
    <name>value.list</name>
    <usage-description>Pipe separated values to provide with property editor.</usage-description>
    <mandatory>false</mandatory>
</parameter>

<tag>
    <level>class</level>
    <name>spring.property.props</name>
    <usage-description></usage-description>
    <unique>true</unique>

    <parameter type="text">
        <name>name</name>
        <usage-description></usage-description>
        <mandatory>true</mandatory>
        </parameter>
</tag>
<tag>
    <level>class</level>
    <name>spring.property.prop</name>
    <usage-description></usage-description>
    <unique>false</unique>
    <parameter type="text">
        <name>key</name>
        <usage-description></usage-description>
        <mandatory>true</mandatory>
    </parameter>

    <parameter type="text">
        <name>value</name>
        <usage-description></usage-description>
        <mandatory>true</mandatory>
    </parameter>
</tag>
```










