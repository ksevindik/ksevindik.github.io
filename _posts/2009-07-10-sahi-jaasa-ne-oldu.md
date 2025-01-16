# Sahi JAAS'a Ne Oldu?
[Java Developer’s Journal](http://java.sys-con.com/)’in bu haftaki sayısında 
“[Whatever Happened To JAAS](http://java.sys-con.com/node/1002315)” başlıklı bir makale dikkatimi çekti. `JAAS`, 
`java runtime security` üzerinde bina edilmiş bir kimliklendirme ve yetkilendirme framework olarak uzun zamandır kurumsal 
Java dünyasında; ancak ilk çıktığından bu yana istenilen ilgi ve alakayı görebilmiş değil. Bunun sorumlusu ise tabi ki 
Java spesifikasyonlarını oluşturan komiteler. Ne `JEE` ve `EJB`, ne de `JAAS`’ın kendi spesifikasyonları tam manası ile 
kurumsal uygulama geliştiricilere cevap verebilecek bir olgunluğa şu zamana kadar erişemediler. Birbirleri arasında da 
eksiklikler ve uyumsuzluklar da şu zamana kadar hep süregeldi.

Kurumsal Java teknolojileri ile yazılım geliştiren bizlerden kaçımız acaba uygulamalarımızda `JAAS`’ı kullanıyoruz. Web 
uygulaması geliştirenler için `Servlet` spesifikasyonu kendi başına güvenlik ihtiyaçlarının kimliklendirme ve basit de 
olsa yetkilendirme kısımlarına bir cevap bulmaya çalışmış. `JAAS`’ı kendi bünyelerine dahil etmeye çalışan container 
üreticileri ise spesifikasyonlardaki açıklardan dolayı kendilerine özgü çözümler üretmişler. Uygulamanızı container’ın 
sağladığı güvenlik kabiliyetlerinden yararlanarak geliştirmek istediğiniz vakit Java’nın “write once run everywhere” 
sloganı da sizin için geçersiz hale gelmiş oluyordu. Gerçi `JEE` dünyasında spesifikasyonlardaki bir eksiklikler ve 
çelişkilerden dolayı “write once, debug everywhere” daha anlamlı bir slogan olur.

Neyse konumuza geri dönelim, makalede `JAAS`’ı toparlamaya, neredeyse `Java 1.3.1`’den bu yana çözüm bulunamamış 
problemlerine çözüm bulmaya çalışan yeni bir spesifikasyondan bahsediliyor. 
[JSR-196](http://jcp.org/aboutJava/communityprocess/edr/jsr196/index.html) sanırım `JEE 6` spesifikasyonun 
içerisinde dahil edilmiş. Güzel ama kurumsal Java geliştiricileri yıllardır `filter` tabanlı kendi in-house çözümleri ile 
baş başa bırakıldıktan sonra biraz geç değil mi? Ayrıca bu alanı gayet başarılı biçimde dolduran 
[Spring Security](http://static.springsource.org/spring-security/site/) gibi 
framework’ler de mevcutken `JSR-196`’nın `Subject`, `Principal` ayrımı gibi problemlere cevap arama gayretleri, sanırım 
büyük resimde yine bizleri tatmin edici kapsamlı bir çözüm ortaya çıkmayacak izlenimi veriyor. Web container security ve 
`JAAS` kurumsal Java geliştiricilerin gözdesi olabilir mi? Pek sanmam, ama zaman içinde bunu hep beraber göreceğiz...
