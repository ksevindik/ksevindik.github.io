# Spring Boot ve JSF

Java Server Faces (JSF)’i başarısız bir UI framework olarak nitelediğimi değişik ortamlarda ve yazılarımda belirtmişimdir. 
Ancak ne yapalım ki JSF sıkça kullanılan bir UI framework olarak karşımıza çıkıyor. Spring ekosisteminde JSF’i Spring 
çözümleri ile entegre etmeye çalışan arkadaşlardan zaman zaman sorular alıyorum.

Spring Boot ile geliştirilen web uygulamalarında UI framework olarak JSF’i kullanmak mümkündür. Spring Boot ile ilgili 
verdiğimiz [kurumsal eğitimimiz](http://www.java-egitimleri.com/springboot.html)de opsiyonel olarak Spring Boot JSF 
entegrasyonuna da değiniyoruz. Bu yazımda da kısaca Spring Boot uygulaması içerisinde JSF kullanabilmek için ne tür 
ayarlar yapmak gerektiğinden bahsedeceğim.

Spring Boot uygulaması içerisinde JSF ile çalışabilmek için aşağıdaki noktalar üzerinde ayarlamalar ve custom kod yazma 
ihtiyacı söz konusudur. Bu ayarları tespit ettiğim Spring Boot sürümünün 2.0.x,  JSF ref impl sürümünün ise 2.2.14 olduğunu 
da belirtmeliyim. Zaman içerisinde hem Spring Boot’un hem de JSF’in sürümlerinden kaynaklanan farklılıklar da söz konusu 
olabilir. Ancak yine de aşağıdaki adımlar genel olarak Spring Boot – JSF entegrasyonu için temel teşkil edecektir.

1. JSF bağımlılıklarının pom.xml’e eklenmesi
2. FacesServlet’in tanımlanması
3. ConfigureListener’ın tanımlanması
4. Spring Boot projesinin executable war’a dönüştürülmesi
5. faces-config.xml içerisinde JSF EL Resolver tanımı ile managed bean ve managed property lookup’ları için Spring 
Container’a bakılmasının sağlanması
6. Ayrıca JSF Backing Bean’ları Spring Managed yapacaksanız custom ViewScope konfigürasyonu da yapılmalıdır

Öncelikle JSF bağımlılıklarını pom.xml’e ekleyerek başlayalım.

```xml
<dependency>
    <groupId>com.sun.faces</groupId>
    <artifactId>jsf-api</artifactId>
    <version>2.2.14</version>
</dependency>
<dependency>
    <groupId>com.sun.faces</groupId>
    <artifactId>jsf-impl</artifactId>
    <version>2.2.14</version>
</dependency>
```

Ayrıca JSF Container çalışma zamanında JSP derleyicisine de ihtiyaç duyduğu için pom.xml’e Tomcat’in JSP compiler’ını da 
eklemeliyiz.

```xml
<dependency>
    <groupId>org.apache.tomcat.embed</groupId>
    <artifactId>tomcat-embed-jasper</artifactId>
</dependency>
```

İkinci adımda Spring Boot konfigürasyon sınıfımız içerisinde Java tabanlı olarak FacesServlet’in tanımını yapalım ve 
uzantısı *.xhtml olan web isteklerinde devreye girmesini sağlayalım.

```java
@Configuration
public class SpringAppConfig implements ServletContextAware {
    @Bean
    public ServletRegistrationBean facesServletRegistration() {
        ServletRegistrationBean registration = new ServletRegistrationBean(new FacesServlet(), "*.xhtml");
        registration.setLoadOnStartup(1);
        return registration;
    }

    //...
}
```

Şimdi de benzer biçimde JSF referans implementation’a ait olan ConfigureListener’ın java tabanlı konfigürasyon ile devreye 
girmesini sağlayalım. ConfigureListener JSF ile ilgili konfigürasyon bilgilerinin yüklenmesini ve çalışma ortamının ayağa 
kaldırılmasını sağlamaktadır.

```java
@Configuration
public class SpringAppConfig implements ServletContextAware {

    @Bean
    public ServletListenerRegistrationBean<ConfigureListener> jsfConfigureListener() {
        return new ServletListenerRegistrationBean<ConfigureListener>(new ConfigureListener());
    }

    //...
}
```

JSF konfigürasyonunun JBoss, Tomcat gibi web container’lar içerisinde sağlıklı biçimde yüklenebilmesi için aşağıdaki 
servlet context parametre tanımının da yapılması gerekmektedir.

```java
@Configuration
public class SpringAppConfig implements ServletContextAware {
    @Override
    public void setServletContext(ServletContext servletContext) {
        servletContext.setInitParameter("com.sun.faces.forceLoadConfiguration", Boolean.TRUE.toString());
    }
    
    //...
}
```

Spring Boot projelerinde JSF sayfaları sadece executable war dosyaları içerisinden erişilebilmektedir. Dolayısı ile Spring 
Boot projesinin tipini executable war yapmamız gerekmektedir. Bunun için pom.xml’deki packaging elemanının değerini 
aşağıdaki gibi war yapmamız yeterli olacaktır.

```xml
<packaging>war</packaging>
```

Spring Boot projesinin executable war yapılmasına paralel olarak JSF sayfalarını da src/main/webapp dizini altında bir 
lokasyona koymamız gerekmektedir.

Son olarak da faces-config.xml içerisinde JSF ELResolver olarak SpringBeanFacesELResolver gerçekleştirimini tanımlayarak 
JSF managed bean ve managed property lookup’ları için Spring ApplicationContext’e de bakılmasını sağlayalım.

```xml
<faces-config ...>
    <application>
        <el-resolver>org.springframework.web.jsf.el.SpringBeanFacesELResolver</el-resolver>
    </application>
</faces-config>
```

Bu aşamada Spring Boot projeniz içerisinde JSF ile çalışmaya başlayabilirsiniz. Eğer view scope JSF bean’lerini de Spring 
ApplicationContext içerisinde yönetmek isterseniz bu durumda son adımda belirttiğim custom view scope konfigürasyonunu 
da yapmanız gerekecektir. Daha önceki yazılarımdan birisinde JSF için sağlıklı çalışan custom view scope implemantasyonunu 
ve nasıl tanımlanacağını Harezmi’deki bir [blog yazısı](http://www.kenansevindik.com/spring-view-scope-for-jsf-2-users/)nda 
anlatmıştım.

JSF ile mücadelenizde başarılar... 😉