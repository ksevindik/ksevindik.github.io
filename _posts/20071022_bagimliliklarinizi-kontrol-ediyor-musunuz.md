# Bağımlılıklarınızı Kontrol Ediyor musunuz?

Geçen aylarda `www.springframework.org` sitesinde yapılan bir ankette nesnelerin ihtiyaç duyduğu bağımlılıkların sağlanıp 
sağlanmadığının hangi yöntemlerle kontrol edildiği sorgulanmıştı. Bu anketten ortaya çıkan ilginç sonuç ise, yaklaşık 
%29’luk bir kesimin gerekli bağımlılıkların kontrolünü hiç yapmadıklarını söylüyordu. Oysa bağımlılık kontrolü bir 
nesnenin sağlıklı bir biçimde oluşturulup kullanılabilmesi için gerekli bir işlemdir. Spring, bağımlıkların kontrolü için 
geliştiricilere birden fazla alternatif sunmaktadır. Alef Arendsen’in de Interface21 sitesindeki 
[bloğunda](http://blog.interface21.com/main/2007/07/11/setter-injection-versus-constructor-injection-and-the-use-of-required/) 
etraflıca incelediği bu konuda öne çıkan üç yönteme kısaca göz atmakta yarar var.

1. `Constructor injection`
2. `@Required` annotation
3. `InitializingBean`

### Constructor Injection

Sınıfların ihtiyaç duyduğu bağımlılıkların nesnelere constructor yardımı ile iletilmesidir. Aslında bağımlılıkların 
sağlanmasını garanti etmek açısından en sağlıklı yaklaşımdır. Bir nesne oluşturulduğu andan itibaren kullanıma hazır 
olmalıdır. Constructor injection Spring tarafından bean tanımlarında desteklenmektedir. Ancak setter injection ile 
kıyaslandığında constructor injection daha seyrek kullanılmaktadır. İş mantığı barındıran sınıflar için bağımlılık 
yönetiminde setter injection yerine constructor injection tercih etmek çok daha uygun olacaktır.

```xml
<bean id="reportExportManager" class="com.ems.base.reporting.export.ReportExportManager" />
<bean id="reportExportManagerOutputTransformer" class="com.ems.base.reporting.transform.ReportExportManagerOutputTransformer">
   <constructor-arg>
        <ref local="reportExportManager" />
   </constructor-arg>
</bean>
```

### @Required Annotation

Spring 2.0 ile gelen annotation desteği sayesinde bağımlılıkların kontrolü tamamen dekleratif yapılabilir. Bunun için 
yapılması gereken sadece application context içerisinde `RequiredAnnotationBeanFactoryPostProcessor`’un tanımlanmasından 
ibarettir. 

```xml
<bean class="org.sfw.beans.factory.annotation.RequiredAnnotationBeanFactoryPostProcessor"/>
```

Ardından kodunuzun içerisinde kontrolü yapılacak bağımlılıkların setter metodlarına `@Required` annotation’ını 
ekleyebilirsiniz. Örneğin;

```java
public abstract class GenericReportGenerator {

      ...

     @Required
     public void setReportEnvProperties(ReportEnvProperties reportEnvProperties) {
          this.reportEnvProperties = reportEnvProperties;
     }

      ...

}
```

### InitializingBean

Diğer bir yöntem ise Spring application context’in callback metodlarını kullanmaktır. Spring’in yönetimine dahil ettiğimiz 
nesnelerimizin sınıfları `InitializingBean` arayüzüne sahip olurlarsa Spring, application context oluşturulması aşamasında 
her bean oluşturulup bağımlılıkları enjekte edildikten sonra bu bean’ların `afterPropertiesSet()` metodunu çağırır. Bu 
metod içerisinde ilgili bağımlılıkların mevcut olup olmadığı kontrol edilebilir.

```java
public class ReportPrintManagerOutputTransformer implements InitializingBean {
    private ReportPrintManager reportPrintManager;

...

    public void afterPropertiesSet() throws Exception {
           Assert.notNull(reportPrintManager, "reportprintManager cannot be null.");
    }


    public void setReportPrintManager(ReportPrintManager reportPrintManager) {
             this.reportPrintManager = reportPrintManager;
    }

...

}
```

```xml
<bean id="reportPrintManager" class="com.ems.base.reporting.print.ReportPrintManager" />

<bean id="reportPrintManagerOutputTransformer" class="com.ems.base.reporting.transform.ReportPrintManagerOutputTransformer">
     <property name="reportPrintManager">
          <ref local="reportPrintManager" />
     </property>
</bean>
```

`InitializingBean` arayüzüne sahip olmak yerine eğer sınıfta mevcut bir init metodu varsa ve bu metod içerisinde 
bağımlılık kontrolü yapılıyorsa Spring’e application context içerisinde bu init metodunu bean oluştururken çağırması 
söylenebilir.

```java
public class ReportPrintManagerOutputTransformer {
       private ReportPrintManager reportPrintManager;

      ...

       public void initialize() throws Exception {
        Assert.notNull(reportPrintManager, "reportprintManager cannot be null.");
       }


       public void setReportPrintManager(ReportPrintManager reportPrintManager) {
        this.reportPrintManager = reportPrintManager;
       }

      ...

}  
```

```xml
<bean id="reportPrintManager" class="com.ems.base.reporting.print.ReportPrintManager" />
<bean id="reportPrintManagerOutputTransformer" init-method="initialize" class="com.ems.base.reporting.transform.ReportPrintManagerOutputTransformer">
   <property name="reportPrintManager">
       <ref local="reportPrintManager" />
   </property>
</bean> 
```

Bütün bu yöntemlerin yerine göre kullanım alanları mevcuttur. İş mantığının yoğun olduğu sınıflarda constructor injection 
doğal bir tercih olabilir. Ancak framework veya altyapı sınıflarında, yani opsiyonel parametrelerin çoğunlukta olduğu 
durumlarda setter injection daha uygun olacaktır. Annotation’ların kullanılması `InitializingBean` gibi bir arayüz 
bağımlılığını ortadan kaldırmaktadır. Ancak Java 5’den önceki sistemler için `InitializingBean` yine de uygun bir 
tercihtir. Ayrıca bağımlılıkların kontrolü tek bir metod içerisinde toplanmaktadır. Eğer hali hazırda geliştirilmiş bir 
sınıf ve bunun bir init metodu varsa bu durumda init metodu kullanmak da çözüm olacaktır.
