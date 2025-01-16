# Spring ve Tapestry’de IoC Yaklaşımları 2

[İlk bölümde](http://www.kenansevindik.com/spring-ve-tapestryde-ioc-yaklasimlari/) Spring ve Tapestry Framework’lerini 
IoC container oluşturma kabiliyetleri ve bağımlılıkların enjekte edilmesi konuları üzerinde durmuştuk. Bu bölümde ise 
kaldığımız yerden bean’ların scope yönetimi ile devam edelim.

## Scope Yönetimi

Tapestry’de varsayılan olarak servisler’in scope’u Spring’de de olduğu gibi Singleton olarak belirlenmektedir. Yani 
servis için tek bir instance yaratılmakta ve tüm threadler bu instance’i kullanmaktadır. Malum olduğu üzere bu tür 
sınıflar için thread-safety oldukça önemlidir. Tapestry’de bunun dışında ön tanımlı gelen bir scope daha vardır: 
Per-Thread. Per-Thread scope’una sahip servis tanımları için her bir thread için ayrı bir servis instance’ı yaratılmaktadır. 
Web tabanlı uygulamalarda her bir request ve response döngüsü bir thread üzerinden yönetildiği için bu servislerin yaşam 
döngüsü request bağlamında sınırlı kalmaktadır.

Spring’de ise Singleton scope’a ek olarak Prototype scope kullanılabilmektedir. Prototype scope’a sahip bean’ler için her 
istekte ApplicationContext, söz konusu sınıfın yeni bir nesnesini yaratıp verilen direktiflere göre konfigüre etmektedir. 
Ayrıca buna ek olarak AOP’nin nimetlerinden de faydalanarak Session ve Request scope’lar da kullanılmaktadır. Dahası, 
Spring CustomScopeConfigurer ile custom scope’lar oluşturmaya izin vermektedir.

## Bean’ların Yaratılması, Lazy ve Eager Initialization

Tapestry, servisleri interface ve concrete sınıfları üzerinden yönetiyor. Yani tanımladığınız her bir servisin muhakkak 
bir interface’i olmalı. Bu durum interface’ler üzerinden çalışmayı getiriyor ve muazzam bir soyutlamayı mecburi kılıyor.
Bunun yanı sıra benim hoşuma giden daha başka bir faydası da Tapestry’nin servisleri yönetmesinde ortaya çıkıyor. 
Tapestry, servislerin instance’larını ilk anda yaratmak yerine bunu sonraya bırakıyor ve servis metodlarından herhangi 
birine ilk çağrı geldiğinde, yani servis ilk defa kullanıldığında yaratıyor. İlk anda servis için interface üzerinden bir 
proxy oluşturuyor sadece. Yani her bir servis, aslında bir proxy’nin arkasından hizmet veriyor. Tapestry’nin servis 
proxy’leri Serializable nesneler. Bu durum servisleri kullanan (servislerin enjekte edildiği) sınıflara ait nesnelerin 
serialize edilmesinde önem kazanıyor. Bu nesneler serialize edildiğinde servis proxyleri de bir token halinde serialize 
ediliyor ve deserialization sonrasında ilgili servis ile olan ilişkisi bu token üzerinden registry’den tekrar kuruluyor. 
Bu durum, servislerin serializable olmasına hiç gerek bırakmıyor. İstenirse @EagerLoad annotasyonu kullanılarak servislerin 
ilk kullanımda değil, context’in oluşturulması esnasında yaratılması sağlanabiliyor. Spring’de ise servisler @Lazy 
annotasyonu ile aksi belirtilmedikçe context ayağa kaldırılırken yaratılıyor.

## AOP, Proxy’leme ve Bean Dekorasyon İşlemleri

Tapestry’de module tanımları servisleri bind etmenin yanı sıra servislere bir takım contribution’lar yapmak ya da servisleri 
decorate etmek için de kullanılabiliyor. Bunlar da naming convention kuralları gereği contribute* ya da decorate* şeklinde 
adlandırılan metodlarla yapılıyor. Dekoratör metodlar yardımıyla servislere logging, auditing gibi aspect’ler eklenebiliyor. 
Spring’de bu iş Spring’in AOP desteği ile sağlanıyor. Contribution metodlarında ise servislerin yaratılması öncesinde bir 
takım veriler, ayarlar, parametreler servislere girdi olarak sağlanıyor. Her bir modül ilgili servis için kendince 
contribution’lar yapabiliyor. Contributionlar collection, sıralı bir liste ya da bir map içerisinde ilgili servisin yaratımı 
esnasında servise iletilebiliyor. Tapestry, context’in yaratımı esnasında önce contribution’ları topluyor, sonra servisi 
build ediyor ve en sonunda da servisi decorate ediyor. Bu metodların modüller arasında dağıtık oluşu da burada güzel bir 
esneklik sağlıyor. Spring’de tam olmasa da benzer işler için bean post processor’ler kullanılabilir.

Tapestry IOC’yi kullanarak geliştirilmiş uygulamalar içerisinde de yeni modüller eklenebiliyor. Default olarak uygulamanın 
ana modülü .service.Module.java dosyası olarak kabul ediliyor. Bunun dışında context’i oluşturmak için kullanılacak 
modüllerin neler olduğu modülü içeren jar dosyasının MANIFEST’i içerisinde belirtilmek zorunda. Manifest dosyası içerisinde 
“Tapestry-Module-Classes:” başlığı ile JAR’ın içerisindeki hangi sınıfların modül tanımı olarak kullanılacağı belirtilmelidir. 
Spring’de bunun yerine tercihen belirli bir package altında yer alan @Configuration annotasyonuna sahip sınıflar application 
context’i oluşturmak için kullanılıyor.

Genel olarak baktığımızda Tapestry, IoC konusunda oldukça güzel bir yaklaşım ortaya koymuş. İlk zamanlarında yola XML 
tabanlı konfigürasyon ile çıkan, ardından annotasyon tabanlı konfigürasyonu çözüm setine dahil eden Spring, versiyon 3 
ile birlikte sunduğu java tabanlı konfigürasyon ile Tapestry’nin java tabanlı modül yönetimine benzer bir çözüm ortaya koyuyor.
