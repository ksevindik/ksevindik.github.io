# Managing Dependencies With Ant
Every non-trivial Java application has many dependencies on other resources, especially JAR files. We must keep track of 
which JARs we are utilizing and their versions as the project develops. Systems may undergo several releases during their 
development lifecycle, and among those releases, dependency lists may change. New JARs may be added, or old versions may 
be replaced with newer ones. We must trace all these changes as part of our codebase. It is not considered good practice 
to keep those JARs in the source control system alongside our source codebase. It is preferred to keep those JARs in a 
separate repository, and dependent JARs are brought from that location into the development environment when required. 
Hence, we only need to keep dependency information— which JARs we depend on and their versions— together with our system’s 
codebase. This information is used to initialize our development and deployment environment during the build or deployment 
processes.

Maven has significant support for dependency management, and in Maven 2.0, it is advanced with transitive dependency 
management. With transitive dependency, you don’t need to discover and specify libraries that our own dependencies require. 
For example, it is sufficient to specify Hibernate as our sole dependency, without specifying the libraries that Hibernate 
depends on. Maven 2.0 also introduces dependency scopes, such as compile-time, runtime, or testing-only dependencies, 
building upon the concept of transitive dependencies.

Maven 2.0 also offers [dependency tasks](http://maven.apache.org/ant-tasks/examples/dependencies.html) for Ant as a 
separate JAR. Unfortunately, it does not currently work in the Turkish locale. We yearn for such a mechanism in our current 
project, and a quick search revealed several other solutions similar to Maven’s. One such solution is 
[Ribomation’s Dependencies Download Ant Task](http://www.ribomation.com/riboutils/dependencies/), and the other is 
[Dependencies Ant Task in HttpUnit.org](http://www.httpunit.org/doc/dependencies.html). Both utilize Maven’s ibiblio 
repository as the default external repository.

I have successfully configured the second solution. The concepts are similar to Maven. It manages a set of dependencies, 
and each missing dependency is downloaded from a remote repository. The default is [Maven Central Repository](https://search.maven.org/), 
and unnecessary repeated downloads are avoided using a local cache. The following lines briefly explain how to install 
and use the dependency task:

Download the [ZIP archive](http://prdownloads.sourceforge.net/httpunit/ant-dependencies-0.4.zip?download) and extract the 
ant-dependencies.jar into your Ant lib directory. Include the typedef in your build.xml file as follows:

```xml
<typedef resource="dependencies.properties" />

<dependencies pathId="base.classpath" fileSetId="web-inf.lib" >
    <dependency group="junit"      version="3.8.1" />
    <dependency group="xerces"     version="2.2.1" artifact="xmlParserAPIs"/>
    <dependency group="xerces"     version="2.6.0" artifact="xercesImpl"/>
</dependencies>
```

The **dependencies** element defines a set containing **dependency** child elements. Each dependency child element defines files 
required in our project. The group attribute defines the external project group that creates the dependency. Each project 
we depend on may consist of several JARs. Therefore, any dependency may also have an artifact attribute, indicating which 
JAR file is required in the specified project group. If the project group consists of a single JAR, there is no need to 
add the artifact attribute, as it defaults to the group. We also need to specify which version of those JAR files our 
project depends on.

```xml
<javac srcdir="${src}" destdir="${classes}">
    <classpath refid="base.classpath" />
</javac>

<copy todir="${web-inf}/lib" flatten="true">
    <fileset refid="web-inf.lib"/>
</copy>
```

Missing JARs are downloaded into the local cache, which is **~/.maven/repository** by default. If you want to change it, you 
must set the **ant.dependencies.cache** system property before running Ant. Please note that this is not a normal Ant property; 
it is a Java system property. Therefore, you should pass it to the JRE as a parameter with the -D option. We can also change 
the default remote repository, which is ibiblio, by setting the **repositoryList** attribute of the dependency task. It takes 
comma-separated HTTP URLs as remote repository values. Another way to change the external repository is to use the 
**ant.remote.repository** system property, but it is deprecated.

You may want to create your own external repository in your intranet and eliminate the need for connecting to a remote 
repository over the Internet. If you examine the Maven Central Repository, you will see that it is enough to create a 
directory structure, with each project group having its own folder with the same name as the group, and a jars folder in 
each group folder to keep JAR files. Each JAR file is in the form of **<jarFileName>-<x.y.z>**, e.g., junit-3.8.1.jar. 
You don’t have to configure web servers to create your own external repository either. It is valid to provide some shared 
network folder in the form of a URI, e.g., **file:///tbsserver/intra-jar-repository**.