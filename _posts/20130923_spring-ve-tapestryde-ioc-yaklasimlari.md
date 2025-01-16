# Spring ve Tapestry’de IoC Yaklaşımları

Yıllar boyunca bir çok projede Spring kulanmanın getirdiği bir alışkanlık olarak IoC ve dependency injection kavramları
benim için vazgeçilmezler arasına girdi. Bu kavramların önerdiği yöntemlerle geliştirilen uygulamalarda sınıflar arası 
bağımlılıkların çok daha sade ve kolay yönetilebilir olduğunu gördüm. Özellikle test güdümlü programlamada 
(TDD – Test Driven Development) birim testleri yazarken bunun büyük yararı olmaktadır. Bu kavramları kullanarak, sınıfların 
kabiliyetlerini ve sorumluluk sınırlarını çok daha kolay belirleyebildiğimiz için işbirlikçi sınıflar için mock nesnelerini 
kolaylıkla oluşturup kullanabiliyoruz.

İki bölümden oluşan bu yazı dizisinde amacımız IoC ve dependency injection kavramlarının ne olduğunu ya da yararlarını 
anlatmak değil. Bu yazıda Tapestry ve Spring Framework’lerin sunduğu IoC kabiliyetlerini genel hatları ile karşılaştırmaya 
çalışacağız. IoC ve Dependency Injection kavramları ile ilgili Martin Fowler on yıl kadar önce güzel bir 
[yazı](https://martinfowler.com/articles/injection.html) yazmış. Bu kavramlara yabancı iseniz, öncelikle bu yazıya bir 
göz atmanızda büyük fayda var.

Bu bölümde IoC container’ın oluşturulması, Tapestry’deki modül kavramı ve bean’ların arasındaki bağımlılıkların yönetilmesi 
konularında duracağız.

## IoC Container’ın Oluşturulması ve Bean’ların Yaratılması

Tapestry, IoC context’ini Java ile oluşturuyor. Module diye tabir edilen sınıflar bir araya gelerek context’i oluşturuyor. 
Modül sınıflarının sahip olduğu metodlar, context içerisinde yer alacak olan nesneleri yani servisleri yaratmaktan sorumlu. 
Bu nedenle bu metodlara “service builder methods” demişler. Tapestry, modüller içerisinde bir takım isimlendirme kuralları 
(naming conventions) koymuş. Service builder metodlar için metod adlarının build* şeklinde olması bekleniyor. Build ön 
ekinin sonrasında gelen kısım servis ID’si olarak kullanılıyor. Örneğin `buildGuvenlikServisi()` metodunun döndürmesi 
beklenen servis nesnesi context’e GuvenlikServisi id’siyle kaydediliyor ve bu isimle erişilebiliyor. ID’ler case-insensitive 
olarak kullanılıyor ve servislere erişimi sağladığı için tekil (unique) olması bekleniyor. Eğer aynı ID’ye sahip birden 
çok bean (nesne) oluşması durumu ortaya çıkar ise bunlar arasındaki ayrım `@Marker` annotasyonu ile marker vererek 
sağlanabiliyor.

Spring’in ilk zamanlarında IoC context, başka bir ifade ile ApplicationContext, XML dosyaları üzerinden konfigüre 
edilebiliyordu. Spring 3 ile birlikte gelen Java tabanlı konfigürasyon yöntemi de Tapestry’dekine benzer kabiliyetler 
sunmaktadır. Ama Spring, Tapestry’deki gibi naming convention kuralları kullanmak yerine `@Configuration` annotasyonuna 
sahip sınıflar üzerinden ApplicationContext’i oluşturmayı sağlıyor. Bu sınıfların metodlarından `@Bean` annotasyonu ile 
işaretlenenlerin döndürdüğü nesneler context’e eklenmektedir. Metodların adları da bean’lerin id’leri olmaktadır.

Tapestry’de servisleri oluşturmak için kullanılan bir başka yöntem de `bind` adlı metodu kullanmaktır. Bu metod static 
bir metod olup parametre olarak bir `ServiceBinder` nesnesi alır. Service Binder’in bind metodu servisin interface’ini 
ve servis için kullanılacak olan concrete class’ı parametre olarak alır. Context içerisinde bu sınıfın bir olgusu yaratılır. 
Buna alternatif bir yöntem olarak ServiceBuilder’lar da kullanılabilmektedir.

ServiceBuilder yapısının Spring tarafında benzeri Spring’deki `FactoryBean` interface’ini implement eden sınıflardır. 
Spring, `FactoryBean` interface’ini implement eden sınıflara farklı muamele gösterir. Bean oluşturma esnasında bu 
interface’in sunduğu `getObject()` metodu çağrılarak dönen nesne bean olarak ApplicationContext’e eklenir.

Spring `@Configuration` sınıflarında da statik metodlar kullanılabilir. Özellikle bean factory post processor bean’lerinin 
statik olması gerekmektedir. Bu tür bean’ler bean definiton’lar üzerinde çalışmakta ve henüz `@Configuration` sınıflarının 
nesneleri yaratılmadan devreye girmektedir.

Spring’de IoC context’i tanımlamak için bazen Application Context ya da Bean Factory isimleri kullanılır. Tapestry’de IoC 
context’ine registry deniyor. Registry içerisinde servis nesneleri yaratılıyor, bağımlılıklar düzenleniyor ve servislere 
ihtiyaç duyulduğunda ihtiyaç duyulan servis, servis id’si ile, registry’den talep edilebiliyor.

## Bağımlılıkların Enjekte Edilmesi (Dependency Injection)

IoC’nin olmazsa olmazı dependency injection için Tapestry’de farklı yöntemler kullanılabilir. JSR-330’un `@Inject` 
annotasyonunun yanı sıra Tapestry’nin kendi `@Inject` ya da `@InjectService` annotasyonları da kullanılabilir. 
Bağımlılıklar service builder metodlara parametre olarak verilebildiği gibi, servislerin constructor’ları üzerinden ya da 
modül sınıfının field’leri üzerinden enjekte edilebilir. Spring’de de benzer mekanizma JSR-330 annotasyonlarının yanı sıra 
Spring’in `@Autowired` annotasyonu ile sağlanabilir.

Bir sonraki yazımızda Scope Yönetimi, bean’ların yaratılması, lazy/eager initialization, AOP kabiliyetleri, proxy’leme ve 
dekorasyon işlemlerinden devam edeceğiz.
