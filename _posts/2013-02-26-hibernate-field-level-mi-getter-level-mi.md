# Hibernate: Field Level Mı? Getter Level Mı?

Entity’lerin persistent property’lerine Hibernate’nin nasıl erişeceği ile ilgili olarak iki yol mevcuttur.

* **Field level access**: JPA/Hibernate mapping tanımları field düzeyinde yapılır, Hibernate field değerlerine reflection’la doğrudan erişir, getter/setter metotlarına ihtiyaç duyulmaz, getter/setter metotlarına iş mantığı ile ilgili kod yazmak da mümkün hale gelir.

```java
@Entity
public class Person {
	@Id
	private Long id;

	@Column(name="FIRST_NAME")
	private String firstName;

	@Column(name="LAST_NAME")
	private String lastName;
}
```

* **Getter level access**: JPA/Hibernate mapping tanımları getter metotlarının üzerinde yapılır. Hibernate persistent property değerlerine erişim ve bu değerleri set etme işlemlerini getter/setter metotları üzerinden gerçekleştirir. Bu sayede field level access’de mümkün olmayan primitive field’lara lazy biçimde erişim imkanına kavuşulmuş olunur.

```java
@Entity
public class Person {
	private Long id;
	private String firstName;
	private String lastName;

	@Id
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name="FIRST_NAME")
	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	@Column(name="LAST_NAME")
	public String getLastName() {
		return lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
}
```

Hangi erişim yönteminin kullanılacağına entity sınıfın “identity” tanımının nerede yapıldığı ile karar verilir. Eğer 
`@Id` annotasyonu field üzerine yerleştirilir ise **field level access**, `getId()` metodu üzerine yerleştirilir ise 
**getter level access** yöntemi tercih edilmiş olunur. Alt sınıflar ve embeddable bileşen sınıfları da bu erişim 
stratejisini default olarak “inherit” ederler. `@MappedSuperClass` ile tanımlanmış üst sınıflardaki persistent alanların 
erişim yöntemi ise default olarak `@Id` annotasyonunun tanımladığı alt sınıflar tarafından belirlenir.

JPA 2 ile birlikte erişim stratejisinin `@Id` annotasyonunun nerede kullanıldığından bağımsız olarak tanımlanabilmesine 
veya sınıf içerisinde persistent property’ler düzeyinde farklı erişim stratejileri kullanılabilmesine imkan tanınmıştır. 
Bu işlem `@Access` annotasyonu ile gerçekleştirilir. JPA 2 öncesinde bu işlem Hibernate’e özel `@AccessType` annotasyonu 
ile benzer biçimde yapılabilmekteydi.

```java
@Entity
public class Person {
	@Id
	private Long id;

	@Column(name="FIRST_NAME")
	private String firstName;

	private String lastName;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	@Column(name="LAST_NAME")
	@Access(AccessType.PROPERTY)
	public String getLastName() {
		return lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
}
```

Yukarıdaki örnekte erişim stratejisi field level tanımlanmış olmasına rağmen, `lastName` alanına erişim ve bu alanın 
değerinin saklanması getter/setter metotları üzerinden olacaktır. `@Access` annotasyonu sınıf düzeyinde de kullanılabilir. 
Bu durumda `@Id` annotasyonunun kullanıldığı yere bakılmaz. Eğer `@Access` değeri ile `@Id` annotasyonunun yeri uyuşmuyor 
ise Hibernate hata verecektir.

Yöntem olarak field level access’in getter level access’e göre artıları çok daha fazladır. Açıkçası getter level access’in 
`String`, `Long`, `Integer`, `Date` gibi built-in Java tiplerine sahip property’lere erişimi lazy yapmasının dışında çok 
büyük bir artısı görünmemektedir. Bilakis bazı açılardan dezavantajlı olmaktadır. Bunlardan birisi getter/setter 
metotlarının Hibernate tarafından entity nesne yüklenirken de çağırılmasından ötürü bu metotlar içerisine iş mantığı ile 
ilgili kod yazılması mümkün olmamaktadır. Diğer bir dezavantaj, entity sınıfın içerisindeki mapping tanımlarının 
okunurluğunun azalmasıdır. Eğer sınıf içerisinde pek çok persistent property var ise bunları getter/setter metotları da 
kod içerisinde daha geniş bir alana yayılacak, diğer metotların da araya girmesi ile getter metotlarının kod içerisinde 
bir çırpıda incelenip entity sınıfın nasıl map edildiğinin anlaşılması daha zor bir hal alacaktır.

Bütün bunların dışında her iki yöntem için de geçerli bir problem olmasına rağmen getter level access yönteminde daha çok 
karşımıza çıkan runtime problemleri ile de karşılaşmamız söz konusu olabilmektedir. Bunlardan birisi de “dirty collection” 
problemidir.

Bu problemin detaylarına da bir sonraki yazımızda bakacağız…
