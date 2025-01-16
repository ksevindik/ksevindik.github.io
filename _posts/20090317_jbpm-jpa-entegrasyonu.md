# JBPM JPA Entegrasyonu
Bir süredir blog yazılarına ara vermiştim. Bu süre zarfında `BusinessProcessManagement` kabiliyetinin mevcut altyapımıza 
kazandırılması için çalışmalar yaptık. BPM için tercihimiz `JBPM`’den yana oldu. Bu ve devamındaki yazılarımda `JBPM` ile 
ilgili tecrübelerimizi, `JBPM`’in `JPA`, `SpringWebFlow`, `AcegiSecurity` gibi diğer frameworklerin de yer aldığı 
altyapımıza entegre edilmesi ile ilgili geliştirdiğimiz çözümleri, `JBPM`’in gömülü biçimde kurumsal web uygulamalarında 
kullanışını, yönetim arayüzünün mevcut uygulamalara nasıl entegre edilebileceğini anlatacağım.

İlk olarak `JBPM JPA` entegrasyonu ile konumuza başlayalım. `JBPM` persistence işlemleri için doğrudan `Hibernate`’i 
kullanmaktadır. Biz ise geliştirdiğimiz uygulamalarda `JPA`’yı, `JPA` implementasyonu olarak da `Hibernate`’i 
kullanmaktayız. Bu durumda uygulamalarımızın gerçekleştirdiği persistence işlemleri ile `JPBM`’in gerçekleştirdiği 
persistence işlemlerinin farklı iki `transaction` context içerisinde çalışması durumu ortaya çıkmaktadır. Bu da doğal 
olarak veriler üzerinde tutarsızlığa yol açacaktır.

`JPA` kullanan bir uygulama ile `JBPM`'in persistence işlemlerini aynı `transaction` context içinde gerçekleştirmelerini 
sağlamak için ilk akla gelen çözüm `JTA`’nın kullanılmasıdır. Aslında uygulamalarımızın ve `JBPM`’in aynı veritabanını 
kullanmalarına rağmen `JTA` kullanma zorunluluğu tahmin ediyorum sizin de kulağınıza garip gelmiştir. Şu ana kadar lokal 
`transaction`’larla uygulama sunucularının herhangi bir servisine ihtiyaç duymadan standalone test edilebilen ve üretim 
hattında çalıştırılabilen uygulamalarımızın `JTA` kullanmaya başlamaları ile sahip olduğumuz esnekliği kaybetmek doğrusu 
benimde hiç içime sinmedi. Oysa her iki taraf da ortak bir veri tabanını, hatta aynı `ORM` implementasyonunu paylaşıyordu.

Aslında `JPA` implementasyonu olarak `Hibernate`’i kullanıyorsanız uygulama tarafında `JPA` API’si ile muhatap olsanız da 
arka tarafta persistence sürecini yine core `Hibernate` implementasyonu yönetmektedir. Yani uygulamanız bir 
`EntityManagerFactory` oluşturduğunda aslında `Hibernate` native `SessionFactory` nesnesini oluşturup kullanmaktadır. 
Aynı şekilde `EntityManagerFactory` üzerinden yeni bir `EntityManager` oluşturduğumuz vakit yine bu `EntityManager` 
nesnesi native bir `Hibernate Session`’ı üzerinden persistence işlemlerini gerçekleştirmektedir. Eğer `JBPM`’in 
persistence işlemleri için `JPA`’nın yönettiği `SessionFactory` ve `Session` nesnelerini kullanması mümkün olursa 
uygulamamız içerisinde gerçekleşen ve `JBPM`’in gerçekleştirdiği persistence işlemlerin `JTA`’ya gerek kalmadan aynı 
`transaction` context içerisinde yer alması sağlanabilir.

Bunun için yapılması gereken iki temel işlem söz konusudur. Birincisi `JBPM`’in ihtiyaç duyduğu `SessionFactory`’nin 
`JPA EntityManagerFactory` tarafından expose edilmesidir. Bu noktada ayrıca `JBPM`’in `hibernate.cfg.xml` içerisindeki 
mapping tanımlarının `JPA persistence.xml` içerisinde tanımlanması gerekir. `JBPM`’in mapping-file tanımlarını belirli 
bir sırada sağlamazsanız (`jar-file` tanımı kullanıldığı vakit bu durum ortaya çıkmaktadır) 
`EntityManagerFactory`/`SessionFactory` ayağa kaldırılırken problem oluşmaktadır.

`EntityManagerFactory`’nin native `Hibernate SessionFactory` nesnesini expose etmesi için basit bir `Spring FactoryBean` 
yazmamız yeterli oldu.

```java
public class EntityManagerFactoryToSessionFactoryBean extends AbstractFactoryBean {

	private EntityManagerFactory entityManagerFactory;

	public EntityManagerFactory getEntityManagerFactory() {
		return entityManagerFactory;
	}

	@Required
	public void setEntityManagerFactory(EntityManagerFactory entityManagerFactory) {
		this.entityManagerFactory = entityManagerFactory;
	}

	protected Object createInstance() throws Exception {
		return HibernateEntityManagerFactory)getEntityManagerFactory(?.getSessionFactory();
	}

	public Class getObjectType() {
		return SessionFactory.class;
	}
}
```

```xml
<bean id="sessionFactory" class="jbpm.jpa.integration.EntityManagerFactoryToSessionFactoryBean">
    <property name="entityManagerFactory" ref="entityManagerFactory" />
</bean>
```

