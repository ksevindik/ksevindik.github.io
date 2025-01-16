# Kafesin Ortaya Çıkışı
Ergenekon soruşturması bir açıdan tarafların arasında teknoloji savaşlarına da sahne oluyor. Bir süre önce Genelkurmay 
karargahından bir subayın gönderdiği iddia edilen ihbar mektubunda, bilgisayarların disklerinin 35 kere silindikten sonra 
savcılığa gönderildiği ifade edilmişti. Buradaki 35 rakamı ile kast edilenin aslında verilerin silindikten sonra geri 
getirilmesini zorlaştıran yöntemlerden Gutmann metodu olabileceği ortaya çıkmıştı. Şimdi de Kafes eylem planının aslında 
bir video dosyasının içerisine “data stash” isimli programla gizlendiği iddia ediliyor.

Söylentilere göre “data stash” adı verilen dosya gizleme programını emekli bir binbaşıya ait dosyalar arasında gören 
uzmanlar buradan yola çıkarak video dosyasının içerisine gizlenmiş eylem planına erişmişler. Peki bir dosya içerisine o 
dosyayı bozmadan başka bir dosya saklanabilir mi? Genellikle ses, resim, video gibi dosyalarının içerisinde başka 
dosyaların saklanması sık rastlanılan bir durumdur. Taşıyıcı konumundaki resim ve video dosyası, içine gizli dosya 
gömüldükten sonra da kullanılabilir vaziyettedir ve bilmeyen birisi için sıradan bir resim, ses veya video dosyasından 
hiçbir farkı yoktur.

Bir mesajın sadece gönderen ve alıcı arasında bilinen bir yöntemle başka bir mesajın veya resmin içerisinde taşınması 
demek olan steganografinin kökeni aslında yüzyıllar öncesine dayanmaktadır. Daha antik yunan döneminde balmumu tabletlerin 
tahta kısmına gizlenecek mesaj kazınır, sonra da tabletin üstü balmumu ile kaplanır, üzerinde de şüphe uyandırmayacak bir 
metin yazılırmış. Yine eski çağlarda en güvendiği kölesinin saçlarını kazıtan bir efendi, göndereceği gizli mesajı kölenin 
kafasına dövme yaptırdıktan sonra kölenin saçlarının uzamasını beklemiş. Görünmez mürekkep kullanarak sıradan bir metnin 
satır aralarına gizli bir mesaj yazmak da eskiden beri bilinen bir steganografi yöntemidir.
İnternet’teki bazı forumlarda yapılan yorumlarda Ergenekon savcılarına “data stash” hakkında sorulduğunda, savcılar böyle 
bir programı ve ne işe yaradığını bilmediklerini söylemişler. Bu cevaptan yolan çıkan bazı çevreler de, video dosyası 
içerisindeki gizli planı bu konular hakkında bilgisi olmayan savcıların kendiliğinden bulamayacaklarını, planı muhtemelen 
ya başka birilerinin servis ettiğini, yada planın savcılığın ve emniyetin bir komplosu olduğunu ima ediyorlar. Bana 
kalırsa akıllı bir savcı tabi ki böyle bir programdan veya yöntemden haberi olmadığını söyleyecektir.

Peki, dijital dünyada steganografi nasıl çalışmaktadır? Aslında dijital ortamdaki hemen her tür dosya bir taşıyıcı olarak 
kullanılabilir. Ancak video, resim ve ses dosyaları yapılarından ötürü bu iş için diğer dosya türlerinden daha uygundur. 
Gizli bir mesajın bilgisayarımızdaki sıradan bir resim içerisine nasıl saklandığını anlamak için biraz teknik detaya 
girmemiz gerekiyor. Resim dosyaları aslında piksel denilen verilerden oluşur. Her bir piksel 3 adet 8 bitlik veri grubu 
içerir. Bu veri grupları kırmızı, yeşil ve mavi renk tonlarını ifade ederler. Yani her bir pikselin rengi bu üç renk 
değerinin karışımı sonucu ortaya çıkar. Bu karışıma RGB değeri denir. Örneğin kızmızı renkli bir pikselin RGB değeri 
(11111111 00000000 00000000) şeklindedir. Eğer bu üç renk grubunun en son rakamlarında bir değişikliğe gidilirse 
(örneğin; 11111111 00000001 00000001), kırmızı pikselin rengi gözle ayırt edilemeyecek ölçüde küçük bir miktar 
farklılaşacaktır. Bu sayede her 3 piksel ile gizli mesajın bir harfi kodlanabilir. Teorik olarak 1024×768 piksel boyutunda 
bir resim içinde 256 KB uzunluğunda bir dosyayı gizlemek mümkün olabilir. Medya da yer aldığı şekli ile kafes eylem 
planının da bu boyutlarda bir dosyaya sığıp sığamayacağını artık siz kestirebilirsiniz.

Bakalım, ortam ve telefon dinlemelerinin sıradanlaştığı, güvenli silme yöntemlerinden Gutmann metodunu öğrendiğimiz, data 
stash programı ile planların gizlendiği bu mücadelede sırada ki hangi teknolojik araç bir silaha dönüşecek?

**Not:** Bu yazı ilk olarak 4 Aralık 2009 tarihinde www.skyturk.net haber sitesinde yayımlanmıştır.
