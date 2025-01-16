# equals, hashCode ve toString icin pojomatic

equals ve hashCode metodlarının doğru ve hatasız biçimde kodlanması, yer aldığım projelerde üstünde durduğum temel 
konulardandır. Her ne kadar basit görünseler de pek çok programcı arkadaşımız hala bu temel metodları nasıl kodlayacaklarını 
tam olarak bilemiyorlar. Bunun yanı sıra her bir sınıf için bu metodları benzer rutinler şeklinde yazmak bir süre sonra 
sıkıcı bir hal alabiliyor. Oysa annotasyonlar yardımı ile deklaratif biçimde bu metodların projeniz için bir sorun olmaktan 
çıkarılması çok kolaydır. İşte [pojomatic](http://pojomatic.sourceforge.net/pojomatic/)’te tam bunun gibi bir şey. 
Aslında geliştirdiğim çözüme çok benzemekle birlikte, hep üzerinde çalışmayı düşündüğüm ama bir türlü el atamadığım field 
düzeyinde annotasyonları da destekleyerek işini yapabiliyor. Bakmanızı tavsiye ederim.
