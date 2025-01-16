# Web Bileşenleri İçin Spring’in Autowiring Desteği

Spring kullanan Java uygulamalarının muhtemelen en az bir yerinde Spring tarafından yönetilmeyen nesnelerin Spring 
bean’ları ile iletişime geçmesi gerekir. Spring’in AOP kabiliyeti sayesinde Spring tarafından yönetilmeyen domain 
nesnelerine bağımlılıkları enjekte etmek mümkündür. Diğer bir tür nesne ise web bileşenleridir. Bunlar servlet, filter 
veya JAX-WS endpoint’leri olabilir. Çoğunlukla Spring tarafından yönetilmeyen bu tür nesnelerin Spring dünyasına erişip 
uygun bir bean’a işleri havale etmesi söz konusu olmaktadır. Bunun için de Spring `WebApplicationContext`‘e erişmek ve 
ilgili bean’a `beanId`’si veya tipi ile “lookup” yapmak gerekir. `WebApplicationContext`’e erişmek için ise 
`WebApplicationContextUtils` “utility” sınıfından yararlanılabilir. Ancak bunun için bir de `ServletContext` nesnesine 
erişmek zorunludur. `ServletContext` nesnesine erişmeye gerek bırakmadan bu tür web bileşenlerinin ihtiyaç duyduğu 
bağımlılıkların “autowire” edilebilmesini sağlayan diğer bir yol daha vardır.

```java
public class PetClinicServiceServlet extends HttpServlet {
    @Autowired
    private PetClinicService petClinicService;

    @Override
    public void init() throws ServletException {
        super.init();
        SpringBeanAutowiringSupport.processInjectionBasedOnCurrentContext(this);
    }

    //...
}
```

`SpringBeanAutowiringSupport` isimli sınıf, Spring tarafından yönetilmeyen nesnelerin bağımlılıklarının autowire 
edilebilmesini sağlayabilir. Örneğin yukarıdaki `PetClinicServlet` sınıfının `init` metodu içerisinde 
`SpringBeanAutowiringSupport.processInjectionBasedOnCurrentContext(this);` ifadesi ile `PetClinicService` tipindeki 
Spring bean’ı autowire edilmektedir. `SpringBeanAutowiringSupport` abstract bir sınıftır. İlgili web bileşeni başka bir 
sınıftan türemiyor ise bu sınıfı extend ettiği takdirde construction sırasında da bağımlılıkların enjekte edilmesi 
mümkün olacaktır.
