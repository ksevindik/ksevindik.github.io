# Hibernate’de Sınıf İlişkileri 1

Herhangi bir ORM çözümünün nesne model üzerinden çalışmayı sağlayabilmesi için öncelikle uygulamanın nesne modeli ile 
veri modeli arasında eşleştirme yapılması gerekir. Bu aşamada;

- sınıflar ile tablolar
- property’ler ile sütunlar
- sınıflar arası ilişkiler ile foreign key’ler
- java tipleri ile SQL veri tipleri

arasında eşleştirmeler yapılır.

Bu yazı dizimizde spesifik olarak JPA ve Hibernate’in sınıflar arası ilişkiler ile foreign key’ler arasında eşleştirme 
yapmamızı sağlayan yapılarını kategorik biçimde incelemeye çalışacağız. Sınıflar arası ilişkiler genel olarak aşağıdaki gibi gruplanarak incelenebilir;

- **Multiplicity:** yani ilişkinin çokluluğu, iki sınıf arasındaki ilişkinin multiplicity’si 1:1, 1:M, M:1 veya M:N şeklinde olabilir.
- **İlişkinin yönü:** Sınıflar arası ilişkiler tek yönlü (uni-directional) veya çift yönlü (bi-directional) olabilir.
- **Source ve target sınıfların türü:** İlişkiye giren sınıflar, Entity – Entity veya Entity – Component (Embeddable) şeklinde olabilir.

Bu gruplandırmaya ilave olarak 1:M veya M:N ilişkiler kendi içerisinde target sınıftan nesnelerin tutulduğu Java 
Collections API’sindeki tipe göre de gruplanabilir.

- **Collection türü:** List, Set, Map veya Bag (Collection) şeklinde olabilir.

Öncelikle entity-entity türündeki sınıflar arasındaki ilişkileri inceleyelim. En basit ilişki türü tek yönlü 1:1 ilişki 
olacaktır. Source entity sınıfındaki property üzerinde `@OneToOne` annotasyonu ile belirtilir. M:N ilişkiler haricinde 
diğer ilişkilerin bilgisi bir “join column” veya “join table” üzerinden yönetilebilir. Bunun için `@JoinColumn` veya 
`@JoinTable` annotasyonları kullanılır. İlişkiyi çift yönlü yapmak istersek bu durumda `@OneToOne` annotasyonu ilişkinin 
diğer tarafına da konmalıdır. Bu durumda Hibernate’in iki entity arasındaki ilişkiyi kurmak veya kaldırmak için uygulama 
kodu içerisinde hangi taraftaki property üzerinde yapılan değişiklikleri dikkate alması gerektiğini söylememiz gerekir. 
Bunun için `@OneToOne` annotasyonundaki `mappedBy` attribute’u kullanılır. `mappedBy` attribute’u `@ManyToOne` annotasyonu 
hariç diğer multiplicity belirten annotasyonların hepsinde mevcuttur. Çift yönlü ilişkilerde ayrıca `@JoinTable` veya 
`@JoinColumn` annotasyonları da ilişkiyi yöneten taraf üzerinden tanımlanmak zorundadır. Aksi takdirde JPA/Hibernate hata 
verecektir.

1:1 ilişkiyi sütun üzerinden yönettiğimiz takdirde, ilişkiyi “foreign key join column” veya “primary key join column” 
üzerinden yönetmek mümkündür. Genel olarak 1:1 ilişkileri foreign key üzerinden yönetmek daha pratiktir. Primary key join 
column yönteminde bir sınıfın primary key’i diğer sınıfın primary key’ine referans veren foreign key olmak zorundadır. Bu 
tür bir ilişkiyi kurmak için `@PrimaryKeyJoinColumn` annotasyonu kullanılır.

JPA ve Hibernate’in ilişkileri eager veya lazy yükleme özelliği vardır. Ancak Hibernate’in proxy yaklaşımından dolayı 
opsiyonel 1:1 ilişkilerde lazy yükleme yapmak mümkün olmayabilir.

Entity-component sınıfları arasında 1:1 ilişkiler ise `@Embedded` veya `@Embeddable` annotasyonları ile gerçekleştirilir. 
Normalde bir entity sınıf içerisindeki ilişki `@Embedded/@Embeddable` annotasyonları ile tanımlandığı takdirde target 
sınıfın property’lerine karşılık gelen sütunlar source sınıfın tablosunun içerisinde yer alır. Başka bir ifade ile nesne 
model üzerinde iki farklı sınıfa dağılmış bilgi, veritabanı düzeyinde ise tek tablo içerisinde toplanır. Veritabanı 
düzeyinde tek tablo içerisinde yönetilen bu ilişki nesne düzeyinde ise iki sınıfın 1:1 ilişkisine karşılık gelmektedir. 
Eğer tek tablo içerisinde tutulan bu bilgiyi iki ayrı tabloya dağıtmak istersek `@SecondaryTable` annotasyonundan 
yararlanabiliriz. Embeddable bileşene ait sütunlar burada ikincil tabloda yer alacaklardır.

Bir sonraki yazımızda M:1 ilişkilerin yönetimi ile devam edeceğiz.
