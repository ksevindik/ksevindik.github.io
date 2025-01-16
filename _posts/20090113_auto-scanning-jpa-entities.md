# Auto Scanning JPA Entities
Most of the time you will find JPA’s auto-scan mechanism for annotated entities very limited. It only scans paths 
starting from the parent of `classpath:META-INF/` folder from which `persistence.xml` is loaded. If you want to use a 
`persistence.xml` file located in a different place, for example, in a jar, your annotated entities won’t be scanned 
because JPA will only process paths in that jar file. It is still problematic if you locate your `persistence.xml` into 
`classpath:META-INF` but want to load entities not in any of the folders under the parent folder of `META-INF`.

Well, what is the solution then? You have the option to list entities to be loaded in fully qualified names, and jar 
files to be processed in your `persistence.xml`. However, this approach is not very flexible in terms of unit testing 
your code and then running it in your container without a change in paths of those listed resources.

Well, I have a better solution for this JPA entity scan problem. The solution is based on Spring’s 
`PersistenceUnitPostProcessor` interface. It can be used to add additional class names and jar files during the 
construction of the `EntityManagerFactory` object.

With our solution, it is possible to define locations using ant-style patterns and exclude some entities identified in 
those locations. You can use ant-style patterns in the exclude list as well. This solution also provides a mechanism to 
automatically locate persistent entities when you use `persistence.xml` files located in places other than the root 
`classpath:/META-INF` folder. For example, in your web application you may use a `persistence.xml` in a jar file located 
in `WEB-INF/lib`, and persistent entities can be in `WEB-INF/classes` folder at the same time. In this case, you don’t 
need to state `WEB-INF/classes` in your location patterns. Our solution only needs a special hook file to be created in 
your classpath (for example, `WEB-INF/classes/META-INF/.entityScanPath`), and if it finds one, it will scan the folder 
starting from the parent folder of that hook file. It is also possible to apply this scanning process only to specified 
persistence units.

You can reach the full source code of this JPA EntityScanner solution from [here](https://github.com/...). Let’s now 
look at how it is configured and used as a spring-managed bean.

```xml
<bean id="entityScanner" class="samples.EntityScanner">
    <property name="locationPatterns">
        <bean class="samples.DelimitedStringToListFactoryBean">
            <property name="listElements">
                <value>${entityScanner.locationPatterns}</value>
            </property>
        </bean>
    </property>
    <property name="targetPersistenceUnits">
        <bean class="samples.DelimitedStringToListFactoryBean">
            <property name="listElements">
                <value>${entityScanner.targetPersistenceUnits}</value>
            </property>
        </bean>
    </property>
    <property name="classesToExclude">
        <bean class="samples.DelimitedStringToListFactoryBean">
            <property name="listElements">
                <value>${entityScanner.classesToExclude}</value>
            </property>
        </bean>
    </property>
    <property name="entityScanPathHook" value=".myJpaScanPathHook"/>
</bean>	
```


First, we need to provide it with `locationPatterns`, which indicates paths in which persistent entities are located. It 
is possible to populate the list with `String` elements from a delimited string property by using 
`DelimitedStringToListFactoryBean`, a simple generic utility used extensively in our projects. It is a `FactoryBean` that 
gets a delimited string and converts it into a `List` object with string elements. With the help of Spring’s 
`PropertyPlaceholderConfigurer` bean, we are able to externalize those properties in environment-specific properties file. 
For example, `entityScanner.locationPatterns` property may have the following values in dev and prod properties files;

```properties
#project.dev.properties
entityScanner.locationPatterns=file:/samples.spring/**/WEB-INF/test-classes/,file:/samples.spring/WebContent/WEB-INF/lib/crank-crud*.jar

#project.prod.properties
entityScanner.locationPatterns=
```

In the development environment, in addition to entities accessible from the location of the loaded `persistence.xml` 
file, entities used in test-classes and entities in `crank-crud*.jar` files will be discovered too.

There might be more than one persistence unit defined in the `persistence.xml` file, and it is possible to apply this 
`entityScanner` post processor only to the selected persistence unit(s). You can list persistence units to be processed 
in the `targetPersistenceUnits` list property.

Another feature in `EntityScanner` is `classesToExclude` property. We can decide to exclude some of the entities among 
discovered entities. For example,

```properties
#project.dev.properties
entityScanPath.classesToExclude=org.crank.crud.controller.**
```

With the above property, entities that match with the above pattern will be excluded while scanning the path 
`file:/samples.spring/WebContent/WEB-INF/lib/crank-crud*.jar`.

The last property that I want to mention about is `entityScanPathHook`. If we use a `persistence.xml` file located, for 
example, in a jar file, then JPA won’t be able to discover entities in `WEB-INF/classes` folder. We can add 
`WEB-INF/classes` path to the `locationPatterns` to include those entities. However, `entityScanPathHook` provides an 
alternative to enlisting `WEB-INF/classes` folder in the `locationPatterns`. `EntityScanner` tries to find a file 
specified by `entityScanPathHook` property (default value is `.entityScanPath`) in the classpath, and when it finds one, 
entities starting from its parent folder are discovered automatically.

Finally, let’s see how `entityScanner` is used in conjunction with `LocalContainerEntityManagerFactoryBean`.

```xml
<bean id="entityManagerFactory" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
...
    <property name="persistenceUnitPostProcessors">
        <list>
            <ref bean="entityScanner" />
        </list>
    </property>
</bean>
```

`LocalContainerEntityManagerFactoryBean` has a `persistenceUnitPostProcessors` property, and `entityScanner` should be 
injected into it.
