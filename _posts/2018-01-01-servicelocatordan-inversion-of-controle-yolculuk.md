# ServiceLocator'dan Inversion of Control'a Yolculuk
Harezmi Bilişim Çözümleri olarak 7 seneden fazla bir zamandır `Spring Application Framework` ile ilgili eğitimler 
veriyoruz. `J2EE`’nin ilk dönemlerinde kurumsal Java uygulamaları geliştirilirken kullanılan `ServiceLocator` 
örüntüsünün nasıl `IoC` veya `Dependency Injection`’a doğru evrildiğini anlamanın `Spring Application Framework`’ün özünü 
ve temel felsefesini anlamak için çok faydalı olduğunu düşündüğümüz için de eğitimelerimizde `Spring`’i anlatmaya bu konu 
üzerinden başlıyoruz. Aşağıdaki makalede kod örnekleri ile birlikte `ServiceLocator` örüntüsünden `IoC`’ye doğru geçiş 
sürecini ve `ServiceLocator` nesnesinin nasıl `Spring BeanFactory` nesnesine ve `ApplicationContext`’e evrildiğini 
anlattık. Yazının sadece `Spring` kullananlar veya kullanmaya başlayacaklar için değil bütün yazılım geliştiriciler için 
ortaya çıkan framework ve teknolojileri anlamak için faydalı olacağını düşünüyoruz. İyi okumalar.

`ServiceLocator`’dan `Inversion of Control`’e Yolculuk ([pdf](files/20180101_servicelocatordan-inversion-of-controle-yolculuk.pdf))
