# Spring ve Bean Scope Tanımları

Spring’in ilk zamanlarında bean tanımları iki değişik kapsama alanına (scope) sahip olabiliyordu. Eğer bir bean singleton 
olarak tanımlanmış ise Spring container içerisinde bu bean tanımından sadece tek bir nesne mevcut olabiliyordu. Klasik 
GOF singleton pattern’ı bir sınıfın class loader düzeyinde ancak tek bir nesnesinin olmasını garanti eder. Ancak Spring 
singleton bundan biraz farklıdır. Spring için singleton container ve bean tanımı düzeyindedir.

```xml
<bean id="foo1" class="org.ems4j.model.Foo" scope="singleton" />

<bean id="foo2" class="org.ems4j.model.Foo" scope="singleton" />
``` 

Yukarıdaki iki bean tanımı için, bu bean tanımları aynı Foo sınıfından olmuş olsa bile, ayrı ayrı birer nesne, container 
kapsama alanında oluşturulacaktır.

İkinci kapsama alanı ise prototype idi. Her ne zaman container’a prototype kapsama alanına sahip bir bean için istek 
geldiğinde (örneğin `getBean(beanName)` metodu ile container’dan bir bean istendiğinde) container bu bean tanımından yeni 
bir nesne oluşturup onu döndürmektedir. Bu nesnelerin oluşturulup ilgili yere döndürülmesinden sonraki yaşam döngülerinin 
idaresi tamamen Spring dışındadır.

```xml
<bean id="bar" class="org.ems4j.model.Bar" scope="prototype" />
```

Bu noktada hemen aklımıza şöyle bir soru gelebilir: Eğer singleton olarak tanımlanmış bir bean prototype olarak tanımlanmış 
bir bean’a bağımlı ise ne olur? Spring bağımlılıkları bean tanımlarından nesneleri oluştururken sağlamaktadır. Bu durumda 
singleton olarak tanımlanmış bean container ayağa kalkarken (lazy olarak tanımlanmadığını varsayalım) oluşturulacağı için 
bu aşamada da bağımlı olduğu prototype kapsama alanındaki bean tanımından yeni bir nesne oluşturulup kendisine inject edilir. 
Bundan sonra singleton bean ömrü boyunca aynı prototype nesneyi kullanacaktır. Eğer singleton bean’a her erişimde yeni 
bir prototype bean nesnesinin inject edilmesini istiyorsanız o zaman method injection olarak tabir edilen başka bir 
yöntemi kullanmalısınız.

Spring 2.0’da, bu iki temel kapsama alanı tipine ek olarak request, session ve globalSession kapsama alanları da eklendi. 
Daha da önemlisi kendimize özel kapsama alanları tanımlama kabiliyetine de sahip olduk. Yeni eklenen bu kapsama alanları 
sadece `WebApplicationContext` tipindeki container'lar için anlamlıdır. Bu kapsama alanlarını diğer container'lar içerisinde 
kullanmaya kalkıştığınızda `IllegalStateException` hatası alabilirsiniz.

İsimlerinden de anlaşılacağı gibi request kapsama alanına sahip bir bean tanımından her yeni request için yeni bir nesne 
oluşturulacaktır. Web request'inin sonlanması ile bu nesne de kapsama alanından çıkmış olacaktır. Session kapsama alanı 
ise `HttpSession` boyunca aktif olacak nesneler için kullanılır. globalSession ise portlet ortamları için anlamlı olup, 
yine `HttpSession`’a benzer bir kapsama alanı oluşturmaktadır.

Spring’in kapsama alanları ile ilgili daha önemli bir özelliği ise değişik kapsama alanlarında tanımlanmış bu bean 
tanımları arasındaki bağımlılıkları uygun biçimde çözebilmesidir. Özetle, eğer request kapsama alanına sahip bir bean 
tanımına bağımlı iseniz ve sizin bean tanımınız da session veya singleton kapsama alanına sahip ise Spring, request kapsama 
alanındaki bean tanımı ile aynı arayüze sahip bir proxy nesnesini asıl kapsama alanındaki nesnenin yerine inject 
edebilmektedir. Bu proxy nesnesi çağrıları asıl kapsama alanındaki gerçek nesneye yönlendirecektir. Spring’in bu 
kabiliyetinden yararlanmak için hedef bean tanımına `<aop:scoped-proxy/>` elemanını eklemek yeterlidir.

