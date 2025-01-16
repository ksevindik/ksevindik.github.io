# 5. TASOD Çalıştayı Yapıldı

Bedir Tekinerdoğan’nın gayretleri ile her sene düzenlenen Ulusal İlgiye Yönelik Yazılım Geliştirme Çalıştayı’nın 5.si 
geçen hafta Bilkent Üniversitesi’nde yapıldı. Bu çalıştayların çoğuna katılan birisi olarak sunumlardan oldukça 
yararlandığımı belirtebilirim. Gün geçtikte ilgiye yönelik yazılım geliştirme yöntemlerinin kurumsal uygulama geliştirmenin 
temel bir parçası olduğunu görmek sevindirici. Etkinlikteki sunumlara [buradan](http://www.cs.bilkent.edu.tr/Bilsen/TAOSD-2011) 
erişebilirsiniz.

Etkinlikteki sunumlara baktığımızda artık ilgiye yönelik yazılım geliştirme pratiklerinin ve tasarım örüntülerinin yaygın 
biçimde kullanıldığını, uygulamaları geliştirirken karşılaşılan, özellikle ortakatman (middleware) olarak tabir edilen 
gereksinimleri karşılamak için aspect’lerin etkin biçimde kullanıldığını görebiliyoruz.

Sunumlar sırasında aldığım bazı notlara tekrar baktığımda ilgimi çeken birkaç konuyu buradan sizinle paylaşmak istiyorum:

- **Tasarım örüntüleri**, özellikle GOF pattern’ları geliştiriciler arasında hızla yaygınlaşıyor. Örüntüler vasıtasıyla tasarım kararları çok daha kolay ve doğru biçimde ifade edilebiliyor. Geliştiriciler arasındaki iletişimi oldukça kolaylaştırıyor.
- **Proxy, strategy, observer, publish-subscribe, state, façade, singleton** gibi örüntüler değişik uygulamalarda karşımıza sıkça çıkabiliyor.
- Uygulamalar genellikle **katmanlı mimariye** sahip biçimde geliştiriliyor ve **MVC mimarisel örüntüsü** uygulama mimarilerinin temel referans noktasını oluşturuyor.
- **Input validasyonu**, güvenlik denetimleri, monitor işlemleri, lokalizasyon (I18N), sıralama gibi konular aspect-oriented programlama ile en sık çözüm getirilen ortakatman ihtiyaçları arasında yer alıyor.
- Bunların yanı sıra **veri madenciliği**, tekrarlayan kayıtların temizlenmesi, tam sürüm sistemlerin demo sürümlerinin elde edilmesi, mesaj filtreleme ve arşivleme, istatistik bilgilerin elde edilmesi gibi konularda da aspect-oriented programlama yöntemleri kullanılabiliyor.
