# Ayrı Bir Repository Katmanı Şart mı? (2)

Daha önceki bir [yazımda](http://www.kenansevindik.com/ayri-bir-repository-katmani-sart-mi/) ayrı bir repository katmanı 
şart mı? diye sormuş ve ORM teknolojilerinin ve JPA’nın popülerleşmesi ile CRUD tabanlı bir takım uygulamalarda yazılım 
geliştiricilerin ayrıca bir DAO/Repository arayüzü oluşturmanın çok da fazla işlevi olmadığını savunarak, doğrudan JPA 
EntityManager üzerinden servis katmanında veri erişim işlemleri gerçekleştirmeye yöneldiklerinden bahsetmiştim. Bu yazımda 
bu tür bir pratiğin muhtemel dezavantajlarından bahsetmeye çalışacağım.

Bu tür bir pratiğin en temel zaafı, uygulamanın veriyi saklama ve veriye erişim için ilişkisel veritabanı yöntemine 
doğrudan bağımlı hale gelmesine neden olmasıdır diyebiliriz. Her ne kadar JPA API’de bize bir arayüz üzerinden çalışmayı 
sağlasa da, JPA API’nin işlevi uygulamayı ORM üreticilerinin gerçekleştirimlerinden izole kılmaya çalışmaktır. Oysa ki 
DAO/Repository arayüzleri arkasına gizlenmiş ayrı bir veri erişim katmanı uygulama için bugün ilişkisel yarın ise tamamen 
farklı, örneğin graph temelli, başka bir veri erişim ve saklama yöntemi ile çalışmayı kolaylaştıran bir fayda sağlamaktadır. 
Aksi durumda ise servis katmanı doğrudan spesifik bir teknolojiye (JPA/Hibernate) bağımlı kılınmaktadır. Hatta 
`OpenEntityManagerInViewFilter`/`OpenSessionInViewFilter` gibi bazı ORM çözümlerinin spesifik problemleri için geliştirilen 
çözümler bu bağımlılığın servis katmanı dışında controller ve presentation katmanlarına dahi sızmasına neden olabilmektedir.

Servis katmanında doğrudan JPA API ile çalışmanın bir diğer zaafı ise birim testlerinde ortaya çıkmaktadır. Ayrı bir 
DAO/Repository arayüzü ile çalışırken daha üst bir düzeyde ve tek bir metot çağrısı ile encapsule edilebilecek bir davranış, 
doğrudan JPA API ile çalışıldığı vakit `EntityManager`, `TypedQuery`, `Query` gibi birkaç ayrı yapı ve bunlarla ilgili 
genellikle sayıca tek bir metot çağrısından daha fazla sayıda metot çağrısı ile ifade edilmiş olduğundan, birim testleri 
içerisinde de servis katmanının bu yapılarla etkileşiminin mocklanması ve ilgili senaryonun testi sırasında bu mock 
nesnelerin sergilemesi istenen davranışların bu mock nesnelere öğretilmesi birim testlerin özellikle eğitim bölümlerinin 
çok daha “verbose” bir hale dönüşmesine neden olmaktadır. Birim testlerindeki bu kalabalıklık ve alt düzeyde daha fazla 
yapı ile etkileşimin söz konusu olması da teste tabi tutulan sınıf ve davranış üzerinde meydana gelen değişikliklerle 
birlikte testin de çok daha kolay bir biçimde kırılgan hale gelmesine kapı aralamaktadır.

Özetle söylemek gerekirse ayrı bir DAO/Repository katmanı oluşturmaktan kaçınarak kazanılan zaman ve iş gücü projenin 
biraz ilerleyen safhalarında, farklı gereksinimlerin ortaya çıkması, davranışların çeşitlenmesi ve değişmesi ile avantajını 
çok çabuk biçimde yitirebilmektedir.

Bu noktada akla Repository katmanını manuel oluşturmak yerine dinamik olarak üretmeyi sağlayan Spring Data gibi çözümler 
kullanmak da gelebilir. Hatta bu çözümlerin sunduğu kabiliyetlerden etkilenerek, CRUD temelli uygulamalarda bu sefer de 
servis katmanını tamamen tasfiye ederek, Controller katmanından doğrudan Repository katmanı ile erişerek çalışmak da 
tercih edilebilmektedir. Gelin bir sonraki yazımızda da bu konu üzerinde duralım.
