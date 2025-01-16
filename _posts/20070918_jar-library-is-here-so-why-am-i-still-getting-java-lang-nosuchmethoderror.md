# Jar Library Is Here, So Why Am I Still Getting java.lang.NoSuchMethodError?

Then it means that either you have more than one version of that `jar` library, or there is another `jar` library which 
contains a class with that problematic method with exactly the same signature.

The first case usually happens when you copy your `jars` into your `lib` folders with their keeping version suffixes. 
Stripping of version suffixes before copying them into the destination folder is a good habit, and `ivy` dependency 
management tool, for example, does it automatically for you. Otherwise, your `lib` folder may contain older versions of 
a library if you are not very careful, and if the dependent class is loaded from the wrong `jar`, then you will get a 
`NoSuchMethodError`.

The second case is much worse. Having two different libraries which contain methods with exactly the same signature might 
sometimes be difficult to diagnose. One easy way to identify which `jars` contain related class might be to use your IDE’s 
type searching facility. For example, in Eclipse, you can open the "Open Type" dialog and search your class within it. It 
will list matching classes coming from available dependencies in your classpath. You are able to see containing jars in 
the resulting list.

Here, I must say that I am having difficulty in understanding why some libraries place classes into their `jar` files 
which actually don’t belong to them. For example, `apacheds-main-0.9.jar`, for example, contains classes from several 
different projects, such as `commons io`, `logging`, `collections`, `oro`, `aspectjrt`, and so on. What is worse is that 
there is no version information about some of those dependencies packed in that `jar` file. In any case, you can easily 
come up with two incompatible class versions you will depend on.
