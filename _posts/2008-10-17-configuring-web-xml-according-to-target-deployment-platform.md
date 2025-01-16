# Configuring web.xml According to Target Deployment Platform
It is a very common requirement to configure JEE web applications according to their current runtime environment. In JEE, 
the `web.xml` file is aimed to be the configuration unit of those web applications. Unfortunately, it is not designed 
with such a requirement in mind.

For example, we use JSF and Facelets in our current project. In the development environment, we need to turn on the 
debugging feature of Facelets but will turn it off when the target platform is the production environment.

```xml
<context-param>
    <param-name>facelets.DEVELOPMENT</param-name>
    <param-value>true</param-value>
</context-param>
```

Servlet containers provide a way to define some common elements in a global `web.xml` file and let individual applications 
inherit those common elements, but that’s it! It would be very nice to be able to bundle a WAR with more than one `web.xml` 
and choose the one which is appropriate for the current runtime environment. It would be even better if we could merge 
more than one `web.xml` file or override some elements defined in one `web.xml` with those defined in another.

The Java community has tried to develop several solutions to this old problem: “building or configuring `web.xml` 
according to the runtime environment”. SmartFrog has a good overview of those efforts. Each effort has its pros and cons. 
We have preferred generating `web.xml` using a template engine. However, maintaining a template and generating `web.xml` 
each time a modification occurs while working within an IDE makes me feel bad. It has a negative impact on development 
fluidness. I want to keep a single `web.xml` which is directly used during development and will be used as a template in 
order to generate an environment-specific `web.xml` file. We have come up with an idea while we were searching and 
discussing possible solutions. Let me illustrate it as follows;

```xml
<context-param>
    <param-name>facelets.DEVELOPMENT</param-name>
    <param-value id="facelets.development">true</param-value>
</context-param>
```

```properties
#project.prod.properties
facelets.development=false
```

We decided to use the `id` attribute of XML elements of which values need to be changed according to the target platform. 
We put an `id` attribute with the value “facelets.development” into the `param-value` element and define a property with 
the same name in a properties file for the target platform. All we need to do is write a postprocessor which will parse 
the `web.xml` file, replace the contents of those XML elements with `id` attributes with corresponding property values, 
and produce a new `web.xml` before deployment.

Let’s look at another case in which our approach works elegantly. If you don’t have an internet connection in one of your 
target environments and one of your libraries tries to process your web XML with Apache Digester, it will fail with a 
complaint that it cannot find or reach the `web-app_2_4.xsd` file over the internet.

```xml
<web-app id="WebApp_ID" version="2.4" xmlns="http://java.sun.com/xml/ns/j2ee xmlns:xsi=http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd" >
</web-app>
```

```properties
#project.prod.properties
WebApp_ID.xsi\:schemaLocation=d:/work/xsd/web-app_2_4.xsd
```

In this case, our postprocessor finds out that the `web-app` XML element has an `id`, and there is a property with the 
same prefix in the properties file; as a result, it decides to replace the value of the attribute corresponding to the 
rest of that property name.

We can as well remove some XML elements out of the `web.xml` with this approach. For example, let's assume your 
development environment is JBoss, and you use Apache MyFaces. In that case, you will need to tell JBoss that your 
application comes with its own JSF implementation in your `web.xml` as follows.

```xml
<context-param id="org.jboss.jbossfaces.WAR_BUNDLES_JSF_IMPL.render">
    <param-name>org.jboss.jbossfaces.WAR_BUNDLES_JSF_IMPL</param-name>
    <param-value>true</param-value>
</context-param>
```

```properties
#project.prod.properties
org.jboss.jbossfaces.WAR_BUNDLES_JSF_IMPL.render=false
```

However, unless your production environment is JBoss, the above configuration element will do nothing except creating a 
mess. In order to remove it from the final `web.xml` file, we just need to add an `id` attribute with the value 
“org.jboss.jbossfaces.WAR_BUNDLES_JSF_IMPL.render”. Our postprocessor will remove that `context-param` XML element when 
it sees that there is a boolean property with a `render` suffix in the `project.prod.properties` file.

In summary, generating `web.xml` with a template engine would be more flexible than this approach, but the above approach 
as well covers most of the platform-specific `web.xml` configuration requirements.
