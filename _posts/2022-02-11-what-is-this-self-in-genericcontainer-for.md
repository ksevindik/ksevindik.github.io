# What is this SELF in GenericContainer For?

`GenericContainer` class belongs to TestContainers library, which is used to create a container instance, launch and 
control it during integration testing. All other TestContainers classes, like `MySQLContainer`, `KafkaContainer`, etc., 
extend from this base class. However, it has a bit weird generic class definition itself as you may notice from the below 
code block.

```java
public class GenericContainer<SELF extends GenericContainer<SELF>>
        extends FailureDetectingExternalResource
        implements Container<SELF>, AutoCloseable, WaitStrategyTarget, Startable {
...
}
```

This somehow recursive generic `SELF` type usually leads developers to create extra class definitions in order to configure 
a container instance within their tests. For example;

```kotlin
    internal class KGenericContainer : GenericContainer<KGenericContainer>("redis:6.0.12-alpine")
    internal class KMySQLContainer : MySQLContainer<KMySQLContainer>("mysql:5.7.33")
```

The purpose of this `SELF` generic type is to let those subclasses extending from `GenericContainer` provide a more fluent 
API for their configurations within the test class. For example, `MySQLContainer` class defines some additional methods, 
apart from the ones coming from the `GenericContainer`, and this `SELF` generic type allows us to access those methods 
fluently.

```kotlin
@Container
private val mySQLContainer = KMySQLContainer()
    .withReuse(true)
    .withDatabaseName("mydb")
    .withUsername("sa")
    .withPassword("secret")
    .start()
```

While `withReuse()` and `start()` methods are coming from `GenericContainer`, other methods, such as `withDatabaseName()`, 
`withUsername()`, and `withPassword()` are defined in the `MySQLContainer` class, and we are able to just mix all of them 
during the instantiation and configuration of a container instance in one single line.

If you think that having a fluent API is not that important for you, you can certainly skip this extra class definition 
step. This is actually easily achievable by giving `Nothing` type in Kotlin as the generic type as follows.

```kotlin
@Container
private val mySQLContainer = MySQLContainer<Nothing>().apply {
    this.withReuse(true)
    this.withDatabaseName("mydb")
    this.withUsername("user")
    this.withPassword("secret")
    this.start()
}
```

Obviously, here we lose fluent API convention. However, thanks to Kotlin’s `apply` function, which lets us invoke a given 
function block within that specific object from which `apply` function is called. Therefore, in practice, there seems not 
that much difference between those two initialization blocks, and I would rather get rid of this extra class definition at all.
