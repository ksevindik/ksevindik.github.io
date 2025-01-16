# Spring Security ile Aynı Kullanıcının Oturum Sayısını Yönetmek

Spring Security kurumsal web uygulamaları için kapsamlı bir güvenlik framework’üdür. Kurumsal web uygulamalarında karşımıza 
çıkan pek çok kimliklendirme ve yetkilendirme ihtiyacına hazır bir çözümü içermektedir. Bu ihtiyaçlardan birisi de aynı 
kullanıcı ile aynı zamanda fakat farklı yerlerden yapılabilecek login sayısının denetlenmesidir. Spring Security bunun 
için sunduğu hazır yapıda iki farklı opsiyon sunar.

- Aynı kullanıcı ile farklı bir yerden login olunduğu vakit, eğer izin verilen oturum sayısı aşılmış ise son login olunan yerde hata vermek,
- Diğerinde ise halihazırda açılmış en eski oturumu sonlandırmaktır.

Spring Security 2.x ile gelen şema desteği sayesinde framework’ü konfigüre etmek oldukça kolaylaşmıştır. Birinci durumu 
gerçekleştirmek için yapmamız gereken `http` elemanı içerisine aşağıdaki XML bloğunu eklemekten ibarettir.

```xml
<sec:session-management> 
     <sec:concurrency-control max-sessions="1" error-if-maximum-exceeded="true"/> 
</sec:session-management>
```

`concurrency-control` elemanı oturum sayısını kontrol eden özelliği framework’de aktive eder. `max-sessions` attribute 
aynı kullanıcı adı ile farklı yerlerden en çok kaç tane login gerçekleştirilebileceğini belirler. Bu sayı aşıldığındaki 
davranış ise `error-if-maximum-exceeded` attribute ile belirlenir. Eğer ikinci durumdaki gibi en son login işlemine izin 
verip en eski oturumu sonlandırmak istersek o zaman `error-if-maximum-exceeded` attribute’unun değerini `false` yapmamız 
yeterlidir.

```xml
<sec:session-management> 
    <sec:concurrency-control max-sessions="1" error-if-maximum-exceeded="false" expired-url="/expired.html"/>
</sec:session-management>
```

İstenirse eski oturum kapatıldığı vakit kullanıcının yönlendirileceği sayfa `expired-url` attribute ile belirtilebilir.

Herkese bol Spring’li günler…
