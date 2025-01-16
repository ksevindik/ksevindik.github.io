# Hibernate’de Sınıf İlişkileri 4

Hibernate’deki sınıf ilişkilerini incelediğimiz yazı dizimizin [bir önceki bölümü](http://www.kenansevindik.com/hibernatede-sinif-iliskileri-3/)nde 
1:M ilişkileri incelemeye başlamıştık. Sınıflar arası ilişkilerde en detaylı ilişki türü olan 1:M ilişkileri kaldığımız 
yerden incelemeye devam edelim.

1:M ilişkilerde kullanılan diğer bir collection tipi ise `java.util.List`'dir. List duplikasyona izin verir ve elemanların 
eklenme sıralarını da korur. Dolayısıyla elemanların liste içerisindeki sırasının veritabanında bir sütunda tutulması 
gerekir. Buna “index column” adı verilmektedir. Bu sütun JPA 2'de `@OrderColumn` annotasyonu ile tanımlanabilmektedir. 
JPA 2 öncesi Hibernate’e özel `@IndexColumn` annotasyonunun kullanılması gerekmekteydi. `@OrderColumn` ile `@IndexColumn` 
annotasyonlarının işlevleri aynı olmasına rağmen aralarında ufak bir fark vardır. `@IndexColumn` annotasyonu ile sıranın 
sıfırdan başka herhangi bir değerden başlaması sağlanabilir. `@OrderColumn`'da ise sütun değerleri mutlaka sıfırdan 
başlamak zorundadır.

List türündeki 1:M ilişkiler performans açısından en problemli olan ilişki türüdür. Liste içerisine yapılan ekleme ve 
çıkarmalar elemanların index column değerini değiştirebileceği için Hibernate, index column değerlerini birkaç `UPDATE` 
ile güncelleme yoluna gidebilmektedir. Bu da eleman sayısının fazla olduğu ve elemanların sıralarının sıkça değiştiği 
durumlar için pek uygun değildir.

List tipli ilişkileri `@JoinColumn` ile eşleştirmek en sağlıklı yöntem olacaktır. Hibernate `@JoinTable` ile tanımlanmış 
liste tipli ilişkileri yönetirken bazı problemlere neden olmaktadır. Eğer `@JoinTable` kullanmışsanız ve liste içindeki 
bir elemanı silmişseniz, Hibernate garip biçimde listenin son elemanını silmeye çalışmaktadır. Konuyla ilgili olarak daha 
detaylı bilgi için bu [bug](https://hibernate.atlassian.net/browse/HHH-5694)’a bakabilirsiniz.

1:M list tipli ilişki eğer çift yönlü bir ilişki ise dikkat etmemiz gereken bir nokta daha vardır. Çift yönlü 1:M list 
ilişkide ilişkiyi yöneten tarafı belirtmek için `mappedBy` attribute’unu `@OneToMany` annotasyonu üzerinde kullanırsak 
ilişkiyi M:1 tarafı yöneteceği için Hibernate uygulama içerisinde çalışma zamanında liste içerisine yapılan ekleme ve 
çıkarmalara dikkat etmeyecek, bu durumda da index column değerleri sağlıklı biçimde yönetilemeyecektir. `@ManyToOne` 
annotasyonu ise `mappedBy` attribute içermez. `mappedBy` attribute 1:M tarafında da kullanılmadığı takdirde ilişki aynı 
anda hem 1:M, hem de M:1 tarafından yönetilecektir. Böyle bir durumda Hibernate ilişkinin yönetilmesi için birden fazla 
SQL ifadesi üretebilir. Ayrıca teknik olarak burada aynı tür iki entity arasında çift yönlü bir 1:M ilişkisi değil, tek 
yönlü 1:M ve M:1 şeklinde iki farklı ilişki söz konusudur. İş mantığına göre bazen bu şekilde ilişkiler olabilir. Ancak 
çift yönlü 1:M ilişki ihtiyacı söz konusu olduğunda bu yanlış bir eşleme anlamına gelmektedir. Kısaca çift yönlü liste 
tipli ilişkiler mutlaka 1:M tarafı üzerinden yönetilmelidir. Çift yönlü 1:M list ilişkinin source entity tarafını yöneten 
taraf yapmak için gereken, aynı `@JoinColumn` annotasyonunu iki tarafta da tanımlamak ancak M:1 tarafının `insertable` 
ve `updateable` attribute’larını “false” yaparak bu tarafın salt okunur bir ilişki olmasını sağlamaktır.

Map kullanılan 1:M ilişkileri ise en nadir karşımıza çıkan ilişkilerdir. Ancak bazı özel senaryolarda oldukça kullanışlı 
olabilmektedirler. Bilindiği üzere `java.util.Map` Java Collection API’sine dahildir, ancak bir collection değildir. 
key-value ikililerini tutar. Key değerleri map içerisinde benzersiz olmalıdır. Başka bir ifade ile key değerleri 
üzerinden map içerisinde duplikasyona izin verilmez. Eklenen key-value pair’lerinin ekleme sıraları ise korunmaz. Value 
değerleri entity olan map tipli 1:M ilişkilerde key değerlerinin ne olacağı `@MapKey` annotasyonu ile belirtilmelidir. 
`@MapKey` annotasyonuna verilen değer hedef entity’nin sınıfındaki bir “property“nin ismi olmalıdır. En sık düşülen 
hatalardan birisi buraya sütun ismi yazmaktır. Bu property ayrıca “persistent” bir property olmalıdır.

Bir sonraki yazımızda bileşen içeren 1:M ilişkileri daha yakından inceleyeceğiz.
