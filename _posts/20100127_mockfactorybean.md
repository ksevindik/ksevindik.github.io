# MockFactoryBean

Diyelim ki Spring application context dosyalarından birini yükleyerek entegrasyon birim testi gerçekleştirmek istiyorsunuz. 
Ancak yüklediğiniz application context içerisindeki bean tanımlarından birisi başka bir application context içinde tanımlı 
bir bean’a ihtiyaç duyuyor, bu bean de diğer bir application context dosyasındaki başka bir bean’a ihtiyaç duyuyor ve bu 
böyle gidiyor… Anlayacağınız entegrasyon birim testi yapacağım derken neredeyse bütün application context dosyalarını 
yüklemek zorunda kalacaksınız. Bu durum testinizin birkaç milisaniye yerine onlarca saniye hatta dakikalarca sürmesine 
neden olabilir. İlk application context dosyası içerisindeki bean’ın bağımlılığını ortadan kaldırabilirsek sorun çözülecek. 
Bunun için bu bean’ın arayüzüne sahip bir stub sınıf oluşturulabilir ve bu sınıf kullanılarak entegrasyon testine özel, 
application context dosyası içerisinde bağımlı bean id’si ile aynı id’ye sahip bir bean tanımı yapılabilir. Bu sayede 
test edilen application context dosyası içerisindeki dışarıya bağımlı bean tanımı bizim stub sınıfımızdan oluşan bean 
tarafından “override” edilmiş olacaktır.

Ancak bu yöntem hemen her entegrasyon birim testinde bizi pek çok bean için stub oluşturmak zorunda bırakacaktır. Bunun 
yerine Mockito’nun yardımı ile bir mock nesne oluşturup bunu Spring application context içerisinde override edeceğimiz 
bean yerine tanıtabilsek işimiz çok daha kolay olabilir. Bunun için yapmamız gereken aslında çok basit: Spring FactoryBean 
kabiliyetinden yararlanarak bir MockFactoryBean oluşturabiliriz. Daha sonra application context içerisinde bu factory bean 
ile hangi arayüz veya sınıftan mock nesne oluşturmak istiyorsak bunu `objectType` parametresi ile belirterek bir mock bean 
oluşturmamız mümkündür. Aşağıda MockFactoryBean sınıfının bir implementasyonunu görüyorsunuz.

```java
public class MockFactoryBean<T> extends AbstractFactoryBean<T> { 
    private Class<? extends T> objectType; 
    @Override protected T createInstance() throws Exception { 
        return Mockito.mock(objectType); 
    } 
    @Override public Class<? extends T> getObjectType() { 
        return objectType; 
    } 
    public void setObjectType(Class<? extends T> objectType) { 
        this.objectType = objectType; 
    } 
}
```

Eğer mock nesne üzerinde entegrasyon birim testi içerisinde bir takım expectation ve verification işlemleri yapmanız 
gerekirse, bu bean’ı test case’ine “inject” etmeniz yeterlidir. Test metodlarınız içerisinde mock nesnenizi dilediğiniz 
gibi kullanabilirsiniz. Bu expectation işlemleri nedeniyle test metodlarının birbirlerine yan etkileri olabilir. Spring 
3.0 ile gelen `@DirtiesContext` özelliği sayesinde testlerin application context’i kirlettiğini belirtip, müteakip test 
metodunda application context’in yeniden yüklenmesini sağlayabiliriz. `@DirtiesContext` annotasyonu metod düzeyinde veya 
sınıf düzeyinde kullanılabilir.
