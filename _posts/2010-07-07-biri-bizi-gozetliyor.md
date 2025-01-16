# Biri Bizi Gozetliyor

Bir süredir tasarım örüntüleri hakkında yazılar yayımlıyorum. Bazı arkadaşlar Java dilinde tasarım örüntülerinin 
gerçekleştirimi için ne tür hazır yapıların olduğunu merak ettiklerini belirtiyorlar. Gelen sorular doğrultusunda bu 
yazıda Observer örüntüsünün Java’daki karşılığından da bahsetmeye çalışacağım. GUI programlama yapanlar, özellikle awt 
ve Swing kullananlar bu örüntüyü bilerek veya bilmeyerek zaten uzun zamandır kullanıyorlar. Herhangi bir UI bileşeni 
üzerinde meydana gelen olayların (event), kullanıcı inputları gibi, ilgili diğer nesnelere bildirilmesi ve bu nesnelerde 
olaylarla ilgili işlem yapılması GUI programlamadaki en temel aktivitelerden biridir. Örneğin JButton bileşeni üzerinde 
meydana gelen buton tıklama olayının uygulama içerisinde ele alınabilmesi için ActionListener nesneleri JButton nesnesi 
ile ilişkilendirilir. Meydana gelen tıklama olayları kayıt olan ActionListener nesnelerine ActionEvent ile bildirilir. 
Ayrıca GUI frameworklerin temelinde prezentasyonla bileşenlerin, uygulama verisinden ayrılması söz konusudur. Bir veri 
modeli üzerinde meydana gelen değişikliklerin birden fazla ilgili UI bileşeni tarafından takip edilmesi ve değişiklikler 
söz konusu olduğunda bunların UI bileşenlerine yansıtılması gerekmektedir. Bu sayede aynı verinin değişik gösterimleri 
sağlanabilir.

Observer örüntüsü, olayların kaynağı ile bu olaylardan haberdar olmak isteyen nesnelerin arasındaki ilişkiyi düzenler. 
İki kilit olgu vardır. “Subject” olayların kaynağıdır. Birden fazla “Observer” ise Subject üzerinde meydana gelen 
olaylardan haberdar olmak için kayıt olur. Subject üzerinde meydana gelen herhangi bir değişiklik sıra ile kayıtlı olan 
Observer nesnelerine bildirilir. Observer nesneleri de kendilerine iletilen olay nesnesinden ve Subject üzerinden gerekli 
bilgilere erişerek kendi durumlarını günceller. Aslında bu örüntünün diğer bir adı da “publish-subscribe”dır. Peki Java, 
awt ve swing kısımlarında bu örüntüyü kullandırtmak dışında örüntüyü implement etmek için bize ne sunuyor? `java.util` 
paketinde Observer-Observable örüntüsünü implement etmek için gerekli yapılar mevcuttur. Subject rolüne sahip olacak 
nesnenizi `java.util.Observable` sınıfından türettiğiniz takdirde, Observer nesnelerinin kayıtlarının takibi ve meydana 
gelen olayların kayıtlı Observer nesnelerine iletilmesi için gerekli kod yapıları bu sınıf içerisinde hazır olarak 
gelmektedir. Observer rolüne sahip sınıfların ise `java.util.Observer` arayüzünü implement etmeleri yeterli olacaktır.

Son olarak bu örüntü ile ilgili küçük bir uyarı. Örüntünün özellikle GUI nesnelerinde kullanımı sırasında hafıza 
sızıntılarına karşı dikkatli olunmalıdır. Observer olarak kayıtlı nesnelerin uygulama içerisinde kullanımdan kalkmalarına 
ve kendilerine herhangi bir yerden referans verilmemesine rağmen Subject nesnesine yapılan kayıt yüzünden ortaya çıkan 
referans dolayısı ile çöp toplayıcı tarafından Observer nesnelerinin hafıza alanının serbest bırakılması mümkün olmayacaktır. 
Bu durum özellikle Observer arayüzünü implement eden view nesneleri için oldukça ihtimal dahilindedir. Java uygulamalarında 
bu tür hafıza sızıntıları sık rastlanan hatalardandır. Zamanında benzer hafıza sızıntıları ile karşı karşıya kalmış biri 
olarak diyorum ki; amman dikkat!…
