# Kurumsal Java Dünyası ve Container Kavramı

Kurumsal Java dünyasının “Container” kavramı ile ilk tanışması sanırım Java Servlet teknolojisi ve Apache Tomcat ile 
olmuştur. O günden bu güne kadar da hayatımıza JSP Container’dan EJB Container’a, JSF Container’dan Spring Container’a 
pek çok “Container” girmiştir. Peki “Container” ne demektir ve bütün bu Container’lar ne iş yaparlar? Aralarındaki 
benzerlikler ve farklar nelerdir?

“Container”, belirli bir takım arayüz veya sınıfları `extend` ederek yazılmış veya belirli bir takım Java anotasyonları 
ile işaretlenmiş veya bütün bunların dışında hiçbir özel arayüz veya sınıftan türemeyip, herhangi bir anotasyon dahi 
barındırmadan yazılmış olan Java sınıflarından nesneler oluşturan, bu nesnelerin yaşam döngüsünü ve aralarındaki 
bağımlılıkları yöneten, bu nesnelere ilave bir takım özellikler ve davranışlar kazandıran yapılara verilen genel bir 
isimdir. Gelin şimdi hep birlikte bu tanıma göre Servlet Container, JSP Container, EJB Container, JSF Container ve Spring 
Container ne iş yaparlar? Java nesnelerimize ne tür kabiliyetler kazandırırlar? Bunların kısaca üzerinden geçelim.

Kurumsal Java dünyasının, biraz evvel de belirttiğim gibi, ilk Container’ı Servlet Container’dır. Peki Servlet Container’lar 
ne yaparlar? Servlet Container, Java Servlet API’sine göre yazılmış Java sınıflarından Servlet nesneleri oluşturarak ve 
bu Servlet nesnelerinin `DataSource` gibi bir takım bağımlılıklarını karşılayarak, istemcilerden gelen HTTP web isteklerini 
işlemeyi ve bu isteklere uygun HTTP yanıtları dönmeyi sağlar. Kısacası Servlet Container, Kurumsal Java’nın dinamik web 
programlama yapmayı sağlayan en temel bileşenidir. Diğer bütün Container’lar bir şekilde Servlet Container ile ilişkilidir.

Ancak o zamanki adı ile J2EE, şimdiki adı ile Java EE dünyasında sadece Servlet teknolojisi ile dinamik web programlama 
yapmaya kalktığımızda ön yüz ve arka tarafın net biçimde birbirinden ayrılamadığı, başka bir ifade ile presentation ve 
controller katmanlarının iç içe geçtiği, bakımı zor çözümler ortaya çıktığı gözlendi. Bu nedenle de Java geliştiricileri 
bize Servlet teknolojisinin üzerine kurulu JSP (Java Server Pages) teknolojisini hediye ettiler ve bununla birlikte de 
hayatımıza JSP Container da girmiş oldu. Peki JSP Container’ın sunduğu kabiliyetler nelerdir?

JSP öncesi dönemde Servlet teknolojisi ile çalışırken, Servlet Java sınıflarının içerisine HTML arayüz kodları yazıyorduk. 
Bu arayüzlerde bir takım değişiklikler yapmak için de Java Servlet sınıflarımızı değiştirmek, derlemek ve web uygulamalarımızı 
yeniden deploy etmek durumunda kalıyorduk. JSP teknolojisi ile birlikte HTML arayüz kodlarının yazımı JSP sayfalarına 
kaydırılmış oldu. İstemciden gelen web istekleri JSP sayfaları tarafından ele alınarak, arka planda Servlet nesneleri ile 
oluşturulmuş controller katmanına havale edilmeye başlandı. Artık HTML kodlarını doğrudan JSP sayfalarının içerisinde yazıp, 
Servlet sınıflarımızı tekrardan derleyip, deploy etmeden arayüz değişikliklerini devreye alabilir hale geldik.

Biraz evvel belirttiğim gibi JSP teknolojisinin arka planı ise tamamen Servlet teknolojisine dayanmaktadır. JSP sayfalarımız 
çalışma zamanında uygulama sunucusunun sahip olduğu bir JSP `compiler` ile Servlet koduna dönüştürülür, bu Servlet kodu da 
derlenerek Java Servlet sınıfı elde edilir, daha sonra da bu Servlet sınıfından bir Java nesnesi oluşturularak ilgili JSP 
sayfasına gelen HTTP web isteklerinin bu Servlet nesnesi tarafından ele alınması sağlanır. Peki bütün bu süreci kim yönetir 
derseniz tahmin edebileceğiniz gibi cevap JSP Container’dır. Aslında JSP Container da özel bir Servlet Container’dır. 
Ancak görevi normal bir Servlet Container’ın ötesinde JSP sayfalarını derlemek, onlardan Servlet sınıfları elde etmek, bu 
Servlet sınıflarını yükleyip onlardan Servlet nesneleri oluşturmak ve HTTP web istekleri geldiğinde onların devreye girmesini 
sağlamaktır.

