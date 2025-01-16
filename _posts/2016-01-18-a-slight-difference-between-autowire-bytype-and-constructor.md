# A Slight Difference Between Autowire byType and constructor

Spring documentation states that both autowire byType and constructor modes expect at most one bean definition in the 
ApplicationContext, so that it can be autowired into the depending bean. Here is the excerpt taken from 
[Spring Reference Documentation](http://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/) 
Table 6.2. Autowiring modes;

| type        | description |
|-------------|-------------|
| byType      |      Allows a property to be autowired if exactly one bean of the property type exists in the container. If more than one exists, a fatal exception is thrown, which indicates that you may not use byType autowiring for that bean. If there are no matching beans, nothing happens; the property is not set.       |
| constructor |      Analogous to byType, but applies to constructor arguments. If there is not exactly one bean of the constructor argument type in the container, a fatal error is raised.       |


However, they don’t show exact behaviour if there are more than one bean in the ApplicationContext and name of one of 
those beans matches with the name of constructor parameter. Let’s see what is the difference with the following code 
samples;

## First, XML based configuration

```java
public class Foo {
	private Bar bar;

	public void setBar(Bar bar) {
		this.bar = bar;
	}
	
	public Bar getBar() {
		return bar;
	}
}
```

```xml
<beans...>
    <bean id="foo" class="examples.Foo" autowire="byType"/>
    
    <bean id="bar1" class="examples.Bar"/>
    
    <bean id="bar2" class="examples.Bar"/>
</beans>
```

The above sample will produce following error as expected:

```console
Caused by: org.springframework.beans.factory.NoUniqueBeanDefinitionException: No qualifying bean of type [examples.Bar] is defined: expected single matching bean but found 2: bar1,bar2
```

Now we change the Foo class so that Bar is to be injected as a constructor parameter, change autowire mode to constructor, 
and give a try;

```java
public class Foo {
	private Bar bar;

	public Foo(Bar bar) {
		this.bar = bar;
	}
}
```

```xml
<beans...>
    <bean id="foo" class="examples.Foo" autowire="constructor"/>
    
    <bean id="bar1" class="examples.Bar"/>
    
    <bean id="bar2" class="examples.Bar"/>
</beans>
```

As expected, we got the same error as above;

```console
Caused by: org.springframework.beans.factory.NoUniqueBeanDefinitionException: No qualifying bean of type [examples.Bar] is defined: expected single matching bean but found 2: bar1,bar2
```

Now, here comes the difference. When we add another name one of those two Bar beans with an element, for example, 
autowire=”constructor” starts working! It injects the bean with name matching with the name of the constructor parameter.

```xml
<beans...>
    <bean id="foo" class="examples.Foo" autowire="constructor"/>
    
    <bean id="bar1" class="examples.Bar"/>
    
    <bean id="bar2" class="examples.Bar"/>

    <alias name="bar2" alias="bar"/>
</beans>
```

Practically, autowire=”constructor” turns into “byName”, in which it is stated that only bean with the matching name is 
injected. However, when we run the code with autowire=”byType”, it still gives the error as listed above.

## Now, annotation based configuration

At this point, let’s give annotation based configuration a try, and see what happens there as well.

```java
@Component
public class Foo {
	private Bar bar;

	@Autowired
	public Foo(Bar bar) {
		this.bar = bar;
	}	
}
```

```xml
<beans...>
    <context:component-scan base-package="examples"/>
    
    <bean id="bar1" class="examples.Bar"/>
    
    <bean id="bar2" class="examples.Bar"/>

    <alias name="bar2" alias="bar"/>
</beans>
```

When @Autowired annotation is placed on constructor, it works as expected.

Now, I change the code so that autowire will be performed with setter injection as follows;

```java
@Component
public class Foo {
	private Bar bar;
	
	@Autowired
	public void setBar(Bar bar) {
		this.bar = bar;
	}
	
	public Bar getBar() {
		return bar;
	}
}
```

I would expect it wouldn’t work when @Autowired annotation is placed over setter method, but, it works!

Unfortunately, the result of xml based autowiring with byType mode prevents us from concluding that autowire byType and 
constructor modes give precedence to bean name – property/constrcutor parameter name correspondence when more than one 
bean of matching type found in the ApplicationContext. There is clearly a behavioural inconsistency between xml and 
annotation based autowire configurations in Spring.
