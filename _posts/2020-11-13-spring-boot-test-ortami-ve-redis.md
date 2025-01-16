# Spring Boot Test Ortamı ve Redis

Spring ekosisteminde çalışırken en çok hoşuma giden özelliklerden birisi de entegrasyon testlerini çalıştırırken veri 
erişim işlemleri ile ilgili işlemleri hafızada çalışan gömülü bir veritabanı (H2 veya Derby) ile kolayca gerçekleştirebilmemizdir. 
Böylece testleri herhangi bir ortamda – ortamda daha önceden herhangi bir setup yapaya gerek kalmaksızın – rahatlıkla 
koşturabiliriz.

Bu kabiliyet Kafka, Redis gibi NoSQL çözümler için de aynı derecede önemlidir. Bu yazımda Redis için bunun nasıl 
yapılabileceğini kısaca anlatmaya çalışacağım.

Veri işlemleri için Redis sunucuya ihtiyaç duyan Spring Boot uygulamalarının entegrasyon testleri için gömülü olarak 
çalışacak bir Redis sunucusu halihazırda mevcut. Öncelikle projenize “it.ozimov:embedded-redis:0.7.3” kütüphanesini 
eklemelisiniz. Daha sonra ise test metodunuzun başında gömülü Redis sunucusunu başlatıp, testin sonunda da sunucuyu 
kapatacaksınız. Yapmanız gereken bundan ibaret!

```kotlin
@SpringBootTest
class FooTests {
    @Test
    fun testFoo() {
        val redisServer = RedisServer()
        try {
            redisServer.start()
            //...
        } finally {
            redisServer.stop()
        }
    }
}
```

Default olarak RedisServer 6379 portunda çalışmaktadır. İsterseniz RedisServer’a constructor parametresi olarak farklı bir 
port da verebilirsiniz. Testlerin farklı ortamlarda koştuğunu düşünürsek, bütün bu ortamlarda aynı portun müsait olması 
her zaman için çok mümkün olmayabilir. Şanslıyız ki Spring bizim için SocketUtils isimli küçük bir yardımcı sınıf sunuyor. 
Bu sınıftaki findAvailableTcpPort() metodunu kullanarak testin çalıştığı ortamda müsait bir portu bularak RedisServer’ımızı 
bu portta kolaylıkla çalıştırabiliriz.

```kotlin
@SpringBootTest
class FooTests {
    @Test
    fun testFoo() {
        val redisServerPort = SocketUtils.findAvailableTcpPort()
        val redisServer = RedisServer(redisServerPort)
        try {
            redisServer.start()
            //...
        } finally {
            redisServer.stop()
        }
    }
}
```

Yukarıdaki işlemi her test metodundan önce ve sonra gerçekleştirmek için setUp ve tearDown metotlarından da yararlanabilirsiniz.

```kotlin
@SpringBootTest
class FooTests {
    
    companion object {
        
        private lateinit var redisServer:RedisServer
        
        @BeforeAll
        @JvmStatic
        fun setUpForAll() {
            val redisServerPort = SocketUtils.findAvailableTcpPort()
            var redisServer = RedisServer(redisServerPort)
            redisServer.start()
        }

        @AfterAll
        @JvmStatic
        fun tearDownForAll() {
            redisServer.stop()
        }
    }


    @Test
    fun testFoo() {
        //...
    }
    
    @Test
    fun testBar() {
        //...
    }
}
```

Yukarıdaki örnekte, bütün test metotlarından önce bir kere çalışacak bir setUpForAll() metodu tanımlayarak, RedisServer’ı 
bu metot içerisinde başlattım. Benzer biçimde bütün test metotlarının çalışması tamamlandıktan sonra çalışacak 
tearDownForAll() metodunda ise RedisServer’ı durdurdum.

Sonuç olarak, “it.ozimov:embedded-redis:0.7.3” kütüphanesinin Embedded RedisServer çözümü sayesinde Spring Boot testlerini 
herhangi bir ortamda hiçbir kuruluma ve ayara gerek duymaksınızın çalıştırmaya devam etmiş oluyoruz.