Şimdi de kısaca EJB Container nedir? ve ne iş yapar(dı)? Ona bakalım. Yapar kelimesinin sonuna (dı) ekledim, çünkü günümüzde 
hala EJB yazan var mıdır? Çok merak ediyorum. Her neyse, o yıllarda (1999 öncesini kast ediyorum) Servlet ve JSP teknolojileri 
ile kurumsal web uygulamalarının sunum ve controller katmanlarını ele alır hale gelmiştik, ama servis ve veri erişim 
katmanlarını geliştirmek için elimizde henüz bir çözüm yoktu. İşte bu aşamada hayatımıza EJB (Enterprise Java Beans) kavramı 
girdi. EJB teknolojisi ile dağıtık ortamda çalışacak “business component”lerin geliştirilmesi ve bu bileşenlerin JSP/Servlet 
web veya Swing/AWT gibi desktop Java client’ları üzerinden kullanılması amaçlanmıştır. İşte EJB Container da bu business 
component’lerin yaratılması, bu bileşenlerin ihtiyaç duyduğu bir takım bağımlılıkların sağlanması, bu bileşenler üzerinden 
gerçekleştirilen veri erişim işlemlerinde transaction yönetiminin sağlanması, thread yönetimi, güvenlik gibi pek çok ihtiyacı 
karşılayan yapıdır.

Burada size yeri gelmişken bir de “Web Container” kavramından bahsetmek istiyorum. J2EE teknolojileri ile geliştirilmiş 
kurumsal Java uygulamalarını deploy edip çalıştırmak için uygulama sunucularına ihtiyaç duyulur. Bu uygulama sunucuları 
içerisinde Servlet, JSP ve EJB Container’lar çalıştırılmaktadır. O zamanlar mevcut olan WebLogic, Websphere, JBoss gibi 
uygulama sunucuları bütün bu Container’lara sahipken, Apache Tomcat, Jetty gibi sunucular ise sadece Servlet ve JSP 
Container içermekteydiler. Servlet ve JSP Container’lar da topluca “Web Container” adı altında ifade edilir, Tomcat ve 
Jetty gibi sunuculara da onlar “application server” değil, “Web Container”, çünkü EJB Container sağlamıyorlar denirdi. 
Tabi Spring ile birlikte EJB’lerin pabucu dama atılınca bu tabirin de çok bir cazibesi kalmadı.

Geldik (benim çok çok sevdiğim!) JSF (Java Server Faces) ve JSF Container’a. JSF, kurumsal Java web uygulamaları için daha 
interaktif, event tabanlı arayüzler geliştirmek için çıkmış bir UI teknolojisidir. Adı da biraz JSP (Java Server Pages)’a 
atıfta bulunmak ve dahiyane(!) bir pazarlama stratejisi olarak JSF (Java Server Faces) olarak konulmuştur. Yukarıda da 
bahsettiğim gibi JSF de JSP gibi Servlet teknolojisi üzerine kurulmuş bir çözümdür. İstemciden gelen bütün HTTP web istekleri 
`FacesServlet` isimli bir “Front Controller” servlet tarafından ele alınarak request processing, validation, method 
invocation ve response rendering gibi JSF teknolojisine ait yaşam döngüsü adımları işletilir. JSF, bileşen tabanlı bir UI 
çözümü olduğu için hem JSF sayfalarını hem de bu sayfalara karşılık gelen “backing bean” olarak adlandırılan bileşenleri 
yaratma, yönetme, bu nesnelerin aralarındaki bağımlılıkları sağlama ve bu yaşam döngüsünü çevirme işini de tahmin edeceğiniz 
gibi JSF Container üstlenmektedir.

Hikayenin sonuna yaklaşıyoruz. Şimdi de Spring Container nedir? ne iş yapar? Biraz da buna bakalım. Spring’in çıktığı 
2000’lerin başında J2EE teknolojileri ile özellikle EJB’ler ve monolith olarak adlandırılan “full stack” uygulama sunucuları 
ile kurumsal Java uygulamaları geliştirmek oldukça meşakkatli ve zaman alıcı bir süreçti. Bazı Java geliştiricileri 
yaşadıkları problemlere ve geliştirdikleri uygulamalara bakarak bu iş böyle değil de şöyle yapılırsa, örneğin tamamen 
POJO tabanlı sınıflar yazarak, EJB kullanmadan da transaction yönetimi, ORM gibi ihtiyaçları bir takım alternatif yollarla 
karşılayarak, “full stack” uygulama sunucusu kullanmak yerine Tomcat veya Jetty gibi daha “lightweight” Web Container’larla 
çalışarak kurumsal Java uygulamalarını çok daha hızlı ve kolay geliştirebileceklerini gördüler ve o dönem ortaya çıkan bir 
takım pratikler ve çözümler Spring Framework olarak vücut buldu. Spring Framework’ün özü olarak da Spring IoC Container 
veya Spring Container karşımıza çıktı. Spring (IoC) Container, kurumsal Java uygulamasındaki Java nesnelerini yaratan 
(bu nesneler sıradan Java nesneleri olmasına rağmen, Spring geliştiricileri onlara EJB’lere atıfta bulunmak, biraz da 
pazarlama stratejisi olarak `Spring bean` adını vermeyi tercih ettiler), bu nesnelerin aralarındaki bağımlılıkları yöneten 
ve bu nesnelere çalışma zamanında transaction yönetiminden, validasyona, caching’den scope yönetimine kadar pek çok ilave 
kabiliyet kazandıran yapıdır.

Evet, biraz uzun oldu ama kurumsal Java dünyasındaki Container’ların hangi ihtiyaçlardan ve nasıl ortaya çıktıklarını 
anlatmaya çalıştım. 1996’da Servlet teknolojisi ile başlayıp, oradan Spring Framework’e uzanan bu hikayeyi umarım 
beğenmişsinizdir.
