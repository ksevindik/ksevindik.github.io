# Spring Konfigürasyonu: XML mi, Annotasyonlar mı, Yoksa Java mı?

Spring Application Framework konfigürasyon metadatasının oluşturulabilmesi için üç farklı yol sunmaktadır. Bunlar XML, 
java annotasyonları ve java kodu şeklindedir. Spring ilk çıktığı günden bu yana XML konfigürasyon metadata formatını 
desteklemektedir. İkinci yol java annotasyonlarını kullanmaktır. Java kodu içerisinde belirtilen annotasyonlar vasıtası 
ile konfigürasyon metadata ifade edilmektedir.

```xml
<bean id="petClinicService" class="test.PetClinicServiceImpl">
    <property name="petClinicDao" ref="petClinicDao"/>
</bean>

<bean id="petClinicDao" class="test.PetClinicDaoJdbcImpl">
    <property name="jdbcTemplate" ref="jdbcTemplate"/>
</bean>

<bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
    <property name="dataSource" ref="dataSource"/>
</bean>

<bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
...
</bean>
```

XML tabanlı konfigürasyon ile annotasyon tabanlı konfigürasyon kıyaslandığında XML tabanlı konfigürasyonun sistem ile 
ilgili büyük resmi tek bir lokasyonda toplamasından ötürü annotasyon tabanlı konfigürasyona göre daha avantajlı olduğu 
söylenebilir. Farklı sınıflara ve bu sınıfların içerisine dağılmış annotasyonlardan sistemin genel yapısı ve konfigürasyonu 
hakkında bir çırpıda fikir edinmek zorlaşmaktadır.

Annotasyonların diğer bir dezavantajı ise sınıf tabanlı olmasıdır. Aynı sınıftan birden fazla bean tanımlamak sınıf 
düzeyinde kullanılan @Component, @Service, @Repository, @Controller gibi annotasyonlarla mümkün değildir. Bu annotasyonlardan 
herhangi biri bir sınıf üzerinde kullanıldığı vakit bu sınıftan sadece tek bir bean tanımı yapılabilir. Farklı isimde aynı 
sınıftan yeni bir bean tanımı yapmak istendiğinde @Bean annotasyonu ile işaretlenmiş factory metotlar implement etmek bir 
çözüm olabilir.

```java
@Service
public class PetClinicServiceImpl implements PetClinicService {
	@Autowired
	private PetClinicDao petClinicDao;

	public void setPetClinicDao(PetClinicDao petClinicDao) {
		this.petClinicDao = petClinicDao;
	}
}

@Repository
public class PetClinicDaoJdbcImpl implements PetClinicDao {
	private JdbcTemplate jdbcTemplate;

	public void setJdbcTemplate(JdbcTemplate jdbcTemplate) {
		this.jdbcTemplate = jdbcTemplate;
	}
}
```

Annotasyon tabanlı konfigürasyonun temel artısı konfigürasyonun java kodu içerisinde yapılması ile type safety’nin java 
kodu içerisinden herhangi bir ekstra efora ihtiyaç duymadan sağlanabiliyor olmasıdır. XML tabanlı konfigürasyon ile 
çalışırken ancak kullanılan XML editörün veya IDE’nin Spring Application Framework için sunduğu kabiliyetler çerçevesinde 
kontroller yapmak mümkün olabilir. Örneğin, bean tanımlarında kullanılan sınıfların tam isimlerinin düzgün kullanılıp 
kullanılmadığı, property’lere enjekte edilen bağımlılıkların geçerli olup olmadıkları kontrol edilebilir.

Spring 3 ile birlikte java kodu yazarak da konfigürasyon metadata oluşturmak mümkün hale gelmiştir. Bu sayede XML tabanlı 
konfigürasyonun artısı olan uygulama ile ilgili büyük resmin bir noktadan görülebilmesi ile annotasyon tabanlı 
konfigürasyonun artısı olan tip güvenliği yani java kodu ile ifade edilen metadatayı derleyicinin denetlemesi kabiliyetleri 
bir arada toplanmıştır.

```java
@Configuration
public class AppConfig {

	@Bean
	@Autowired
	public PetClinicService petClinicService(PetClinicDao petClinicDao) {
		PetClinicServiceImpl petClinicServiceImpl = new PetClinicServiceImpl();
		petClinicServiceImpl.setPetClinicDao(petClinicDao);
		return petClinicServiceImpl;
	}

	@Bean
	@Autowired
	public PetClinicDao petClinicDao(DataSource dataSource) {
		PetClinicDaoJdbcImpl petClinicDaoJdbcImpl = new PetClinicDaoJdbcImpl();
		petClinicDaoJdbcImpl.setJdbcTemplate(new JdbcTemplate(dataSource));
		return petClinicDaoJdbcImpl;
	}
}
```

Bu üç konfigüsyon metadata oluşturma yönetimi bir projede aynı anda kullanılabilmektedir. Genellikle uygulama içerisinde 
ihtiyaç duyulan temel spring’e özel bean ve namespace tanımları XML tarafında yapıldıktan sonra konfigürasyon metadatayı 
içeren java sınıfı oluşturulup, java annotasyonları ile birlikte metadata konfigürasyonu yapılmaktadır.

 