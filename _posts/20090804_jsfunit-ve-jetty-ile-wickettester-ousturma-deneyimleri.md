# JSFUnit ve Jetty ile WicketTester Ouşturma Deneyimleri

Geçenlerde `JSFUnit`’i değişikliğe uğratarak `WicketTester` benzeri bir test altyapısı kurmaya çalıştım. `WicketTester`, 
istemci çağrılarını tek bir noktada ele alıyor. `JSFUnit`, `HtmlUnit`, `Selenium` gibi istemci- sunucu iletişimi söz 
konusu olmuyor.

Ancak `JSFUnit` in-container test framework. Bu nedenle uygulamanın testlerle birlikte sunucuya deploy edilmesini ve 
sunucunun çalıştırılmasını bekliyor. `HtmlUnit` vasıtası ile sunucu tarafında uygulamaya request’ler göndererek 
`JSFSession` ile sayfanın durumunu, `FacesContext` nesnesini ve dönen cevaptaki html içeriğini test etmeye çalışıyor. 
Projelerimizde genellikle UI düzeyinde fonksiyonel testleri gerçekleştirmek için uygulamanın ihtiyaç duyduğu 
`Spring ApplicationContext`’in de initialize olması gerekmektedir. Bu da aslında web container ile uygulamanın ayağa 
kaldırılmasına denk gelmektedir. Ayrıca `WicketTester`’a birebir benzeyen bir test altyapısını oluşturmak için dönen 
cevap içerisindeki html sayfasının işlenmesi, web requestlerinin oluşturulması, DOM ağacının kısmi güncellenmesi, 
javascript ile ilgili işler gibi konularda kapsamlı çalışma yapmak gerekmektedir. Bütün bu noktaları değerlendirdiğimizde 
mevcut çözümlerden `JSFUnit`, `Jetty`, `JUnit` gibi çözümleri bir araya getirerek HTTP tabanlı istemci-sunucu iletişimine 
dayanan in-container tabanlı fakat standalone çalıştırılan bir tester oluşturmak daha anlamlı gözüktü.

Geliştirilen `JSFTester` çözümünün içerisinde `JSFUnit`’in kullanımı söz konusudur. `JSFTester`’ da `JSFUnit`’in 
`JSFSession` nesnesi üzerinden `JSFClientSession` ve `JSFServerSession` nesnelerine erişmek gerekiyor. `JSFUnit`’deki 
`ClientSession` `HtmlUnit` ile dönen cevabı incelemeye, `ServerSession` ile de en son request sonucu oluşan `FacesContext` 
nesnesine, `UIComponent` ağacına ve sunucu tarafındaki “faces managed bean”lara erişmeye yardımcı oluyor. `JSFServerSession` 
nesnesi runtime’da `FacesContext`’in intialize olmasını bekliyor.

`JSFTester` içerisinde `Jetty` web sunucusunu gömülü olarak çalıştırıp `HttpSession` nesnesini, `JSFTester`’a `
ServletRequestListener` yardımı ile iletmeyi denedim. İletilen `Session` `JSFUnit` tarafında bir `ThreadLocal` değişken 
vasıtası ile en son request’e ait `FacesContext` nesnesini almak için kullanılıyor.

Bu noktaya kadar başarılı oldum ancak `testcase`, servlet container’ın `classloader`’ından farklı bir `classloader` ile 
çalıştırıldığından, `JSFServerSession`’ın çalışması için gerekli olan faces initialization o `classloader`’da yapılmamış 
oluyordu. Bu durumda dönen cevap üzerinde herhangi bir html elemanına click’lediğimiz vakit `JSFUnit` tarafında 
faces-initialization’a tabi tutulmuş bir thread context olmadığından problem oluyordu. Bunu aşmak içinde `Jetty`’nin 
`WebAppContext`’inin `classLoader`’ını `testcase`’i çalıştıran thread’in `contextClassLoader`’ı ile değiştirmek gerekiyor. 
Daha öncesinde de aynı class’ın `Jetty`’nin `WebAppClassLoader`’ı tarafından tekrar yüklenmesi nedeniyle ortaya çıkan bir 
class cast probleminden ötürü `WebAppContext`’in `parentLoaderPriority` değeri true yapılmıştı. Bu sayede `WebAppClassLoader` 
öncelikle kendisi değil, parent class loader’ı ile sınıfları yüklemeye çalıyordu.

Şu ana kadar karşıma çıkan problemleri bir biçimde çözüme kavuşturdum. Ancak muhtemel en büyük problem noktası olarak 
`JSFTester`’in ve `Jetty`’nin ayrı ayrı thread’lerde çalışması şimdilik uyuyan bir yanardağ gibi duruyor. Ayrıca `HttpSession` 
timeout olup, yeni bir session yaratıldığı vakit bu session’ın da `ThreadLocal` değişkene tekrar set edilmesi gerekiyor.
