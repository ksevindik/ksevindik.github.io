# Eclipse ve Kubuntu Arasında Kopyala-Yapıştır Problemi

Uzun bir aradan sonra dizüstü bilgisayarımda Ubuntu dağıtımı ile Linux kullanmaya başladım. Genel olarak Ubuntu’dan oldukça 
memnun olmama rağmen geliştirme ortamım ile ilgili bazı problemlerle de karşı karşıya kalmadım değil. Problemlerin çoğu 
Eclipse ile Gnome ve Kubuntu desktop’ları arasında ortaya çıkıyor. Ubuntu’yu ilk kurduğumda Gnome desktop ile çalışmaya 
başladım. Aslında gnome desktop hoşuma gitmesine rağmen Eclipse’in bir süre sonra bütün desktop’a da etki edecek biçimde 
tepki vermez hale gelmesi ve buna yönelik uygun bir çözüm bulamamam beni Kubuntu’ya yönlendirdi. Gnome’a alışmış birisi 
olarak KDE ilk dönemde biraz ters gelmesine rağmen alışmam da çok uzun sürmedi. Ancak burada da Eclipse geliştirme ortamı 
ile ilgili problemler tamamen ortadan kalkmadı. İşte bunlardan birisi de Eclipse içerisinde java editor’de kopyala yapıştır 
işleminin sağlıklı biçimde gerçekleşmemesi. Ctrl+C ile kopyalama yaptıktan sonra, başka bir alanı tekrar Ctrl+C ile 
kopyalamaya çalıştığınız vakit, Ctrl+V ile en son olan değil bir önceki kopyalanan metin yapıştırılıyor. Kesme işleminde 
de benzer bir durum söz konusu oluyor. Kopyalama işlemi iki kere üst üste Ctrl+C yapıldığı vakit ise düzgün çalışıyor. 
Problemin KDE’deki Klipper ile Eclipse arasındaki bir bug veya uyum sorunu olduğunu tahmin etmek hiç zor değil. Ancak 
Klipper’deki ayarlardan ilk bakışta problemi ortadan kaldıracak ayarı kestirmek pek mümkün olmuyor. Problem iyice can 
sıkıcı hale geldiğinde etrafta bir “googling” yapmak şart oldu. Yaptığım araştırmada tam da benim yaşadıklarımı etraflı 
biçimde inceleyen ve alternatif çözümler öneren bu blog yazısı ile karşılaştım. Çözüm önerileri arasında Klipper ayarlarından 
“Prevent empty clipboard” seçeneğinin kaldırılması benim açımdan en iyi çözüm oldu diyebilirim.
