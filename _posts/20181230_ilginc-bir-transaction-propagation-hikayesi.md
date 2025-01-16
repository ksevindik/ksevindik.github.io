# İlginç Bir Transaction Propagation Hikayesi

Aşağıdaki örnekte Foo, Bar ve Baz şeklinde üç basit entity sınıf görüyorsunuz. Foo ve Baz içerisinde PK dışında hiçbir 
property mevcut değilken, Bar sınıfında ise not null özelliğinde bir name property’si tanımlı. Ayrıca bu entity’leri 
persist eden FooService ve BarService servis bean sınıflarımız da var.

```java
@Entity
public class Foo {
@Id
@GeneratedValue
private Long id;
}

@Entity
public class Bar {
@Id
@GeneratedValue
private Long id;

    @Column(nullable=false)
    private String name;
}

@Entity
public class Baz {
@Id
@GeneratedValue
private Long id;
}

@Service
public class FooService {

    @Autowired
    private BarService barService;

    @PersistenceContext
    private EntityManager em;

    @Transactional(propagation=Propagation.REQUIRED)
    public void foo() {
        em.persist(new Foo());
        barService.bar();
    }
}

@Service
public class BarService {
@PersistenceContext
private EntityManager em;

    @Transactional(propagation=Propagation.REQUIRES_NEW)
    public void bar() {
        em.persist(new Baz());
        try {
            em.persist(new Bar());
        } catch(Exception ex) {
            //ignore ex...
        }
    }
}
```

Dikkat ederseniz FooService’in transactional foo() metodu içerisinde EntityManager vasıtası ile bir Foo nesnesi persist 
edildikten sonra barService.bar() metodu çağrılıyor.

BarService’in bar() metodu da transactional, ancak propagation kuralı olarak REQUIRES_NEW tanımlı. Yani bar() metodu 
çağrıldığında ortamda mevcut bir transaction olup olmamasına bakılmaksızın yeni bir transaction başlatılacak ve Bar 
entity’sinin persist işlemi bu yeni transaction içerisinde gerçekleştirilecek.

Propagation REQUIRES_NEW kuralına göre, ortamda mevcut bir transaction varsa bu mevcut eski transaction, bar() metodu 
sonlanana değin suspend edilerek bekletilir, bar() metodu sonlandıktan sonra da kaldığı yerden devam eder.

BarService.bar() metodu içerisinde önce yeni bir Baz nesnesi, ardından da benzer biçimde yeni bir Bar nesnesi yaratılıp 
EntityManager.persist() metodu ile DB’ye insert ediliyor. Bar entity’sinin persist işlemi sırasında meydana gelebilecek 
herhangi bir hata da yakalanıp ignore ediliyor. Çünkü Bar nesnesi içerisinde not null tanımlı bir name property’si var 
ve buna herhangi bir değer set edilmeden insert edilmeye çalışıldığı için insert SQL’i çalıştırılırken DB’den bir constraint 
violation hatası meydana gelecektir. Uygulama içerisinde bu hata try/catch bloğu ile yakalanıp ignore ediliyor. Yani 
BarService.bar() metodunun başarılı biçimde sonlanması, böylece Spring’in dekleratif transaction yönetim kurallarına göre 
başarılı sonlanan metot için de transaction commit tetiklenmesi isteniyor.

Bu noktada sizce tam olarak ne olur? BarService.bar() metodu başarılı sonlandığı vakit Spring transaction’ı commit edip 
Baz entity’si, ardından da FooService.foo() metodu başarılı sonlanıp Foo entity’si DB’ye insert edilirler mi? Yoksa 
BarService.bar() metodu içerisinde Bar nesnesinin insertion işlemi sırasında meydana gelen constraint violation hatası 
ile Baz entity’si de Bar ile aynı transaction içerisinde olduğu için DB’ye eklenemez, ama FooService.foo() metodunun 
transaction’ı farklı olduğu için Foo entity’si DB’ye insert edilir mi? Ya da bunların dışında bir sonuçla mı karşılaşırız?

Cevap bir sonraki yazımızda 🙂