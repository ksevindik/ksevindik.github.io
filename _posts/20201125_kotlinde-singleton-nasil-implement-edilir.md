# Kotlin'de Singleton Nasıl Implement Edilir?

Java programlama dilinde “static” keyword ile statik sınıflar , statik metotlar ve statik değişkenler tanımlarız. Java’da 
statik olarak tanımlanmış metot ve değişkenlere de, herhangi bir nesneye ihtiyaç duymadan, sınıf düzeyinde erişebiliriz. 
Uygulama genelinde bir sınıftan tek bir nesne ile çalışılmasını garanti eden Singleton örüntüsünü de yine bu statik metot 
ve değişkenler yardımı ile implement ederiz.

```java
public class Utils {
    private Utils() {
    }

    private static final Utils instance = new Utils();

    public static Utils getInstance() {
        return instance;
    }

    public Date getCurrentTime() {
        return new Date();
    }
}
```

Yukarıdaki örnekte, Utils isimli bir sınıf tanımladık. Bu sınıfın constructor’ını da private yaptık. Böylece bu sınıftan 
kendisi dışında bir yerden instance oluşturulmasının önüne geçmiş olduk. (Tabi bazı istisnai durumlar haricinde, ama 
istisnalar kaideyi bozmaz ;-)) Ardından da kendi tipinde static final bir değişken tanımlayıp, bu değişkeni initialize 
ettik ve son olarak da static getInstance() metodu ile dış dünyanın bu değişkene erişmesine izin verdik. İşte size Java’da 
Singleton gerçekleştirimi! Artık Utils sınıfımızın singleton instance’ına istediğimiz her yerden erişip getCurrentTime() 
metodunu çağırabiliriz.

```java
Utils.getInstance().getCurrentTime();
```

Peki Kotlin’de durum nasıl? Kotlin “static” keyword’üne sahip değil arkadaşlar. Ama bu demek değil ki, Kotlin’de Java’daki 
gibi sınıf düzeyinde erişilebilen metot veya değişken tanımlanamaz. Kotlin geliştiricileri bu ihtiyaçlar için farklı yollar 
sunmuşlar.

## Companion Object

Kotlin’de bir sınıfın bütün instance’larının otomatik olarak sahip olacağı tek bir nesne tanımlamak için “companion object” 
kabiliyeti mevcut. Aslında companion object ile tanımlanmış nesnenin kendisi de bir “singleton” dur.

```kotlin
class Utils {
    companion object {
        fun getCurrentTime() : Date {
            return Date()
        }
    }
}
```

Yukarıdaki örneğimizde, Utils sınıfı içerisinde bir companion object ve onun içerisinde de getCurrentTime() isimli bir 
metot tanımladık. Artık Utils sınıfının içerisindeki bu companion object’e ve onun da içindeki getCurrentTime() metoduna 
sınıf düzeyinde erişebiliriz.

```kotlin
val now = Utils.getCurrentTime()
```

Companion object içerisinde metot gibi değişken de tanımlayabiliriz. İşte size Kotlin’de statik metot ve statik değişken 
tanımlama yolu. Companion object’in içerisindeki metot ve değişkenlere doğrudan sınıf ismi ile erişilebileceği gibi 
aşağıdaki gibi, companion object’in ismi ile de erişmek mümkün.

```kotlin
val now = Utils.Companion.getCurrentTime()
```

Bu örnekte, tanımladığımız companion object’e bir isim vermediğimiz için ismi varsayılan durumda “Companion” olarak kabul 
ediliyor. Dolayısı ile companion object’imize kendimiz spesifik bir isim de verebiliriz.

```kotlin
class Utils {
    companion object Instance {
        fun getCurrentTime() : Date {
            return Date()
        }
    }
}
```

Bu durumda companion object’e erişmek için bu ismi kullanmalıyız.

```kotlin
val now = Utils.Instance.getCurrentTime()
```

İsim verdikten sonra da Utils.getCurrentTime() şeklindeki kullanım hala mümkün.

## Class Yerine Object

Kotlin’deki güzel yeniliklerden birisi de eğer bir sınıftan tek bir instance oluşturulmasını istiyorsak, onu 
“class” yerine “object” keyword’ü ile tanımlayabiliriz.

```kotlin
object Utils {
    fun getCurrentTime() : Date {
        return Date()
    }
}
```

Bu durumda artık Utils sınıfından uygulama içerisinde yeni bir nesne yaratamayacağız. Tek nesnemiz olacak ve o da Utils
ismi ile erişilecek, içerisindeki metotlara da yine aynı şekilde erişmeye devam edeceğiz. Alın size diğer bir singleton 
oluşturma yöntemi 🙂

## Private Constructor

Yok, “ben Java’daki singleton oluşturma tarzından memnundum”, derseniz, tabi o da mümkün.

```kotlin
class Utils private constructor() {
    
    companion object {
        
        private val instance = Utils()
        
        fun getInstance() : Utils {
            return instance
        }
    }

    fun getCurrentTime() : Date {
        return Date()
    }
}
```

Bu örnekte, Java’daki gibi constructor’ımızı private yaptık. Böylece dışarıdan Utils sınıfından herhangi bir nesne 
oluşturamaz hale geldik. Ardından companion object tanımlayıp, içerisinde de Utils sınıfından bir değişken tanımlayıp, 
bunu initialize ettik. Bunu yapabildik, çünkü companion object Utils’in içerisinde tanımlı. Bu değişken tanımı ise 
Java’daki “private static final” a karşılık gelmiş oldu. Daha sonra da yine companion object içerisinde bu instance’ı 
döndürecek de bir metot ekledik. Bu metot ise Java’daki “public static Utils getInstance()” metodunun karşılığı. 
Sonuç olarak yine bir singleton elde etmiş olduk.

Benim en çok hoşuma giden yöntem ikinci olarak bahsettiğim, class yerine object ile Utils sınıfını (nesnesini desek daha 
doğru olacak sanırım) tanımladığımız yöntem. Bununla kısa ve öz biçimde uygulama genelinde erişilebilecek tek bir Utils 
instance’ı elde etmiş olduk. Siz hangi yöntemi tercih ederdiniz?
