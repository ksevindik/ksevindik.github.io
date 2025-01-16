# Spring Uygulamalarında Kafka ile Transaction Yönetimi

Kafka’nın transaction kabiliyeti read-process-write örüntüsüne sahip senaryolar için gayet uygundur. Spring Boot ve Spring 
Kafka ile çalışırken Kafka’nın transaction kabiliyetini devreye almak için aşağıdaki property tanımını yapmak yeterlidir.

```properties
spring.kafka.producer.transaction-id-prefix=tx-
```
    

transaction-id-prefix tanımı sayesinde Spring Boot Kafka AutoConfiguration’ı bir KafkaTransactionManager bean’i tanımlamaktadır. 
transaction-id-prefix tanımının yanı sıra Kafka transaction’ları ile çalışırken aşağıdaki property tanımlarını yapmak da 
önem arz etmektedir.

```properties
spring.kafka.consumer.enable-auto-commit=false
spring.kafka.consumer.isolation-level=read_committed
```

enable-auto-commit=false olarak set edildiği vakit container offset bilgisini Kafka Transaction’a ancak MessageListener 
başarılı biçimde sonlandığı vakit gönderecektir. enable-auto-commit=true olma durumunda ise consumer offset bilgisi 
transaction’ın durumuna bakılmaksızın periyodik olarak gönderilmektedir. auto.commit.interval.ms property’si milliseconds 
düzeyinde bu periyodu yönetmeyi sağlar.

isolation-level=read_committed ise MessageListener, yani consumer’ların sadece commit’lenmiş transaction içerisinden veya 
transaction olmaksızın gönderilmiş mesajları okumasına olanak tanır. Kafka Broker read_committed durumunda abort/rollback 
olmuş transaction’a ait gönderilmiş mesajların consumer tarafından okunmasına izin vermez.

Kafka transaction kabiliyetinin devreye alınması ile birlikte artık KafkaTemplate kullanarak yapılacak olan send işlemlerinin 
aktif bir transaction içerisinde yapılması zorunlu hale gelmiştir. Bunun için Spring’in dekleratif transaction yönetim 
kabiliyetinden yararlanılabilir. @Transactional anotasyonunu metot veya sınıf düzeyinde kullanabilirsiniz. Spring’in 
anotasyon tabanlı deklaratif transaction yönetimi @EnableTransactionManagement anotasyonu ile devreye alınmaktadır. Ancak 
bu anotasyonu uygulama içerisindeki konfigürasyon sınıflarında kullanmanız şart değildir, bu tanım sizin yerinize Spring 
Boot tarafından eğer ApplicationContext’de bir TransactionManager bean tanımı varsa otomatik olarak yapılmaktadır. 
KafkaTransactionManager bean tanımı da bu şartı sağlamaktadır.

