# Prototype Örüntüsü

Hemen hepimizin projelerimizde sıklıkla Factory Method ve Builder örüntüleri ile karşılaşıyoruz. Zaman zaman da, özellikle 
belirli bir platforma veya konfigürasyona özgü nesne grubu oluşturmaya ihtiyaç duyulduğu durumlarda Abstract Factory 
örüntüsünü de kullanıyoruz. Ancak Prototype örüntüsü hakkında aynı şeyi söylemek zor. Özellikle Java ile uğraşan bir 
yazılımcı olarak bu örüntüyü neredeyse doğrudan hiç implement ettiğimi hatırlamıyorum.

Peki bu neden olabilir diye düşünürken, bunun nedeni ile ilgili bir şeyler yakalamak ümidi ile GOF’a geri dönüp bir bakmak 
istedim. Prototype, kabaca bir nesne üzerinden kopyalama ile yeni nesnelerin oluşturulmasını sağlıyor. Buradaki güzellik, 
nesnelerin oluşturulması sürecinde eğer belirli birtakım adımların da yürütülmesi söz konusu ise, halihazırda oluşturulmuş 
bir nesneden yeni bir nesnenin klonlanması ile bu adımların uygulanmasına ihtiyaç duyulmadan nesnelerin kolayca yaratılmasıdır. 
Eğer istenirse, duruma göre dinamik olarak klonlamada kullanılan nesne yani prototipin değiştirilmesi ile üretilen nesnelerin 
de değiştirilmesi sağlanabilir. İnsan, hemen Java Object sınıfının sağladığı `clone` metodunu da hatırlayınca bunun Java 
için çok uygun bir örüntü olduğunu düşünüyor. Ancak Josh Bloch’un *Effective Java Programming Language Guide* kitabında 
`clone` metodu ile ilgili maddeyi okuyan birisi, bu metodu implement etmeden önce en az iki defa düşünmelidir.

Aslında sorunun cevabı yine GOF’un içerisinde bulunuyordu. Sonuçlar kısmında, Class bilgisinin normal diğer nesneler gibi 
bir nesne olarak ele alındığı dillerde, örneğin Java, Class nesnesi kendiliğinden Prototype örüntüsünün yerini almaktaydı. 
Bu durumda bu örüntü, biraz da C++ gibi sınıf bilgisini çalışma zamanına taşımayan dillerin kullanıldığı durumlarda daha 
çok implement ediliyordu. `Class` sınıfındaki `newInstance()` metodunu hemen her zaman kullanıyoruz. Bunun yanında RTTI 
ile herhangi bir sınıfın `Constructor` nesnelerine erişip bunların `newInstance(...)` metotları ile default no-arg 
constructor dışındakilerle de nesnelerin oluşturulması mümkün. İşte size built-in Prototype!
