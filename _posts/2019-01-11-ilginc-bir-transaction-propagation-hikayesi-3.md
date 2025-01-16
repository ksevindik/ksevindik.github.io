# İlginç Bir Transaction Propagation Hikayesi 3

İlginç Bir Transaction Propagation Hikayesi başlıklı yazı dizisinin [ikinci bölümü](http://www.kenansevindik.com/ilginc-bir-transaction-propagation-hikayesi-2/)nde 
Foo, Bar ve Baz entity’lerinden hiçbirinin mevcut durumda DB’ye insert edilemediğini söylemiştim. Ancak problemde 
hedeflenen Bar entity’sini persist eden ifadeyi try/catch bloğuna alarak, mümkünse Baz ve Foo entity’lerinin Bar’ın 
insert işleminden etkilenmeden DB’ye insert edilmesidir.

Bar entity’si ile ilgili, DB’den gelen constraint violation hatası JPA PersistenceContext’in `PersistenceException` 
fırlatmasına neden olmaktadır. JPA’da fırlatılan `PersistenceException`’lar, birkaçı hariç (`NoResultException`, 
`NonUniqueResultException`, `LockTimeoutException`, ve `QueryTimeoutException`) aktif transaction’ın rollback’e set 
edilmesine neden olurlar. Dolayısı ile Baz entity’si de Bar ile aynı transaction’da persist edildiği için onun insert 
işlemi de Bar’la birlikte başarısız olmaktadır. Başka bir ifade ile Baz, Bar’dan bağımsız DB’ye insert edilememektedir.

Ancak Foo entity’si için durum böyle olmak zorunda değildir. Foo entity’sinin insert edildiği transaction ile Bar ve Baz 
entity’lerinin insert edildikleri transaction birbirlerinden tamamen bağımsızdırlar. Spring’in transaction yönetim altyapısı 
bir JPA transaction’ı aktif iken, yeni bir JPA transaction’ı başlatmak için mevcut transaction’ı suspend ederek yeni 
transaction’ı başlatır. Yeni bir JPA transaction’ı başlatmak demek eskisinden bağımsız yeni bir PersistenceContext 
(yani `EntityManager`) oluşturmak demektir.

Dolayısı ile ikinci `PersistenceContext`’de yapılan işlemler ve burada meydana gelen hata ilk `PersistenceContext`’i 
hiçbir şekilde etkilemeyecektir. Eğer ikinci servis metodundan (transaction commit/rollback yapan middleware kısmı dahil) 
fırlatılabilecek olası bütün exception’ları yakalayan bir `try/catch` bloğunu `foo()` metodu içerisinde `barService.bar()` 
metodunu çağırdığımız yere koyarsak, `bar()` metodu sonlanırken ortaya çıkabilecek her türlü exception `foo()` metodu 
içerisinde yakalanacaktır.

```java
@Transactional(propagation=Propagation.REQUIRED)
public void foo() {
    em.persist(new Foo());
    try {
       barService.bar();
    } catch(Exception ex) {
        //ignore ex...
    }
}
```

Böylece `foo()` metodu başarılı biçimde sonlanacak ve transaction’da commit edilebilecektir. Böylece Foo entity’si de 
DB’ye insert edilmiş olacaktır. Bu noktada `BarService.bar()` metodu içerisinde Bar entity’sinin persist edilmesi işlemini 
`try/catch` bloğu içerisine almak gereksizdir diyebiliriz.

Spring ile çalışırken `BarService.bar()` metodunun içerisinde unexpected rollback exception tetiklemeden sessiz biçimde 
transaction’ı rollback ettirmek de mümkündür.

```java
@Transactional(propagation=Propagation.REQUIRES_NEW)
public void bar() {
    em.persist(new Baz());
    try {
        em.persist(new Bar());
        em.flush();
    } catch(Exception ex) {
        //ignore ex...
        TransactionAspectSupport.currentTransactionStatus()
                 .setRollbackOnly();
    }
}
```

Bunun için öncelikle Bar entity’si `EntityManager.persist()` metodu ile persistent hale getirildikten sonra `PersistenceContext` 
üzerinde hemen bir `flush` tetikleyerek insert SQL’inin DB’ye gitmesi sağlanır. Bu aşamada constraint violation hatası 
nedeni ile `PersistenceException` meydana gelecektir, ama `PersistenceException` yakalanıp ignore edilmektedir. Ancak 
`PersistenceContext`’in artık `bar()` metodu başarılı biçimde sonlansa bile Spring’in transaction yönetim altyapısına 
transaction commit yapamayacağı, sadece rollback yapabileceği belirtilmelidir. Bu da mevcut transaction’a karşılık gelen 
`TransactionStatus` nesnesine erişip bunun `setRollbackOnly()` metodunu çağırarak olabilir. Artık Spring, yakalanan 
exception ignore edilip `bar()` metodu başarılı sonlansa bile transaction’ı commit yapmayacak, dolayısı ile transaction 
yönetim altyapısı da unexpected rollback exception ile karşılaşılmayacaktır.

