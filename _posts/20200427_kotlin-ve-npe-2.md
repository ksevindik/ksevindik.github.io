# Kotlin ve NPE (2)

Bir önceki [yazımızda](http://www.kenansevindik.com/kotlin-ve-npe/) başladığımız Kotlin’de NPE konusunu incelemeye devam 
ediyoruz. Peki önceki yazımızda bahsettiğimiz durumların dışında başka hangi durumlarda NPE hatası ile karşılaşırız?

NPE hatası alabileceğimiz durumlardan birisi de inheritance’ın kullanıldığı bir senaryodur. Kotlin’de nesneler yaratılırken, 
değişkenler sınıf hiyerarşisine göre initialize edilir. Hiyerarşide her bir sınıfa karşılık gelen nesne alanları construct 
edilirken, bu işlem üst sınıflardan alt sınıflara doğru sıra ile devam eder. Bu durumda üst sınıfa ait bir constructor 
içerisinde bir şekilde alt sınıfa ait bir değişkene erişmeye kalkarsak, alt sınıfın değişkenleri daha initialize edilmediği 
için NPE hatası ile karşı karşıya kalırız.

Aşağıdaki kod örneğinde Foo ve Bar isimli iki sınıf görüyorsunuz. Bar sınıfı Foo sınıfından türüyor ve printMessage() 
metodunu da override ediyor.

```kotlin
open class Foo {

    constructor() {
        printMessage()
    }
    
    open fun printMessage() {
        
    }
}

class Bar:Foo() {
var name:String = "bar"

    override fun printMessage() {
        println(name.length)
    }
}

fun main() {
    val b = Bar()
}
```

Buradaki printMessage() metodu Foo constructor’ı içerisinde çağrılan bir metot. Eğer Bar sınıfı içerisinde bu metot 
override edildiğinde, içerisinde Bar sınıfında tanımlanmış herhangi bir değişkene erişmeye kalkarsak, ki örneğimizde name 
attribute’una erişmeye çalışıyoruz, NPE hatasını alırız. Çünkü Bar nesnesi yaratılırken önce, Foo sınıfına karşılık gelen 
bir nesne alanı oluşturuluyor ve bunun içi initialize ediliyor. Bu aşamada daha Bar nesnesine ait attribute’lar 
uninitialized vaziyette duruyorlar. Bar sınıfına karşılık gelen nesne alanının oluşturulması ve initialize edilmesi ise 
ancak Foo nesnesinin construction’ından sonra gerçekleşecek. Ama biz Foo constructor’ı içerisinde printMessage() metodunu 
çağırıyoruz, printMessage() metodu da override edildiği için Bar sınıfındaki gerçekleştirimi çağrılıyor ve burada da Bar 
sınıfındaki name attribute’una erişim söz konusu. İşte tam bu noktada da NPE hatası alıyoruz.

Sanırım bu örnek bile “inheritance is evil” söylemi için yeterli argüman olacaktır. 🙂

Gelelim diğer NPE case’imize. Burada ise ise Kotlin içerisinden Java metotlarını çağırdığımız bir durum söz konusu. 
Diyelim ki Foo isimli bir Java sınıfımız olsun ve name metodu da String değer döndürsün, ama NULL değer return etsin.

```java
public class Foo {
    public String name() {
        return null;
    }
}
```

Eğer Kotlin projemiz içerisinde bu Foo sınıfından bir nesneyi alıp name() metodunu çağırırsak ve bu değeri de optional 
olmayan bir yerden dönmeye çalışırsak, çalışma zamanında yine bir NPE hatası ile karşılaşırız.

```kotlin
class Bar(val foo:Foo) {
    fun name():String {
        return foo.name()
    }
}
```

Yukarıdaki kod örneğinde gördüğünüz gibi Bar Kotlin sınıfındaki name () metodu da String değer döneceğini tanımlamış, 
ama dikkat ederseniz NULL değer dönmeyecek biçimde tanımlanmış (String? değil). Bu durumda foo.name() metot çağrısından
NULL değer dönme ihtimalini Kotlin derleyicisi, derleme aşamasında null olma durumu tespit edemediği için bizi bir null 
kontrolüne zorlamaz. Biz de dönen değeri olduğu gibi name() metodundan döndürdüğümüz için çalışma zamanında foo.name() 
metot çağrısından NULL değer döndüğü vakit NPE hatası ile karşı karşıya kalırız.

Bu noktada özellikle Java kütüphanelerine eriştiğimiz yerlerde bizim explicit olarak NULL kontrolü yapmamız çalışma 
zamanında ortaya çıkabilecek hataların önüne geçmemize yardımcı olacaktır.
