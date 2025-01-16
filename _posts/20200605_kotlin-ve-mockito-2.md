# Kotlin ve Mockito (2)

Kotlin ve Mockito yazı dizimizin ilkinde Kotlin içerisinde Mockito ile mock nesneler oluştururken veya nesnelerimizi spy 
yaparken Kotlin sınıflarımızın open olması gerektiğinden bahsetmiştik. Kotlinde Mockito kütüphanesi ile çalışırken
karşılaşacağımız en temel sorunlardan bir diğeri ise Mockito.any() veya ArgumentCaptor.capture() gibi metotların NULL 
döndürmesidir.

Eğer mock nesnemizde input argüman olarak NULL olmayan bir değer bekleyen herhangi bir metodu train etmek için yukarıdaki 
bu metotları çağırırsak, test metodumuzu çalıştırdığımızda ArgumentMatchers’ın doğru yerde kullanılmadığını belirten 
aşağıdaki gibi bir hata mesajı ile karşı karşıya kalırız.

```error
You cannot use argument matchers outside of verification or stubbing.
Examples of correct usage of argument matchers:
when(mock.get(anyInt())).thenReturn(null);
doThrow(new RuntimeException()).when(mock).someVoidMethod(anyObject());
verify(mock).someMethod(contains("foo"))
This message may appear after an NullPointerException if the last matcher is returning an object
like any() but the stubbed method signature expect a primitive argument, in this case,
use primitive alternatives.
when(mock.get(any())); // bad use, will raise NPE
when(mock.get(anyInt())); // correct usage use
Also, this error might show up because you use argument matchers with methods that cannot be mocked.
Following methods cannot be stubbed/verified: final/private/equals()/hashCode().
Mocking methods declared on non-public parent classes is not supported.
```

Örneğin, aşağıdaki gibi not-null String input argüman bekleyen Foo sınıfımızdaki foo metodunu herhangi bir String değer 
ile çağrıldığında çalışacak biçimde train etmeye kalktığımızda bu hata ile karşılaşırız.

```kotlin
open class Foo {
    open fun foo(s: String) {
        println(s)
    }
}

class FooTest {
    @Test
    fun testFoo() {
        val mockFoo = Mockito.mock(Foo::class.java)
        Mockito.doNothing().`when`(mockFoo).foo(Mockito.any())
        mockFoo.foo("abc")
    }
}
```

Bunun nedeni Kotlin’deki NULL kontrolüdür. Mockito.any() metodundan NULL değer dönüldüğü ve foo(String) metodumuz da 
input argüman olarak not-null bir String değer ile çalışacak biçimde tanımlandığı için çalışma zamanında böyle bir hata 
alırız.

Bu problemi bu senaryoya özgü aşmak için generic tiplerde null kontrolü ile ilgili bu issue‘da belirtilen bir açığı 
kullanabiliriz. Bunun için generic tip dönen bir metot tanımlayıp döndümüz null değeri bu generic tipe cast edersek sorun 
ortadan kalkacaktır.

```kotlin
class FooTest {
    @Test
    fun testFoo() {
        fun <T> castNull(): T = null as T

        val mockFoo = Mockito.mock(Foo::class.java)
        Mockito.doNothing().`when`(mockFoo).foo(castNull())
        mockFoo.foo("abc")
    }
}
```

Ama mock nesnemizin metodunun invokasyonunu verify etmeye kalkarsak veya daha kompleks senaryolarda metot input 
argümanlarını capture edip incelemek istersek bu null cast işleminin Mockito kütüphanesi tarafından ilgili Mockito.any() 
veya ArgumentCaptor.capture() metot çağrıları içerisinde yapılıyor olması gerekmektedir.

Allah’tan bu noktada Kotlin içerisinde Mockito kütüphanesinin bu tür ArgumentCaptor nesneleri ile kullanımı için 
geliştirilmiş basit bir wrapper [kütüphane](https://github.com/nhaarman/mockito-kotlin) imdadımıza yetişiyor.

```kotlin
class FooTest {
    @Test
    fun testFoo() {
        val argCaptor = argumentCaptor<String>()
        val mockFoo = Mockito.mock(Foo::class.java)
     Mockito.doNothing().`when`(mockFoo).foo(argCaptor.capture())
        mockFoo.foo("abc")
        Mockito.verify(mockFoo).foo(argCaptor.firstValue)
    }
}
```

nhaarman’ın Mockito-Kotlin kütüphanesi de aslında capture() metodu içerisinde Mockito’nun ArgumentCaptor nesnesini wrap 
etmenin yanı sıra, dönülen null değer üzerinde bizim yaptığımız castNull() işlemini gerçekleştirerek çalışmaktadır.