# Accessing An Object Whose Class Is Already Loaded By Another ClassLoader
Let’s assume you use the inter-ServletContext communication mechanism to transfer an Object created by one web application 
to another web application. In order to make this object fully available to your target web application, you must ensure 
that those two web applications use the same ClassLoader to load that object’s class.

This can be easily achievable if you put related classes into a shared location of your servlet container, like the 
`common/lib/ext` folder in Tomcat. However, this approach cannot always be possible as those classes/jars to be put into 
the shared folder might conflict with those which are already there, or you may come across class loading problems, like 
those shared classes are loaded instead of classes which exist in one of your other web application’s `WEB-INF/lib` folder. 
In short, it is much more preferable to keep application-specific classes or jars isolated in each web application’s private 
classpath. Unfortunately, you will face another problem in this case.

In Java, two classes are the same if they have the same fully qualified name in addition to being loaded by the same 
ClassLoader. In our case, an object is instantiated in one of our web applications which uses its own ClassLoader to load 
that object’s class, and then uses inter-ServletContext communication to pass that object, possibly putting it into the 
current request as an attribute, to another web application. At this time, if the second application tries to cast that 
object into its exact type, it will get a `ClassCastException`. This is because that object’s class is loaded by another 
ClassLoader, and here we try to cast it to a type which is also loaded by the second application’s private ClassLoader. 
Our object is simply not castable to its type!

How can we solve this problem? I use a simple trick to overcome such a problem: object serialization/deserialization. Let’s 
look at the code snippet below:

```java
Object obj = req.getAttribute("myObject");
ByteArrayOutputStream bout = new ByteArrayOutputStream();
out = new ObjectOutputStream(bout);
out.writeObject(obj);

ByteArrayInputStream bin = new ByteArrayInputStream(bout.toByteArray());
in = new ObjectInputStream(bin);
obj = in.readObject();
```

We get our object from the request, and then stream it into a byte array using `ObjectOutputStream`. Afterwards, we 
deserialize it using `ObjectInputStream` from that byte stream, and obtain the same object whose class is loaded by our 
second web application’s ClassLoader. In order for this solution to be workable, we need to mark our object’s class as 
`Serializable`. Some may argue that streaming an object to a byte array, and then reversing it back to an object might 
create a performance issue, but I am sure that the cost is tolerable when compared to class loading issues which might 
possibly occur if you put many application-specific classes or jars into a common location, especially if you have several 
other applications having dependencies to those shared classes/libraries.
