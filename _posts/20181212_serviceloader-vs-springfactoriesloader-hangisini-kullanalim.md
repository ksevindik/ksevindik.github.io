# ServiceLoader vs SpringFactoriesLoader, Hangisini Kullanalım?

Java’nın ServiceLoader kabiliyeti, Java 1.6’dan bu yana sunulan, ancak pek de bilinmeyen, basit bir kabiliyettir. Biraz 
da Spring’in gölgesinde kalmıştır diyebiliriz. Sonuçta ServiceLoader ile sunulan kabiliyeti de kapsayan ve çok daha 
fazlasını sunan bir IoC container’ınız varsa uygulama içerisinde farklı servis gerçekleştirimlerini dinamik olarak yükleme 
ve kullanma ihtiyacı için Spring ApplicationContext içerisinde bean tanımlamak çok daha tercih edilesi bir yaklaşımdır. 
Yine de nesneleri ApplicationContext içerisinde bean olarak tanımlamanın uygun veya mümkün olmadığı bir takım senaryolar 
için ServiceLoader tercih edilebilir.

Nedir ServiceLoader ile yapılan şey? ServiceLoader ile çalışırken öncelikle yaratılacak olan servis nesnelerinin sınıflarının 
sahip olması gereken interface tanımlanmalıdır. Sonuçta ServiceLoader bu interface’i parametre alarak sistemdeki servis 
gerçekleştirimlerini bulup, yaratıp uygulamanın kullanımına sunacaktır.

```java
ServiceLoader serviceLoader = ServiceLoader.load(FooService.class);
```

ServiceLoader.load(FooService.class) ile FooService arayüzüne sahip servis gerçekleştirimlerini classpath’den bulup yüklemeyi 
sağlayacak yeni bir ServiceLoader nesnesi yaratmış oluruz.

Peki, ServiceLoader, FooService gerçekleştirimlerini nasıl bulur? Bunun için ServiceLoader, classpath’deki 
META-INF/services/com.example.FooService şeklinde oluşturulmuş dosyaları tespit etmektedir. Bu dosyalar classpath’de 
birden fazla da olabilir. Her bir dosyanın içerisinde servis sınıflarının FQN şeklinde isimleri yer almalıdır.

```manifest
com.example.demo.my.MyFooService
com.example.demo.your.YourFooService
```

Her bir dosyada da birden fazla gerçekleştirim yer alabilir. Her servisin gerçekleştiriminin FQN’si ayrı bir satırda 
tanımlanır.

```java
Iterator iterator = serviceLoader.iterator();
```

serviceLoader.iterator() metodu ile mevcut servis dosyalarını lazy biçimde parse ederek servis nesnelerini oluşturacak bir 
Iterator elde edilir.

```java
while(iterator.hasNext()) {
    FooService fooService = iterator.next();
}
```

iterator.hasNext() ve next() metotları ile de servis sınıfları yüklenir, ardından default no arg constructor’ları çağrılarak 
servis nesneleri yaratılır ve uygulamaya dönülür. Artık uygulama FooService instance’ları üzerinde istediği işlemi yapabilir.

Eğer uygulama farklı bir servis arayüzü üzerinden başka servis nesnelerini elde edecek ise bu durumda da yeni servis arayüzü 
için META-INF/services dizini altında yeni dosyalar tanımlanıp, benzer biçimde bu servis arayüzü üzerinden servis nesnelerinin 
oluşturulması söz konusudur.

Şimdi de biraz Spring’in SpringFactoriesLoader kabiliyetine bakalım.SpringFactoriesLoader, Java’nın ServiceLoader’ı ile 
hemen hemen aynı işlemi yapmaktadır. Ancak tek farkı birden fazla servis arayüzü için ayrı ayrı servis dosyaları tanımlamak 
yerine, bütün servis gerçekleştirimlerini classpath’de META-INF/spring.factories isimli bir dosya içerisinde toplamaya 
olanak sağlamasıdır. Spring Framework’ün bu sınıfı kendi dahili kullanımı için olsa bile, rahatlıkla Spring enabled bir 
uygulamada da kullanılabilir.

```properties
com.example.demo.FooService=com.example.demo.my.MyFooService,com.example.demo.your.YourFooService
com.example.demo.BarService=com.example.demo.BarServiceImpl
```

spring.factories dosyası içerisinde servis gerçekleştirimleri servis arayüzü key, servis gerçekleştirimleri de virgüllerle 
ayrılmış biçimde FQN’li isimleri ile value olacak biçimde tanımlanmalıdır.

```java
List services = SpringFactoriesLoader.loadFactories(FooService.class, FooService.class.getClassLoader());
```

SpringFactoriesLoader.loadFactories() metodu ile belirtilen servis arayüzüne veya sınıfına karşılık gelen sınıflar 
yüklendikten sonra, default no arg constructor’ları çağrılarak servis instance’ları elde edilir ve uygulamaya bir liste 
şeklinde dönülür.

Kısacası Spring kullanan projelerde Java’nın ServiceLoader mekanizması ile ayrı servis dosyaları üzerinden çalışmaya çok 
da lüzum yoktur. Spring’in SpringFactoriesLoader mekanizması servis tanımlarının tek noktadan yönetimi açısından bize 
daha pratik bir yol sunmaktadır.