# Hibernate’de Sınıf İlişkileri 2

Hibernate’de sınıflar arası ilişkileri incelediğimiz yazı dizimizin [ilk bölümü](http://www.kenansevindik.com/hibernatede-sinif-iliskileri-1/)
nden sonra ikinci bölüm ile devam ediyoruz. Bu bölümde M:1 ilişkiler üzerinde duracağız.

M:1 ilişkiler entity-entity veya component-entity şeklinde olabilir. Fakat target sınıfın component yani “Embeddable” 
olması mümkün değildir. Çünkü herhangi bir bileşenin ancak ve ancak tek bir sahibi olabilir. Birden fazla entity 
instance’ın ortak bir bileşene refer etmesi mümkün değildir.

entity-entity arasında tek yönlü M:1 ilişki kurmak için `@ManyToOne` annotasyonu kullanılır. İlişkinin zorunlu olup 
olmadığı `optional` attribute ile gösterilir. İlişki veritabanında join cloumn veya join table üzerinden yönetilebilir. 
Join column üzerinden yönetmek için `@JoinColumn` annotasyonu kullanılır. `nullable` attribute ile foreign key’in 
NULL/NOT NULL olup olmadığı belirtilebilir. `optional` attribute ilişkinin zorunluluğunu, `nullable` attribute ise 
foreign key’in null olup olmayacağını belirlemesine rağmen, mevcut hibernate sürümlerinde her ikisinden birisinin 
ilişkinin zorunlu olduğunu belirten bir değer alması üretilen DDL ifadesinde foreign key sütununun da NOT NULL olmasını 
sağlamaktadır. Konu ile ilgili 4.x sürümleri için açık bir [bug](https://hibernate.atlassian.net/browse/HHH-8229) mevcuttur.

Optional attribute’un önemi M:1 ilişkinin `@JoinTable` ile map edilmesinde ortaya çıkar. `optional=false` olarak işaretlenmiş 
bir M:1 ilişkiye sahip bir entity persist edilmek istendiğinde Hibernate ilişkinin değerinin olmadığını tespit ederek daha 
SQL ifadesi çalıştırmadan `org.hibernate.PropertyValueException: not-null property references a null or transient value` 
hatası üretir. Hibernate 4.x sürümlerinde ilişki `@JoinTable` ile map edilmiş ise malesef property değerinin null olup 
olmadığı kontrol edilmeden entity DB’de persist edilmesine neden olan bir bug mevcuttur. Veri modeli açısından herhangi 
bir tutarsızlık söz konusu olmamasına rağmen Hibernate metadatasında zorunlu olduğu söylenen bir ilişkiye sahip olmadan 
entity instance’ının persist edilmesi doğru değildir. Bu bug 4.1.12‘de fix’lenmiştir.

Tablolar arası ilişkileri yönetmek için kullanılan join table yönteminde dikkat edilmesi gereken temel nokta `@JoinTable` 
annotasyonundaki `joinColumns` ve `inverseJoinColumns` attribute’larının değerleridir. `JoinColumns` source entity’nin PK 
sütunlarına, `inverseJoinColumns` ise target entity’nin PK sütunlarına foreign key ilişkiler kurmalıdır.

Tek yönlü ilişkilerde component-entity için de M:1 ilişkilerin kurulması mümkündür. Buradaki tanımlama da aynen 
entity-entity M:1 ilişkilerinde olduğu gibidir.

Çift yönlü M:1 ilişkilerde ise ilişkinin diğer tarafı 1:M olarak ele alınmaktadır. 1:M ilişkili entity’lerin tutulduğu 
collection’ın `List` olmadığı durumlarda çift yönlü ilişkiyi yöneten genellikle M:1 tarafı olarak belirtilir. Bunun için 
`@OneToMany` annotasyonundaki `mappedBy` attribute’u kullanılır. 1:M ilişkileri inceleyeceğimiz bir sonraki yazımızda 
`@OneToMany` annotasyonu üzerinde ayrıntılı biçimde duracağız.

`@ManyToOne` annotasyonu `mappedBy` attribute’una sahip değildir. Dolayısı ile çift yönlü ilişkilerde M:1 tarafını 
ilişkiyi yöneten taraf yapmamak için farklı bir yol izlenmektedir. Çift yönlü ilişkilerde M:1 tarafını salt okunur yapmak 
için `@JoinColumn` annotasyonunun `insertable`, `updateable` attribute’ları kullanılmaktadır. `insertable=false` ve 
`updateable=false` olarak tanımlanan çift yönlü bir M:1 ilişki salt-okunur bir ilişki halini alacak, böylece ilişkinin 
yönetimi 1:M tarafında olacaktır.

1:M ilişkileri inceleyeceğimiz bir sonraki yazımızda görüşmek üzere...