```xml
<bean id="foo" class="org.ems4j.model.Foo" scope="request">
    <aop:scoped-proxy/>
</bean>
```  

Gelelim kendimize özel kapsama alanları oluşturmaya. Yeni bir kapsama alanı oluşturmak için Spring’in sağladığı 
`org.springframework.beans.factory.config.Scope` arayüzünü implement eden bir sınıf geliştirmemiz yeterlidir.

Scope arayüzündeki metodların üstünden kısaca geçmek yararlı olabilir. Bu metodlardan ilki:

```java
Object get(String name, ObjectFactory objectFactory);
```  

`name` parametresine karşılık gelen nesneyi ilgili kapsama alanında mevcutsa döndürür, yoksa `objectFactory.getObject()` 
ile yeni bir nesne yaratır, bunu kapsama alanına tanıtır ve sonuç olarak döner.

```java
Object remove(String name);
```  
  
Bu metod ise `name` parametresine karşılık gelen nesneyi ilgili kapsama alanından kaldırır ve bu nesneyi döner. Eğer nesne 
mevcut değilse `null` döner. Bu metod ayrıca bu nesne için kayıtlı destructor callback nesneleri varsa bunları da kaldırmalıdır. 
Bu metod destructor callback nesnelerini çağırmamalıdır, çünkü kapsama alanından çıkarılması istenen nesne bu metod çağrısını 
yapan yer tarafından hâlâ kullanılıyor olabilir.

```java
void registerDestructionCallback(String name, Runnable destructionCallback);
```  

İlgili nesne için kapsama alanına bir destructor callback nesnesi kaydeder. Destructor callback nesneleri kapsama alanı 
veya ilgili nesne ortadan kaldırılırken çağırılmalıdır. Bu metoda verilen callback eğer ilgili kapsama alanı tarafından 
çağırılmak için uygun değilse herhangi bir şey yapılmadan warning verilebilir.

```java
String getConversationId()
```  

Son olarak ise ilgili kapsama alanını tanımlayan herhangi bir belirteç varsa bunu dönen bir metottur. Örneğin session 
scope için `sessionId` dönülmektedir. Eğer kapsama alanı için uygun bir belirteç yoksa `null` dönülebilir.

Kapsama alanı için gerekli sınıfı yazdıktan sonra bunu ister programatik ister deklaratif olarak Spring’e tanıtabiliriz. 
Programatik olarak tanıtmak için Spring container'ın implement ettiği `ConfigurableBeanFactory` arayüzünün 
`registerScope(String name, Scope scope)` metodunu çağırmalısınız. Deklaratif olarak yapmak için ise Spring’in 
`org.springframework.beans.factory.config.CustomScopeConfigurer` sınıfından bir bean tanımı oluşturup key-value eşleniği 
olarak scope adını ve scope nesnenizi verebilirsiniz.

```xml
<bean class="org.springframework.beans.factory.config.CustomScopeConfigurer">
    <property name="scopes">
        <map>
            <entry key="thread">
                <bean class="org.ems4j.factory.scope.ThreadScope" />
            </entry>
        </map>
    </property>
</bean>
```  

Eugene Kuleshov’un [blog yazısı](http://www.jroller.com/eu/entry/implementing_efficinet_id_generator)nda örnek bir custom 
thread kapsama alanının oluşturulması ve tanıtılmasını bulabilirsiniz. 
Konu ile ilgili diğer bir örneği ise Rick Hightower’ın [blog yazısı](http://www.jroller.com/RickHigh/entry/adding_a_jsf_view_scope)ndan 
okuyabilirsiniz. Rick bu örnekte JSF için view scope tanımını geliştirmektedir.

