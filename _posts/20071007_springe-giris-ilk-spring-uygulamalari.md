# Spring’e Giriş: İlk Spring Uygulamaları

Spring, JEE uygulamaları için geliştirilmiş bir iskelet frameworktür. Bildiğimiz gibi JEE uygulamaları geliştirirken 
ilgilenilmesi gereken pek çok altyapısal (middleware) ihtiyaçlar sözkonusudur. Her katman için bu altyapısal ihtiyaçları 
karşılayan, genelde JSR spesifikasyonları üzerine kurulmuş, API kütüphaneleri ve popüler frameworkler mevcuttur. Kurumsal 
Java uygulamaları geliştirirken karşılaşılan en büyük zorluklar da bütün bu kütüphaneleri, frameworkleri bir araya 
getirebilmek, katmanlar arası entegrasyonu sağlıklı biçimde kurabilmek, altyapısal ihtiyaçları iş mantığından bağımsız 
biçimde karşılayabilmektir.

İşte `Spring Framework`de, başta `Dependency Injection` ve `AOP` konseptleri üzerine kurulu hafif sıklet container 
yardımıyla, `transaction`, `jdbc` işlemleri, `remoting`, `mesajlaşma` ve diğer pek çok altyapısal hizmeti hem mevcut API 
kütüphanelerini ve ilgili frameworkleri birbirleri ile entegre hale getirerek, hem de bunların yazılım geliştirme 
sürecinde daha efektif ve standard bir yaklaşımla kullanılmasını sağlayacak yardımcı yapılar ve sınıflar sunarak JEE ile 
kurumsal uygulama geliştirmeyi kolaylaştırmaktadır. `Spring Framework` uygulama geliştirmeyi monolitik tabir edilen 
uygulama sunucularından kurtararak, test driven yazılım geliştirme sürecine de ciddi biçimde katkı sağlamıştır. Bütün 
bunların yanında `Spring`, tüm hizmetlerini normal Java nesneleri (`POJO`) kullanarak sağlamaktadır.

`Spring`e başlamak, `Spring` ile uygulama geliştirmek oldukça kolaydır. Bunun en temel nedenlerinden biri de `Spring`'in 
sağladığı hizmetlerin istediğimiz kadarını istediğimiz zaman ve yine kendi belirlediğimiz seviyede sistemimize dahil 
edebiliyor olmamızdır. Örneğin, ihtiyacımız sadece sıradan transaction desteği ise `RMI` ile , `JTA` ile uğraşmak zorunda 
değiliz. Hem normal Java uygulamalarında, hem de JEE web uygulamalarında `Spring` rahatlıkla kullanılabilmektedir. Ayrıca 
`Spring`’i kullanmaya başlamak için mutlaka yeni bir projeye başlamamız da gerekmiyor; projenin herhangi bir aşamasında 
`Spring`’in sağladığı hizmetleri sistemimize dahil edebiliriz.

`Spring`’in çekirdeğinde `lightweight IoC container` vardır. Uygulamamızın ihtiyaç duyduğu nesneler bu container 
içerisinde oluşturulur, container bu nesneler arasındaki kablolamayı (`wiring`), nesnelerin konfigürasyonunu ve diğer pek 
çok altyapısal ihtiyacı karşılar. `BeanFactory` ve `ApplicationContext`’de bu container’ın temel arayüzleridir. Yeni bir 
`IoC container` oluşturmak için bir `ApplicationContext` nesnesi yaratmamız yeterlidir. IoC container tarafından 
yönetilecek nesneleri, bu nesnelerin özelliklerini, konfigürasyon bilgilerini, aralarındaki ilişkileri değişik yöntemlerle 
tanımlayabiliriz. Bu yöntemlerden en popüleri `XML`dir. `XML` dosyaları içerisindeki bu tanımlar ve `POJO` sınıflarımız 
IoC container tarafından işlenerek tam olarak kullanıma hazır bir sistem ayağa kaldırılır.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
           http://www.springframework.org/schema/beans/spring-beans-2.0.xsd">

</beans>
```

Yeni bir `ApplicationContext` oluşturmak için yukarıdaki `XML` yeterlidir. `Spring` tarafından yönetilmesini istediğimiz 
nesnelerin tanımlarını bu `XML` içerisine ekleyeceğiz.

```java
public class Foo {
      private Bar bar;

      public String getMessage() {
            return"Foo" + bar.getMessage();
      }

      publicvoid setBar(Bar bar) {
            this.bar = bar;
      }
}

public class Bar {

      public String getMessage() {
            return"Bar";
      }
}
```

Örnek olarak aralarında bağımlılık olan iki basit sınıf oluşturalım. `Foo` nesnesi `getMessage()` metodunda bir `Bar` 
nesnesine ihtiyaç duyuyor. Eğer bu nesneleri kullanarak bir iş yapmak istiyorsak, `XML` dosyası içerisinde bu nesneleri 
`bean` olarak tanımlamamız ve aralarındaki ilişkiyi de belirtmemiz gerekiyor. Bunun için aşağıdaki `bean` tanımlarını 
`XML` dosyasına eklememiz yeterli.

```xml
<bean id="foo" class="com.ems.samples.spring.Foo">
      <property name="bar" ref="bar"/>
