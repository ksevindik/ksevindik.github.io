# Ayrı Bir Repository Katmanı Şart mı?

Kurumsal yazılım sistemlerinde üç katmanlı mimari yaklaşımı uygulamak “de facto” olmuştur. Bu tür uygulamalarda sunum 
(presentation), servis (service/business) ve depo (DAO/repository) ayrı ayrı görevlere sahip katmanlar olarak karşımıza 
çıkarlar.

Sunum katmanında UI ile ilgili işlemler gerçekleştirilir. Bu katmanda kendi içinde arayüz (UI) ve dönüşüm/kontrol 
(controller) şeklinde alt katmanlara ayrılabilir. Dolayısı ile JavaEE dünyasında üç katmanlı (3 tiered) mimariler aynı 
zamanda N katmanlı (N tiered) olarak da adlandırılmaktadır. Sunum katamanına gelen kullanıcı istekleri gerekli dönüşüm 
ve kontrollerin ardından servis katmanına iletilir. Servis katmanından dönen cevaplarda yine gerekli dönüşümlere tabi 
tutularak kullanıcıya sunulur.

Servis katmanında uygulamanın iş mantığı ile ilgili işlemler ve süreçler yürütülür. Ayrıca servis katmanı karşımıza 
transaction yönetimi, güvenlik kontrolleri, validasyon gibi middleware operasyonların yönetim yeri olarak da çıkmaktadır.

Depo (DAO/Repository) katmanında ise veri erişim işlemleri gerçekleştirilir. Servis katmanı iş mantığını yürütürken veri 
erişimi, verinin saklanması (persist edilmesi) ile ilgili ihtiyaçlarını karşılamak için de depo katmanına başvurmaktadır.

Katmanlı mimarinin en büyük avantajı soyutlama (encapsulation) ve modülerliktir. Her bir katman sadece bir altındaki 
katmanı bilir ve sadece onunla iletişimde olur. Böylece herhangi bir katmanda yapılan değişikliklerin sistem içerisindeki 
etkisi sınırlı bir alanda kalmış olacaktır. Bunun yanı sıra herhangi bir katmanda kullanılan spesifik bir teknoloji, 
kütüphane, framework veya veritabanı o katman arkasında gizlenebilir ve gerektiğinde sistemin geri kalanını etkilemeden 
uygun diğer bir alternatifi ile değiştirilebilir.

ORM teknolojilerinin gelişmesi ve JPA’nın ortaya çıkması ile birlikte ayrı bir depo katmanının gerekli olup olmadığı 
tartışılır hale gelmiştir. Uygulama içerisinde veri erişim işlemleri için JPA’yı kullananlar için ORM provider’ın 
halihazırda veritabanı bağımsızlığı sağladığı ve SQL lehçe farklılıklarından uygulamanın geri kalanını izole ettiği 
belirtilerek ayrı bir repository arayüzü ve implemantasyon sınıfı oluşturmanın fazlalık olduğu iddia edilmektedir. 
Bu yaklaşımı savunanlar doğrudan PersistenceContext yani EntityManager nesnesini servis katmanına enjekte ederek de 
çalışılabileceğini ifade ederler. Bu görüşü savunanlara göre EntityManager üzerindeki operasyonları ayrı bir depo arayüzü 
ve implemantasyonu ile gizlemenin çok da fazla bir getirisi yoktur.

Gerçekten de entity sınıfları için oluşturulan CRUD arayüz ve sınıflarına baktığımızda, tanımlı metotların aslında JPA 
PersistenceContext API’sinde sunulan metotlardan çok da farklı olmadığını söyleyebiliriz. Örneğin, User entity sınıfı için 
oluşturulan CRUD depo arayüzünde genellikle aşağıdaki örneğe benzer metotların yer aldığını görürüz.

```java
public interface UserRepository {    
    List<User> findAll();
    User findById(Long id);
    void create(User user);
    void update(User user);
    void delete(Long id);
}
```

Farklı entity’ler için benzer depo arayüzlerini ve sınıfları implement ettiklerini görenlerin projelerinde bu entity 
spesifik depo sınıflarını generic bir depo sınıfına dönüştürmeleri de çoğu zaman karşımıza çıkan bir durumdur.

```java
public interface GenericRepository {
    <T> List<T> findAll(Class<T> entityClass);
    <T> T findById(Class<T> entityClass, Long id);
    <T> void create(T entity);
    <T> void update(T entity);
    <T> void delete(Class<T> entityClass, Long id);
}
```

JPA EntityManager arayüzünde de bu metotlara benzer metotlar yer almaktadır.

```java
public interface EntityManager {    
    <T> T find(Class<T> entityClass, Object primaryKey);
    void persist(Object entity);
    <T> merge(T entity);
    remove(Object entity);
}
```

findAll metodu da JPA’nın TypedQuery arayüzü ve JPQL kullanılarak rahatlıkla karşılanabilmektedir.

```java
TypedQuery<User> query = em.createQuery("select u from User as u", User.class);
List<User> users = query.getResultList();
```

Görüldüğü üzere, uygulama için oluşturulan entity spesifik veya generic depo arayüz ve implemantasyon sınıfları söz konusu 
ise bunların yaptığı çok fazla birşey olmayacak ve görevleri kabaca işi EntityManager’ın ilgili metoduna havale etmekle 
sınırlı kalacaktır. Dolayısı ile yukarıda bahsettiğim görüşü savunanlar bu tür ayrı bir depo katmanını tamamen tasviye 
edip servis katmanına EntityManager’ı enjekte ederek çalışmayı tercih etmektedirler.

Peki bu tür bir tercihin muhtemel dezavantajları nedir? Gelin bunu da bir sonraki yazımızda tartışalım.