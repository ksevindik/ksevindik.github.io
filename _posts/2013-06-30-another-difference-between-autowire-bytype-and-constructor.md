# Another Difference Between Autowire byType and constructor

Lets keep playing with autowiring behaviour of Spring Framework. Autowire byType or byName is not required by default. 
In other words, they will do nothing if they cannot find suitable candidates to inject into target beans. They can be 
made required in two different ways;

1. One is to use `@Required` annotation in setter method if you use xml based configuration.
2. The other is to set `@Autowired` annotation’s `required` attribute as true if you use annotation based configuration.
If dependency is required Spring will fail with the `BeanInitializationException` exception stating that property is 
required for target bean.

Now, if we attempt to apply this principle to autowire constructor we will see slightly different behaviour. Bean 
construction will simply fail but not with the exception stated above. This time Spring tries to find a bean in order to 
call constructor of the target bean, and if it can’t find it will throw `NoSuchBeanDefinitionException` stating that no 
qualifying bean definition found for the dependency. Spring doesn’t inject NULL value if it can’t find suitable bean. For 
setter injection it can simply ignore that dependency injection, however for autowire constructor it can’t, as it needs 
to create target bean.

If our target bean class has both default no arg constructor and constructor with input arguments, then it will call 
default no arg constructor whether autowire mode is byType, byName or constructor, and there will be no dependency 
injection if autowiring is not required.

`@Required` annotation can only be used on method level. so if we make use of xml based bean configuration, how shall we 
state that dependency is required if we have both constructors and autowire mode is constructor? Answer is `@Autowired` 
annotation with required attribute having value as “true”. `@Autowired(required=true)` can also be used on constructor, 
setter method level or field level as well.

Actually, Spring reference documentation suggests not mixing `@Required` annotation with `@Autowired(required=true)` 
annotation on the same setter method.

In summary, constructor injection behaves like autowiring is required even if it is not marked so, when there isn’t 
default no arg constructor available.
