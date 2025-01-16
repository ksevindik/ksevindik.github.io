# Nesnelerin Yaratılması ve SRP Prensibi

Geçen gün şu sıralar birlikte çalıştığım bir müşterimin projesinde şöyle bir durumla karşılaştım. `ProjectElement` ve 
`CustomerOrder` adında iki entity arasında 1:M parent-child ilişki söz konusuydu. ProjectElement’in tekilliğini businessKey 
ve client gibi iki değişken belirlerken, CustomerOrder’ın tekilliğini ise businessKey, client ve nesnenin ait olduğu 
projectElement’i belirliyordu. Başka bir ifade ile CustomerOrder nesnesinin, yaşam döngüsü boyunca tek bir projectElement’e 
ait olması gerekiyordu. CustomerOrder constructor’ı şu şekilde tanımlanmıştı.

```java
public CustomerOrder(String businessKey, Client client, ProjectElement projectElement) {
      this.businessKey = businessKey;
      this.client = client;
      this.projectElement = projectElement;
      this.projectElement.getCustomerOrders().add(this);
}
```

Görüldüğü gibi parent-child ilişki CustomerOrder constructor’ı içerisinde kuruluyor ve nesne yaratıldıktan sonra bir daha 
bu ilişkinin değiştirilmemesi isteniyordu. İlişkinin kurulması görevinin CustomerOrder’ın constructor’ına verilmesinin 
“single responsibility” prensibi (SRP) ile çeliştiğini düşünüyorum.

SRP bir sınıf veya metot düzeyinde tek bir sorumluluğun üstlenilmesini ister. Herhangi bir sınıf sadece belirli bir 
sorumluluğu yerine getirmeye odaklanmalıdır. Yada bir metot sadece tek bir görevi gerçekleştirmelidir. Java’daki sınıf 
constructor’larının normal metotlardan pek bir farkı yoktur. Constructor’lar nesneler oluşturulurken çağırılırlar ve 
nesnelerin düzgün biçimde yaratılıp kullanıma hazır hale gelmesini sağlarlar. Yani constructor (metotlarının) görevi 
nesnenin yaratılmasından ibaret olmalıdır. Yukarıda ise nesnenin düzgün biçimde işlevini yerine getirebilmesi için gerekli 
initialization işlemleri yapıldıktan sonra ilaveten parent-child ilişkisinin kurulması görevi de constructor içerisine 
verilmiş. Bu durumda constructor iki farklı görev üstlenmiş oluyor.

1. CustomerOrder nesnesinin yaratılması
2. ProjectElement-CustomerOrder ilişkisinin kurulması

Oysa constructor’ın aşağıdaki gibi yazılması yeterlidir.

```java
public CustomerOrder(String businessKey, Client client, ProjectElement projectElement) {     
	this.businessKey = businessKey;     
	this.client = client;
	this.projectElement = projectElement; 
}
```


Parent-child ilişkinin kurulması görevi ise ya ProjectElement’e ya da bir Factory metoda verilebilir.

```java
public class CustomerOrderFactory {
    public CustomerOrder create(String businessKey, Client client, ProjectElement projectElement) {
        CustomerOrder co = new CustomerOrder(businessKey,client,projectElement);
        projectElement.getCustomerOrders().add(co);
    }
}

public class ProjectElement {
    public void addCustomerOrder(CustomerOrder co) {
        customerOrders.add(co);
    }
}
```


SRP prensibinin ihlal edilmesi, bu metotları uygulama içerisinde değişik yerlerde kullanırken istenmeyen durumlarla 
karşılaşılmasına, metodun asıl fonksiyonalitesine ihtiyaç duyulurken onun yanında o durumda ihtiyaç duyulmayan veya 
gerçekleşmemesi gereken diğer işlemin yapılması nedeni ile asıl senaryonun görevini yerine getirememesine neden olabilir.

Yeni bir senaryo ile bu durumu örneklemeye çalışalım. Projede ilk CustomerOrder constructor’ının kullanıldığı var sayılarak 
ProjectElement sınıfına o anda belirli bir CustomerOrder nesnesine sahip olup olmadığının sorulmasını sağlayan bir metot 
eklemeye çalışalım.

```java
public boolean exists(CustomerOrder co) {
    return customerOrders.contains(co);
}
```


Sizce burada karşılaşacağımız problem nedir? Peki problemi çözmek için nasıl bir yol izleyebiliriz? Bu yazı yeterince 
uzadı, bir sonraki yazıda bu konuya devam edeceğim. Sizin içinde bu ara, problemi ve çözüm yollarını düşünme şansı olsun.