</bean>
<bean id="bar" class="com.ems.samples.spring.Bar"/>
```

Artık bu `XML` dosyasını ve Java sınıflarını kullanarak `application context`’i başka bir deyimle `IoC container`’ı 
oluşturup, context içerisinden istediğimiz bir nesneyi “id”sini belirterek `application context`’ten isteyip 
kullanabiliriz. Bunun için de basit bir test sınıfı oluşturalım.

```java
public class Tester {
      public static void main(String[] args) {
            ApplicationContext applicationContext = new ClassPathXmlApplicationContext("/appcontext/spring-beans.SpringSamples.xml");
            Foo foo = (Foo)applicationContext.getBean("foo");
            System.out.println("Mesaj :" + foo.getMessage());
      }
}
```

Main metodunda classpath’imizde bulunan `XML` dosyamızı kullanarak bir `ApplicationContext` nesnesi oluşturduk, ardından 
bu `application context` içinden `bean id`’sini belirterek `foo` nesnesini aldık ve `getMessage()` metodunu çağırdık. Bu 
örneği çalıştırmak için de classpath’imizde sadece `spring.jar` ve `commons-logging.jar` kütüphanelerinin bulunması 
yeterlidir.

`Spring XML` dosyasını classpath yerine doğrudan dosya sisteminden de yüklememiz mümkündür. `Spring` ne `bean` 
tanımlarının yapılış şekline, ne de bu tanımların lokasyonuna bir sınır getirmektedir. Yani `XML` yerine `property` 
dosyalarını da, `Java 5 annotation`’larını da kullanabiliriz.

Web uygulamalarında ise bizim doğrudan bir `IoC container` oluşturmamıza gerek yoktur. `web.xml` dosyasına eklenecek bir 
kaç satırlık standard bir konfigürasyon ile web uygulamamız ayağa kalktığı vakit `Spring`’in `IoC container`’ı da 
kullanıma hazır olacaktır.

```xml
<context-param>
      <param-name>contextConfigLocation</param-name>
      <param-value>classpath:/appcontext/spring-beans.SpringSamples.xml</param-value>
</context-param>

<listener>
      <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>
```

Daha sonra web uygulamasının herhangi bir aşamasında, kullandığımız sunum katmanı teknolojisine göre 
(`JSF`, `Struts` vb.) `WebApplicationContextUtils` veya `FacesContextUtils` yardımcı sınıflarını kullanarak rahatlıkla 
`application context`’e erişmemiz mümkündür. Örneğin bir Servlet içerisinde;

```java
public class TestServlet extends HttpServlet {

      protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
            ApplicationContext applicationContext = WebApplicationContextUtils.getRequiredWebApplicationContext(req.getSession().getServletContext());
            Foo foo = (Foo)applicationContext.getBean("foo");
            String message = foo.getMessage();
            resp.setContentType("text/plain");
            resp.setContentLength(message.length());
            resp.setCharacterEncoding("utf-8");
            PrintWriter writer = resp.getWriter();
            writer.write(message);
            writer.close();
      }
}
```

`Spring Struts`, `JSF`, `Tapestry`, `WebWork` gibi popüler web frameworklerine doğrudan entegre edilebilmektedir. Bu 
sayede yukarıdaki gibi extra herhangi bir işlem yapmadan web katmanından `Spring` tarafından yönetilen nesnelere 
erişebiliriz. Örneğin `JSF` için, `DelegatingVariableResolver` sınıfını `faces-config.xml` içinde tanımlamamız bu 
entegrasyon için yeterlidir.

```xml
<application> 
 <variable-resolver>org.springframework.web.jsf.DelegatingVariableResolver</variable-resolver> 
</application>
```

Daha sonra herhangi bir `JSF` sayfamızın içerisinde bu nesnelerimize normal bir `JSF managed bean` gibi erişebiliriz:

```html
<html>
    <body>
          <f:view>
                <h:form id="test">
                      <h:outputText id="txtMessage" value="#{foo.message}"/>
                </h:form>
          </f:view>
    </body>
</html>
```

Bütün bu örneklerden de gördüğümüz gibi `Spring Framework` ile çalışmaya başmak için ne yüzlerce sayfalık kullanım 
kılavuzlarını okumaya, ne de uygulamamız içerisinde onlarca satırlık karmaşık ayarlar yapmaya gerek vardır. Bütün 
bunların yanında `Spring` kullanmaya başlamak, sağladığı faydalardan istifade etmek için mutlaka bir yeşil vadi 
(`green field`) projesine de ihtiyacımız yoktur. Hemen şimdi projemiz içerisinde `Spring`’i kullanmaya başlayabilir, 
ihtiyaçlarımız ölçüsünde sistemimize dahil edebiliriz.