Spring transaction yönetim altyapısının en önemli temel kabiliyetlerinden birisi “transaction senkronizasyon” kabiliyetidir.
Bu kabiliyet sayesinde uygulamadaki transactional metotlar içerisinde bir takım işlemleri hemen o an değil, aktif 
transaction sonlanırken (commit, rollback veya her ikisi durumunda da) çalışmalarını sağlayabiliriz. Ancak 
KafkaTransactionManager bu transaction senkronizasyon kabiliyetini default olarak 
[devre dışı bırakmıştır](https://docs.spring.io/spring-kafka/docs/current/api/org/springframework/kafka/transaction/KafkaTransactionManager.html). Buna neden 
olarak da Kafka transaction’larının ve KafkaTransactionManager’ın genellikle JDBC DataSourceTransactionManager gibi datastore 
tabanlı başka bir TransactionManager ile birlikte kullanılması gösterilmektedir. Bu birlikte kullanım da Spring Data 
projesinin sunduğu ChainedTransactionManager vasıtası ile olmalıdır. Spring Kafka projelerinde [ChainedTransactionManager](https://docs.spring.io/spring-data/data-commons/docs/current/api/org/springframework/data/transaction/ChainedTransactionManager.html) 
olarak [ChainedKafkaTransactionManager](https://docs.spring.io/spring-kafka/api/org/springframework/kafka/transaction/ChainedKafkaTransactionManager.html) alt sınıfı kullanılmalıdır. Chained TransactionManager kullanımı David Syer’in Spring 
uygulamalarında karşımıza çıkan transactional processing örüntüleri incelediği [makalesinde](http://www.kenansevindik.com/spring-uygulamalarinda-kafka-transaction-yonetimi/#:~:text=processing%20%C3%B6r%C3%BCnt%C3%BCleri%20inceledi%C4%9Fi-,makalesinde,-bahsetti%C4%9Fi%20%E2%80%9CBest%20Effort) bahsettiği “Best Effort 1PC 
pattern”a karşılık gelmektedir.

Eğer projenizde bir nedenle sadece KafkaTransactionManager’ı kullanıyorsanız ve transaction senkronizasyonunu da aktive 
etmeniz gerekiyorsa (mesela Kafka ile Redis’i birlikte kullanacaksınız, herhangi bir JDBC veritabanı kullanımı söz konusu 
değilse ve Redis/Kafka işlemleri için de transaction senkronizasyonuna da ihtiyacınız varsa), bunun için KafkaTransactionManager 
bean tanımını override etmeniz gerekmektedir.

```kotlin
@Bean
@ConfigurationProperties(prefix = "spring.kafka")
fun kafkaTransactionManager(producerFactory: ProducerFactory<Any, Any>): KafkaTransactionManager<Any, Any> {
    val bean = KafkaTransactionManager<Any, Any>(producerFactory)
    bean.transactionSynchronization = AbstractPlatformTransactionManager.SYNCHRONIZATION_ON_ACTUAL_TRANSACTION
    return bean
}
```

Spring Kafka, eğer TransactionManager mevcut ise MessageListener’lar içerisinde meydana gelebilecek exception’ları handle 
etmek için ErrorHandler gerçekleştirimi olarak SeekToCurrentErrorHandler gerçekleştirimini tanımlamaktadır. Varsayılan 
durumda SeekToCurrentErrorHandler 10 denemeden sonra hatalı mesajı log’a yazmaktadır. Uygulama içerisinde custom bir 
errorHandler bean tanımı yaparak hatalı mesajların dead letter topic’lerine yazılmasını sağlayabiliriz.

```kotlin
@Bean
fun kafkaErrorHandler(kafkaTemplate: KafkaOperations<Object,Object>) : SeekToCurrentErrorHandler {
    val dlt = DeadLetterPublishingRecoverer(kafkaTemplate)
    val errorHandler = SeekToCurrentErrorHandler(dlt)
    return errorHandler
}
```

MessageListenerContainer, ErrorHandler’ın yanı sıra AfterRollbackProcessor’a da sahiptir. Bu bean, transaction rollback 
sonrası fail etmiş ve diğer işlenmemiş mesajları ele almayı sağlar. Varsayılan durumda DefaultAfterRollbackProcessor 
gerçekleştirimi kullanılmaktadır. Bu processor, mesajların belirli bir sayıda (max 10) tekrar process edilmesini denedikten 
sonra tanımlı BiConsumer Recoverer nesnesini kullanarak bu mesajı ele almayı bırakır. Varsayılan durumda tanımlı Recoverer 
hatalı mesajı log’a yazmaktadır. Yukarıdaki örnekte ErrorHandler’a tanıtılan DeadLetterPublishingRecoverer ErrorHandler 
yerine DefaultAfterRollbackProcessor’a da tanıtılabilir. Bunun için custom bir AfterRollbackProcessor bean tanımı yapılması 
yeterlidir.

```kotlin
@Bean
fun kafkaAfterRollbackProcessor(kafkaTemplate: KafkaOperations<Object,Object>) : AfterRollbackProcessor<Any,Any> {
    val dlt = DeadLetterPublishingRecoverer(kafkaTemplate)
    val processor = DefaultAfterRollbackProcessor<Any,Any>(dlt)
    return processor
}
```
