# Spring ve Test Driven Programlama

Bir önceki yazımda `Spring Framework`'ün test driven yazılım geliştirmeye ciddi katkılarının olduğunu ifade etmiştim. Bu 
3 temel nedene dayanıyor;

1. `Spring`’de “`Program to interface`” yaklaşımına uygun kod geliştirmenin desteklenmesi
2. Monolitik uygulama sunucularından bağımsız çalışabilen “`lightweight IoC container`”
3. Framework’ün sunduklarından istifade edebilmek için sıradan `Java` nesnelerinin (`POJO`) yeterli olması

Şayet uygulama içerisindeki bağımlılıklarımız sadece interface’lere olursa, kodlama ile ilgili detaylardan da kendimizi 
izole etmiş oluruz. Bunun anlamı biz kendi tarafımızı değiştirmeden bağımlı olduğumuz tarafta değişiklikler yapılabilir. 
Örneğin, gerçek bir veritabanına erişimin söz konusu olduğu yerde, test aşamasında bu ihtiyacı `mock` veya `stub` 
nesnelerle rahatlıkla karşılayabiliriz. Daha sonra bu sahte nesneler gerçek veritabanına erişim sağlayan kodlar ile 
değiştirilebilir.

```java
public class LibraryService {
      private IBookDAO bookDAO;

      public Collection getBooks() {
            returnbookDAO.getBooks();
      }
}

public interface IBookDAO {
      public Collection getBooks();
}
```

Yukarıdaki örnekte `LibraryService` sınıfı kütüphanedeki mevcut bütün kitapları döndüren bir metoda (`getBooks`) sahip. 
`LibraryService` mevcut kitaplara erişmek için bir `bookDAO` nesnesine ihtiyaç duyuyor. Onun için kitapların nerede 
tutulduğunun bir önemi yok. `bookDAO` nesnesi ise `IBookDAO` interface’ine sahip; yani `LibraryService` sınıfının işini 
`IBookDAO` interface’ini implement eden herhangi bir sınıf görebilir. Gerçek zamanda kitap bilgileri veritabanında 
tutuluyor olabilir, ancak test aşamasında sistemin çalışırlığından emin olmak için örnek birkaç kitap dönen bir `bookDAO` 
nesnesi de kesinlikle işimizi görecektir.

```java
public class InMemoryBookDAO implements IBookDAO {
      public Collection getBooks() {
            List books = new ArrayList();
            books.add(new Book("Great Expectations"));
            books.add(new Book("1924 - Bir Fotoğrafın Uzun Hikayesi"));
            books.add(new Book("White Nights"));
            return books;
      }
}
```

Test sırasında `LibraryService` nesnesi `InMemoryBookDAO` sınıfından oluşturulmuş bir `bookDAO` nesnesi kullanabilir. Bu 
`DAO` sabit biçimde 3 adet kitap döndürecektir.

```java
public class LibraryServiceTests extends TestCase {
      publicvoid testGetBooks() {
            LibraryService libraryService = new LibraryService();
            libraryService.setBookDAO(new InMemoryBookDAO());
            Collection books = libraryService.getBooks();
            assertEquals(3,books.size());
      }
}
```

Uygulamamız içerisinde kullanılan nesneler sıradan `Java` nesneleri olduğu için rahatlıkla `new` operator’ü ile 
yaratılabilir ve `JUnit` veya `TestNG` ile yukarıdaki örneğe benzer biçimde birim testine tabi tutulabilir. Buradaki 
`LibraryService` ileride `transaction`, `security`, `audit logging` gibi middleware servislere de ihtiyaç duyacak; fakat 
`Spring Framework` bu servisleri `POJO` modelden uzaklaşmadan bize sunacaktır. Bu da kodumuzun sürekli olarak birim 
testleri ile sınanabilir biçimde kalmasını sağlayacaktır.

Uygulamamızı sunucuya deploy etmeden de nesneler arası bağımlılıkların sağlıklı biçimde karşılanıp karşılanmadığını, 
veritabanına erişimin vs. düzgün biçimde gerçekleşip gerçekleşmediğini test edebiliriz. Bu tür testlere 
`entegrasyon testleri` adı verilmektedir. Bu testler sırasında diğer altyapısal servisleri ayağa kaldırmamıza da her 
zaman için gerek yoktur.

Örneğimizdeki `LibraryService` gerçek ortamda `JDBCBookDAO` sınıfından oluşturulmuş bir nesne kullanarak kitap 
bilgilerine veritabanından erişecektir. Aşağıdaki kodda `JDBCBookDAO` kitapları `Spring`’in `JdbcTemplate` utility 
sınıfını kullanarak doğrudan veritabanından döndürmektedir.

```java
public class JDBCBookDAO implements IBookDAO {
      private JdbcTemplate jdbcTemplate;

      public Collection getBooks() {
            returnjdbcTemplate.queryForList("select * from Book", Book.class);
      }
}
```

`LibraryService` nesnesinin sağlıklı biçimde veritabanından kitap bilgilerini getirip getirmediğni test etmek, bunu da 
uygulamamız gerçek zamanda bir sunucuda çalışacak olsa bile geliştirme sürecinde sunucuya deploy etmeden kendi başına 
sınamak isteyebiliriz. Uygulama geliştirme esnasında, özellikle presantasyon katmanının geliştirilmesi aşamasında sürecin 
daha hızlı işlemesi açısından sürekli veritabanına giden bir `DAO` nesnesini kullanmak yerine `InMemoryBookDAO` sınıfı 
gibi sabit veri dönen yapıları kullanabiliriz.

