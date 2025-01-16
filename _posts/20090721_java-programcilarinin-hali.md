# Java Programcılarının Hali
Geçenlerde Yakov Fain’in 5 java developer ile yaptığı mülakatlarla ilgili [yazısını](http://java.sys-con.com/node/1040135) 
ve gelen yorumları ilgiyle okudum. 
Fain, görüştüğü kişilerin kendilerini 5-8 yıllık tecrübeli denebilecek Java geliştiriciler olarak tanımladıklarını 
belirtiyor. Ancak bu yazılımcıların yapabildiklerinin genel manada `Spring`, `Hibernate` gibi frameworklerin xml 
dosyalarının konfigürasyonu, java nesnelerinin veritabanına map edilmesi ve bunların sistemde birbirleri ile entegrasyonu 
ile ilgili ayarlardan ibaret olduğunu belirtiyor. Yazıya gelen yorumlardan bazılarında da `Hibernate`’deki lazy problemine 
çözüm üretirken, lazy ihtiyacının ne olduğunu, bunun nasıl çalıştığını tam manası ile kavrayamamış programcılardan bile 
bahsediliyor.

Zaman zaman çalıştığım şirketteki iş görüşmelerine bende katılıyorum. Malesef yukarıda tasvir edilen tablo bizim için de 
geçerli. Çoğu yazılım geliştirici arkadaşımız kendilerini `Java`, `Spring`, `Hibernate` gibi konularda tecrübeli ve 
deneyimli olarak nitelemelerine rağmen, görüşmelerde çoğunlukla bu konularla ilgili temel bazı sorularıma tatmin edici 
cevaplar alamadığımı belirtmeliyim.

Bazı arkadaşların hemen, mülakatlarda `Spring`, `Hibernate` gibi teknolojiler üzerinde çok durulmaması gerektiğini, 
önemli olanın temel mühendislik ve programlama kabiliyetlerini sorgulamak olduğunu dillendirdiklerini duyar gibiyim. 
Salt teknoloji odaklı bir sorgulamayı bende tasvip etmiyorum, ve bu tür kütüphane ve frameworklerin sağlam bir eğitime 
sahip yazılım geliştiriciler tarafından makul bir zaman içerisinde öğrenilip, projelerde başarılı biçimde uygulanabileceğini 
kabul ediyorum.

Ancak bu gibi framework ve kütüphanelerde `java` ve yazılım dünyasında karşılaşılan problemlere üretilen çözümlerin genel 
yapıları, uygulanan tasarım kalıpları, iyi pratikler ve dil kalıpları hakkında konuşarak mülakat sürecinde karşımızdaki 
kişinin mühendis ve teknik kimliği, bilgi ve deneyimleri hakkında sağlıklı bir fikir sahibi olmak mümkündür. Burada dikkat 
edilmesi gereken husus mülakatta bu framework ve kütüphanelerin kullanım biçimleri, spesifik API’leri düzeyinde konuşmaktan 
uzak durmaktır.
