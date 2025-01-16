# Spring Application Framework ve Tasarım Örüntüleri 2

Önceki [yazılarımızdan](http://www.kenansevindik.com/spring-application-frameworkde-kullanilan-tasarim-oruntuleri/) birinde 
Spring Application Framework’de kullanılan örüntülerin bir kısmından bahsetmiştik. Factory Method, Singleton, Prototype, 
Proxy, Template Method, Observer, Mediator, Front Controller örüntüleri Spring Application Framework içerisinde değişik 
şekillerde karşımıza çıkmaktadır. Bu yazımızda da Spring Application Framework içerisinde kullanılan diğer bazı 
örüntülerden bahsedeceğiz.

* **Strategy**: Bu örüntü Spring ürün ailesinin hemen her yerinde karşımıza çıkmaktadır. Spring Framework’de kullanılan en 
temel örüntülerden birisidir. Ben bu örüntüyü anlatırken Spring Security Framework’deki `UserDetailsService` örneğini 
kullanmayı çok seviyorum. Spring Security `AuthenticationProvider` kimliklendirme işleminden sorumludur. Kendisine verilen 
kullanıcı adı ve parola bilgilerini kullanarak kimliklendirmeyi gerçekleştirir. Bu işlem için öncelikle kullanıcı adına 
karşılık gelen kullanıcı bilgisine erişmesi gerekir. Bunun için de `UserDetailsService` arayüzünde bir bean’dan yararlanır. 
Ancak farklı `UserDetailsService` implementasyonları vardır. Kullanıcı bilgileri bir properties dosyasından, bir ilişkisel 
veritabanından veya Active Directory gibi bir LDAP lokasyonundan elde edilebilir. Kullanıcı bilgisinin yönetildiği ortama 
uygun `UserDetailsService` “strateji”si konfigüre edilip `AuthenticationProvider`’a enjekte edilmesi yeterli olacaktır.

* **Decorator**: `ApplicationContext` ve `BeanFactory` ilişkisi tam bir decorator örüntüsüdür. `BeanFactory`’nin görevi 
Spring managed bean’ları yaratmak ve aralarındaki bağımlılıkları yönetmektir. `ApplicationContext` ise `BeanFactory`’nin 
gelişmiş halidir. Bean yaratma ve bağımlılıkları yönetmeye ilave olarak lazy yönetimi, post processing, proxy kabiliyeti, 
TX, AOP gibi pek çok özelliği daha barındırmaktadır. `ApplicationContext` aynı zamanda kendi içerisinde bir `BeanFactory` 
de barındırmaktadır.

* **Interpreter**: Spring expression dili bu örüntünün vücut bulduğu yerdir. SpEL olarak da bilinen “Spring Expression Language” 
Spring ürün ailesindeki expression ihtiyaçlarını karşılamak için tasarlanmıştır. Unified EL’e benzer ancak ondan daha 
yeteneklidir ve Spring container ile de uyumludur. “Object graph” üzerinde expression’ların evaluate edilmesi söz konusudur. 
Object graph SpEL expression’ına `EvaluationContext` içerisinde sunulur. Interpreter örüntüsünde de “Context” isimli bir 
nesne üzerinden expression’ın parse edilmesi ve dönülecek değerlerin tutulması sağlanır.

* **Command**: Spring’deki JDBC, JPA, Hibernate, REST, `TransactionTemplate` gibi sınıfların Template Method örüntüsü üzerine 
bina edildiğini daha önce vurgulamıştık. Bu “template” nesnelerine execute edilecek kod bloğu “callback” yardımı ile iletilir. 
Callback bildiğimiz Command örüntüsüne karşılık gelmektedir. Java’da callback’ler genellikle “anonim sınıflar” ile implement 
edilir.

* **Builder**: Spring içerisinde pek çok yerde karşımıza çıkmasına rağmen en güncel örneğini Spring 3.2 ile birlikte gelen 
MVC TestContext Framework’den verebiliriz. `MockHttpServletRequest` oluşturmak için `RequestBuilder` kullanılır. 
`MockMvcRequestBuilders` vasıtası ile `RequestBuilder` oluşturulup entegrasyon birim testi gerçekleştirilir. Spring MVC 
TestContext Framework sayesinde standalone ortamda request ve session scope bean’ların ve Controller bean’larının test 
edilmesi mümkün hale gelmiştir.

Spring Application Framework üzerinde çalışırken bu örüntüleri bilerek framework’ün sunduğu kabiliyetleri öğrenmek çok 
daha kolay ve anlaşılır olmaktadır. Diğer bir yandan çoğu temel GOF örüntüsünü Spring içerisinde görmek, kod kalitesi ile 
birlikte değerlendirildiğinde framework’ün kalitesi ile ilgili de bize bir fikir vermektedir.
