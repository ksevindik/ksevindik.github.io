# Hibernate’de Sınıf İlişkileri 6

Bir önceki [yazımız](http://www.kenansevindik.com/hibernatede-sinif-iliskileri-5/)da 1:M entity-bileşen türü ilişkileri 
incelemiştik. Bu yazımızda ise M:N ilişkileri incelemeye başlayacağız.

M:N ilişkiler sadece entity’ler arasında olabilir. İlişkili entity’lerin bilgisi veritabanında bir “association tablo“da 
tutulur. İlişkiler tek veya çift yönlü olabilirler. Eğer çift yönlü bir M:N ilişki varsa, taraflardan birisi bu ilişkiyi 
yöneten olarak tanımlanmalıdır. Hedef entity’lerin tutulduğu `Collection` sınıfının türüne göre de M:N ilişki `List`, 
`Set`, `Bag` veya `Map` şeklinde olabilir.

M:N ilişki kurmak için `@ManyToMany` anotasyonu kullanılır. Eğer ilişki çift yönlü ise ilişkinin diğer tarafına da 
`@ManyToMany` anotasyonu yerleştirilir. Çift yönlü ilişkilerde yöneten taraf `mappedBy` attribute ile tanımlanır. İlişki 
ister tek, isterse çift yönlü olsun association tablo tanımı yapılmalıdır. Bunun için `@JoinTable` anotasyonu kullanılır. 
`@JoinTable` anotasyonunda tablo isminin yanı sıra her iki entity’nin tablolarına doğru kurulacak FK ilişkilerinin 
bilgilerinin de belirtilmesi gerekir. `joinColumns` attribute’una source entity’nin PK’sına, `inverseJoinColumns` 
attribute’unda ise target entity’nin PK’sına doğru referans verilmesi gerekir. Bu referanslar association tablo’da iki 
ayrı sütun olarak karşılık bulur.

M:N ilişkilerinde genellikle association tablo içerisinde ilişkili tablolara FK veren bu iki sütun dışında ilave başka 
bilgilerin de tutulması söz konusudur. Bu ilave bilgiler ilişki ile ilgili bilgilerdir. Örneğin, ilişkinin kim tarafından 
kurulduğu, ne zaman kurulduğu, geçerlilik süresi vb. Böyle bir durumda association tablonun da ayrı bir entity veya 
bileşen sınıf ile eşleştirilmesi gerekir. Association tablo da ayrı bir entity ile eşleştirildiği vakit bu durumda M:N 
ilişki iki tane 1:M ilişkiye dönüşmektedir. Association tablo bir entity veya embedabble ile eşleştirilebilir. Her 
ikisinin de kendine göre artı ve eksileri vardır.

Association tablo entity ile eşleştirildiği vakit asıl M:N ilişkisinin her iki yanından da bu “association entity“ye 1:M 
referanslar verilebilir. Association entity’den de bu source ve target entity’lere M:1 referans verilebilir. Association 
tablonun entity ile eşleştirilmesinin en önemli artısı M:N ilişkideki her iki entity’den de association entity’ye referanslar 
verilebilmesidir. Association entity kendi başına Hibernate’deki entity’lerin yaşam döngüsüne dahil olacaktır. Bu durumda 
da association entity’nin collection’dan çıkarılması entity’nin silinmesi anlamına da geleceği için genellikle bu tür 1:M 
ilişkiler `orphanRemoval=true` attribute ile parent-child şeklinde tanımlanmaktadır.

Diğer senaryo ise association tablo’nun entity yerine embeddable bir bileşen sınıf ile eşleştirilmesidir. Association 
tablo bir bileşen sınıf ile eşleştirildiği takdirde asıl M:N ilişkideki source ve target entity’lerin hangisinde bu 
bileşenleri içeren collection’ın tanımlanacağına karar vermek gerekir. Çünkü bileşenler sadece ve sadece tek bir entity 
instance’ına ait olabilirler. Ancak bileşen içerisinden bir veya daha fazla farklı türde entity ile M:1 ilişki kurulması 
mümkündür. Bu şekilde association tablo bir embeddable ile eşleştirilerek M:N ilişki association tablosuna karşılık gelen 
bileşen ile birlikte tanımlanmış olur.

M:N ilişkiler lazy veya eager olarak tanımlanabilir. Default olarak M:N ilişkiler lazy’dir. Ancak `@ManyToMany` 
anotasyonundaki `fetchType` attribute’una değer olarak `FetchType.EAGER` değeri verilerek M:N ilişki eager yüklenebilir.

Bu yazı ile birlikte, Hibernate’de sınıf ilişkilerini incelediğimiz altı bölümlük yazı dizimizi tamamlamış oluyoruz. 
Sonuç olarak, Hibernate’de veya JPA’da sınıflar arası ilişkilerin iş mantığının ve veri modelin ihtiyaçlarına göre uygun 
ve doğru biçimde oluşturulmasının çalışma zamanındaki persistence işlemlerinin sağlıklı ve hızlı biçimde yürütülmesi için 
oldukça önemli olduğunu söyleyebiliriz.
