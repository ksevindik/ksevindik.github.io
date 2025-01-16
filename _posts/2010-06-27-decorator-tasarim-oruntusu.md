# Decorator Tasarim Oruntusu

Decorator tasarım örüntüsü ile aslında GOF’un kitabından önce tanıştım. Peter Van Der Linden’in *Beyond Java 1.1* isimli 
bir kitabı vardı. O zamana kadar tam olarak anlamakta zorlandığım Java I/O paketinin mantığını bu kitap sayesinde bir 
çırpıda öğrenivermiştim. Aslında Decorator, GOF’da her nedense “yapısal örüntüler” kategorisinde gösterilmiş. Ancak 
kendisi bir nesnenin davranışını çalışma zamanında değiştirmek için kullanılan bir örüntüdür. Bu açıdan pek çok yazar 
Decorator’ü davranışsal olarak sınıflamayı daha doğru bulur.

Her örüntüyü ortaya çıkaran ve şekillenmesine sebep olan belirli bir takım çevresel şartlar vardır. Decorator için bunlar, 
eldeki bazı nesnelerin davranışlarına çalışma zamanında bir takım ilaveler yapılması, ancak bu davranış genişletmesinin 
nesnenin ait olduğu tip genelinde yapılmamasıdır. I/O stream gerçekleştirimlerinde sıklıkla Decorator örüntüsünü görmek 
mümkündür. Verinin belirli bir stream’den okunması gerekmektedir. Bu stream dosya, hafıza veya network olabilir. Ancak 
bu okumanın çalışma zamanında değişik koşullara göre davranış olarak zenginleştirilmesi de gerekmektedir. Örneğin, bir 
durumda dosyadan okuma yaparken tampon alan kullanılarak okumanın yapılması, diğer bir durumda ise okumanın satır satır 
yapılması, üçüncü bir durumda ise hem tampon bellek kullanılması hem de satır satır okuma yapılması gerekebilir.

Eğer her bir ilave davranış için temel stream sınıflarından yeni sınıflar türetme yolu izlenecek olursa, bu kısa bir 
sürede bir nevi “kambriyen patlaması”na benzeyecektir. Burada izlenmesi gereken yol, davranış çeşitlemesinin kalıtım ile 
değil, composition ile nesne düzeyinde sağlanmasıdır. Decorator sınıflar, wrap edecekleri nesneler ile aynı arayüze sahip 
olurlar. Asıl nesneye gelene kadar ardı ardına birden fazla değişik Decorator nesne uygulanarak istenen davranış 
kombinasyonları ortaya çıkartılabilir. Bu sayede istemci tarafı, asıl nesnenin herhangi bir dekorasyona tabi tutulduğundan 
bihaberdir.

Yukarıdaki örneğe geri dönersek, tampon alan kullanma, satır satır okuma gibi ilave davranış özelliklerinden istenildiği 
kadarı bir araya getirilerek asıl stream nesnesi üzerinden okuma yapılabilir. Decorator sınıfının zaaflarından birisi, 
aslında onun temel gereksinimi olan hedef nesneler ile aynı arayüze sahip olmaktır. Eğer bu arayüzde tanımlı çok fazla 
metot varsa veya arayüz sıklıkla değişiyorsa, üretilen bütün Decorator sınıflarında da bu metotların teker teker implement 
edilmesi ve değişikliklerin yansıtılması gerekmektedir. Aslında bu davranışların pek çoğu asıl nesneye delegasyon yapmaktan 
ibaret olacaktır. Decorator sınıflarının sayısı arttıkça daha derin bir problem teşkil edebilecek böyle bir durumun önüne 
geçebilmek için *Abstract Decorator* sınıfı faydalı olabilir. Ancak Java için single inheritance gerekliliği bazen bunu 
imkansız kılabilir.
