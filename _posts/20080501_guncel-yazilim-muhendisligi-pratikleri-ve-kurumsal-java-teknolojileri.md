# Güncel Yazılım Mühendisliği Pratikleri ve Kurumsal Java Teknolojileri

28 Nisan 2008 Pazartesi günü ODTÜ Bilgisayar Mühendisliği Bölümü’nde “**Contemporary Software Engineering Practices Together 
with Enterprise Java Technolojies**” başlıklı bir sunum gerçekleştirme fırsatı buldum. Aşağıda sunumdan yola çıkarak
oluşturduğum kısa bir makaleyi yayımlıyorum. Ayrıca sunum’un kendisine de 
[buradan](http://www.slideshare.net/ksevindik/contemporary-software-engineering-practices-together-with-enterprise/) 
erişmek mümkün. Umarım bu çalışma yakın dönemde mezun olacak öğrenci arkadaşlara faydalı olmuştur.

Yazılım geliştirme genel olarak karmaşık ve zaman alan bir süreçtir. Uzun yıllar boyunca bu karmaşık süreci disipline 
etmek ve belirli bir sistematiğe oturtmak amacıyla değişik yazılım mühendisliği metodları ve pratikleri ortaya konmuştur. 
İlk olarak 90’lı yılların ortalarında kullanılmaya başlanan Java programlama dili orta ve büyük ölçekli kurumsal yazılım 
sistemlerinin geliştirilmesinde dominant bir platform haline gelmiştir. Açık kaynak kod hareketinin ve Java teknolojileri 
etrafında kümelenen geniş bir geliştirici topluluğunun da etkisi ile kurumsal Java platformu aslında kökleri çok daha 
eskilere dayanan güncel birtakım yazılım mühendisliği metod ve pratiklerinin, örneğin nesne ve aspect tabanlı programlama, 
çevik metodlar, XP, yazılım örüntüleri (pattern) gibi, ana uygulama alanına dönüşmüştür. Zaman içinde bu metod ve pratikler 
ve kurumsal Java platformu karşılıklı olarak birbirlerinin evrilmelerine ve yaygınlaşmalarına ciddi katkıda bulunmuşlardır. 
Bu makale boyunca çeşitli yazılım mühendisliği kavram, metod ve pratiklerinin bazılarından, bunların yazılım projelerine 
uygulanmasından ve Spring, Hibernate, JSF gibi popüler bazı kurumsal Java teknolojilerinden bahsedeceğiz. Yazılım 
projelerinde neden bu kadar “spagetti kod” olarak tabir edilen türden kötü, anlaşılması ve bakımı zor kod yazılıyor? 
Sanırım hemen her projenin geliştirme sürecinde belirli bir noktaya gelindiğinde projenin üyelerinin ağzından şu sözleri 
duymak mümkündür: “Bu projeyi sıfırdan tekrar yazmamız mümkün olsaydı, bazı şeyler çok daha farklı olurdu!” Burada hemen 
ünlü Mythical Man Month kitabının yazarı Fred Brooks’un bir sözü aklımıza geliyor: “Üzerinde çalıştığınız işin bir kopyasını 
çöpe atmayı planınıza ekleyin, çünkü eninde sonunda bunu yapacaksınız.” Sosyoloji bilimindeki önemli metaforlardan birisi 
de “Kırık Pencereler Teorisi” dir. Bu teoriye göre, eğer bir binanın kırılan bazı pencereleri hemen tamir edilmez ise, 
etrafa zarar vermeye meyilli insanların bu binadaki diğer camları da kırma ihtimali daha da fazlalaşır. En sonunda bina 
bu tür insanların istilasına uğrayabilir, onların yerleşim mekanına dönülebilir, hatta içerisinde yangın vb. diğer hasar 
verici olayların meydana gelmesi bile söz konusu olabilir. Sonuç olarak başında küçük birkaç pencere kırığına sahip bina 
zaman içerisinde tamamen metruk bir hale bürünebilir. Yazılım projelerinde de benzer bir durum söz konusudur. Her proje 
geliştirilmeye başlandığı ilk andan itibaren ömrünü tüketmeye de başlamıştır. Eğer sistem içerisinde oluşan küçük tasarım 
ve kod hataları düzeltilmezse bunlar zaman içerisinde bir çığ olup projenin geliştirilmesine ve bakımına ciddi problem 
teşkil edecek bir noktaya gelecektir. Başlangıç aşamasında çok kolay çözülebilecek bu tür problemler belirli bir noktaya 
gelindiğinde artık el sürülemez bir hal alacaktır. Burada karşımıza son yıllarda popüler olan bir yazılım mühendisliği 
pratiği çıkmaktadır: Refactoring. Refactoring, kodun dışsal davranışını ve çalışma şeklini değiştirmeden iç yapısını 
düzenlemeyi, iyileştirmeyi hedefler. Bir dizi küçük yapısal dönüşümden oluştur. Bu küçük fakat sürekli yapısal dönüşümler 
zaman içerisinde ciddi bir yeniden yapılandırma olarak karşımıza çıkar. Son dönemlerde önem kazanan bir diğer yaklaşım da 
büyük ön hazırlıklı, tasarımlı yazılım geliştirme faaliyetlerinin yerine aşamalı, azar azar adımlarla yürütülen yazılım 
geliştirme faaliyetleridir. Yazılım mühendisliği dünyasından dışarıya baktığımızda da, pek çok diğer uzmanlık alanında 
büyük ön planlamalara dayalı faaliyetlerin, özellikle şehir, bölge planlamacılığı gibi, zaman içinde ciddi problemlerle 
karşılaştığı görülmüştür. Bu tür büyük ön hazırlıklı, planlamalı çalışmaların başarısızlığındaki temel nedenler bunların 
katı olması, baştan bazı yanlış kabullere dayanmaları ve güncelliklerini zaman içerisinde yitirmeleridir. Bu tür sistemlerin 
kullanıcıları zaman içerisinde baştan öngörülemeyen pek çok değişikliğe ihtiyaç duymaktadırlar. Bu nedenle sadece planlama 
yapmak yeterli değildir.Değişikliklere uyum sağlayabilecek planlamalar yapmak gerekmektedir. 1986’da uzaya fırlatılan Mir 
Uzay İstasyonu artırımlı geliştirme için çok güzel bir örnektir. Mir Uzay İstasyonu yeniden konfigüre edilebilir ve modüler 
biçimde büyütülebilir biçimde tasarlanmıştır. Fırlatılış tarihinden itibaren 1996 yılına kadar uzay istasyonuna zamanın 
ihtiyaçlarına göre pek çok yeni ekleme ve düzenleme yapılmıştır. Uzay istasyonu bu genişleme sürecinde tekrar tekrar 
ayarlamalara tabi tutulmuştur. Mir Uzay İstasyonu 2001 yılında işlevini yitirdiğinden dolayı yörüngesinden çıkartılmış ve 
Fiji sahilleri yakınlarında atmosfere girerek parçalanmıştır. Artırımlı ve büyük planmalara dayalı geliştirme modellerini 
kıyaslarsak, artırımlı geliştirmenin kademeli onarım ve tamirat kavramı üzerine kurulmasına karşın büyük planlamalı 
geliştirmenin ise toptan değiştirme üzerine bina edildiği görülmektedir. Büyük ön hazırlığa dayalı çalışmalar ilk seferde 
mükemmele ulaşılabileceği yanlış inancına kapılmıştır. Artırımlı geliştirme, hataların kaçınılmaz olduğunu, sistemlerin 
ve kullanıcıların birbirlerine uyumlarının zaman alan ve yavaş bir süreç olduğunu kabullenmektedir. 2001 yılında bir grup 
yazılım mühendisliği kanaat önderinin bir araya gelmesi ile “Agile Manifesto” adında bir bildiri yayımlanmıştır. Bu bildiri 
de yazılım projelerinde yaşanan başarısızlıklar ve problemlere çözüm olabilecek birtakım yaklaşımlar vurgulanmıştır. Bu 
bildiride öne çıkan konuları şöyle sıralayabiliriz: 

1. Yazılım projelerindeki en öncelikli konu erken ve sürekli biçimde, çalışır bir yazılım sisteminin ortaya konması ile müşteri tatmininin sağlanmasıdır.
2. Geliştirme sürecinin sonlarında olunsa bile kullanıcı ihtiyaçlarındaki değişklikler hoş karşılanmalıdır. 
3. Sık aralıklarla çalışan bir sistem kullanıcıya teslim edilmelidir. 
4. Müşteri, analistler ve yazılım geliştiriciler gün boyunca birlikte çalışmalıdırlar. 
5. Projeler motive kişilerle geliştirilmelidir. 
6. En etkili ve verimli bilgi edinme ve iletişim yöntemi yüz yüze iletişimdir.
7. Projenin asli ilerleme göstergesi çalışan yazılımdır.
8. Teknik mükemmellik ve tasarımda kalite hedefi çevikliği geliştiren unsurlardır.
9. Yapılması gerekmeyen iş miktarını artırmak, yani basitlik esastır. 
10. En iyi mimariler ve tasarımlar kendi kendilerine organize olabilen ekipler tarafından ortaya konmaktadır. 
11. Ekipler belirli zaman aralıklarında çalışmalarını ve iş yapış şekillerini gözden geçirmeli ve bunları iyileştirmelidirler. 

1977 yılında Christopher Alexander isimli bir mimar ortaçağ dönemlerinde yapılmış binaların, yaşam alanlarının neden çekici, 
insanlara yaşam enerjisi verici ve ortamla uyumlu olduğunu sorgulayan bir eser yayımlamıştır. “A Pattern Language: Towns, 
Buildings, Construction” isimli eserinde bu sorulara verdiği cevap, bu binaların o dönemlerdeki ve yapıldıkları ortamlardaki 
bazı yerel düzenlemelere ve kurallara uymak zorunda olmalarına rağmen mimarlarının o ortamda karşılarına çıkan belirli 
birtakım ihtiyaç ve problemlerde bağımsız karar verebilmeleri, bu kararların, yapıların şeklini, kullanımını o ortama uygun 
biçimde şekillendirdiğini tespit etmiştir. Christopher Alexander, kitabında daha estetik, çevre ve insan doğası ile uyumlu 
binalar, yaşam alanları yaratmak için örnek resimler, tasarımlar sunmuş, ancak kesin kararların alınmasını her bir projenin, 
çalışmanın kendisine bırakmıştır. 1994 yılında, daha sonra “Gang of Four” lakabı ile tanınır olacak dört yazılım mühendisi 
Christopher Alexander’ın bu kitabından etkilenerek yazılım sistemlerindeki bazı tasarım örüntülerini (pattern) kataloglayan 
bir çalışma yayımlamışlardır. Tasarım örüntüleri sistematik biçimde isimlendirilmiş ve bunların nesneye dayalı sistemlerde 
hangi tasarım problemlerine çözüm getirdiği açıklanmıştır. Genel olarak bu çözümler statik ve dinamik olarak sınıf ve nesne 
modellerinden, bunların açıklamalarından, kod örneklerinden ve bu örüntüler uygulandığı vakit ortaya çıkacak olumlu ve 
olumsuz sonuçlardan oluşmaktadır. Tasarım örüntüleri ve refactoring kavramlarının birlikte yorumlanması ile 2000’li 
yıllarda değişik bir bakış açısı ortaya çıkmıştır. Genel olarak tasarım örüntüleri, kodumuzda varmak istediğimiz nihai 
aşama olarak düşünülürse, refactoring çalışmaları bu nihai aşamaya ulaşmaya yardım eden ara adımlar olarak görülebilir. 
Herhangi bir problemin ilk çözüm aşamasından itibaren bir örüntünün doğrudan kullanılmaya çalışılması zaman zaman çözümün 
gereksiz yere karmaşıklaşmasına neden olmaktadır. “Refactoring to Patterns” yaklaşımı ile basit bir yapıdan yola çıkarak 
ideal çözüme zaman içinde ihtiyaçlar doğrultusunda kademeli olarak varılmaktadır. Son yıllarda öne çıkan diğer bir yazılım 
mühendisliği pratiği ise test güdümlü programlamadır. Aslında test kavramı programcılığın ilk dönemlerinden itibaren 
geliştiricilerin dağarcığında yer etmiştir. En basitinden bir uygulamanın kabul edeceği girdi ve üreteceği çıktının kodlamadan 
evvel değerlendirilmesi ve asıl fonksiyonalitenin bundan sonra yazılması bilinen bir çalışma yöntemidir. Test güdümlü 
programlamada ise ilk önce istenilen fonksiyonaliteyi veya iyileşmeyi sınayan bir test kodu yazılır. Ardından bu testin 
başarılı biçimde çalışmasını sağlayacak gerçek fonksiyonalite kodu yazılır. Daha sonra ise refactoring ile yazılan kod ve 
tasarım daha sonraki ihtiyaçları karşılayacak biçimde iyileştirilir. Yazılım projelerinde genellikle yoğun çalışma temposu 
ve sıkışık teslim süreçlerinde stres katsayısının artması sonucunda ekiplerin ilk terk ettikleri aktivitelerden birisi 
test kodlarının yazılması ve çalıştırılması olmaktadır. Malesef bu durum “test için zamanımız yok” kısır döngüsü ile 
sonuçlanmaktadır. Daha az test yazılması ve çalıştırılması geliştiricilerin sistemle ilgili özgüvenlerini azaltacağı için 
stres katsayısının daha da artmasına sebep olmaktadır. Stres katsayısının artışı da testlerin yazılmasını iyice azaltmaktadır. 
Herhangi bir yazılım sisteminin tasarımının iyi veya kötü olup olmadığını hangi kriterlerle değerlendirmeliyiz? Kötü bir 
tasarım hakkında neler ipucu olabilir? Bu noktada karşımıza birkaç temel kriter çıkmaktadır. Eğer sistem içerisinde 
herhangi bir modülü değiştirmek zorsa, bu değişiklik sistemin pek çok diğer bölümünü etkiliyorsa bu esnek olmayan bir 
tasarım demektir. Eğer sistemde yapılan bir değişiklik ilgisiz diğer bölümlerde hatalara sebep oluyorsa bu durumda sistem 
kırılgan demektir. Sistem içerisinde herhangi bir modülün başka benzer bir problem de de kullanılabileceği gözlenmesine 
rağmen, bu modülün diğer sistemde kullanılacağı vakit mevcut sistemden kolayca ayrıştırılamaması sistemin yeterince izole 
olmadığı anlamına gelmektedir. Yazılım geliştirciler herhangi bir problemle kaşılaştıklarında mevcut tasarım içerisinde 
bu problemi çözen birden fazla yol bulabilirler. Bunlardan bazıları mevcut tasarıma uygun olup, sistemin genel mimarisi 
ve tasarımı ile çelişmeyen, diğerleri ise “hacking” diye tabir edilen kestirme, günü kurtaran çözümlerdir. Eğer uygun 
çözümlerin uygulanması, kestirme çözümlere göre çok daha zor ve zaman alıcı ise geliştiricilerde doğal olarak kolay olan 
yolu tercih edeceklerdir. Bu durum sistemin yeterince olgunlaşmadığına, akışkan olmadığına işarettir. Peki kaliteli bir 
nesneye yönelik tasarım ortaya çıkarmak için sınıf, nesne, soyutlama, encapsulation, soya çekim gibi temel nesneye yönelik 
kavramların bilinmesi ne derecede yeterlidir? Malesef bu kavramlar nesneye yönelik tasarımlarda atomik birimlerdir. 
Herhangi bir yazılım sisteminin nitelikli bir tasarıma sahip olması için daha üst düzeyde ve geniş kapsamda yapılara ve 
prensiplere ihtiyaç duyulmaktadır. Nesneye yönelik tasarım prensiplerinden en önde geleni “açık-kapalı” prensibidir. 
Bu prensibe göre yazılım birimleri, genişlemeye açık, fakat değişikliklere kapalı olmalıdır. Eğer bu birimlerle ilgili 
yeni birtakım ihtiyaçlar sözkonusu ise bu ihtiyaçlar bu birimlerin genişletilmesi, yeni yapıların ilavesi ile karşılanmalı, 
mevcut birimlerin, yapıların kendilerinde herhangi bir değişikliğe gidilmemelidir. Diğer bir prensip ise her sınıfın tek 
bir görevinin olmasıdır. Herhangi bir sınıfta bir değişiklik yapmak için birden fazla değişik sebep ortaya çıkmamalıdır. 
Bir diğer önemli prensip ise sınıflar arasındaki bağımlılıkların yönü ile ilgilidir. Soyut sınıflar kesinlikle sabit 
(concrete) sınıflara bağlı olmamalıdır. Soyut sınıflar tasarım olarak genişlemeye açık türden sınıflardır. Bu nedenle 
bağımlılıkların yönü sabit sınıflardan soyut sınıflara doğru olmalıdır. Nesneye yönelik programlama belirli ölçüde modüler 
yazılım sistemleri geliştirmeye yardımcı olmuşlardır. Ancak yazılım sistemlerinde ortaya çıkan bazı fonksiyonalitelerin 
kendi başlarına tek bir modül içerisinde toparlanması nesneye yönelik programalama ile mümkün olmamaktadır. Bu fonksiyonlar 
sistem genelinde değişik modüllere yayılmaktadır. Bu noktada ilgiye yönelik (aspect oriented) programlama ortaya çıkmıştır. 
Kökeni eskilere dayanmasına rağmen ilk olarak Java programa dili üzerine geliştirilen AspectJ programlama dilinin popüler 
olması ile ilgiye yönelik programlama da güncel yazılım mühendisliği metodları arasında yer almıştır. Java programlama dili 
ilk olarak 1994 yılında ortaya çıkmıştır. Önceleri istemci taraflı, görselliği yüksek uygulamaların geliştirilmesinde 
popüler olmasına rağmen zaman içinde kurumsal, sunucu taraflı sistemlerde de yaygın bir platform olmuştur. Kurumsal Java 
platformunun gelişimi 1998 yılına kadar uzanmaktadır. İlk dönemlerde katmanlı mimariler, Enterprise Java Beans, RMI, 
dağıtık transactionlar gibi kavramlar öne çıkmıştır. Kurumsal ölçekli sistemlerin bu ihtiyaçlarını karşılayan, bütün bu 
kurumsal Java servislerini içlerinde barındırmayı hedefleyen büyük monolitik uygulama sunucuları ortaya çıkmıştır. Zaman 
içinde klasik kurumsal Java platformunun düştüğü temel problem “her bedene uyacak tek bir elbisenin dikilebileceği” 
düşüncesidir. Gerçek hayata bakıldığında pek çok proje dağıtık sistemlerin ihtiyaç duyduğu servislere ihtiyaç duymamaktadır. 
Sıradan veritabanı işlemleri için EJB teknolojisi çok karmaşıktır. Uygulamaları çalıştırmak için mutlaka uygulama sunucularına 
ihtiyaç duymak özellikle geliştirme ve test süreçlerini olumsuz yönde etkilemektedir. Genel olarak klasik J2EE platformu, 
spesifikasyonlar tarafından yönlendirilmektedir. Bu yaklaşımın sağladığı başarılar olsa bile, yukarıda bahsedilen noktalarda 
dezavantajlara da sahiptir. 2000’li yılların başlarında Java geliştircileri kurumsal Java projelerindeki başarısızlıklarından 
pek çok dersler çıkartmıştır. Bu deneyimler sonucunda monolitik, hantal kurumsal Java platformları yerine, yine 
spesifikasyonları temel alan ancak daha hafif sıklet ve çevik kurumsal Java platformuna doğru bir dönüşüm söz konusu 
olmuştur. Bu dönüşümde uygulamaların herhangi bir ortamda çalışabilmesi, sıradan Java sınıflarının kullanılabilmesi, test 
güdümlü programlamanın etkin biçimde kullanılabilmesi temel hareket noktaları olmuştur. Bu dönüşüme öncülük eden kurumsal 
Java çözümlerine kısaca değinirsek, bunlardan en önde geleni Spring Application Framework’tür. Spring’in çıkış noktası 
J2EE ile yazılım geliştirmeyi çok daha kolay bir hale getirmektir. Daha önce bahsedilen, açık-kapalı, bağımlılıkların 
sabit sınıflardan soyut sınıflara doğru olması gibi tasarım prensipleri Spring’in temelini oluşturmuştur. Genel olarak 
Spring çok katmanlı bir kurumsal Java çatısı (framework) sunmaktadır. Bu çatının özünde, uygulamanın nesnelerini oluşturan, 
nesneler arasındaki ilişkileri yöneten hafif sıklet bir container yer almaktadır. Birbirlerinden kolaylıkla ayrılabilir 
yazılım bileşenleri kendi başlarına rahatlıkla test edilebilir durumdadır.Spring ilgiye yönelik (aspect oriented) 
programlama konusunda da kapsamlı bir entegrasyon sunmakta, böylece AOP’u kurumsal Java ugulamalarında rahatlıkla 
kullanılabilir kılmaktadır. Diğer bir popüler kurumsal Java çatısı ise nesne ve ilişkisel modeller arasında mapping 
yapmayı sağlayan Hibernate OR Mapping Framework’tür. Kurumsal uygulamalardaki veriler çoğunlukla ilişkisel veritabanlarında 
tutulur ve bu verilere SQL aracılığı ile erişilir. Nesneye yönelik geliştirilmiş bir uygulamada nesnelerin o andaki 
halleri veritabanında saklanıp, daha sonra saklanan bu veriler ile nesneler aynı durumda tekrar yaratılabilir. İlişkisel 
veritabanları veriyi tabular formda saklamaktadır. Malesef nesne modelini birebir tabular formla eşleştirmek mümkün 
olmamaktadır. Nesne ve ilişkisel modellerdeki bu uyumsuzluk şu noktalarda yoğunlaşmaktadır. Nesne modeli ve ilişkisel 
model farklı ölçekte yapılar üzerine bina edilmişlerdir. İlişkisel modelde iki tablo ile ifade edilen bir veri yapısı, 
nesne modelinde daha fazla sayıda sınıfın yer aldığı bir modele karşılık gelebilir. Nesne dünyasındaki soyaçekimin 
(inheritance) ilişkisel modelde tam bir karşılığı yoktur. Bu eksiklik polimorfik sorgularda da karşımıza çıkmaktadır. 
Nesne dünyasındaki kimlik (identity) kavramı ile ilişkisel modeldeki kimlik kavramı birebir örtüşmemektedir. Nesne 
modeldeki ilişkilerde yön kavramı söz konusudur, ancak ilişkisel modelde veriler arasındaki ilişkilere bir yön atamak 
mümkün değildir. Nesneler arası ilişkiler çoka çoklu da olabilirken, ilişkisel modelde sadece bire çoklu ve bire bir 
ilişkiler desteklenmektedir. Nesneler arasında dolaşırken her bir nesneye birer birer erişilerek hedef bilgiye erişmek 
sözkonusudur. Bu durumda da ilişkisel modelden verinin o an ihtiyaç duyulduğunda getirilmesi gerekmektedir. Ancak veriye 
birden fazla erişim maliyeti yüksek bir işlem olduğundan, genellikle veriye erişmeden evvel navigasyon derinliğinin tespit 
edilmesi söz konusudur. Bu da nesneye dayalı uygulamalarda ya gerektiğinden fazla verinin hafızaya yüklenmesine, ya da 
veritabanına çok fazla sorgu gönderilmesine neden olmaktadır. Kurumsal Java platformunda bir diğer katman ise görsel 
katmandır. Bu katman için ilk dönemlerden itibaren Servlets, JSP gibi teknolojiler ortaya çıkmıştır. Ancak bunlardan daha 
üst bir seviyede, tekrar kullanılabilir ekran bileşenleri oluşturma, kullanıcı isteklerini ele alma, nesne modeli ekran 
bileşenleri ile ilişkilendirme, navigasyon yönetimi gibi ihtiyaçlara cevap verecek bir çatıya ihtiyaç duyulmuştur. Zaman 
içinde bu ihtiyaçlar Struts, Tapestry, Webwork gibi çözümlerle karşılanmıştır. Son dönemde kurumsal Java platformunda 
görsel katman için Java Server Faces spesifikasyonu bir standart olarak ortaya çıkmıştır. Temelde MVC örüntüsü üzerine 
kurulu bu teknoloji bahsettiğimiz görsel katman problemlerine çözüm sunmaya çalışmaktadır. Sonuç olarak, hangi teknoloji, 
araç vs. tercih edilirse edilsin, bunların büyük yazılım sistemleri geliştirilirken etkin ve verimli biçimde kullanılabilmesi, 
bu tür yazılım sistemlerinin sağlıklı biçimde geliştirilebilmesi için çok daha temel bir takım yazılım mühendisliği kavram, 
metod ve pratiklerinin bilinmesi ve yerine göre uygulanması gerekmektedir. Son dönemde güncel hale gelen bazı yazılım 
mühendisliği metod ve pratiklerinde de kurumsal Java platformu uygun bir geliştirme tezgahı olarak kullanılmıştır. Her 
iki alan da birbirlerine karşılıklı geri beslemede bulunmuş, bu geri beslemelerin ışığında hem yeni kavram, metod ve 
pratikler hemde yeni teknoloji ve araçlar ortaya çıkmıştır.