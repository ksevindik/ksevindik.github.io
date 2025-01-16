# Spring Uygulamalarında Redis ile Transaction Yönetimi

[Spring Data Redis projesi](https://docs.spring.io/spring-data/redis/docs/current/reference/html/#reference)nin 
“Redis Repositories” özelliği sayesinde domain nesnelerinin herhangi bir extra efor harcamadan “Redis” veritabanında 
saklanması mümkündür. Redis Repositories’in custom mapping ve secondary index desteği de söz konusudur. Ancak 
“Redis Transaction”ları ile [çalışmaz](https://docs.spring.io/spring-data/redis/docs/current/reference/html/#redis.repositories). 
Eğer Redis’in transaction kabiliyetini kullanmak ve Redis veritabanı üzerinde gerçekleştirdiğiniz işlemlerin Spring’in 
transaction senkronizasyonu ile yönetilmesini istiyorsanız ya doğrudan “RedisTemplate”‘i kullanmalısınız, ya da transaction 
senkronizasyon işlemini Spring TX senkronizasyon API’sini kullanarak manuel biçimde siz gerçekleştirmelisiniz.

Eğer “RedisTemplate” ile çalışmaya karar verirseniz, default olarak Redis transaction’larının devre dışı olduğunu 
bilmelisiniz. Spring Boot Redis AutoConfiguration’ı ile gelen RedisTemplate ve StringRedisTemplate bean tanımlarında da 
transaction desteği kapalıdır ve malesef bunu enable etmek için herhangi bir property de mevcut değildir. Dolayısı ile 
yapılması gereken şey RedisTemplate ve StringRedisTemplate bean tanımlarını override ederek transaction desteğini aktive 
etmek olacaktır.

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

Aktif bir transaction’ın olduğu bir metodun içerisinde (örneğin @Transactional anotasyon ile işaretlenmiş bir metot) 
RedisTemplate ile Redis database’den bir key’e karşılık gelen değeri redisTemplate.getOpsForValue().get(key) metodu ile 
okumaya kalkarsanız get metodu size [NULL değer dönecektir](https://docs.spring.io/spring-data/data-redis/docs/current/api/org/springframework/data/redis/core/ValueOperations.html#get-java.lang.Object-). 
Transactional bir metot içerisinde Redis veritabanından okuma yapmak için ayrı bir connection oluşturup bu connection 
üzerinden okuma yapmalısınız.

```kotlin
val c:RedisConnection = stringRedisTemplate.connectionFactory!!.connection
val v :ByteArray? = c.get(id.toByteArray())
c.close()
```

Bu durumda uygulamanız içerisinde Redis veritabanındaki güncellemeler ve okumalar için farklı iki RedisTemplate 
konfigürasyonu gerektirebilir.

Eğer RedisTemplate’in transaction desteğini aktive ettiyseniz Redis database’inde gerçekleştirdiğiniz işlemler transaction 
commit aşamasında Redis veritabanına yansıtılacaktır. Spring Data Redis projesi Redis’e özel herhangi bir 
PlatformTransactionManager gerçekleştirimi sunmamaktadır. Genel olarak beklenti Redis’in, JDBC datastore gibi klasik bir 
transaction kabiliyetine sahip veritabanının yanında kullanılması olup, buna paralel olarak Spring ApplicationContext 
içerisinde de DataSource, Hibernate, JPA veya JTA PlatformTransactionManager gerçekleştirimlerinden birisinin olması, 
transaction yönetiminin ve transaction senkronizasyonunun da bunun tarafından yapılması yönündedir. Dolayısı ile Transaction 
desteği aktive edilmiş bir RedisTemplate ile gerçekleştirilen işlemler, Spring’in transaction senkronizasyon kabiliyeti 
üzerinden aktif transaction commit olduktan hemen sonra Redis veritabanına otomatik olarak yansıtılacaktır.

Aşağıda bu amaçla Spring RedisConnectionUtils sınıfı içerisinde yer alan RedisTemplate üzerinden herhangi bir işlem 
gerçekleştirirken RedisConnectionUtils tarafından aktif transaction’a register edilen RedisTransactionSynchronizer sınıfının 
kaynak kodunu inceleyebilirsiniz.

```kotlin
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

Burada dikkat edilecek önemli bir husus bu transaction senkronizasyonunun afterCommit aşamasından işletilecek olmasıdır. 
Örneğin, JDBC ile veritabanında bir takım işlemler yaptınız ardından Redis veritabanına erişip bu işlemlerle ilgili bir 
takım bilgileri de güncellemek istediniz, bu güncellemeler JDBC transaction’ı commit olduktan sonra Redis’e yansıtılacaktır. 
Eğer bu aşamada güncellemelerin Redis’e yansıtılması ile ilgili herhangi bir sorun olursa bu sorunun JDBC transaction’ına 
hiçbir yan etkisi olmayacaktır. Başka bir deyişle eğer JDBC işleminiz başarılı ise güncellemeleriniz Redis’e başarılı 
biçimde yansıtılsın veya yansıtılmasın, senaryonuz başarılı biçimde sonlanmış olacaktır. Eğer iş mantığınız bu akışa uygun 
ise Redis TX senkronizasyonunu kullanmanızda hiçbir sakınca yoktur. Bu tür bir kullanım, David Syer’in Spring uygulamalarında 
karşımıza çıkan transactional-processing pattern’ları incelediği popüler 
[makalesinde](https://www.infoworld.com/article/2077963/distributed-transactions-in-spring--with-and-without-xa.html?nsdr=true&page=3) 
de “Nontransactional Access Pattern”a karşılık gelmektedir.

Eğer projenizde transactional RedisTemplate yerine Redis Repositories ile çalışmayı tercih ediyorsanız ve domain nesneleriniz 
üzerinde yaptığınız güncellemelerin ilgili repository bean ile Redis veritabanına yansıtılmasını ve bu işlemin de aktif 
transaction’ın commit aşamasında gerçekleşmesini istiyorsanız bu durumda izlemeniz gereken yöntem transactional metot 
içerisinde bu işlemleri bir Spring transaction senkronizasyon nesnesi içerisinde tanımlamak ve bu senkronizasyonu Spring’in 
TransactionSynchronizationManager’ına manuel olarak register etmektir.

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

Spring Data Repositories Redis veritabanındaki işlemler için arka planda RedisTemplate’ı kullanmaktadır ve bu RedisTemplate 
bean’i üzerinde transactional kabiliyet devre dışı olmalıdır. Eğer projenizde transactional RedisTemplate ile Spring Data 
Repositories kabiliyetini bir arada kullanmak isterseniz Spring Data Repositories için ayrı bir non-transactional RedisTemplate 
bean’i tanımlayıp Repository bean’lerinin işlemlerini bu bean üzerinden yapacaklarını @EnableRedisRepositories anotasyonu 
ile söylemek gerekir.
