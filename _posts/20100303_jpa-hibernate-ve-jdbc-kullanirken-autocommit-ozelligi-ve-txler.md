# JPA, Hibernate ve JDBC Kullanırken AutoCommit Özelliği ve TXler

### Doğrudan JDBC Kullanırken

JDBC spesifikasyonuna göre veritabanı bağlantılarının default autocommit değeri `true`’dur. Bu nedenle doğrudan JDBC ile 
işlem yaptığınızda, veri üzerinde değişiklik yapan operasyonların her birisi kendi başına ayrı bir transaction’da ele 
alınacaktır. Transactional çalışabilmek için öncelikle bağlantının `autocommit` özelliğini `false` yapmanız gerekmektedir. 
Eğer veritabanı bağlantısı yaratılırken `autocommit` değerinin `false` olmasını istiyorsanız, bunu `DataSource`’un 
`defaultAutoCommit` property’si üzerinden yapabilirsiniz. Ya da doğrudan veritabanı üzerinde `autocommit`’i `false` olarak 
set edebilirsiniz. Örneğin, HSQLDB’de “`SET AUTOCOMMIT FALSE`” komutunu çalıştırmanız yeterlidir.

Eğer Spring kullanıyorsanız, `DriverManagerDataSource` bean’ının `connectionProperties` property’si ile `defaultAutoCommit`’i 
`false` olarak set edebilirsiniz. Test ortamları için yazılmış olan `SingleConnectionDataSource` bean’ını kullanıyorsanız, 
ya `connectionProperties` ile ya da doğrudan `autoCommit` property’si üzerinden `false` yapabilirsiniz.

### Doğrudan Hibernate Kullanırken

Hibernate tarafında autocommit davranışı `hibernate.connection.autocommit` property’si ile düzenlenmektedir. Default 
olarak Hibernate, autocommit’i `false` olarak set etmektedir ve bu property ile oynanmaması önerilmektedir. Detaylar için 
Hibernate’in sitesindeki ilgili [yazıyı](https://www.hibernate.org/403.html) okuyabilirsiniz.

Peki autocommit `false` olunca ne oluyor? Autocommit `false` olduğunda veri erişim işlemleri yine eskiden olduğu gibi 
problemsiz gerçekleşiyor. Ancak `insert`, `update`, `delete` gibi veri üzerinde değişikliklere neden olan işlemler için 
Hibernate `Session` üzerinde mutlaka transaction başlatılması gerekiyor. Yapılan işlemler sonrasında ise iş akışına göre 
transaction `commit` veya `rollback` edilmeli ki yapılan değişiklikler veritabanına yansısın. Transaction başlatılmadan 
yapılan `insert`, `delete`, `update` işlemleri ile ilgili hiçbir hata olmamaktadır; Hibernate bu işlemleri sessizce göz
ardı etmektedir.

```xml
<hibernate-configuration>
    <session-factory>
        <property name="connection.autocommit">true</property>
        <property name="dialect">org.hibernate.dialect.HSQLDialect</property>
        <property name="connection.driver_class">org.hsqldb.jdbcDriver</property>
        <property name="connection.url">jdbc:hsqldb:hsql://localhost</property>
        <property name="connection.username">sa</property>
        <property name="connection.password"></property>
        <mapping class="examples.Foo"/>
    </session-factory>
</hibernate-configuration>
```

```java
Foo foo = new Foo();
Configuration configuration = new AnnotationConfiguration().configure();
SessionFactory factory = configuration.buildSessionFactory();
Session session = factory.openSession();
session.save(foo);
session.close();
```

Eğer Hibernate ile çalışırken autocommit davranışını doğrudan JDBC kullanımı gibi yapmak istiyorsanız, yapmanız gereken 
yukarıdaki örnekte gördüğünüz `connection.commit` property değerini `true` olarak set etmekten ibarettir. Bu durumda 
Hibernate `Session` üzerinde hiç transaction oluşturmadan veri manipülasyonu gerçekleştirebilirsiniz.

### Spring ile Hibernate Kullanırken

Eğer Spring üzerinden Hibernate’i kullanıyorsanız işler biraz farklılaşmaktadır. Muhtemelen Hibernate `SessionFactory` 
nesnesini Spring’in `LocalSessionFactoryBean` factory bean’ı ile oluşturuyorsunuzdur. Hibernate `SessionFactory` bu 
durumda “user supplied connection” kullandığını düşünerek JDBC bağlantısını kendisi oluşturmak yerine doğrudan Spring’in 
inject ettiği `DataSource` bean’ından beklemektedir. Bu durumda da Hibernate’in `hibernate.cfg.xml` dosyası içerisinde 
belirteceğiniz `connection.autocommit` değişkeninin bir etkisi olmamaktadır.

Veritabanı bağlantısının autocommit özelliği, `DataSource` bean’ı nasıl konfigüre edilmişse ona göre değişmektedir. 
`DriverManagerDataSource` bean’ı, `defaultAutoCommit` değerine bir değişiklik yapmadığı için de bu değer `true` olarak 
kalmakta ve Hibernate üzerinden gerçekleşen veri manipülasyonları da ortada bir transaction olmasa bile veritabanına 
yansıtılmaktadır.

Doğrudan Hibernate kullanırken ki default Hibernate davranışını sağlamak için Spring ile konfigüre ettiğiniz `DataSource` 
bean’ına, veritabanı bağlantısı oluştururken `autocommit`’i `false` yapmasını söylemeniz gerekmektedir.

```java
Foo foo = new Foo();
hibernateTemplate.persist(foo);
```

### JPA ile Hibernate Kullanırken

Hibernate’i JPA ile kullanırken durum biraz daha değişmektedir. JPA, veri üzerinde manipülasyon yapan işlemler için mutlaka
bir transaction beklemektedir. Sizin `DataSource` bean’ı üzerinde veya `hibernate.cfg.xml` içerisinde autocommit davranışını
`true` yapmanızın bir etkisi olmamaktadır. Her iki durumda da transaction olmadan yapılan bir veri manipülasyonu
`javax.persistence.TransactionRequiredException` ile sonuçlanmaktadır.

Eğer yukarıdaki işlemin başarılı biçimde sonuçlanmasını istiyorsanız, bu işlemi mutlaka bir transaction içerisinde
çalıştırmanız gerekmektedir.

```java
Foo foo = new Foo();
jpaTemplate.persist(foo);
jpaTemplate.flush();
```

Kısacası autocommit özelliği, Hibernate’in doğrudan kullanımı veya `SessionFactory`’nin Spring tarafından yönetilmesi,
JPA üzerinden Hibernate kullanılması durumlarının her birinde farklı biçimlerde ele alınmaktadır. Bu nedenle yazdığınız
servislerin veri erişim mekanizmaları farklılaştığında davranışlarında da değişiklikler söz konusu oluyorsa şaşırmayın.