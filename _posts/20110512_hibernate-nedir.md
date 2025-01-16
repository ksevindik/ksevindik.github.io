# Hibernate Nedir?

![](images/what_is_hibernate.jpeg)

Bu soruya hepimizin vereceğimiz cevap hemen hemen şu şekildedir: “Hibernate bir object relational mapping framework’dür.” 
“object relational mapping framework”ün ne olduğuna dair sorduğumuzda ise aldığımız cevaplar

- nesnelerle tablolar, nesnelerin property’leri ile tabloların sütunları, nesneler arasındaki ilişkilerle tablolar arasındaki foreign key’ler arasında eşlemeler yapan bir araçtır
- uygulama içerisinde -mümkün olduğunca- nesne dünyaya odaklanarak relational dünyadan bizi soyutlamaya çalışır
- nesneler üzerinde yaptığımız `insert`, `delete`, `update` gibi işlemler ve sorgular için yazılması gereken SQL’leri bizim yerimize üretip, çalıştırır

şekline olmaktadır. Evet, bütün bu tanımlar ve açıklamalar doğrudur. Ancak, bunların hepsi karanlıkta fili, değişik 
uzuvlarını elleyerek tarif etmeye çalışan Hintlilerin çabasına benzemektedir. Hibernate ile ilgili olarak işin özünü 
ıskalamaktadırlar.

Aslında Hibernate ve benzeri ORM araçlarının özü “persistent state” yönetimidir. Nesneler bir Java process’i içerisinde 
yaratıldıkları zaman “transient” state’dedirler. Eğer Java process’i sonlanırsa nesnenin ömrü de sona ermiş olur. Nesne 
üzerine yapılan değişiklikler vb. Java process’i dışında bir yerde saklanmaz ise process’in sonlanması ile bütün bu 
değişiklikler de kaybolacaktır. İşte, Hibernate nesneler üzerine meydana gelen bu state değişikliklerini takip eden, 
değişiklikleri ilişkisel veritabanında saklayan ve Java process’i sonlandıktan sonra da aynı state’i bir sonraki Java 
process’ine tekrar oluşturabilmemizi sağlayan bir framework’dür.

Hibernate `Session` ile yüklenmiş bir entity üzerine yaptığınız değişiklikler sonrasında transaction’ın bitişiyle birlikte 
Hibernate, `Session` içerisinde değişikliğe uğramış entity’leri teker teker tespit eder ve değişikliğe uğramış entity’ler 
için otomatik olarak SQL `UPDATE` ifadesini çalıştırır. Sizin explicit biçimde `session.update()` metodunu çağırmanıza 
gerek yoktur. Aslında `Session.update` metodunun asıl amacı `Session`dan koparılmış yani “detached” nesneler üzerinde 
değişiklik yapıldığını Hibernate’e bildirmekten başka bir şey değildir.

Asıl amacının persistent nesnelerin state yönetimini yapmak olduğunu bildiğiniz takdirde hem Hibernate’i öğrenme süreci 
çok daha kolay hale gelebilir, hem de bu framework’ü projelerinizde çok daha doğru ve etkin biçimde kullanabilirsiniz.

