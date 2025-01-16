# Weird Autowiring Behaviour in Spring Framework

During lab sessions in our Enterprise Java trainings, I usually leave the main track of lab outlines and start trying 
various cases related to the topic. It is a bit risky for me, but it also becomes beneficial for attendees in terms of 
learning by experimenting with the framework. The risky point is that I may face undocumented or buggy behavior with the 
technology at hand, and I have to develop a solution to the problem in a limited time slice or at least bring a reasonable 
explanation to it.

Recently, I had such a problem during one of my Spring trainings. The problem was related to different autowiring behavior 
in Spring Framework. Autowiring is a dependency injection feature that transparently wires up beans with their dependencies 
if available in the application context. It has several modes: no, byType, byName, and constructor. According to Spring 
Framework’s reference documentation in table 5.2;

With this information at hand, lets start playing with the two classes defined as below:

| type        | description |
|-------------|-------------|
| no          |   (Default) No autowiring. Bean references must be defined via a ref element. Changing the default setting is not recommended for larger deployments, because specifying collaborators explicitly gives greater control and clarity. To some extent, it documents the structure of a system.          |
| byName      |   Autowiring by property name. Spring looks for a bean with the same name as the property that needs to be autowired. For example, if a bean definition is set to autowire by name, and it contains a master property (that is, it has a setMaster(..) method), Spring looks for a bean definition named master, and uses it to set the property.          |
| byType      |   Allows a property to be autowired if exactly one bean of the property type exists in the container. If more than one exists, a fatal exception is thrown, which indicates that you may not use byType autowiring for that bean. If there are no matching beans, nothing happens; the property is not set.          |
| constructor |   Analogous to byType, but applies to constructor arguments. If there is not exactly one bean of the constructor argument type in the container, a fatal error is raised.          |


```java
public class A {
	private B b;

	public A() {
	}

	public void setB(B b) {
		this.b = b;
	}
}

public class B {
}
```

If you have the following bean configurations in your application context, you will have `NonUniqueBeanDefinitionException` 
stating that there is more than one bean of the same type as an autowire candidate, and Spring doesn't know which one to 
inject.

```xml
<bean id="a" class="examples.A" autowire="byType"/>

<bean id="b1" class="examples.B" />

<bean id="b2" class="examples.B" />
```

Everything as expected according to the above documentation. If we change the autowire mode to `byName` and add the 
following alias definition, it works because the bean with the name `b2` is also known as the bean `b`, and autowire 
`byName` matches the bean name with the property name.

```xml
<alias name="b2" alias="b" />
```

If we keep the alias definition and return back to autowire `byType` mode, it fails with the same exception again. Still, 
nothing different than what is stated in the documentation.

Let's change the autowire mode to `constructor` and also remove the alias definition in the XML; we also need to change 
the default no-arg constructor so that it will accept an input argument of type `B`. As a result, we will again come up 
with `NonUniqueBeanDefinitionException` as expected, as autowire `constructor` is similar to `byType` but injects via 
the bean constructor.

Now comes the weird point: if we keep the autowire mode as `constructor` but add the alias again, we will see no exception! 
It wires the bean name `b2` into the bean as in the case with autowire mode `byName`. We can understand which bean is 
getting injected by changing the alias to something different, e.g., `myB`, and it fails with the related exception this 
time. So autowire `constructor` silently acts like `byName`, but the documentation does not say anything about this.

In conclusion, nothing is perfect. Neither is Spring Framework!
