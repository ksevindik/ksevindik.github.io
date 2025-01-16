# Javanin Gelecegi

Son zamanlarda Java’nın geleceği, nereye doğru gittiği hakkında çok değişik yazılar çıkıyor, yorumlar yapılıyor. Aslında 
programlama tarihinde Java’dan daha fazla yaygınlığa erişmiş başka bir dil daha olduğunu düşünmüyorum. Muazzam genişlikte 
kullanım alanı ile ve artık dilden çok daha öteye gitmiş bir platform olarak Java’nın daha uzun seneler pek çoğumuzun 
kariyerinde önemli bir yer tutacağı aşikar. Çoğumuzu emekli bile eder diyebiliriz. Ancak son dönemde Java’nın geleceği 
hakkındaki spekülasyonlar da en ilgi çeken gündem maddelerinden birisini oluşturuyor. En son Effective Java’nın yazarı 
ve Java Collections API’nin mimarı Josh Bloch’un konu ile ilgili fikirlerini öğrenme [fırsatımız](http://www.infoq.com/news/2010/04/bloch_java_future) oldu.

Bloch’la yapılan söyleşiyi okurken, “Ya bu adam daha birkaç sene evvel Java’nın artık çok fazla komplike hale geldiğini,
tabiri caiz ise şiştiğini, bundan sonra “[Closure](http://www.javac.info/bloch-closures-controversy.ppt)” gibi özellikleri dile eklerken çok daha dikkatli olunması gerektiğini 
vurgularken, nasıl oluyor da şimdi kendisi de Java’daki ataletten bahsediyor?” diye içimden geçirmedim değil. Son dönemde 
Java’dan sonrasının bu kadar çok konuşulmasının birkaç nedeni var diye düşünüyorum. Bunlardan biri [Java 7](https://jdk7.dev.java.net/)‘nin ortaya 
çıkmasının yılan hikayesine dönmesi, diğer bir nedeni JVM’i ortak bir “runtime environment” olarak görüp bunun üzerine 
geliştirilen alternatif çözümlerin birer ikişer ortaya çıkması diyebiliriz. Son olarak da Sun’ın Oracle’a satılmasının 
ardından [James Gosling](http://nighthacks.com/roller/jag/entry/time_to_move_on)‘in de aralarında bulunduğu bir grup eski Sun personelinin “Oracle’da çalışmaktansa aç kalırım daha 
iyi” diyerek ayrılmalarının yarattığı spekülatif hava işin tuzu biberi oldu.

Aslına bakılırsa Bloch’un söylediklerinden anlaşılan Java’daki bu atalet, dilin zenginleştirilmesine yönelik çabaların 
zayıflığından çok açık kaynak kodlu Java çalışmalarındaki lisans modellerindeki anlaşmazlıklardan ve son yıllarda Sun’ın 
içine düştüğü ekonomik buhran nedeni ile Java’ya ayırdığı kaynakların neredeyse kuruma noktasına gelmesinden dolayı ortaya 
çıkıyor. Bilindiği üzere değişik derivasyonlar olmasına rağmen şu an açık kaynak kodlu Java çalışmaları olarak [OpenJDK](http://openjdk.java.net/) ve 
[Apache Harmony](http://harmony.apache.org/) öne çıkıyor. Ancak OpenJDK GPL v2, Harmony ise Apache V2 lisanslarına sahip ve iki kamp da kendi yolunda 
ilerlemekte diretiyor. Parasızlık nedeni ile ortaya çıkan liderlik problemi ise Oracle’ın Sun’ı satın alması ile nasıl 
çözülecek herkes için biraz merak, biraz da endişe konusu olmuş durumda. Her ne kadar Bloch’un da söyleşide belirttiği 
gibi Oracle’ın da JRE’yi herkese açık ve ulaşılabilir tutması en akılcı yol gözükse bile Oracle’ın Java’nın geleceğini 
şekillendirirken çalışmaları nalıncı keseri gibi kendine yontacağından şüphe edenlerin sayısı az değil. Bu nedenle JRE’yi 
ortak bir platform olarak temel alan diğer alternatif çalışmalara olan ilgi de sürekli olarak artacağa benziyor. Bakalım 
gelişmeler neler getirecek hep birlikte göreceğiz…
