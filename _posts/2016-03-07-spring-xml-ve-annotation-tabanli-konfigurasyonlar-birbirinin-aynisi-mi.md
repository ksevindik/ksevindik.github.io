# Spring XML ve Annotation Tabanlı Konfigürasyonlar Birbirinin Aynısı mı?

Yakın bir zamanda [Beginning Spring](http://www.amazon.com/Kenan-Sevindik/e/B00Q4E10XM/) isimli kitabımız üzerinden Spring 
öğrenmeye çalışan bir arkadaşımdan kitapta okudukları sonrasında kafasında beliren böyle bir soru geldi. Kendisine verdiğim 
cevap belki Spring ile çalışan veya çalışmaya başlayacak arkadaşların da işine yarayabilir düşüncesi ile buradan paylaşıyorum.

Spring ApplicationContext‘e hangi sınıfları kullanarak hangi bean’leri oluşturacağını, bu bean’lerin özelliklerinin neler 
olacağını, bean’ler arasındaki bağımlılıkların bilgisini, ve diğer pek çok uygulama ile ilgili kabiliyeti tanımlamamız 
gerekiyor. Bu tanımlara “configuration metadata” adı veriliyor. Spring ApplicationContext runtime’da bu configuration 
metadata’yı işleyerek uygulamanın ihtiyaç duyduğu bean’leri yaratıyor, aralarında ilişkiler kuruyor ve diğer pek çok 
kabiliyeti hayata geçiriyor.

Configuration metadata farklı formatlarda tanımlanabilir. XML geleneksel yöntemdir, Spring ilk çıktığında sadece XML vardı. 
Diğer pek çok framework gibi Spring’de konfigürasyon bilgilerini (metadata) XML formatında dosyalardan okuyarak elde 
ediyordu. O zamanlar daha Java’ya annotation kabiliyeti eklenmemişti. Java 1.5 sürümü ile birlikte Java programlama diline 
annotation kabiliyeti eklenince bu sefer framework’ler arasında konfigürasyon metadata tanımlama yöntemi olarak annotation 
kullanma furyası başladı. Spring’de bu dönemde XML’in yanına bir de annotation kullanarak bean tanımlama, bean’ler 
arasındaki bağımlılıkları enjekte etme gibi kabiliyetler ekledi.

Tabi burada Spring ekibi şunu da sağlamıştır. ApplicationContext metadata formatından bağımsız tutularak, ister XML, ister 
annotation tabanlı konfigüre etmek mümkün kılınmıştır. Hatta bu metadata formatlarını bir arada aynı anda kullanarak da 
ApplicationContext konfigürasyonu yapılabilir. Ancak burada şuna da dikkat etmek gerekiyor. Annotation tabanlı konfigürasyon 
XML tabanlı konfigürasyonun bire bir kopyası veya alternatifi olacak seviyede veya kabiliyette değildir. Aslında annotation 
tabanlı konfigürasyon XML tabanlı konfigürasyonla birlikte kullanılacak, onu complement edecek biçimde şekillendi. Günümüzde 
Spring kullanan projelerde de XML ve annotation tabanlı konfigürasyonlar çoğunlukla birlikte kullanılır. Spring’e özel 
altyapısal kabiliyetlerin konfigürasyonu veya uygulama koduna ait olmayan sınıflardan bean tanımları XML ile yapılırken, 
uygulamaya özel sınıflardan bean tanımları ve bağımlılıkların enjeksiyonu ise `@Component`, `@Service`, `@Repository`, 
`@Controller`, `@Autowire` gibi annotasyonlar kullanılarak annotasyon tabanlı gerçekleştirilir.

Zaman içerisinde XML tabanlı konfigürasyonlarla ilgili type safety, refactor edilebilirlik, modülerlik, extend edilebilirlik 
gibi noktalarda eleştirilerden dolayı bu sefer de framework’lerde Java tabanlı konfigürasyon popülerlik kazandı. Spring’de 
bu akıma ayak uydurdu ve XML tabanlı konfigürasyon ile yapılan işlemlerin bire bir aynısını Java sınıfları, metotlar ve 
bunların üzerinde bazı annotasyonları kullanarak yapmayı sağladı. Doğalarından ötürü kullanım biçimlerinde, davranışlarında 
bazı farklar olsa da, Java tabanlı konfigürasyona XML tabanlı konfigürasyonun bire bir alternatifi diyebiliriz. Tabi Spring 
ekibi ApplicationContext konfigürasyonunu daha önceden metadata formatından bağımısz kıldığı için bu davranışı Java tabanlı 
konfigürasyonda da korumuştur.

Spring uygulamalarında aynı anda hem XML, hem `@Component`, `@Autowire` gibi annotasyonlar, hem de Java konfigürasyon 
sınıfları ile ApplicationContext konfigürasyonu yapmak mümkündür. Artık günümüzde Servlet 3 API’sindeki yeniliklerle 
birlikte hiç Spring XML dosyalarına ve `web.xml` dosyasına ihtiyaç duymadan da Spring kabiliyetine sahip web uygulamalarının 
konfigürasyonu yapılabilmektedir.
