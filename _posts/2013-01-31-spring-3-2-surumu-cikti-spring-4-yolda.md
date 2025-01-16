# Spring 3.2 Sürümü Çıktı, Spring 4 Yolda…

Aslında Spring 3.2.0 sürümü Aralık 2012’nin ortalarında çıktı. Biz de projelerimizde Spring 3.2 ile çalışmaya başladık. 
Spring’in farklı sürümler arasındaki geçişleri yönetme başarısı burada da devam ediyor. Spring 3.x serisi içerisinde 
herhangi bir problem yaşamadan upgrade’ler yapabiliyorsunuz. Hatta bu geçişler 1.x’den 2.x’e, daha sonrasında 3.x’e de 
hemen hemen aynı kolaylıkta oldu diyebilirim. Herhangi bir framework’ün, özellikle de kurumsal Java uygulamalarında bu 
kadar yaygın kullanılan bir framework’ün sürümler arasında uyumluluk göstermesi çok önemli ve proje ekibi için de güven 
verici diyebiliriz. Ocak 2013’ün son haftasında 3.2.1 bakım sürümü ile Spring’in 3.2 serisinin “kemale” erdiğini 
söyleyebiliriz. Zaten bu yönde bir sinyal de Jürgen Höller’in blogunda Spring 4 anonsu ile gelmişti.

Evet, Spring için artık yol haritası belli oldu. Bir sonraki sürümde Java 8’in ve JEE 7 spesifikasyonunun ana 
teknolojilerinin desteklenmesi başlıca hedefler olarak deklare edildi. JEE 7 ile gelen bu teknolojik yeniliklerden bizce 
en önemlileri JPA 2.1 ve Servlet 3.1 spesifikasyonları olarak görülüyor. Tabi bu yol haritasındaki diğer bir dikkate değer 
konu başlığı da Groovy desteği. Groovy’nin uçtan uca kurumsal uygulama geliştirme dili olarak kullanılmasını sağlayacak 
adımlar Spring 4 ile birlikte atılacak. Groovy’nin diğer dinamik dillerle kıyaslandığında en öne çıkan yanı Java diline 
sintaktik benzerliği diyebiliriz. Geliştiriciler için fazladan bir efor sarf etmeden Java platformu içerisine entegre 
dinamik bir dile araç setlerinde sahip olmak güzel bir şey. Dinamik ve JVM dillerinin gün geçtikçe popülerleştiği ortamda 
Spring’in tercihini Groovy’den yana yapması dikkate değer ve bakalım Spring kullanıcıları için bu tercih neler getirecek…

Spring 4’ün yol haritasında dikkate değer diğer bir nokta ise “conversation” desteği ile ilgili yine herhangi bir madde 
olmaması. Seam ve Webflow çekişmesinin yaşandığı günlerde gündeme gelen ve Spring’in içerisine dahil edilmesi beklenen 
“conversation scope” kabiliyeti uzun zamandır erteleniyor. Aslında Hibernate’in lazy ilişkileri ele alma yönteminden 
kaynaklanan bu ihtiyaç, UI teknolojilerindeki gelişmeler ve yeni nesil RIA framework’leri de göz önüne alındığında gün 
geçtikçe önemini yitiriyor diyebiliriz. Spring JIRA’da bu konu ile ilgili issue’ya baktığımızda 4.0 Backlog’a dahil 
edildiğini görüyoruz. Bu da bize Spring ekibi için bu konunun artık o kadar da “top priority” olmadığını işaret ediyor.
