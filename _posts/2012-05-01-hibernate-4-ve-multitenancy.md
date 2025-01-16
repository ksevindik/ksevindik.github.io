# Hibernate 4 ve Multitenancy
Multi-tenant uygulamaları kurumsal yazılım projelerinde hayata geçirmenin üç temel yolu vardır. Birinci yol her bir istemci 
için tamamen ayrı bir fiziksel veritabanı kullanmaktır. Bu yaklaşımda JDBC veritabanı bağlantıları her bir istemci için 
ayrı ayrı yönetilmektedir. Bu yönetim veritabanı bağlantı havuzları için de geçerlidir. Uygulamalar sisteme login olmuş 
kullanıcıya ait `tenant identifier` ile aktif veritabanı bağlantı havuzunu seçerek faaliyet gösterirler.

İkinci yol ise fiziksel veritabanı düzeyinde ayırmak yerine her bir istemciyi birbirinden farklı şemalar ile ayırmaktır. 
Bu yöntemin çalışabilmesi için ya JDBC veritabanı bağlantısının ya da bağlantı havuzunun parametre olarak `tenant identifier` 
kabul etmesi gerekir. Bu durum söz konusu değil ise `ALTER SESSION SET SCHEMA` benzeri bir komut ile JDBC veritabanı 
bağlantısının şema bilgisi değiştirilebilir.

Üçüncü yol ise bütün verinin tek bir şemada tutularak her bir istemci için ayrı `tenant identifier` değerlerinin 
kullanılmasıdır. Bu yöntemde ortak bir şema ve bunun üzerindeki tablolar ile çalışılır. Veritabanı üzerinden çalıştırılacak 
her bir sorguya `tenant identifier` kontrol ifadesi de eklenir. Hibernate ilk iki yöntemi 4.0 sürümü ile desteklerken, 
üçüncü yöntem şu an için Hibernate 5’in bir özelliği olarak planlanmaktadır. Hibernate 4 öncesi dönemde bu özellik daha 
önceki yazımızda da bahsettiğimiz gibi `filter` kabiliyeti ile hayata geçirilmektedir.

Hibernate 4 ile çalışırken öncelikle yapılması gereken konfigürasyon ayarlarında `hibernate.multiTenancy` attribute ile 
hangi stratejinin kullanılacağını belirtmektir. Hali hazırda `NONE`, `DATABASE`, `SCHEMA`, `DISCRIMINATOR` değerleri 
kullanılabilir, ancak aktif olarak sadece `DATABASE` ve `SCHEMA` değerleri desteklenmektedir. `DATABASE` ve `SCHEMA` 
değerleri kullanıldığı vakit `MultiTenantConnectionProvider` arayüzünden implement edilen bir sınıfın da 
`hibernate.multi_tenant_connection_provider` attribute değeri ile Hibernate’e tanıtılması gerekir. Bu sınıf içerisinde 
basitçe `tenant identifier` değerine karşılık gelen veritabanı bağlantısı veya bağlantı havuzu dönülür. Eğer veritabanı 
bağlantısı dönülürse bu bağlantının kullandığı şema bu sınıf içerisinde `tenant identifier` ile değiştirilmelidir.

`hibernate.multi_tenant_connection_provider` attribute’u yerine `hibernate.connection.datasource` attribute’unun 
tanımlandığı durumda ise Hibernate `DataSourceBasedMultiTenantConnectionProviderImpl` sınıfından bir instance’ı 
kullanarak JNDI’dan `tenant identifier` değerine karşılık gelen isimde bir datasource nesnesine lookup yapmaya 
çalışmaktadır. Bu konfigürasyon detaylarından sonra uygulama içerisinde 
`sessionFactory.withOptions().tenantIdentifier("myTenantId").openSession();` 
benzeri bir ifade ile o andaki istemciye karşılık gelen bir tenant identifier ile Hibernate Session oluşturulabilir.

Eğer Hibernate 3 ile birlikte gelen `contextual session` kabiliyeti `jta` veya `thread` değerlerinden birisi ile devreye 
alınmış ise bu durumda Hibernate’e `sessionFactory.currentSession()` metodu çağrıldığında hangi `tenant identifier` ile 
Session oluşturması gerektiği söylenmelidir. Bunun için `CurrentTenantIdentifierResolver` arayüzünden implement edilmiş 
bir sınıf kullanılabilir. Aktive edilmesi için `hibernate.tenant_identifier_resolver` konfigürasyon attribute değeri 
olarak tanımlanması gerekir.
