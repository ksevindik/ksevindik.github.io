# Redis Transactions in Spring Enabled Applications

Thanks to the [Spring Data Redis](https://docs.spring.io/spring-data/redis/docs/current/reference/html/#reference) project’s **Redis Repositories** support, it is much easier to manage domain objects 
within the Redis datastore. Redis Repositories also provide support for custom mapping and secondary indexes. Unfortunately,
Redis Repositories [don’t work](https://docs.spring.io/spring-data/redis/docs/current/reference/html/#redis.repositories) with **Redis Transactions**. If you want to make use of Redis Transactions and synchronize 
your Redis database operations with Spring, you need to either revert to `RedisTemplate` or perform your operations with 
Redis Repositories while manually synchronizing your operations using Spring transaction synchronization API.

If you decide on using `RedisTemplate`, you must be aware that by default Redis Transactions are disabled. `RedisTemplate` 
and `StringRedisTemplate` bean configurations defined within Spring Boot Redis AutoConfiguration haven’t enabled it, and 
unfortunately, they don’t expose any property to enable it via the `application.properties`. Therefore, the only thing 
you can follow at this point is to override those two bean definitions in your configuration classes and enable transaction 
support there.  

```kotlin
@Bean
fun redisTemplate(redisConnectionFactory: RedisConnectionFactory): RedisTemplate<Any, Any> {
    val template = RedisTemplate<Any, Any>()
    template.setConnectionFactory(redisConnectionFactory)
    template.setEnableTransactionSupport(true)
    return template
}

@Bean
fun stringRedisTemplate(redisConnectionFactory: RedisConnectionFactory): StringRedisTemplate {
    val template = StringRedisTemplate()
    template.setConnectionFactory(redisConnectionFactory)
    template.setEnableTransactionSupport(true)
    return template
}
```

Whenever you attempt to read a value corresponding to a key using `redisTemplate.getOpsForValue().get(key)` method from 
the Redis database while there exists an active transaction around (for example, from within a method marked with 
`@Transactional` annotation), it will return a [NULL value](https://docs.spring.io/spring-data/data-redis/docs/current/api/org/springframework/data/redis/core/ValueOperations.html#get-java.lang.Object-). You must perform such read operations over a separate 
connection that doesn’t belong to the current transactional connection.  

```kotlin
val c:RedisConnection = stringRedisTemplate.connectionFactory!!.connection
val v :ByteArray? = c.get(id.toByteArray())
c.close()
```

In such cases, you may need to create two distinct `RedisTemplate` bean configurations: one with transaction support and 
the other without.

If you have already enabled `RedisTemplate` transaction support, Redis database operations will be accumulated and reflected 
onto the database at transaction commit time. The Spring Data Redis project doesn’t offer a separate implementation of 
`PlatformTransactionManager` specific for Redis. The general expectation is that Redis usage will complement some other 
transactional datastore access like JDBC. Accordingly, there will be a corresponding `PlatformTransactionManager` bean 
configuration targeted for `DataSource`, Hibernate, JPA, or JTA, and transaction management and transaction synchronization 
requirements will be satisfied by it. Hence, operations performed via a `RedisTemplate`, which has enabled transaction 
support, will participate in the currently active transaction managed by that `TransactionManager`, and they will be 
reflected just after the active transaction completion if it is committed.  

Below, you can inspect related RedisTransactionSynchronizer source code which is registered for that purpose, as a 
transaction synchronization object to the currently active transaction by the RedisConnectionUtils while any operation is 
being performed over RedisTemplate.

```java
private static class RedisTransactionSynchronizer extends TransactionSynchronizationAdapter {
    private final RedisConnectionHolder connHolder;
    private final RedisConnection connection;
    private final RedisConnectionFactory factory;

    @Override
    public void afterCompletion(int status) {
        try {
            switch (status) {
                case TransactionSynchronization.STATUS_COMMITTED:                                
                connection.exec();
                break;
                case TransactionSynchronization.STATUS_ROLLED_BACK:
                case TransactionSynchronization.STATUS_UNKNOWN:
                default:
                connection.discard();
            }
        } finally {
            if (log.isDebugEnabled()) {
                log.debug("Closing bound connection after transaction completed with " + status);
            }                    
            connHolder.setTransactionSyncronisationActive(false);
            doCloseConnection(connection);                    
       TransactionSynchronizationManager.unbindResource(factory);
        }
    }
}
```

The important point here is that registered Redis transaction synchronization will be executed after the transaction commit. 
For example, when you perform some JDBC operations and at the same time access the Redis database to update some information 
related to those operations, those updates to the Redis database will be reflected only after the JDBC transaction is 
committed. If something goes wrong during the execution of this Redis transaction synchronization, it won’t have any effect 
on the already completed JDBC transaction. In other words, regardless of the outcome of your Redis operations, your business 
scenario will be completed successfully if its JDBC operations are successful. There is no problem with that kind of flow 
as long as your business scenario complies with it. Such usage corresponds to the **Nontransactional Access Pattern** 
mentioned in the [article](https://www.infoworld.com/article/2077963/distributed-transactions-in-spring--with-and-without-xa.html?nsdr=true&page=3) written by David Syer, in which he examines common transactional processing patterns.

If you prefer to go with the Redis Repositories instead of `RedisTemplate` within your project and you expect your 
operations performed via the Redis Repository bean corresponding to your domain object to be reflected in the Redis 
database at the time of transaction commit, then the method you must follow for this purpose is to create a transaction 
synchronization object by yourself, place your Repository operation within the specific callback method(s) in the 
transaction synchronization object, and then register it to Spring’s `TransactionSynchronizationManager` manually.  

```kotlin
@Transactional
fun doSomething() {
    val foo = Foo()
    TransactionSynchronizationManager.registerSynchronization(object:TransactionSynchronizationAdapter(){
        override fun afterCommit() {
            fooRedisRepository.save(foo)
        }
    })
}
```

Here you must be aware that Spring Data Repositories behind the scenes also make use of `RedisTemplate` to perform their 
operations, and transaction support of that `RedisTemplate` instance must be disabled for Redis Repositories to function 
without any problem. If you want to use both transactional `RedisTemplate` and Spring Data Repositories together in your 
project, then you must define another non-transactional `RedisTemplate` bean in your application and indicate Redis 
Repositories to use it via `@EnableRedisRepositories` annotation in your application configuration.
