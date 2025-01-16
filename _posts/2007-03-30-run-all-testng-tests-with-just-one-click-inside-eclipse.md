# Run all TestNG tests with just one click inside Eclipse
It can be a little bit annoying if you have looked around in Eclipse and tried to find a shortcut to run all of your 
tests using **TestNG** with one mouse click. One way of running **TestNG** tests is by creating a `testng.xml` file and 
defining tests in it. There are several options to define and group tests in this file, in addition to including or 
excluding them. The [**TestNG** documentation](http://testng.org/doc/documentation-main.html#testng-xml) provides a good 
overview of what can be done using `testng.xml`. Basically, you define test elements consisting of individual methods, 
classes, and packages.

During the development process, you continually introduce new methods, test classes, delete, or rename them, and simply 
don’t want to bother with keeping this XML up to date. Unfortunately, their documentation doesn’t mention how to achieve 
this, or I haven’t been able to find it. Anyway, it is very simple. Instead of placing a full package name, just put a 
higher package name which spans all of your tests with an asterisk at the end. For example:

```xml
<suite name="PortalCoreSuite" verbose="1">
    <test name="AllTests">
        <packages>
            <package name="com.ontometrics.*" />
        </packages>
    </test>
</suite>
```

That’s all. From now on, you will be able to just click on that `testng.xml` and run it inside Eclipse. All tests under 
`com.ontometrics.*` packages will be run.