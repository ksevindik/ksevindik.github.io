# BeanFactoryLocator ve Spring ile Modüler Programlama

Spring ile ilgili bir önceki [yazımızda](http://www.kenansevindik.com/spring-ve-applicationcontext-hiyerarsisi/) 
BeanFactoryLocator yardımı ile web uygulamalarında parent-child ApplicationContext 
hiyerarşisinin nasıl kurulabileceğini anlatmıştık. Bu yazımızda ise BeanFactoryLocator ile standalone bir uygulamanın 
birden fazla modüle ayrıştırılarak her bir modülün kendine ait bir ApplicationContext yönetmesi nasıl sağlanabilir, modüller 
arası bağımlılıklar nasıl yönetilebilir gibi sorulara cevap vermeye çalışacağız.

Öncelikle, yazı genelinde bahsettiğimiz modül kavramı ile, bir veya daha fazla bileşen içeren jar dosyasını kast ettiğimizi 
belirtelim. Elimizde X ve Y isimli iki modül, her iki modül de de XService ve YService arayüzleri ve bu arayüzleri implement 
eden servis sınıflarımız olsun.

```java
public interface XService {
	public String name();
}

public interface YService {
	public String name();
}

public class XServiceImpl implements XService {

	private YService yService;

	public String name() {
        return "x-service:" + yService.name();
	}
	public void setyService(YService yService) {
		this.yService = yService;
	}
}

public class YServiceImpl implements YService {
	public String name() {
		return "y-service";
	}
}
```

Görüldüğü gibi XServiceImpl, YService’ine ihtiyaç duymaktadır. Başka bir deyişle X modülünden Y modülüne bir bağımlılık 
söz konusudur. Daha sonra her iki modüle de bu servis sınıflarıdan oluşan bileşen tanımlarını içeren konfigürasyon 
dosyalarını ekleyelim.

X modülü için classpath:/appcontext/xContext.xml:

```xml
<beans...>
    <bean id="xService" class="examples.service.XServiceImpl">
        <property name="yService" ref="yService"/>
    </bean>
</beans>
```

Y modülü için classpath:/appcontext/yContext.xml:

```xml
<beans...>
    <bean id="yService" class="examples.service.YServiceImpl"/>
</beans>
```

Son olarak da iki ayrı beanRefContext.xml içerisinde aşağıdaki gibi iki modülü temsil eden ApplicationContext bileşenlerini 
tanımlayalım.

```xml
<beans ...>

    <bean id="x.module" class="org.springframework.context.support.ClassPathXmlApplicationContext">
        <constructor-arg value="classpath*:/appcontext/xContext.xml"/>
        <constructor-arg ref="y.module"/>
    </bean>

</beans>

<beans ...>

    <bean id="y.module" class="org.springframework.context.support.ClassPathXmlApplicationContext">
        <constructor-arg value="classpath*:/appcontext/yContext.xml"/>
    </bean>

</beans>
```

Yukarıda da gördüğünüz gibi X modülü Y modülüne ihtiyaç duyduğu için “x.module” isimli ApplicationContext bileşen tanımına 
constructor-arg olarak “y.module” verilmiştir. Bu durumda “y.module” isimli ApplicationContext, “x.module” isimli 
ApplicationContext’in parent’ı olmaktadır. Bir ApplicationContext birden fazla ApplicationContext için parent olabilir. 
Ancak her ApplicationContext en fazla tek bir ApplicationContext’i parent gösterebilir.

Son olarak da bahsettiğimiz sınıfları ve konfigürasyon dosyalarını bir araya getirerek x.jar ve y.jar arşiv dosyalarını 
yaratalım. Artık X modülünü kullanarak testimizi gerçekleştirebiliriz.

```java
BeanFactoryLocator beanFactoryLocator =
ContextSingletonBeanFactoryLocator.getInstance();

BeanFactoryReference beanFactoryReference =
beanFactoryLocator.useBeanFactory("x.module");
BeanFactory beanFactory = beanFactoryReference.getFactory();

XService xService = beanFactory.getBean(XService.class);
System.out.println(xService.name());
```

Öncelikle ContextSingletonBeanFactoryLocator ile BeanFactoryLocator instance’ı elde edilir. Bu işlem classpath’deki bütün 
beanContextRef.xml dosyalarının tespit edilip içlerindeki bileşen tanımlarından bileşenleri oluşturur. Daha sonra 
BeanFactoryLocator’dan ilgili modüle karşılık gelen ApplicationContext’e referans içeren BeanFactoryReference nesnesi 
elde edilir. BeanFactoryReference’in görevi ilgili ApplicationContext’e yani BeanFactory nesnesine erişimleri takip etmek 
ve yönetmektir. Ardından BeanFactoryReference üzerinden ApplicationContext’e erişilir. Artık elimizde X modülüne karşılık 
gelen ApplicationContext bileşenimiz mevcuttur. Bundan sonraki adımlarda X modülünde tanımlı herhangi bir bileşene erişerek, 
örneğimizde xService, istediğimiz senaryoyu çalıştırabiliriz.

