# Kotlin ve Hibernate Getter Level Access

JPA/Hibernate ile çalışırken PersistenceContext’in entity nesnelerin state’ine doğrudan field düzeyinde mi, yoksa getter 
metot ile mi erişeceğini @Id anotasyonunu nerede kullandığımız belirlemektedir. Eğer @Id anotasyonunu field üzerinde 
kullanırsak, JPA/Hibernate field level access stratejisini kullanacaktır, yani entity state’lerine erişmek ve veritabanından 
okuduğu değerleri entity nesnenin içerisine aktarmak için getter/setter metotlarını kullanmayıp, doğrudan Reflection API 
ile nesnenin field’ına erişecek veya değeri field’a set edecektir. Eğer @Id anotasyonunu getter metot üzerinde kullanırsak 
bu durumda da getter/setter metotlarından yararlanacaktır.

PersistenceContext’deki işlemler için getter/setter metotlara dokunmadan field level access kullanılması daha kullanışlıdır, 
böylece getter/setter metotlara bir takım “custom logic” ekleme şansımız olur, validasyon kontrolleri vs yapabiliriz.

Kotlin ile çalışırken çoğunlukla domain sınıflarında sadece constructor parametreleri yada instance değişkenleri tanımlarız. 
Kotlin compiler bizim için getter/setter metotları otomatik olarak üretmektedir. Entity sınıfları yazarken de id ve version 
attribute’larını genellikle instance değişken olarak tanımlarız, JPA anotasyonlarını da bunların üzerine koyarız.

```kotlin
@Entity
class Foo(var name:String) {
    @Id
    @GeneratedValue
    @Column(name = "id", nullable = false)
    var id: Long? = null

    @Version
    @Column(name = "version", nullable = false)
    var version: Long = 0
}
```

Id ve version dışındaki diğer attribute’ları ise eğer nesnenin oluşturulması sırasında girilmesi zorunlu alanlar ise 
çoğunlukla constructor parametresi şeklinde tanımlarız.

Varsayılan durumda @Id anotasyonu, üretilen Java sınıfında field düzeyinde set edilmektedir. Dolayısı ile JPA/Hibernate 
için access stratejisi de field level olmaktadır. Biraz evvel belirttiğim gibi, normal şartlarda da field level access 
strateji daha avantajlıdır, ancak tek eksiği primitive tipli değişkenlere erişimi lazy yapmamıza imkan vermez. Böyle bir 
durumda getter level access stratejiye ihtiyacımız duyarız, ama bunun için de ayrıca Hibernate tarafından derleme veya 
sınıfların yüklenmesi sırasında bytecode enhancement yapılmalıdır. Yine de eğer bir şekilde Kotlin ile çalışırken entity 
sınıflarındaki access stratejiyi getter yapmak isterseniz izleyeceğimiz yöntem @Id anotasyonunu @get:<Annotation> yazım 
biçimi ile tanımlamaktır.

```kotlin
@Entity
class Foo(var name:String) {
    @get:Id
    @get:GeneratedValue
    @Column(name = "id", nullable = false)
    var id: Long? = null

    @Version
    @Column(name = "version", nullable = false)
    var version: Long = 0
}
```

id attribute’u dışındaki diğer attribute’ların anotasyonlarını @get:<Annotation> şeklinde tanımlamamıza gerek yoktur.

Persistence işlemleri sırasında state manipülasyonunun gerçekten getter/setter metotları üzerinden yürüdüğünden emin 
olmak için attribute’lardan birisinin setter metodunu override edebilirsiniz.

```kotlin
@Entity
class Foo() {
    @get:Id
    @get:GeneratedValue
    @Column(name = "id", nullable = false)
    var id: Long? = null
        set(value) {
            println("inside setter :" + value)
            field = value
        }

    @Version
    @Column(name = "version", nullable = false)
    var version: Long = 0
        set(value) {
            println("inside setter :" + value)
            field = value
        }

    var name: String? = null
        set(value) {
            println("inside setter :" + value)
            field = value
        }
}
```

Kotlin constructor parametresi olarak tanımlanmış attribute’ların getter/setter’larını override etmeye izin vermemektedir. 
Bu nedenle örneğimizde name attribute’unu constructor’dan çıkarıp normal bir instance değişken gibi tekrardan tanımladık.

Sonuç olarak özetlersek Kotlin ile çalışırken JPA/Hibernate’in erişim stratejilerinden field level erişim varsayılan 
davranış olarak bize sunulmaktadır, ama her zaman için bu davranış sınıf düzeyinde getter erişim stratejisi ile 
değiştirilebilir.