Uygulamalarımızda `JBPM` konfigürasyonunu ayağa kaldırmak ve `JBPM` işlemlerini gerçekleştirmek için `Spring Modules` 
projesinden yararlandık. `Spring Modules` `JBPM` işlemleri için Spring’in klasikleşmiş `XXXTemplate` callback yapısına 
uygun `JbpmTemplate` sınıfını sunmaktadır. `JbpmTemplate`’in kullanılabilmesi için yapılması gereken bir 
`JbpmConfiguration` nesnesinin oluşturulmasıdır. `Spring Modules`’ün `LocalJbpmConfigurationFactoryBean` sınıfı bir 
`JbpmConfiguration` nesnesi oluşturmaktadır. Bu `FactoryBean`, `JbpmConfiguration` nesnesi üzerinden `JBPM` persistence 
servisinin (`DbPersistenceService`) kullandığı `SessionFactory` nesnesini `EntityManagerFactory`’den expose ettiğimiz 
`SessionFactory` nesnesi olarak set etmektedir.

```xml
<bean id="jbpmConfiguration" class="org.springmodules.workflow.jbpm31.LocalJbpmConfigurationFactoryBean">
    <property name="sessionFactory" ref="sessionFactory"/>
    <property name="configuration" value="classpath:jbpm.cfg.xml"/>
    <property name="createSchema" value="false"/>
</bean>

<bean id="jbpmTemplate" class="org.springmodules.workflow.jbpm31.JbpmTemplate">
    <constructor-arg index="0" ref="jbpmConfiguration"/>
    <property name="hibernateTemplate" ref="hibernateTemplate"/>
</bean>
```


Gelelim ikinci adımımıza. Bu adımda yapmamız gereken uygulamamızın persistence işlemler için kullandığı 
`EntityManager`’ın native `Hibernate Session` nesnesinin `JBPM`’in persistence işlemler için kullanmasını sağlamalıyız.

`Hibernate` 3.1’den itibaren “contextual session” kabiliyetini sunmaktadır. Bu sayede `SessionFactory`’ye 
`Hibernate Session`’ı nereden ve nasıl temin edeceğini pluggable biçimde belirtebilmekteyiz. `Hibernate`’in konfigürasyon 
parametrelerinden “`hibernate.current_session_context_class` “ bunun için tahsis edilmiştir. Bu prametreye `Hibernate`’in 
`CurrentSessionContext` interface’ini implement eden bir sınıfın full paket adını değer olarak girmemiz yeterlidir. 
`CurrentSessionContext` implementasyonu bizim için o anda mevcut olan `thread` bound `EntityManager`’ın native 
`Hibernate Session`’ını döndürecektir.

```java
public class EntityManagerAwareCurrentSessionContext implements CurrentSessionContext {

	private EntityManagerFactory emf;

	private ThreadLocalSessionContext threadLocalSessionContext;


	public Session currentSession() throws HibernateException {
		EntityManager em = EntityManagerFactoryUtils.getTransactionalEntityManager(getEmf());
		if(em != null){
			return (Session)((HibernateEntityManager) em).getSession();
		} else {
			return threadLocalSessionContext.currentSession();
		}
	}

	public EntityManagerAwareCurrentSessionContext(SessionFactoryImplementor factory) {
		threadLocalSessionContext = new ThreadLocalSessionContext(factory);
	}


	private synchronized EntityManagerFactory getEmf() {
		if(emf == null) {
			emf = (EntityManagerFactory)SpringUtils.getBean("entityManagerFactory");
		}
		return emf;
	}
}
```

`EntityManagerAwareCurrentSessionContext` eğer `thread` bound bir `EntityManager` varsa bunun kullandığı `Session`’ı 
yoksa fallback olarak `ThreadLocalSessionContext`’i kullanarak yeni bir `Session`’ı döndürmektedir. Yukarıdaki 
`CurrentSessionContext` implementasyonunun aktif olması için `persistence.xml` dosyasının içerisinde

```xml
<properties>

...

    <property name="hibernate.current_session_context_class" value="jbpm.jpa.integration.EntityManagerAwareCurrentSessionContext" />
</properties>
```

şeklinde bir tanım yapmamız yeterli olacaktır.

JBPM’in `DbPersistenceService` sınıfına `Hibernate SessionFactory`’nin `getCurrentSession()` metodu ile o an mevcut 
`Session`’ı kullanması (`isCurrentSessionEnabled`) söylenebilir. Ancak bu değer default false olarak set edilidir. Bu 
property’de değişiklik yapmadan da `DbPersistenceService`’in mevcut `Session`’ı kullanması sağlanabilir. Nasıl mı? 
Okumaya devam…

`Spring Modüles`’ün `JbpmTemplate` sınıfı, bütün `JBPM` işlemlerini `HibernateTemplate` içinde yürütmektedir. 
`JbpmTemplate` herhangi bir operasyon gerçekleşmeden evvel `HibernateTemplate`’dan gelen `Session`’ı `JbpmContext`’e set 
etmektedir. Böylece `DbPersistenceService`’in yeni `Session` yaratmak yerine `JbpmContext`’deki mevcut `Session`’ı 
kullanması sağlanır. Bu arada `HibernateTemplate`’a da her seferinde yeni bir `Session` yaratmak yerine halihazırdaki 
`SessionFactory`’nin `getCurrentSession()` metodunu çağırarak mevcut `Hibernate Session`’ı kullanması (`allowCreate=false`) 
söylenmelidir.

```xml
<bean id="hibernateTemplate" class="org.springframework.orm.hibernate3.HibernateTemplate">
    <property name="sessionFactory">
        <ref local="sessionFactory"/>
    </property>
    <property name="allowCreate" value="false"/>
</bean>
```

Artık `JBPM`’in halihazırda thread bound bir `EntityManager`’dan expose edilmiş native `Hibernate Session`’ı kullanması 
sağlanmış olur. Bir sonraki yazımda `JBPM` ve `Spring WebFlow`’un entegrasyonu üzerinde duracağım.
