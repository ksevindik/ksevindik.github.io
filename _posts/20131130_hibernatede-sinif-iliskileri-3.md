# Hibernate’de Sınıf İlişkileri 3

Hibernate ORM Framework’ündeki sınıflar arası ilişki kurma yöntemlerini incelediğimiz yazı dizimize üçüncüsü ile devam 
ediyoruz. İlk iki yazımızda

[1:1](http://www.kenansevindik.com/hibernatede-sinif-iliskileri-1/)  
[M:1](http://www.kenansevindik.com/hibernatede-sinif-iliskileri-2/)  

ilişkileri incelemiştik. Bu bölümde ise 1:M ilişkileri inceleyeceğiz.

Öncelikle sadece entity – entity şeklindeki ilişkilere odaklanalım. Daha sonra entity – component arasındaki ilişkilere 
de bakacağız. İki entity arasında 1:M ilişki kurmak için `@OneToMany` annotasyonu kullanılır.

1:M ilişkiler, normal entity – entity ilişkileri ve parent – child entity – entity ilişkileri olmak üzere kendi içinde 
de ikiye ayrılır. 1:M parent – child ilişkilerin normal 1:M ilişkilerden farkı child entity’nin parent’dan bağımsız 
biçimde var olamamasıdır. Child entity’nin parent ile olan bağı koparıldığı anda child entity’nin veritabanından da 
silinmesi söz konusudur. Maalesef bu tür 1:M ilişkiler JPA 2.0’a kadar doğrudan spesifikasyon tarafından desteklenmemiştir. 
Hibernate 1:M parent-child ilişki davranışını `CascadeType.DELETE_ORPHAN` enum değeri ile cascade mekanizması üzerinden 
sağlamaktadır. JPA 2.0 ile birlikte 1:1 ve 1:M ilişkilere `orphanRemoval` şeklinde bir attribute eklenerek ilişkinin 
parent-child veya diğer bir ifade ile “part-whole” ilişkisi olduğunu belirtmek mümkün hale gelmiştir. Hibernate’e özel 
`CascadeType.DELETE_ORPHAN` enum değeri ise Hibernate 4.x sürümünde deprecated olmuştur.

Eğer ilişki çift yönlü ise ilişkinin diğer tarafı doğal olarak M:1’dir. Çift yönlü ilişkilerde Hibernate’e ilişkiyi kimin 
yönettiğinin söylenmesi gerekir. İlişkiyi yönetmek demek Hibernate’e uygulama içerisinde çalışma zamanında iki entity 
arasında bir foreign key ilişkisi kurmak veya mevcut bir foreign key ilişkisini kaldırmak için hangi sınıfın hangi 
attribute’una bakacağının belirtilmesi demektir. Çift yönlü ilişkilerde ilişkiyi yöneten taraf genellikle M:1 tarafı olur. 
Çift yönlü ilişkiyi yöneten M:1 tarafı, `@OneToMany` annotasyonunun `mappedBy` attribute’u ile belirtilir. Değer olarak 
da M:1 tarafının tanımlı olduğu property’nin ismi yazılır. Eğer `mappedBy` attribute’u kullanılmış ise ilişkinin 1:M 
tarafında yapılan işlemlerin yani collection’a entity koyma/çıkarma işlemlerinin Hibernate için çalışma zamanında hiçbir 
önemi yoktur. O ilişki kurmak veya ilişkiyi kaldırmak için `mappedBy` attribute’u ile belirtilen target entity’nin ilgili 
property’sinin değerine bakacaktır. Eğer bir değer set edilse de foreign key ilişkisi kuracak, değer NULL ise varsa daha 
önceden kurulmuş olan DB’deki foreign key ilişkisini de sonlandıracaktır. Collection’a yapılan ekleme ve çıkarmalar 
tamamen uygulama tarafı için gereklidir.

1:M ilişkiler `@JoinColumn` veya `@JoinTable` annotasyonları ile DB’deki tablolarla eşleştirilebilir. `@JoinTable` 
annotasyonu kullanılırsa `joinColumns` ve `inverseJoinColumns` attribute’larına uygun değerler girilmesi önemlidir. 
Bu konu ile ilgili açıklama için bir önceki bölüme bakabilirsiniz. Eğer ilişki çift yönlü ise `@JoinColumn` veya 
`@JoinTable` annotasyonları ancak ilişkiyi yöneten tarafta kullanılabilir. Başka bir ifade ile eğer `@OneToMany` 
annotasyonunda `mappedBy` attribute’u varsa bu tarafta bu annotasyonları kullanamazsınız.

1:M ilişkiler default olarak LAZY‘dir. Başka bir ifade ile ilişkiyi barındıran entity’nin yüklenmesi ilişkinin diğer 
tarafındaki entity’lerin de yüklenmesi anlamına gelmez. İlişkili entity’lerin yüklenmesi için ya collection’a yeni bir 
eleman eklenmesi veya çıkarılması, ya collection’daki herhangi bir elemana erişilmesi, ya da collection’ın `size`, 
`contains` gibi metotlarına erişilmesi gerekir. Lazy davranış `@OneToMany` annotasyonunun `fetch` attribute’una 
`FetchType.EAGER` değeri atanarak EAGER‘a çevrilebilir.

1:M ilişkilerde hedef entity’lerin tutulduğu collection’ın tipine göre ilişkilere set, list, bag veya map ilişkileri 
denmektedir. En basit ve performanslı ilişki türü bag ilişkileridir. Bag collection tipi kural olarak tekrarlayan 
elemanlara izin verir, ama elemanların collection’a ekleme sırasını takip etmez. Bilindiği gibi Java’nın Collection 
API’sinde doğrudan bag tipini destekleyen bir veri yapısı yoktur. Bu nedenle Collection API’sindeki `java.util.List`, 
bag tipinde collection’lar oluşturmak için de kullanılmaktadır. Bag tipli 1:M ilişkilerde dikkat edilmesi gereken bir 
nokta vardır. Aynı entity içerisindeki iki 1:M bag ilişkisi aynı anda EAGER yüklenemez.

Fazla efor sarf etmeden kurulabilecek diğer bir 1:M ilişki türü de set’dir. Set tipli collection içinde aynı elemandan 
tek bir tane tutulabilir fakat elemanların ekleme sıraları korunmaz.

Bir sonraki yazımızda 1:M ilişkileri incelemeye devam edeceğiz.
