# Spring WebFlow 1.0’dan 2.0’a Geçiş
Bir süredir projelerimizde `Spring WebFlow 1.0.x`’i kullanmaktaydık. `1.0.x`’i kullanmaya başladığımız dönemlerde Spring 
WebFlow ekibi de `2.0.x` için hummalı bir çalışma içine girmesine rağmen `2.0.x`’in ilk dönemleri üretim hattındaki 
uygulamaların ihtiyaçlarını karşılayacak kalitede değildi, milestone sürümleri arasında ciddi mimarisel ve APIsel 
değişiklikler meydana geliyordu. Bu nedenle `1.0.x`’den başlamayı uygun gördük.

Ancak şu an için `Spring WebFlow`, `2.0.4` sürümü ile istenen olgunluğa ulaşmış durumda. `2.0.x` ile birlikte webflow 
kullanan uygulamalar için önemli gelişmeler sağlanmaktadır. Örneğin Hibernate kullanan web uygulamaları için 
`LazyException` problemine kökten bir çözüm getiriliyor. Flow, state ve transition düzeyinde güvenlik kabiliyeti 
sağlanıyor. Bunun yanı sıra JSF kullanan web uygulamaları MVC pattern’ı açısından daha sağlıklı bir yapıya kavuşuyor. 
Yine webflow’un JSF ile birlikte kullanılabilirliği noktasında pek çok yeni özellik sunuluyor.

Bizde eski projelerimizde olmasa da yeni projelerimizde bundan böyle `Spring WebFlow 2.0.x` ile devam etmeye karar verdik. 
Bunun için de `1.0.x`’den `2.0.x`’e geçiş aşamasında bütün projelerimiz tarafından ortak kullanılan middleware 
çözümlerimizde bazı değişikliklere gidildi. Bu geçiş süreci ile ilgili öne çıkan ve dikkat edilmesi gereken noktaları 
ayrıntılı biçimde kayıt altına almaya çalıştım. Bu çalışmanın `2.0.x`, `1.0.x`’e göre hangi noktalarda farklılaşıyor, 
yeni özellikleri hakkında bilinmesi gereken püf noktalar gibi konularda hem `Spring WebFlow 1.0.x`’den `2.0.x`’e geçmeye 
çalışanlar için hem de `Spring WebFlow 2.0.x` kullanmayı düşünenler için yararlı olacağını düşünüyorum.

İlgili dokümana [buradan](http://blog.harezmi.com.tr/spring-webflow-1-0dan-2-0a-gecis/spring-webflow-1-0dan-2-0a-gecis-2/) erişebilirsiniz.
