# Mockito'da Mock ve Spy Nesnelerin Eğitilmesi

Bir önceki yazımızda Mockito kütüphanesinin Kotlin projelerinde kullanılması üzerinde durmuştuk. Bu konuya devam edeceğiz. 
Ancak bu yazımızda Kotlin özelinden çıkıp Mockito’nun kullanımı ile ilgili daha genel bir konudan bahsetmek istiyorum.

Bilgidiğiniz üzere, Mockito kütüphanesi, mock ve spy nesnelerin hedef metotlarının eğitilmesi için iki farklı kullanım 
biçimi sunmaktadır. Bunlardan ilki, daha sık kullanılan aşağıdaki;

```kotlin
Mockito.when(methodCall).thenReturn(value)
```

“when method invoked then return value” yazım biçimidir. Diğeri ise biraz daha az kullanılan,

```kotlin
Mockito.doReturn(value).when(mock).methodCall
```

daha çok void metotlar çağırıldıklarında, `doNothing()` diyerek birşey yapmamaları istendiğinde kullanılan, 
**“return value when mock method invoked”** yazım biçimidir.

Yukarıdaki iki kullanım biçiminden ilkinin daha çok tercih edilmesi muhtemelen metot return değeri ile ilgili derleme 
zamanında tip kontrolü yapılmasına imkan sağlanmasıdır. İkinci kullanım biçiminde bu mümkün olmayıp, programcının 
yanlışlıkla return değeri olarak metot return tipi ile uyumsuz bir değer girmesi mümkündür. Derleme zamanında yakalanamayan 
bu hata çalışma zamanında ortaya çıkacaktır.

Yukarıdaki farklı iki kullanım biçimi `Mockito.mock()` ile oluşturulan mock nesneler için fark yaratmamaktadır. Ancak 
`Mockito.spy()` ile spy yapılan nesneler için durum farklıdır. Spy nesnelerin metotları eğitilirken ilk yöntem kullanılırsa 
eğitim sırasında asıl metodun çağrılması söz konusu olacaktır. Bu nedenle spy yapılan nesneler için ikinci yöntem tercih 
edilmelidir. Ben testleri yazarken hem mock, hem de spy nesnelerin her ikisininde eğitilmesinde ikinci yöntemi kullanmaktan 
yanayım.