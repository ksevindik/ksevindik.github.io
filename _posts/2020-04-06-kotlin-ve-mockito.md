# Kotlin ve Mockito

TDD ile programlama yapan Java yazılım geliştiricilerin en temel araçlarından birisi de Mockito mock kütüphanesidir. 
Mockito yardımı ile arayüz ve sınıflardan mock ve stub nesneler oluşturarak, bunları eğittikten sonra test ettiğimiz 
nesneye enjekte ederek birim testlerimizi gerçekleştiririz.

İlk iki yazımızdan sonra Kotlin ile geliştirilen yazılım projelerinde Mockito kütüphanesi ile çalışırken karşılaştığımız 
en temel problemi sanırım tahmin etmekte zorlanmadınız 🙂 Evet, sınıflardan mock nesneler oluşturmak istediğimiz vakit 
bu sınıfları ve mock’layacağımız metotları “open” yapmak zorundayız.

```kotlin
class Foo {
    fun message(): String {
        return "foo"
    }
}

class Bar(private val foo: Foo) {
    fun message(): String {
        return foo.message() + " bar"
    }
}

class FooTests {
    @Test
    fun testMessage() {
        //given
        val foo = Mockito.mock(Foo::class.java)
        val bar = Bar(foo)
        Mockito.doReturn("mock foo").`when`(foo).message()
        //when
        val message = bar.message()
        //then
        MatcherAssert.assertThat(message, Matchers.equalTo("mock foo bar"))
        Mockito.verify(foo).message()
    }
}
```

Yukarıdaki basit örneğimizde Bar sınıfından oluşturulan nesneye dependency olarak Mockito ile Foo sınıfından oluşturulmuş 
mock nesneyi vermeye çalıştığımızda aşağıdaki gibi bir hata alırız.

```error
Cannot mock/spy class com.example.Foo
Mockito cannot mock/spy because :
final class
org.mockito.exceptions.base.MockitoException:
Cannot mock/spy class com.example.Foo
Mockito cannot mock/spy because :
final class
```

Dolayısı ile Foo sınıfını “open” olarak işaretlememiz gerekir. Ama sadece sınıf düzeyinde “open” kullanmak yetmez. Çünkü 
metotlarda, varsayılan durumda “final” olarak işaretlenmiştir, metotların da mock’lanabilmesi için “open” olarak 
tanımlanması gerekir. Aksi takdirde metot mock’lanamayacak ve asıl metot içeriği çalıştırılacaktır.

```kotlin
open class Foo {
    open fun message(): String {
        return "foo"
    }
}
```

Spy işlemi için de durum aynıdır. Eğer test edilen nesnenin diğer metotlarından birini mock’lamak istiyorsak, yada 
bağımlılıklardan birini spy nesne olarak oluşturma durumu söz konusu ise yine ilgili sınıfı ve mock’lamak istediğimiz 
metodunu “open” yapmamız gerekecektir.

Gelin şimdi örneğimizde ufak bir değişiklik yapalım ve spy durumunu da yakından inceleyelim.

```kotlin
open class Foo {
    open fun message(): String {
        return "foo"
    }
}

class Bar(private val foo: Foo) {
    fun message(): String {
        return foo.message() + " bar at ${currentTime()}"
    }

    fun currentTime(): Long {
        return Date().time
    }
}

class FooTests {
    @Test
    fun testMessage() {
        //given
        val foo = Mockito.mock(Foo::class.java)
        Mockito.doReturn("mock foo").`when`(foo).message()
        val bar = Mockito.spy(Bar(foo))
        Mockito.doReturn(1L).`when`(bar).currentTime()
        //when
        val message = bar.message()
        //then
        MatcherAssert.assertThat(message, Matchers.equalTo("mock foo bar at 1"))
        Mockito.verify(foo).message()
        Mockito.verify(bar).currentTime()
    }
}
```

Örneğimizde Bar sınıfına o anki güncel zamanın long gösterimini dönen currentTime() isimli bir metot ekledik ve message() 
metodundan da currentTime() metodunu çağırdık. Testimizde de oluşturduğumuz bar nesnesini Mockito.spy() ile spy yaptık ve 
currentTime() metodunu da eğiterek, o anki güncel zaman yerine 1 değerini dönmesini söyledik. Eğer kodumuzu bu şekilde 
çalıştırırsak yukarıdaki hatanın aynısını alırız. Dolayısı ile hata almamak için Bar sınıfını da open yapmalıyız. Ancak 
sadece sınıfı open yapmak yetmez, bunun yanında currentTime() metodunu da open olarak işaretlememiz gerekir. Aksi takdirde 
sadece Bar sınıfını open yaparak testimizi çalıştırdığımızda bu sefer de aşağıdaki gibi bir hata ile karşılaşırız.

```error
Unfinished stubbing detected here:
-> at com.example.FooTests.testMessage(FooTests.kt:32)
E.g. thenReturn() may be missing.
Examples of correct stubbing:
when(mock.isOk()).thenReturn(true);
when(mock.isOk()).thenThrow(exception);
doThrow(exception).when(mock).someVoidMethod();
Hints:
missing thenReturn()
you are trying to stub a final method, which is not supported
you are stubbing the behaviour of another mock inside before 'thenReturn' instruction is completed
```

Sonuçta, çözüm olarak hem Bar sınıfını, hem de mock’ladığımız currentTime() metodunu birlikte open yapmalıyız.

```kotlin
open class Bar(private val foo: Foo) {
    fun message(): String {
        return foo.message() + " bar at ${currentTime()}"
    }

    open fun currentTime(): Long {
        return Date().time
    }
}
```
