# Kotlin ve Hibernate

Bir süredir Udemy’deki microservice çalışmalarımızda programlama dili olarak Kotlin’i kullanıyoruz. Hepinizin bildiği 
gibi Kotlin, Java üzerine geliştirilmiş JVM tabanlı bir programlama dili. Sunduğu iyileştirmeler ve değişiklikler büyük 
çapta “syntactic sugar” olarak nitelendirilebilir. IntelliJ IDEA ile birlikte (sanırım efektif olarak şu an sadece bu IDE 
ile çalışılabiliyor) kullanıldığında ve mevcut Java kütüphaneleri de Kotlin kodu içerisinde rahatlıkla kullanılabildiğinden 
dolayı, Java programlama geçmişi olanlar için bazı noktalarda kod geliştirme sürecini daha hızlı ve akıcı hale getirdiğini 
söylemek mümkün.

Kotlin’in Java dili üzerine getirdiği değişikliklerin en önemlilerinden birisi de sınıfların ve sınıflardaki bütün 
metotların varsayılan olarak “final” olarak tanımlanmasıdır. Sanırım JetBrains ekibi “inheritance is evil” mottosunun çok 
etkisinde kalmış olacak ki, böyle bir karar almışlar.

Tabii günümüzde geliştirilen hemen hiçbir kurumsal uygulama sıfırdan, sadece dilin sunduğu bazı API’lerle geliştirilmiyor. 
Elimizde Spring, Hibernate, Vaadin gibi başarısı kanıtlanmış pek çok framework ve kütüphane mevcut, ve biz yazılım 
geliştiriciler olarak çoğunlukla çözümlerimizi bu tür framework ve kütüphaneler üzerine bina etmeyi tercih ediyoruz.

Ancak Spring, Hibernate gibi framework’lerin pek çoğu en temel kabiliyetlerini inheritance üzerine kurulu “proxy örüntüsü” 
ile hayata geçirmektedir. Örneğin, Hibernate’in en temel özelliklerinden biri olan “lazy loading” kabiliyeti için kullandığı 
yöntemlerden birisi proxy örüntüsüdür. Lazy loading için diğer yöntem ise “bytecode enhancement”dır, ancak varsayılan 
yöntem proxy yöntemidir. Hibernate, uygulamanın bootstrap aşaması sırasında entity sınıfları Javassist kütüphanesi yardımı 
ile extend ederek proxy sınıflar üretir ve lazy M:1 ve 1:1 ilişkilerde, ya da persistence context üzerinden entity referansı 
elde ederken bu proxy sınıfları kullanır. Tabii bunu yapabilmesi için temel şart entity sınıfların ve metotlarının final 
olmamasıdır. Eğer entity sınıf final modifier ile işaretlenmiş ise bu durumda Hibernate sessizce bu sınıf için proxy 
üretmekten vazgeçmektedir. Dolayısıyla bu sınıfın geçtiği yerlerde de lazy kabiliyeti kullanılamamaktadır. Davranış 
“eager loading”e dönmektedir.

İşte Kotlin, sınıf inheritance ihtiyacının kaçınılmaz olduğu bu gibi durumlar için “open” anahtar kelimesini sunmaktadır. 
Sınıf düzeyinde open anahtar kelimesi ile Kotlin sınıfları inheritance’a izin vermektedir. Ancak sınıfları open ile 
inheritable yapsanız bile metotları da aynı şekilde alt sınıflarda override edilebilmeleri için yine tek tek open modifier 
ile işaretlemeniz gerekecektir.

```kotlin
@Entity
open class Person(open var firstName:String, open var lastName:String) {
    @Id
    @GeneratedValue
    open var id:Long? = null
}
```

Kotlin tarafında sunulan, “data class” olarak adlandırılan sınıflar ise Hibernate ile çalışmak için hiç uygun değildir. 
Çünkü data class’ların başına open anahtar kelimesini ekleyerek inheritable yapmak mümkün değildir.

JetBrains ekibi, yazılım geliştiricilerin kod içerisinde bütün entity sınıfları, attribute’ları ile birlikte “open” ile 
işaretlemek zorunda kalmamaları için derleme aşamasında bunların hepsini “open” olarak işaretlenmesini sağlayacak bir 
plugin geliştirmiştir. “allopen plugin”i sayesinde kod içerisinde entity sınıfları ve attribute’larını işaretlemeden 
derleme aşamasında ilgili sınıflar, attribute’ları ile birlikte open yapılmaktadır. Aşağıdaki örnek gradle build script’i 
içerisinde allopen plugin’inin nasıl ayarlanacağını göstermektedir.

```gradle
plugins {
  id "org.jetbrains.kotlin.plugin.allopen" version "1.3.71"
}
allOpen {
    annotation("javax.persistence.Entity")
    annotation("javax.persistence.MappedSuperclass")
    annotation("javax.persistence.Embeddable")
}
```

Hibernate’in entity sınıflarla ilgili bir diğer minimum gereksinimi ise en azından paket görünürlük düzeyinde de olsa bir 
tane “default no arg constructor” tanımlanmasıdır. Ancak Kotlin ile çalışırken sınıf constructor’larından bir tanesi 
“primary constructor” olarak kabul edilmekte ve tanımlanan diğer constructor’ların da bu primary constructor’a invokasyon 
yapması istenmektedir.

```kotlin
@Entity
class Person(var firstName:String, var lastName:String) {
    
    constructor():this("Dummy First Name","Dummy Last Name")
    
    @Id
    @GeneratedValue
    var id:Long? = null
}
```

Oysa Hibernate veritabanından dönecek bir Person kaydını yüklemek için runtime’da reflection kullanarak bu default no arg 
constructor ile nesneyi oluşturup, attribute’ların değerlerini teker teker field level access ile veya setter metotları 
çağırarak populate etmektedir.

Burada da Kotlin geliştiricilerinin imdadına yine JetBrains ekibi yetişmiş ve “noarg plugin”i sunmuşlardır. noarg plugin’i 
de benzer şekilde sınıflar için default no arg constructor’ını derleme aşamasında eklemektedir.

```gradle
plugins {
  id "org.jetbrains.kotlin.plugin.noarg" version "1.3.71"
}
noArg{
    annotation("javax.persistence.Entity")
    annotation("javax.persistence.MappedSuperclass")
    annotation("javax.persistence.Embeddable")
}
```

JetBrains ekibi JPA/Hibernate kullananlara bir iyilikte daha bulunmuşlar ve “kotlin-jpa plugin”i de sunmuşlardır. noarg 
plugin’i üzerine kurulu kotlin-jpa plugin’i @Entity, @MappedSuperclass ve @Embeddable anotasyonuna sahip sınıflar için 
no arg constructor tanımını otomatik olarak yapmaktadır.

```gradle
plugins {
  id "org.jetbrains.kotlin.plugin.jpa" version "1.3.71"
}
```

Not: kotlin-jpa plugin’i noarg için bu anotasyonlarla ilgili tanımları gereksiz kılsa da gradle build script’iniz içerisinde 
allopen plugin tanımına hâlâ ihtiyacınız olduğunu hatırlatmak isterim.
