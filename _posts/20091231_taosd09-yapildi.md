# TAOSD09 Yapıldı

Bedir Tekinerdoğan Hoca’nın öncülüğünde Bilkent Yazılım Mühendisliği Grubu tarafından düzenlenen Aspect Oriented Software 
Development Çalıştayı’nın (TAOSD) 4.sü geçen Salı günü yapıldı. Çalıştay Bilkent Üniversitesi’ndeki Aspect Oriented Software 
Development dersi kapsamında organize ediliyor. Öncelikle etkinliği sürekli hale getirdiği ve bizlerin de dışarıdan
katılımına izin verdiği için Bedir Hoca’ya teşekkür etmek istiyorum. İlki 2003 yılında yapılan çalıştay bir dönem UYMS 
bünyesinde genel katılıma da açık olarak düzenlenmişti. Ancak o dönemde katılım sadece üç dört bildiri ile sınırlı kalınca 
Bedir Hoca’da şimdilik çalıştayı bu şekilde ders kapsamında götürüyormuş. Sanırım AOP’a yönelik ilgi ve alaka Türkiye 
genelinde yaygınlaştıkça bu etkinlik de tekrar daha geniş bir katılımcı kitlesine hitap edecek.

Etkinlik sayesinde bilgisayar mühendisliği öğrencilerinin OOP ve AOP konularında iş hayatında kullanılabilecek düzeyde 
bilgi ve deneyim sahibi olduklarını gözlemleme fırsatım oldu. En azından bu dersi alan öğreciler design patterns, temel 
OOP prensipler ve AOP gibi önemli konulardan bi-haber piyasaya atılmıyorlar. Sektörde OOP paradigması ile yazılım 
geliştirme uzun zamandır gerçekleştiriliyor, ancak şu ana kadar ki kişisel gözlemim ne kurum düzeyinde, ne de kişisel 
düzeyde OOP kavramları tatmin edici biçimde projelere yansıtılamıyor. Zaman zaman iş mülakatlarına, mülakatı yapanlardan 
biri olarak, katılıyorum. OOP prensipleri, design patterns gibi konularda sorduğum sorularda mülakata gelen pek çok 
arkadaşımızın yetersiz olduğunu, bunların pek çoğununda sektörde en az bir kaç yıl tecrübe sahibi olmalarına rağmen bu 
alanda kendi açıklarını gidermek adına herhangi bir aksiyon al(a)madıklarını gözlemledim. AOP konusunda böyle bir ders ve 
dönem sonunda düzenlenen proje bazlı bir çalıştayın öğrencilere gelecek için çok büyük katkısı olduğunu belirtmeliyim.

Etkinliğe katılırken bir düşüncem de AOP bizde ne düzeyde algılanıyor ve kullanılıyor, acaba middleware ihtiyaçların 
ötesine geçip iş mantığının kodlanmasında da aspektlerden yaralanılıyor mu? şeklinde sorularıma cevap bulmaktı. AOP 
konususun daha Türkiye’de kendi başına bir gündem oluşturamadığını Bedir Hoca’ın yukarıdaki tecrübesinden öğrenmiş oldum. 
Öğrencilerin çalışmalarına baktığımda da genel olarak projelerde tespit edilen ve kullanılan aspektlerin hemen hepsinin 
middleware ihtiyaçların karşılanması düzeyinde kaldığını gözlemledim. Belki bu durum projelerin OOP ile geliştirildikten 
sonra “aspect mining” yapılmasının etkisi olabilir. Bu yaklaşımda iş mantığından bağımsız olan middleware ihtiyaçların 
daha kolay biçimde aspect soyutlamasına tabi tutulması mümkün oluyor. Oysa iş mantığı içeren kısımlarında ayrı birer 
“concern” olarak ifade edilebilmesi için projenin başından itibaren probleme aspect gözlüğü ile bakılması gerekli diye 
düşünüyorum. Projelerde aspectlerin daha kolay tespiti ve kullanılması için OOP’daki GOF design patterns gibi bir katalogun 
da çok büyük yardımı olacaktır. Bu amaçla TAOSD’da bahsedilen aspektlerin kısaca listelendiği bir katalog “Aspect Browser” 
olarak siteye konmuş. Ancak daha kapsamlı ve bir “pattern language” olarak ve belli bir notasyon ile aspektlerin 
kataloglanması çok daha faydalı olacaktır.

Öğrencilerin yaptığı projelerde en çok öne çıkan aspektler ise logging, security, persistency, transaction, validation, 
monitoring “concern”leri ile ilgiliydi. Ancak bunların yanı sıra communication, multi language support gibi middleware 
ihtiyaçların da aspektlerle ele alındığını görmek ilginçti. Sanırım şu an için aspektler daha çok loglama, güvenlik ve 
transaction yönetimi gibi middleware ihtiyaçlarda akla geliyor. Kişisel görüşüm loglamanın AOP konusunda tanıtıcı örnek 
olarak verilmesi AOP’un gücünün tam olarak anlaşılmasını da engelliyor. Bunun yanı sıra metod başlangıcında ve sonunda 
üretilen mesajlar, input ve return değerlerinin loglanması gibi ihtiyaçlar uygulamaların üretmesi gereken logların 
nispeten az ve önemsiz bir kısmını tutuyor. Loglamanın AOP örneği olarak bu kadar öne çıkarılması hem uygulamalarda biraz 
hafife alınmasına yol açıyor, hem de AOP’un metodların başında ve sonunda ilaveten bazı işlemler yapmayı sağlayan bir 
teknolojiye indirgenmesine yol açabiliyor. Uygulamalarda, özellikle kurumsal uygulamalarda loglama kendi başına uzun 
uzadıya tartışılması gereken ayrı bir konu.

Bir dahaki TAOSD çalıştayında görüşmek üzere…
