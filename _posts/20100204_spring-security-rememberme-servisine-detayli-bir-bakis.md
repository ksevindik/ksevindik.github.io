# Spring Security RememberMe Servisine Detaylı Bir Bakış

### Spring Security’nin "Beni Hatırla" (Remember-Me) Servisi

Spring Security’nin hazır paket şeklinde sunduğu servislerden birisi de "beni hatırla" (remember-me) servisidir. Bu özellik 
sayesinde form tabanlı kimliklendirme ile giriş yapan kullanıcı, tarayıcısını her açtığında kullanıcı adı ve şifresini tekrar 
girmek zorunda kalmaz. Login ekranında yer alan "Beni Hatırla" seçeneği sayesinde kullanıcının kimlik bilgileri çerez olarak 
bilgisayarında saklanır. Tarayıcı kapatılıp tekrar açıldığında, bu çerez Spring Security tarafından yorumlanır ve kullanıcı 
otomatik olarak sisteme giriş yapar.

Bu özelliği etkinleştirebilmek için login sayfasına bir HTML input elemanı eklenmeli ve bu elemanın ismi `_spring_security_remember_me` 
olarak belirtilmelidir. Bu sayede Spring Security, kullanıcının kimlik bilgilerinin çerez olarak saklanmasını isteyip istemediğini 
anlayabilir.

```html
<input type="checkbox" name="_spring_security_remember_me" accesskey="r" tabindex="3"/>
```

Spring Security’nin 2.x serisinden önce, framework’ün zor bir konfigürasyona sahip olması en büyük eleştirilerden birisiydi. 
Filtre tabanlı yapısı nedeniyle gerekli bean tanımlarındaki eksiklikler, bağımlılıkların yanlış yapılandırılması veya 
filtrelerin yanlış sıralanması sık karşılaşılan problemlerdendi. Ancak, 2.x serisi ile birlikte Spring’in XML namespace 
konfigürasyon özelliği security framework’e dahil edildi. Böylece minimal bir XML konfigürasyonu ile Spring Security 
framework’ünü çalıştırmak mümkün hale geldi.

Varsayılan ayarlar içerisinde "beni hatırla" servisi de mevcuttur. Ancak XML namespace kabiliyeti, konfigürasyonu 
kolaylaştırmasına rağmen framework’ün iç yapısını ve bean ilişkilerini görmeyi zorlaştırarak işleyişi kavramayı güçleştirebilir. 
Bu nedenle, örnek çalışmalar dışında XML konfigürasyonu yerine bean wiring işlemlerini doğrudan yapmayı tercih ediyorum.

"Beni hatırla" servisi XML ile aktive edilse bile çalışabilmek için çeşitli bean tanımları ve ilişkilerine ihtiyaç duyar. 
Bu tanımları bilmek, runtime hatalarını daha kolay tespit etmeyi sağlar. Şimdi bu servisin detaylarına bakalım.

### 1. Beni Hatırla Çerezinin Oluşturulması

Form tabanlı kimliklendirmenin temel bean’i `AuthenticationProcessingFilter`’dır. Bu filtre, kullanıcının kimlik bilgilerini 
aldıktan sonra `AuthenticationManager` vasıtasıyla kimliklendirme işlemini gerçekleştirir. Eğer işlem başarılı olursa, 
kullanıcı istediği sayfaya yönlendirilir. Ancak yönlendirme yapılmadan önce `RememberMeServices` bean’i kullanılarak beni 
hatırla çerezinin oluşturulması tetiklenir. Bu işlem sırasında `loginSuccess()` metodu çağrılır ve çerez HTTP response’a 
set edilir.

### 2. Çerezin Okunması ve Otomatik Kimliklendirme

Beni hatırla servisinin giriş noktası, `RememberMeAuthenticationFilter` bean’idir. Bu bean, `AuthenticationProcessingFilter`’dan 
sonra konumlandırılmalıdır. Gelen her web isteğinde, eğer `SecurityContext` içinde bir `Authentication` nesnesi yoksa, 
`RememberMeServices` bean’inin `autoLogin()` metodu çağrılarak bir `Authentication` nesnesi elde edilmeye çalışılır.

`RememberMeServices` çerezi kontrol eder, geçerliliğini doğrular ve çerezdeki kullanıcı adı bilgisini kullanarak bir 
`Authentication` nesnesi oluşturur. Eğer çerezde bir problem yoksa, `UserDetailsService` aracılığıyla kullanıcı bilgisi 
alınır ve `Authentication` nesnesi oluşturulur. Ancak kullanıcı şifresinin değişmesi gibi durumlarda çerez geçersiz hale 
gelir.

`AuthenticationManager`, `RememberMeAuthenticationProvider` yardımıyla `Authentication` nesnesini doğrular. Eğer key 
bilgilerinde uyumsuzluk varsa `BadCredentialsException` fırlatılır.

### 3. Çerezin Geçersiz Kılınması

`RememberMeServices` sınıfları, `LogoutHandler` arayüzünü implement eder. `LogoutFilter`, logout sırasında `logout()` 
metotlarını çağırarak çerezi iptal eder. Bu sayede kullanıcı, bir sonraki girişte yeniden login yapmak zorunda kalır. 
Ayrıca sistem yöneticisi tarafından key bilgisinin değiştirilmesi tüm çerezleri geçersiz kılar.

### Diğer Noktalar

- **HttpSession Oluşumu:** "Beni hatırla" çerezi ile yapılan kimliklendirme sırasında `HttpSession` oluşturulmazsa, 
- "concurrent session" özellikleri düzgün çalışmayabilir. Bu problemi çözmek için `HttpSessionContextIntegrationFilter`’ın 
- `forceEagerSessionCreation` özelliği `true` yapılabilir.
- **RememberMeServices Türleri:** Spring Security, `TokenBasedRememberMeServices` ve `PersistentTokenBasedRememberMeServices` 
- olmak üzere iki farklı servis sağlar. İlki daha basit bir yaklaşım sunarken, ikincisi daha güvenlidir ve çerezde kullanıcı 
- adını dahi saklamaz.

Remember-me servisi ile ilgili bu bilgiler ışığında, özelliğin detaylarını ve nasıl yapılandırılacağını anlamak mümkündür.
