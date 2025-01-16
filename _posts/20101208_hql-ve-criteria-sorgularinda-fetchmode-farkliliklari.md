# HQL ve Criteria Sorgularında FetchMode Farklılıkları

Lazy tanımlanmış 1:M bir ilişkinizinin fetch tipini eager’a çektiğiniz vakit sorgu sonucu dönen kayıtlar arasında duplikasyon 
olduğunu tecrübe ettiğiniz oldu mu? Eğer sorgunuzda Criteria API’sini kullanmış iseniz bu durumla pek muhtemelen 
karşılaşmışsınızdır. Sorgunuzu HQL’e çevirdiğiniz takdirde sonuçlardaki duplikasyonların ortadan kalktığını görürsünüz. 
Peki Hibernate sorgularındaki bu farklılık neden ortaya çıkmaktadır?

Cevabı hemen söyleyelim. HQL sorgusu entity’ler arasındaki ilişkilerin fetch tiplerini sorgu üretimi sırasında dikkate 
almaz. Criteria API’si ise tam tersine ilişkilerin fetch modunu da hesaba katarak SQL sorgusunu üretir. Konuyu küçük bir 
örnek ile açıklayalım. A ve B sınıflarımız arasında 1:M bir ilişki tanımlanmış olsun. Önce ilişkiyi LAZY olarak tanımlayalım. 
Veritabanına da 1 tane A, bu A instance’ı ile ilişkili 2 tane de B instance’ı ekleyelim.

```java
@OneToMany(fetch=FetchType.LAZY)
@JoinColumn(name="a_id")
private Set bSet = new HashSet();

List result = s.createQuery("select a from A a").list();
```

Yukarıdaki sorguyu çalıştırdığımız vakit eğer Hibernate’in SQL gösterimi aktif ise aşağıdaki SQL ifadesinin üretildiğini, 
result.size() değerinin ise 1 olduğunu göreceksiniz.

```console
Hibernate: /* select a from A a */ select a0_.id as id3_ from A a0_
```

Criteria API’sini kullanarak aşağıdaki gibi A entity’lerini sorgularsak, sonuç yine aynı olacak.

```java
List result = s.createCriteria(A.class).list();
```

```console
Hibernate: /* criteria query */ select this_.id as id3_0_ from A this_
```

Şimdi ilişkinin fetch modunu EAGER olarak değiştirerek aynı sorguları tekrarlayalım. HQL sorgusu için result.size() 1 
olarak kalırken ve aşağıdaki iki sorgu üretilirken;

```console
Hibernate: /* select a from A a */ select a0_.id as id3_ from A a0_
Hibernate: /* load one-to-many com.javaegitimleri.hibernate.fetch.A.bSet */ select bset0_.a_id as a2_1_, bset0_.id as id1_, bset0_.id as id4_0_ from B bset0_ where bset0_.a_id=?
```

Criteria API’si çalıştırıldığında aşağıdaki tek bir sorgunun üretildiğini, ayrıca result.size() değerinin de 2 olduğunu 
göreceksiniz.

```console
Hibernate: /* criteria query */ select this_.id as id3_1_, bset2_.a_id as a2_3_, bset2_.id as id3_, bset2_.id as id4_0_ from A this_ left outer join B bset2_ on this_.id=bset2_.a_id
```

İlginç bir şekilde, HQL sorgusunda, 1:M eager ilişkiyi yüklemek için ikinci bir SELECT kullanılırken, Criteria API’sinde 
ise A ile B arasında “outer join” yapılmaktadır. Şimdi de ilişkinin eager biçimde yüklenirken hangi yöntemin kullanılacağını 
söyleyelim.

```java
@OneToMany(cascade=CascadeType.ALL,fetch=FetchType.EAGER)
@JoinColumn(name="a_id")
@Fetch(FetchMode.SELECT)
private Set bSet = new HashSet();
```

HQL sorgusu çalıştığında üretilen sorgularda ve result.size()’da bir değişiklik olmaz iken, Criteria API’si çalıştırıldığında 
eager ilişkinin yüklenmesi için “outer join” yerine ikinci bir select SQL ifadesinin üretildiğini, aynı zamanda result.size()’ın 
da 1 olduğunu görüyoruz.

```console
Hibernate: /* criteria query */ select this_.id as id3_0_ from A this_
Hibernate: /* load one-to-many com.javaegitimleri.hibernate.fetch.A.bSet */ select bset0_.a_id as a2_1_, bset0_.id as id1_, bset0_.id as id4_0_ from B bset0_ where bset0_.a_id=?
```

Eğer @Fetch(FetchMode.JOIN) olarak değiştirilirse HQL sorgusunda birşey değişmezken, Criteria API sorgusunun ilişkiyi join 
ile yüklediği görülecektir. Kısacası HQL sorguları entity’ler arasındaki ilişkilerin fetch stratejilerinden hiç bir şekilde 
etkilenmezken, Criteria sorguları ise fetch stratejisine göre değişiklik göstermektedir.

Sorgu sonuçlarındaki duplikasyon ise tamamen join işleminin bir sonucudur. İster HQL, ister Criteria API’si kullanılsın, 
eğer sorgunuz içerisinde join söz konusu ise duplikasyon kaçınılmazdır. Duplikasyonu ortadan kaldırmak için HQL ve Criteria 
API’si için değişik yöntemler vardır. HQL için select ifadesinden sonra “distinct” kullanarak duplikasyonun önüne geçebiliriz. 
Criteria sorgularında ise Criteria.DISTINCT_ROOT_ENTITY ResultTransformer set edilmelidir.