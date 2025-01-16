# Ivy Configurations
One of the nicest features of `Maven` is its ability to specify some dependencies as compile time only, and they won’t be 
included at runtime because they are already provided by the target web container. Here is an example of it.
```xml
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>servlet-api</artifactId>
    <version>2.4</version>
    <scope>provided</scope>
</dependency>
```
But that’s it! I don’t remember any other feature in `Maven` if I want to download some jars for only `Tomcat v6`, but 
some others only for `Tomcat v5` container. In `Ivy`, there is a very powerful dependency grouping mechanism called 
configurations. You can easily achieve the above “provided” effect and the other conditional case using `Ivy` conf feature.
```xml
<ivy-module version="1.4">
    <info organisation="org.ems4j" module="test.webproject" />
    <configurations>
        <conf name="compile"/>
        <conf name="tomcatv5"/>
        <conf name="tomcatv6"/>
    </configurations>
    <dependencies>
        <dependency org="apache" name="commons-lang" rev="2.2" />
        <dependency org="sun" name="servlet" rev="2.4" conf="compile->default"/>
        <dependency org="sun" name="el" rev="1.0" conf="tomcatv5->default"/>
        <dependency org="apache" name="jasper-el" rev="6.0.14" conf="tomcatv6->default"/>
    </dependencies>
</ivy-module>
```
Here above is an example `ivy.xml` file to demonstrate the power and flexibility of `Ivy` configurations. First of all, 
you must define which configurations your current module should have: `compile`, `tomcatv5`, `tomcatv6` in our case. Then 
in your dependencies, you need to specify how each dependency will be resolved according to those configurations. For 
example, when your module is built with the “compile” parameter, `Ivy` will include `servlet-2.4.jar` in your dependency 
list, and any of `servlet-2.4.jar’s` (transitive) dependencies, if they exist, will be resolved with the “default” 
configuration. The “default” configuration exists by default and is valid until you define any `conf` explicitly in the 
`ivy.xml` file of your module. As you guess, you can specify any available `conf` definition on both sides of the `->` 
equation. In other words, you map how configurations of your module (`test.webproject`) are mapped to configurations of 
its dependent modules. If you omit the `conf` attribute in your dependency element, then it is assumed as `*->*` by 
default, which means it will be resolved from any configuration to any other configuration.

Here is another example to illustrate this mapping concept. 

```xml
<ivy-module version="1.4">
    <info organisation="org.ems4j" module="ems4j" />
    <configurations>
        <conf name="apache-tomcatv5"/>
        <conf name="apache-tomcatv6"/>
    </configurations>
    <publications>
        <artifact name="ems4j" type="jar" ext="jar"/>
    </publications>
    <dependencies>
        <dependency org="apache" name="myfaces" rev="1.2.0" conf="apache-tomcatv6->default"/>
        <dependency org="apache" name="myfaces" rev="1.1.5" conf="apache-tomcatv5->default"/>
    </dependencies>
</ivy-module>
```

Let’s say I have another module called “ems4j”. For example, I want it to depend on `myfaces 1.1.5 impl` when `tomcatv5` 
is used, and depend on `1.2.0` when `tomcatv6` is used. In our `test.webproject`’s `ivy.xml` file, we can add a dependency 
element for our `ems4j.jar`. 

```xml
<dependency org="org.ems4j" name="ems4j" rev="latest.integration" conf="tomcatv5->apache-tomcatv5;tomcatv6->apache-tomcatv6"/>
```

If you look at its `conf`attribute closely, you will notice that when our `test.webproject` is built for `tomcatv5`, the 
`ems4j` module will be resolved with its `apache-tomcatv5` configuration, and when `conf` is `tomcatv6`, then the `conf` 
for `ems4j` module will be `apache-tomcatv6`. Hence, for the `ems4j` module, `myfaces 1.1.5` will be resolved for 
`apache-tomcatv5`, and `1.2.0`for `apache-tomcatv6`, and will be included in the dependency list of `test.web` project as 
a transitive dependency. You don’t have to make `conf` names different in your different `ivy.xml` files of your module. 
I here preferred to make `conf`definitions for `tomcat` version 5 in those two `ivy.xml` files, but it is also valid to 
make them the same.

There are several other features related to `Ivy` configurations, such as inheritance between configurations, and 
`defaultconfmapping` for dependencies, etc. However, in my opinion, the above part is enough to show how `Ivy` 
configurations are powerful and flexible.
