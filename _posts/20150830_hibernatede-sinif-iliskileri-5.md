# Hibernate’de Sınıf İlişkileri 5

Hibernate’de sınıf ilişkilerini incelediğimiz yazı dizimizin [bir önceki bölümü](http://www.kenansevindik.com/hibernatede-sinif-iliskileri-4/)nde 
entity’ler arasındaki 1:M türünden ilişkileri ele almıştık. Bu bölümde ise target sınıfı component yani bileşen olan 1:M 
ilişkileri inceleyeceğiz. Bildiğimiz gibi bileşenler sadece tek bir entity instance’a ait olabilirler ve kendi başlarına 
var olamazlar. Başka bir ifade ile ait oldukları parent entity instance’ın yaratılmasından sonraki bir zamanda onunla 
ilişkilendirilerek yaratılırlar, ve parent entity ile olan ilişkileri ortadan kalktığı anda da veritabanından da 
silinirler.

entity – component 1:M ilişkisi source entitydeki collection property’si üzerinde @ElementCollection anotasyonu ile 
tanımlanır. Hedef bileşen sınıfı basic Java tipinden bir sınıf, yani Integer, Long, String, Boolean, Date vb, veya 
@Embeddable anotasyonu ile işaretli custom bir sınıf olabilir.

Varsayılan durumda 1:M ilişkiler LAZY tanımlandıkları için parent entity yüklendiğinde ilişkili bileşenler yüklenmezler. 
Parent entity yüklendiği anda ilişkili bileşenlerin de yüklenmesi için @ElementCollection’ın fetch attribute’unun değerinin 
FetchType.EAGER olarak set edilmesi gerekir. 1:M bileşen içeren ilişkiler tek yönlü veya çift yönlü olarak tanımlanabilir. 
Hibernate’e özel @Parent anotasyonu bileşen sınıfının içerisinde parent entity property’si üzerinde kullanılarak bileşen 
içerisinden parent entity’ye erişilmesi sağlanabilir. JPA tarafından bu anotasyon desteklenmemektedir. JPA’da ise 
bileşenden ait olduğu parent entity’ye referans normal bir M:1 ilişki tanımı ile gerçekleştirilebilir. Bileşen içerisinde 
M:1 ilişkileri sadece parent entity’ye doğru değil herhangi türden bir entity’ye doğru da kurulabilir.

1:M bileşen içeren ilişkilerde bileşenlere ait veri ayrı bir tabloda tutulur. Bu tablonun yönetilmesi için JPA 
@CollectionTable anotasyonunu sunmaktadır. @CollectionTable anotasyonu ile tablonun ismi, bileşen tablosundan parent 
entity’nin tablosuna olan join column’un ismi vs yönetilebilir. Bileşen tablosundaki diğer sütun veya sütunlar ise 
bileşenin sınıfı üzerinden elde edilmektedir. Eğer bileşen sınıfı basic bir Java tipinden ise sütun ismi @CollectionTable 
anotasyonu ile birlikte kullanılan @Column anotasyonundan elde edilecektir. Eğer bileşen sınıfı @Embeddable anotasyonu ile 
işaretlenmiş custom bir tip ise bu durumda sütun isimleri hedef sınıfın property’lerindeki @Column tanımlarından elde 
edilecektir.

Collection tipi bag, list, set veya map olabilir. List tanımı için entity-entity ilişkilerinde olduğu gibi @OrderColumn 
anotasyonu kullanılması gerekir. Map için ise key değerlerinin tutulduğu sütun @MapKeyColumn anotasyonu ile belirtilmelidir. 
Burada eğer bileşen tipi embeddable bir sınıf ise key column embeddable sınıfın persistent property’lerinin dışında bir 
sütuna karşılık gelmelidir. Aksi takdirde Hibernate hata verecektir.

Yazı dizimize M:N ilişkilerle devam edeceğiz.