Peki `LibraryService` nesnesi istendiğinde `InMemoryBookDAO`, istendiğinde de `JDBCBookDAO` sınıflarının nesnelerini 
nasıl elde edecektir? `IoC container` tam da bu aşamada devreye girmektedir. Nesneler arasındaki bağımlılıklar 
`IoC container` tarafından yönetilmektedir. `Dependency Injection` vasıtası ile `LibraryService` o anda hangi tür 
`bookDAO` nesnesine ihtiyaç duyuyor ise bu türde bir nesne container tarafından oluşturulur ve `LibraryService` nesnesine 
iletilir. Bu işlem için genellikle `setter injection` tercih edilir. `LibraryService` sınıfı içerisinde;

```java
publicvoid setBookDAO(IBookDAO bookDAO) {
     this.bookDAO = bookDAO;
}
```

şeklinde bir `setter` metodu oluşturulur. `Spring Container ApplicationContext XML` dosyasındaki tanımlara göre bu 
`setter` metodunu çağırır ve elindeki `bookDAO` nesnesini `LibraryService` nesnesine iletir.

`Spring Framework` entegrasyon testleri için güzel bir altyapı sağlamaktadır. Bu altyapı ile `Spring ApplicationContext` 
nesnelerini test sırasında transparan biçimde oluşturmak, context içerisindeki bean’lara testlerimizden erişmek, 
`transaction` desteği gibi kolaylıklar sağlanmaktadır. `AbstractDependencyInjectionSpringContextTests`, 
`AbstractTransactionalSpringContextTests`, ve `AbstractTransactionalDataSourceSpringContextTests` sınıfları ile 
kolaylıkla entegrasyon testleri geliştirmek mümkündür. `Spring Framework` 2.1 serisi ile entegrasyon testleri için 
sağladığı altyapıyı kapsamlı biçimde yenileyip, `JUnit 4` ile uyumlu hale getirmektedir. Yine de yukarıdaki sınıflar 
ile oluşturulan test case’lerimiz deki ihtiyaçlarımızı karşılayacaktır.

```java
public class LibraryServiceIntegrationTests extends AbstractDependencyInjectionSpringContextTests {

      private LibraryService libraryService;
      protected String[] getConfigLocations() {
            returnnew String[]{"/appcontext/spring-beans.test.SpringSamples.xml"};
      }

      publicvoid testGetBooks() {
            Collection books = libraryService.getBooks();
            assertEquals(3,books.size());
      }

      publicvoid setLibraryService(LibraryService libraryService) {
            this.libraryService = libraryService;
      }
}
```

Yukarıdaki örnekte `LibraryServiceIntegrationTests` sınıfı `AbstractDependencyInjectionSpringContextTests` sınıfından 
türemiştir. Bu test sınıflarında `getConfigLocations`, `getConfigPath` veya `getConfigPaths` metodlarından herhangi 
birini override ederek test sırasında kullanılmak üzere oluşturulacak `ApplicationContext` nesnesi için kullanılacak 
konfigürasyon bilgisinin yeri belirtilebilir. Daha sonra test kodumuz içerisinde context içindeki herhangi bir bean’ın 
enjekte edilmesini isteyebiliriz. Bunun bir yolu, bean ile aynı isimde bir değişken tanımlayıp, bunun için bir `setter`
metodu oluşturmaktır. Örneğimizde `libraryService` bean’ı bağımlılıkları sağlanmış biçimde test metodlarımızda 
kullanılmak üzere bize sunulmaktadır.

```xml
<bean id="libraryService" class="com.ems.samples.spring.LibraryService">
      <property name="bookDAO" ref="jdbcBookDAO"/>
</bean>

<bean id="jdbcBookDAO" class="com.ems.samples.spring.JDBCBookDAO">
      <property name="jdbcTemplate" ref="jdbcTemplate"/>
</bean>

<bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
      <property name="dataSource" ref="dataSource"/>
</bean>

<bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
      <property name="url"                     value="jdbc:mysql://localhost:3306/test"/>
      <property name="username"                value="admin"/>
      <property name="password"                value="admin"/>
      <property name="driverClassName"   value="com.mysql.jdbc.Driver"/>
</bean>
```

Yukarıdaki `XML`’de `libraryService` bean’ı `jdbcBookDAO` bean’ını kullanmaktadır. Dolayısı ile kitap bilgileri doğrudan 
veritabanından gelecektir. Herhangi bir nedenle, örneğin geliştirme sürecinde ik etapta veritabanı bağımlılığından uzak 
durmak, hız vb. nedenlerle `InMemoryBookDAO` sınıfından oluşturulmuş bir bean da `libraryService` nesnesine wire 
edilebilir. Bunun için yapılması gereken

```xml
<bean id="inMemoryBookDAO" class="com.ems.samples.spring.InMemoryBookDAO"/>

<bean id="libraryService" class="com.ems.samples.spring.LibraryService">
      <property name="bookDAO" ref="inMemoryBookDAO"/>
</bean>
```

`inMemoryBookDAO` bean’ının tanımlanıp bu bean’ın `libraryService` bean’ına enjekte edilmesi gerektiğini belirtmekten 
ibarettir.

`Spring Framework`’ün sağladığı test sınıfları, bunların özellikleri ve kullanım şekilleri, `Spring 2.1` (final sürümde 
`2.5` olacak) ile gelen yenilikler uzunca üzerinde durmayı gerektiren konular. Ancak bu yazıda test driven programlama 
yaparken, sistemin ilk temellerinin atılmasından genişlemesine doğru `Spring`’in bu süreci nasıl kolaylaştırdığını 
gösteren bir giriş yaptık. Umarım yazılım geliştirme süreciniz `Spring`’in sağladığı bu servisler yardımı ile daha 
akıcı biçime dönüşecektir.
