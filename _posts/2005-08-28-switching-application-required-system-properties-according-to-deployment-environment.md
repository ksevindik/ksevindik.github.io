# Switching Application Required System Properties According to Deployment Environment
Any serious application depends on a number of configuration properties, such as JDBC connection properties and caching 
properties. These properties should change according to the target deployment environment.

Various methods are employed by people to extract these properties from their web applications. One commonly used method 
is to create a properties file and gather any property whose value should change depending on the current deployment 
environment. Then, variations of that properties file are created for each deployment environment. During the build 
process, the property file to be taken into account is specified via another parameter, such as an environment property 
or system property.

We currently utilize a similar method in our project. We employ Apache Ant in our build process and have defined an Ant 
global property named 'target.environment', which takes values such as 'dev', 'test', or 'prod'. We then use the following 
construct in our build.xml to customize our build process according to the target deployment environment.
```xml
<property file=”build.properties.${target.environment}”/>
```
Thus, we load the specified build properties file to customize our build process according to the target environment. 
For example, we use Tomcat as a web container and its Ant tasks to deploy, stop, and start our web application. 
Development, test, and production environments are simply located on different physical servers and accessible with 
different user credentials. In order to utilize the same Tomcat Ant tasks for each target environment, we keep Tomcat 
server URL, port, and credential information in this build properties file.

When customizing our application configuration properties, we simply copy the specified 'project.properties.${target.environment}' 
file into the web application classpath while stripping off the suffix at the end. As the old saying goes, a layer of 
indirection solves every problem in computer science.

Karl Baum has a nice [blog entry](http://www.jroller.com/page/kbaum?entry=cut_down_on_system_properties) about this topic 
and provides a solution based on the above method. However, it is much more flexible as it enables us to switch between 
configurations without requiring a new build or deployment at all.