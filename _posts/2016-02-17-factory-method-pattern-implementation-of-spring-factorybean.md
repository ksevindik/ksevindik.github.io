# Factory Method Pattern Implementation of Spring: FactoryBean

Factory method pattern aims to encapsulate object creation process within a separate method in your system. That’s why 
it is called as so. Factory methods can be created as either static or instance methods within a class. In Spring 
Application Framework, although it is possible to make use of static or instance factory methods to create Spring managed 
beans, Spring offers an interface, namely FactoryBean, for this purpose. It has following contract:

```java
public interface FactoryBean<T> {
	T getObject() throws Exception;
	Class<?> getObjectType();
	boolean isSingleton();
}
```

Whenever we need to encapsulate an object creation logic, we just implement this interface and create the target object 
within its getObject() method.

```java
public class FooFactoryBean implements FactoryBean<Foo> {

	@Override
	public Foo getObject() throws Exception {
		return new Foo();
	}

	@Override
	public Class<?> getObjectType() {
		return Foo.class;
	}

	@Override
	public boolean isSingleton() {
		return true;
	}

}
```

getObject() method is in role of factory method in that case. getObjectType() method just returns type of the instance we 
are creating. isSingleton() says whether the object managed by the Spring is singleton or not. If it’s singleton, that 
means getObject() returns always the same instance, and Spring Container can cache it.

Afterwards, we define our bean and give FQN of our FactoryBean implementation class instead of our target bean class as 
follows;

```xml
<bean id="foo" class="examples.FooFactoryBean"/>
```

During bootstrap process, Spring Container pays special attention to the bean definitions whose classes implement 
FactoryBean interface. Whenever it sees a subclass of FactoryBean interface, it creates an internal bean from that class, 
but also invokes its getObject() method and make the returned instance as the actual bean. Therefore, following code 
block can be used to obtain a reference to the Foo object;

```java
Foo foo = applicationContext.getBean(Foo.class, "foo");
```

However, sometimes you may need to access to the FactoryBean instance of “foo” bean instead. Spring provides a special 
“&” operator for this purpose. If you perform your bean lookup with “&foo“, then ApplicationContext will return you the 
FooFactoryBean instance. It looks similar to referencing addresses of variables in C programming language! Another option 
to access FooFactoryBean instance is to perform lookup by type, as follows;

```java
FooFactoryBean fooFactoryBean = applicationContext.getBean(FooFactoryBean.class);
```

Of course, above will only work, if there is only one bean definition of type FooFactoryBean in the ApplicationContext.

By default, beans defined in the Spring Container are initialized eagerly during bootstrap unless they are marked as lazy, 
and FactoryBean instances obey the same rule, too. However, FactoryBean.getObject() method is not invoked until target 
bean is actually needed or accessed even its bean definition is kept as eager.

If you want your bean to be initialized even it is not accessed or injected into another bean, then you need to implement 
another interface from Spring Application Framework, which is called as SmartFactoryBean.

```java
public interface SmartFactoryBean extends FactoryBean {
	boolean isPrototype();
	boolean isEagerInit();
}
```

SmartFactoryBean is actually a sub type of FactoryBean interface. It declares two methods. One is isPrototype(), which 
indicates returned instances from getObject() method are always independent from each other. That means, they are prototype 
in Spring terminology. The other method is what we seek for. isEagerInit() method can be used to indicate that target 
bean should be eagerly initialized during bootstrap.





