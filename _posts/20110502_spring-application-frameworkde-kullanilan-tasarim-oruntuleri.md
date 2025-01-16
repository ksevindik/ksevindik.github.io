# Spring Application Framework'de Kullanılan Tasarım Örüntüleri

Spring Application Framework’ü öğrenirken, sunduğu kabiliyetlerin hangi iyi pratikler ve design pattern’lar üzerine 
kurulu olduğunu bilmek şüphesiz framework’ü daha sağlıklı biçimde öğrenmenizi sağlayacaktır. İşte Spring Application 
Framework içerisinde kullanılan pattern’lar ve kullanıldıkları yerler:

- **Factory Method**: `BeanFactory` bu pattern üzerine bina edilmiştir. Spring managed bean'ların yaratılması ve bağımlılıkların sağlanmasında kullanılır.
- **Singleton**: Yaratılan bean’ler default olarak container genelinde tek bir instance’a sahip olmaktadırlar. Spring’in Singleton implementasyonu GOF Singleton pattern’ından scope olarak biraz daha farklıdır.
- **Prototype**: İstendiği takdirde `ApplicationContext`, herhangi bir bean tanımından her `getBean('beanName')` ile erişimde yeni bir instance yaratmaktadır. Bean tanımı burada tam bir prototype örüntüsüdür.
- **Proxy**: Spring Application Framework’ün en çok faydalandığı pattern diyebiliriz. Scoped bean oluşturmada, Spring AOP kabiliyetinin sunulmasında, TX kabiliyetinin implementasyonunda hep bu pattern kullanılmaktadır.
- **Template Method**: Spring’in veri erişim altyapısı bu pattern üzerine kuruludur. `JdbcTemplate`, `HibernateTemplate`, `JpaTemplate`, `RestTemplate`...
- **Observer**: `ApplicationContext`’in event yönetimi tam bir publish-subscribe örneğidir. `ApplicationContext` bir event medium rolündedir. Bir grup Spring managed bean, `ApplicationContext` vasıtası ile `ApplicationListener` tipindeki diğer bir grup bean’lere event notifikasyonunda bulunabilirler.
- **Mediator**: Bir önceki pattern’da `ApplicationContext`’in event medium rolünde olduğunu söylemiştik. Bu sayede birbirleri ile haberleşmek isteyen bean’lar loosely coupled halde kalabilmektedirler. Sadece bildikleri `ApplicationContext`’in kendisidir, yani mediator.
- **Front Controller**: Spring MVC Framework’ün iskeletini oluşturan `DispatcherServlet` bu pattern’ın bire bir karşılığıdır.

4 günlük Spring Application Framework eğitimimiz boyunca bu pattern’lar üzerinde yeri geldiğince duruyor, framework 
içerisindeki kullanım şekillerini ayrıntılı biçimde açıklıyoruz. Kurumsal projelerinizi yanlış ve ezber bilgilerle değil, 
sağlam temeller üzerinden bina etmek hem size hem çalışanlarınıza çok şey kazandıracaktır. Mayıs ayındaki Spring Application 
Framework [Eğitimi](http://www.kenansevindik.com/mayis-ayinda-spring-application-framework-egitimi/)’mizi kaçırmayın!

