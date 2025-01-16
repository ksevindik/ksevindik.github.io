# Kotlin Exception'ları ve Spring Transaction Yönetimi

Bilindiği üzere Java programalama dilinde exception’lar checked ve unchecked şeklinde ikiye ayrılır ve geliştirme sürecinde 
genellikle unchecked exception’larla çalışma tercih edilir. Kotlin’in Java programlama pratiği üzerine koyduğu 
iyileştirmelerden birisi de bütün exception’ları unchecked olarak ele almasıdır. Kotlin ile çalışırken exception’ları 
ister Kotlin’in Exception sınıfından, istersek de RuntimeException sınıfından türetelim bu exception’ları fırlattığımız 
yerde ne metot imzasına exception ile ilgili birşey eklememize gerek vardır, ne de ilgili kod bloğunu try-catch bloğuna 
almamız gerekir. Kotlin derleyicisi hiçbir sorun çıkartmaz.

Ancak burada dikkat etmemiz gereken önemli bir nokta vardır. Kotlin kodu bytecode’a derlenirken ilgili Kotlin exception 
sınıfları da Kotlin’deki kotlin.TypeAliases.kt içerisindeki tip eşleme tanımlarına göre Java’daki java.lang.Exception 
veya java.lang.RuntimeException karşılık gelmektedir.

```kotlin
@SinceKotlin("1.1") public actual typealias Exception = java.lang.Exception
@SinceKotlin("1.1") public actual typealias RuntimeException = java.lang.RuntimeException
```

Bu durumda Kotlin tarafında tanımladığımız exception sınıflarımız eğer Kotlin’in Exception sınıfından türüyorlarda JRE 
içerisinde çalışma zamanında java.lang.Exception tipinden türemiş olacaklardır. Peki bunun bize çalışma zamanında ne gibi 
etkileri olabilir?

Bu eşleştirmenin bazı framework’lerin çalışma zamanındaki davranışlarına doğrudan etkisi söz konusu olacaktır. Spring ile 
çalışıyorsanız çok muhtemelen Spring’in veri erişim kabiliyetlerinden yararlanıyorsunuzdur. Spring’in veri erişim 
kabiliyetinin sunduğu dekleratif transaction yönetimini de kullanıyorsunuzdur. Dekleratif transaction yönetiminde sınıf 
düzeyinde veya public metot düzeyinde @Transactional anotasyonları kullanılır. Sınıf düzeyinde kullanılırsa o sınıfın 
bütün public metotları transactional olur. Metot düzeyinde ise sadece ilgili metotlar transactional olur. Bu metotlar 
invoke edildiklerinde ortamda aktif bir transaction yoksa Spring tarafından yeni bir transaction başlatılır, aktif 
transaction varsa da bu transaction ile devam edilir. Metot başarılı sonlandığı vakit ise bu başlatılan transaction commit 
edilir. Eğer metot içerisinden herhangi bir exception fırlatılırsa rollback için exception’ın türüne bakılır. Eğer 
exception unchecked exception ise, yani java.lang.RuntimeException veya ondan türeyen bir exception ise transaction 
rollback yapılır. Ancak, fırlatılan exception checked exception ise, yani java.lang.Exception veya ondan türeyen bir 
exception ise bu durumda transaction rollback değil, commit yapılır. Bu davaranış EJB döneminden Spring’e miras kalmıştır. 
Çoğunlukla da rollback kuralları ile override edilir. Ancak varsayılan durumda işleyiş bu şekildedir.

Şimdi Kotlin exception’larımıza geri dönecek olursak, kaynak kodumuzu yazarken Kotlin’in Exception sınıfından türeyen 
Exception sınıfıları tanımlayıp, bunları metotlarımızdan güzel güzel fırlatmış, o sırada da Kotlin’in bütün exception’ları 
unchecked şekilde ele almasından dolayı bu exception’ları Java’daki RuntimeException gibi düşünüp, bu metotlar çalıştırılırken 
mevcut olan Spring transaction’larının da rollback olacağını varsaymış olabilirsiniz. Ama Kotlin kodunuzu java bytecode’una 
derlediğiniz vakit bu exception’lar JRE’de java.lang.Exception türünden, yani checked exception olarak gözükeceklerinden 
Spring’in transaction yönetim mekanizması da bu exception’lar fırlatıldığında rollback yerine commit işlemini yürütecektir.

Peki çözüm nedir? Çözüm olarak Kotlin exception’larının Java’daki unchecked exception’lara yani java.lang.RuntimeException’lara 
karşılık gelebilmesi için Kotlin tarafında tanımladığımız exception’ları Kotlin’in RuntimeException sınıfından türetmeliyiz. 
Diğer bir çözüm yolu ise Spring’in @Transactional anotasyonunda rollbackFor attribute’u ile ilgili checked exception’lar 
fırlatıldığında da rollback yapması söylenebilir. Bana kalırsa Kotlin kodumuzu bytecode’a derleyip JVM içerisinde çalıştıracak 
isek en doğrusu Exception sınıflarımızı Kotlin’in RuntimeException sınıfından türetmek olacaktır. Tabi yine de zaman zaman 
uygulama içerisinde tanımladığınız Exception sınıflarının hangi sınıftan türetildiğini kontrol etmeyi de ihmal etmeyin. 
Kotlin derleyicisinin bütün exception’ları unchecked exception olarak ele almasından dolayı geliştirme sırasında 
RuntimeException yerine Exception sınıfından türetmek kolaylıkla söz konusu olabilir.