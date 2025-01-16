# Kafka Transactions in Spring Enabled Applications

Kafka’s transactions are very suitable for scenarios that have a read-process-write pattern. It will be enough to add the 
following property definition in your application in order to enable Kafka transactions while you are working with Spring 
Boot and Kafka.

```properties
spring.kafka.producer.transaction-id-prefix=tx-
```

When Spring Boot notices transaction-id-prefix, Spring Boot AutoConfiguration feature enables KafkaTransactionManager bean 
within the ApplicationContext. Apart from the transaction-id-prefix, it might also be important to configure the following 
properties while you are working with Kafka transactions.

```properties
spring.kafka.consumer.enable-auto-commit=false
spring.kafka.consumer.isolation-level=read_committed
```

enable-auto-commit=false property setting makes the container send the offset information to Kafka transaction only when 
MessageListener ends without error. If we define enable-auto-commit=true, it allows the container to send offset information 
periodically without considering there exists a transaction or not. The auto.commit.interval.ms property which is in 
milliseconds precision becomes important to manage this period.

The isolation-level=read_committed property, on the other hand, only allows MessageListener, in other words, consumers to 
consume messages whose transaction is committed, or those messages sent without a transaction at all. Kafka broker won’t 
allow consumers to read messages whose transactions are aborted/rollbacked.

It becomes mandatory to have an active transaction in order to send messages using KafkaTemplate once we enabled Kafka 
transactions. For that purpose, you can utilize Spring’s declarative transaction management feature. You can employ 
@Transactional annotation over the class or method level. Declarative transaction management feature is enabled with 
@EnableTransactionManagement annotation, however, it is not necessary to explicitly add this annotation in your configuration 
classes, because it is already done by the Spring Boot for you if there exists a TransactionManager bean within the 
ApplicationContext. KafkaTransactionManager bean we already enabled above satisfies this condition.

One of the most important capabilities of Spring’s transaction management infrastructure is its “transaction synchronization” 
ability. With the help of transaction synchronization, we can defer the execution of some of the operations that we define 
within the transactional method until the end of that transaction (either to the commit or rollback, or both). Unfortunately, 
KafkaTransactionManager by default [disabled this feature](https://docs.spring.io/spring-kafka/docs/current/api/org/springframework/kafka/transaction/KafkaTransactionManager.html). The reason for disabling this feature is stated as it is generally 
expected that Kafka transactions and KafkaTransactionManager will be used together with another TransactionManager which is
based on something like JDBC DataSourceTransactionManager. In such a combination, the Spring Data project’s 
[ChainedTransactionManager](https://docs.spring.io/spring-data/data-commons/docs/current/api/org/springframework/data/transaction/ChainedTransactionManager.html) class is utilized to orchestrate among individual TransactionManagers. In Spring Kafka projects, 
if there is such a combination then [ChainedKafkaTransactionManager](https://docs.spring.io/spring-kafka/api/org/springframework/kafka/transaction/ChainedKafkaTransactionManager.html) subclass must be configured because it exposes 
KafkaTransactionManager to the outside. Usage of ChainedTransactionManager corresponds to the “Best Effort 1PC pattern” 
which is mentioned in the [article](https://www.infoworld.com/article/2077963/distributed-transactions-in-spring--with-and-without-xa.html?nsdr=true&page=2) written by David Syer in which he examines transactional processing patterns commonly 
appear in Spring enabled applications.

If you are, somehow, only using KafkaTransactionManager in your project, and you need to activate the transaction 
synchronization feature (for example, you will be using Kafka and Redis together, and there will be no such usage of JDBC 
database, and you will need to synchronize Kafka and Redis operations), then you must override KafkaTransactionManager 
bean definition in your application in order to activate this feature.

```kotlin
@Bean
@ConfigurationProperties(prefix = "spring.kafka")
fun kafkaTransactionManager(producerFactory: ProducerFactory<Any, Any>): KafkaTransactionManager<Any, Any> {
    val bean = KafkaTransactionManager<Any, Any>(producerFactory)
    bean.transactionSynchronization = AbstractPlatformTransactionManager.SYNCHRONIZATION_ON_ACTUAL_TRANSACTION
    return bean
}
```

If there is a TransactionManager bean defined in your application, Spring Kafka adds SeekToCurrentErrorHandler implementation 
by default as the ErrorHandler in order to deal with the exceptions that might occur within MessageListeners while they 
are consuming messages. You can define your own custom ErrorHandler bean definition in your application, and send messages 
to dead letter topics after some max number of failure retries which max 10 by default.

```kotlin
@Bean
fun kafkaErrorHandler(kafkaTemplate: KafkaOperations<Object,Object>) : SeekToCurrentErrorHandler {
    val dlt = DeadLetterPublishingRecoverer(kafkaTemplate)
    val errorHandler = SeekToCurrentErrorHandler(dlt)
    return errorHandler
}
```

Apart from ErrorHandler configuration, MessageListenerContainer has also AfterRollbackProcessor. It handles messages whose 
transactions rollback and those messages which cannot be processed at all. Spring Kafka configures DefaultAfterRollbackProcessor 
implementation by default. This processor implementation tries to process those failed messages for some number of times 
(max 10 by default) and then logs them using a BiConsumer Recoverer instance configured for it. You can configure
DeadLetterPublishingRecoverer as the recoverer of AfterRollbackProcessor instead of configuring it in ErrorHandler bean.

```kotlin
@Bean
fun kafkaAfterRollbackProcessor(kafkaTemplate: KafkaOperations<Object,Object>) : AfterRollbackProcessor<Any,Any> {
    val dlt = DeadLetterPublishingRecoverer(kafkaTemplate)
    val processor = DefaultAfterRollbackProcessor<Any,Any>(dlt)
    return processor
}
```