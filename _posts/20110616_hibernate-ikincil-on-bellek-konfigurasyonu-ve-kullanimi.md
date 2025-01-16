# Hibernate İkincil Ön Bellek Konfigürasyonu ve Kullanımı

İkincil önbelleği aktive etmek için Hibernate konfigürasyonunda üç property tanımına ihtiyaç vardır. EHCache provider 
için konfigürasyonumuz şu şekilde olabilir.

```xml
<property name="hibernate.cache.use_second_level_cache">true</property>
<property name="hibernate.cache.use_query_cache">true</property>
<property name="hibernate.cache.provider_class">org.hibernate.cache.EhCacheProvider</property>
```
Buradaki tanımlardan ilki ikincil önbelleği aktive eder. Entity sınıflarda ve ilişkilerde yapılacak önbellek tanımlarımız 
ancak bu tanımdan sonra devreye girebilir. İkinci tanım ise sorgu önbelleğini devreye alır. Fakat her sorgu için önbellekleme 
yapılıp yapılmayacağını sorguyu çalıştırmadan evvel ayrıca Hibernate’e söylememiz gerekir. Son tanım ise önbellek 
sağlayıcısının sınıfıdır. Bu sınıftan oluşturulan önbellek sağlayıcısı runtime’da devreye girer.

Hibernate’de maalesef property isimlerinin validasyonu söz konusu olmadığından bazı property’lerin isimlerini ve değerlerini 
yanlış girseniz bile Hibernate hiçbir sorun yokmuş gibi çalışabilir. Bu durum saatlerinizin heba olmasına, bildiklerinizi 
de sorgulamanıza neden olabilir. Böyle bir durumdan şüpheleniyorsanız, log4j ile Hibernate’in ilgili sınıflarının log 
düzeylerini ayarlayıp çalışma zamanında üretilen logları gözleyin. Eğer, örneğin Hibernate sorgusu gerçekleştiği sırada 
sorgu önbelleği ile ilgili herhangi bir log satırı görmüyorsanız property isimlerini ve değerlerini tekrar kontrol edin.

Property tanımlarının ardından sırada, önbellekte tutulacak entity ve collection tanımları vardır. Bunları da örnek bir 
model ile anlatalım. Eğitimlerde kullandığımız petclinic projesindeki `Owner – Pet – PetType` ilişkisini ele alalım. Bir 
`Owner`’ın değişik sayıda `Pet`’i olabilir. Aralarında 1:M bir ilişki söz konusudur. Her bir `Pet`’in de bir tipi vardır 
ve bu da `PetType` ile ifade edilir. Burada da karşımıza M:1 bir ilişki çıkmaktadır. Eğer `Pet` nesneleri üzerinde çok 
fazla değişiklik yapılmıyorsa `read-write` eşzamanlı erişim stratejisi sınıf düzeyinde kullanılabilir. `Owner`’ın sahip 
olduğu `Pet`’lerde de sıklıkla bir değişiklik olmuyorsa `Owner-Pet` ilişkisi de `read-write` erişim stratejisini kullanabilir. 
`PetType` entity’lerinin ise tanım tablosundaki değerlere karşılık geldiği düşünülürse uygulama genelinde muhtemelen bu 
entity’lere hiç değişiklik yapılmayabilir. Dolayısıyla bunların `read-only` erişim stratejisine sahip olmalarında bir 
sakınca yoktur.

```java
@Entity
@Table(name="types")
@Cache(usage=CacheConcurrencyStrategy.READ_ONLY)
@org.hibernate.annotations.Entity(mutable=false)
public class PetType extends BaseEntity {
}

@Entity
@Table(name="pets")
@Cache(usage=CacheConcurrencyStrategy.READ_WRITE)
public class Pet extends BaseEntity {
}

@Entity
@PrimaryKeyJoinColumn
@Table(name="owners")
public class Owner extends Person {

 @Embedded
 private Address address = new Address(this);

 @OneToMany(mappedBy="owner")
 @Cascade(value={CascadeType.SAVE_UPDATE})
 @Cache(usage=CacheConcurrencyStrategy.READ_WRITE)
 private Set<Pet> pets = new HashSet<Pet>();
}
```

Inheritance hiyerarşisinin söz konusu olduğu durumlarda sadece alt sınıfta önbellek tanımı yeterli olmayacaktır. Üst 
sınıflarda da aynı önbellek tanımını yapmak gerekir. Sorgularda ise, oluşturuldukları zaman önbellek tanımları yapılmalıdır.

```java
session.createQuery("from PetType pt where pt.name = :name").setString("name", name).setCacheable(true).list();
```

Sorgularda ikincil önbelleği devreye alma işlemi hem HQL hem de Criteria sorgularında aynıdır. Sorgular ikincil önbellekte 
sorgu ifadesi ve parametreleri ile birlikte tutulurlar. Bu nedenle, aynı sorgunun farklı parametrelerle çalıştırılması 
farklı bir önbellek entry’si olarak tutulmasına neden olacaktır.

Hibernate’in önbellek ile etkileşimini, `Session` genelinde veya sorgu özelinde yönetmek de mümkündür. Bunun için 5 değişik 
`CacheMode` tanımı mevcuttur:

### Ignore
- `Session` hiçbir biçimde önbellek ile etkileşimde olmaz. Ne okunan entity önbellekten okunur veya önbelleğe yerleştirilir, ne de entity üzerindeki güncelleme önbelleğe yansıtılır.
- Ancak entity üzerindeki güncellemeler önbellekte ilgili entity’nin invalidate edilmesine neden olur.

### Normal
- Entity’ler önbellekten erişilebilir veya önbelleğe yerleştirilebilir.

### Get
- `Session` önbelleği sadece entity’nin yüklenmesi sırasında kullanır. Entity önbelleğe yerleştirilmez.
- Entity üzerindeki değişiklikler sonucu ilgili invalidasyon söz konusudur.

### Put
- Entity’nin yüklenmesi sırasında hiçbir zaman önbelleğe bakılmaz, ancak entity önbelleğe yerleştirilebilir.

### Refresh
- Entity’nin yüklenmesi sırasında asla önbelleğe bakılmaz, ancak DB’den okunan entity, önbelleğe yerleştirilebilir.
- Hibernate’in clustered önbellek implementasyonları için daha anlamlı olan `hibernate.cache.use_minimal.puts` konfigürasyon property değerini de göz ardı eder.
