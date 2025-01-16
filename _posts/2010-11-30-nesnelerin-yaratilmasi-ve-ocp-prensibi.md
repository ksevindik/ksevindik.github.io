# Nesnelerin Yaratılması ve OCP Prensibi

Bir önceki yazımda CustomerOrder constructor’ı içerisinde nesnenin initialization’ı dışında ProjectElement ile 1:M 
parent-child ilişkinin kurulmasından bahsetmiştim. Ardından da exists metodunu ProjectElement’e eklemeye kalkarsak ne 
gibi bir problemle karşılaşırız diyerek yazıyı sonlandırmıştım.

Problem new CustomerOrder(...) ile yeni bir nesne oluşturduğumuz anda ProjectElement nesnesinin child set’inin içerisine, 
oluşturulan CustomerOrder nesnesinin eklenmesinden ötürü, exists metodunun CustomerOrder nesnesini input parametre aldığı 
takdirde, hiçbir şekilde belirli bir businessKey ve client değerine sahip bir CustomerOrder’ın ProjectElement child 
setinde olup olmadığını tespit edememesidir. Exists metodu her seferinde belirtilen CustomerOrder nesnesinin ProjectElement’in 
child seti içerisinde olduğunu dönecektir.

Görüldüğü üzere CustomerOrder constructor’ının SRP prensibine uymaması sisteme yeni bir özellik eklerken beklenmedik bir 
durumun ortaya çıkmasına neden oldu. Oysa CustomerOrder constructor’ı sadece nesne initialization’ını yapıp sonlansa idi, 
exists metodunun signature’ında CustomerOrder’ın kullanılması herhangi bir problem teşkil etmeyecekti.

Burada hemen aklımıza şöyle bir çıkış yolu gelebilir. Exists metodunun görevi belirli bir businessKey ve client değerine 
sahip CustomerOrder nesnesinin ProjectElement’in child set’inde olup olmadığını tespit etmek ise, metodun signature’ı 
CustomerOrder almak yerine businessKey ve client değerlerini alacak biçimde tanımlanabilir.  
Bu durumda exists metodu görevini yerine getirmiş ve sorun çözülmüş gibi görünüyor. Ancak farz edelim ki, bir süre sonra 
CustomerOrder’ın kimlik tanımında bir eksik olduğu fark edilsin. Örneğin, String x property’sinin de CustomerOrder’ın 
tekilliğini belirlemede rolü olduğu anlaşılsın. Bu durumda exists metodunun signature’ında da değişiklik yapmak gerekecektir. 
Signature’daki bu değişiklik ise exists metodunu kullanan diğer modüllerin de yeniden derlenmelerini gerektirecektir. Bu 
durum bariz biçimde Open Closed Principle (OCP) olarak bilinen temel bir OO prensibin ihlali demektir.

OCP, sisteme eklenecek yeni bir özelliğin mevcut yapıda bir değişiklik yapmadan, sistemin extend edilerek yapılmasını 
hedefler. Oysa exists metodunun signature’ında CustomerOrder yerine CustomerOrder’ın tekilliğini belirleyen property’leri 
kullanarak hem CustomerOrder’ın encapsulation’ını bozmuş olduk, hem de CustomerOrder’ın kimliğinde meydana gelen 
değişikliklerin doğrudan exists metoduna ve bu metoda bağımlı sistemin diğer kısımlarına da sirayet etmesine neden olduk.

Bu örnekten de görüldüğü gibi temel OOP prensiplerine dikkat etmemiz sistemimizin ilerleyen safhalarında ortaya çıkacak
yeni gereksinimlere ve değişikliklere karşı daha sağlıklı cevap verebiliyor olması için oldukça önemlidir. Başlangıçta 
belki CustomerOrder constructor’ı içerisinde ihlal edilmesi çok önemli bir şey gibi durmuyordu. Sonuçta tek satırlık bir 
işlem olarak, sistemin geneline etki edecek şekilde problemler yaratması pek de olası gözükmüyor olabilir. Ancak küçük 
görünen işlerin büyük sonuçlar doğurabileceği hiçbir zaman unutulmamalıdır. Atalarımızın dediği gibi, bir mıh bir nal, 
bir nal bir at kurtarır…
