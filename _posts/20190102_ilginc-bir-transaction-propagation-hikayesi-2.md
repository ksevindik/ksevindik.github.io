# İlginç Bir Transaction Propagation Hikayesi 2

İlginç Bir Transaction Propagation Hikayesi isimli [blog yazımızın](http://www.kenansevindik.com/ilginc-bir-transaction-propagation-hikayesi/) 
ilk bölümünde `Foo`, `Bar` ve `Baz` entity’lerini insert eden `FooService` ve `BarService` bean’lerinin birbirlerini 
çağırırken, insert işlemlerini iki farklı transaction içerisinde yapmaya çalıştıklarından bahsetmiştik. Önce `FooService.foo()` 
metodu içerisinde `Foo` entity’si, ardından da `BarService.bar()` metodu içerisinde sıra ile `Baz` ve `Bar` entity’leri 
JPA `EntityManager` vasıtası ile persist ediliyorlardı. `Bar` entity’si içerisinde `nullable=false` şeklinde tanımlı bir 
property nedeniyle `Bar` entity’sinin DB’ye insert edilmesi sırasında bir constraint violation exception meydana geliyordu. 
Sorumuz da bu exception sonucunda, DB’de `Foo`, `Baz` ve `Bar` entity’lerinden hangilerinin insert edilip edilmeyeceği 
şeklindeydi.

Aslında `Bar`’ın persist edilme bölümünde bu senaryonun sonucunu etkilemeyen ama constraint violation’ın tam olarak meydana 
geleceği noktayı veritabanı spesifik hale getiren eksik bir ifadenin olduğunu fark ettim.

JPA, `PersistenceContext`’te biriken entity state değişikliklerini (insert, update ve delete operasyonları) transaction 
commit anında topluca gerçekleştirir. Bu yaklaşıma “transaction write behind” adı da verilmektedir. Dolayısıyla `EntityManager.persist()` 
metodunun invoke edildiği tam o anda, gerçekten de DB’ye bir SQL insert ifadesi gitmeyebilir. Bu insert TX commit aşamasına 
kadar ötelenebilir. Sonuç olarak, constraint violation hatasının, `Bar` entity’sinin persist edildiği ilgili kod bloğu 
tarafından catch edilmesi söz konusu olmayabilir.

```java
try {
    em.persist(new Bar());
} catch(Exception ex) {
//ignore ex...
}
```

Bu durumda constraint violation hatası `bar()` metodunun sonlandığı ve Spring `TransactionManager` bean’inin aktif 
transaction’ı commit etmeye çalıştığı anda meydana gelecektir.

“Transient entity’yi DB’ye insert edecek SQL insert ifadesinin tam olarak `EntityManager.persist()` metodu çağrıldığı 
vakit yürütülmesi hangi durumda söz konusu olmaktadır?” gibi bir soru sorarsak, buna cevabımız “DB’nin sentetik PK üretme 
stratejisi olarak default yönteminin `identity` veya `autoincrement` yöntemlerinden birisi olması durumunda” şeklinde 
olacaktır. Spesifikasyon gereği JPA, `PersistenceContext`’e eklenen transient nesnelere hemen bir PK değeri atamak zorundadır. 
Sentetik PK üretme stratejisinin `identity` veya `autoincrement` olduğu durumda PK değerini elde etmenin tek yolu entity’ye 
karşılık gelen bir kaydı DB’ye o anda insert etmektir. Bu durumda da constraint violation hatası tam olarak `EntityManager.persist()` 
ifadesinin çağrıldığı yerde olacak ve exception `try..catch` bloğu tarafından da yakalanıp ignore edilebilecektir.

DB’nin default sentetik PK üretme stratejisi `sequence`, `UUID` vb. olursa kayıt DB’ye insert edilmeden de rahatlıkla bir 
PK değeri üretilebileceği için yeni persist edilen bir entity’ye ait insert SQL’i TX commit anına kadar ötelenir ve bu 
senaryodaki hata da `try..catch` bloğuna düşmeyecektir.

Sentetik PK üretme stratejisinin `sequence`, `UUID` vb. olduğu senaryolarda da `EntityManager.persist()` metodu çağrılır 
çağrılmaz entity’ye ait SQL insert ifadesinin DB’ye yansıtılması da mümkündür. Bunun için `PersistenceContext`’in `flush()` 
metodu kullanılır.

```java
try{
    em.persist(new Bar());
    em.flush();
} catch(Exception ex) {
    //ignore ex...
}
```

Yukarıdaki kod bloğunda olduğu gibi, persist() metot çağrısından hemen sonra yapılacak bir `flush()` metot çağrısı `PersistenceContext`’te 
birikmiş state değişikliklerini topluca DB’ye yansıtacaktır. Böylece `Bar` entity’sinin `nullable=false` tanımlı property’sinin 
`NULL` bırakılmasından kaynaklı constraint violation hatası da hemen o anda ortaya çıkacak ve `try..catch` bloğu tarafından 
da handle edilebilecektir.

Ancak DB sentetik PK stratejisinin türü veya `persist()` işleminden sonra `flush()`’ın çağrılıp çağrılmaması senaryomuzda 
ortaya çıkacak sonucu değiştirmemektedir. Exception ister persist anında, isterse TX commit anında fırlatılsın bu senaryo 
sonucunda `Foo`, `Baz` ve `Bar` entity’lerinden hiçbiri DB’ye insert edilmezler. Yani hem `FooService.foo()` metodunda 
başlatılan transaction, hem de `BarService.bar()` metodunda `Propagation.REQUIRES_NEW` ile tetiklenen yeni transaction’ın 
her ikisi de rollback olmaktadır. Bunun nedeni de JPA’nın, constraint violation hatası meydana geldiği anda `PersistenceContext`’e 
ait aktif transaction’ı ilerleyen adımlarda sadece rollback yapılabilir diye işaretlemesidir. Farz edelim ki `EntityManager.persist()` 
metodu çağrıldığı anda veya bu ifadeden sonra yer alan bir `flush()` metot çağrısı ile birlikte constraint violation hatası 
fırlatılmış olsun. Hata bizim `try..catch` bloğumuz tarafından yakalanıp ignore edilse bile, JPA bu hata dolayısıyla 
transaction’ı rollback’e set etmektedir. Daha sonra `bar()` metodu başarılı biçimde sonlanıp Spring `TransactionManager` 
transaction’ı commit etmeye çalışsa bile JPA/Hibernate’in fiziksel transaction’ı rollback’e işaretlemesinden ötürü Spring’in 
transaction’ı da fail eder ve commit aşamasında `UnexpectedRollbackException` şeklinde bir hata fırlatır. Bu hata da bir 
üstteki `foo()` metoduna ulaşır ve onun da dışına çıkarak `RuntimeException` ile sonlanmasına neden olur. Bu durumda `foo()` 
metoduna ait Spring transaction’ı da rollback edilir ve sonuç olarak `Foo` entity’si de DB’ye insert edilememiş olunur.

`BarService.bar()` metodu içerisinde `Bar` ve `Baz` entity’lerinin constraint violation hatası meydana geldiği müddetçe 
hiçbir biçimde DB’ye insert edilmeleri mümkün olamaz. Ancak `FooService.foo()` metodu içerisindeki `Foo` entity’si için 
aynı durum söz konusu değildir. Yani `Foo` entity’si diğerlerinden bağımsız olarak DB’ye insert edilebilir. Peki bunun 
için ne yapabiliriz, hangi yöntemleri kullanabiliriz? Gelin bunu da bir sonraki yazımızda ele alalım…

