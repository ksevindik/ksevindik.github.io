# ThreadLocal Değişken Kullananlar, Aman Dikkat!

ThreadLocal değişkenler hem Java hem de .NET ile geliştirilen kurumsal uygulamalarda zaman zaman karşımıza çıkıyor. 
ThreadLocal bir değişkenin değeri her Thread için farklı farklı olabilmektedir. Bu değişkenler, en çok uygulamanın 
katmanları arasında bağlamsal bir verinin (contextual data) metotlara parametre geçmeden taşınması için kullanılmaktadır; 
örneğin, transaction verisi veya güvenlikle ilgili kullanıcı bilgisi gibi. Bu açıdan “global” değişkenlere de 
benzetilmektedirler.

Aşağıda Spring Security Framework projesinden alınmış bir kod parçacığında SecurityContext bilgisinin tutulmasında 
kullanılan ThreadLocal değişken mevcuttur.

```java
final class ThreadLocalSecurityContextHolderStrategy implements SecurityContextHolderStrategy {

   private static final ThreadLocal<SecurityContext> contextHolder = new ThreadLocal<SecurityContext>();

   public void clearContext() {
        contextHolder.remove();
    }

    public SecurityContext getContext() {
        SecurityContext ctx = contextHolder.get();
        
        if (ctx == null) {
            ctx = createEmptyContext();
            contextHolder.set(ctx);

        }
        return ctx;
    }

    public void setContext(SecurityContext context) {
        Assert.notNull(context, "Only non-null SecurityContext instances are permitted");
        contextHolder.set(context);
    }

    public SecurityContext createEmptyContext() {
        return new SecurityContextImpl();
    }

}
```

Web uygulaması geliştirenlerin ThreadLocal değişkenler ile çalışırken biraz daha dikkatli olmaları şarttır. Aksi takdirde 
hafıza sızıntılarına (memory leaks) yol açmaları veya güvenlik açıklarına neden olmaları çok kolaydır.

Eğer ThreadLocal değişkeniniz statik olarak tanımlanmış ise, ki yukarıdaki kod örneğinde de olduğu gibi, bu genellikle 
böyledir, ve değişkenin içeriği, bağlamsal veri üzerinde çalışma tamamlanmasına rağmen temizlenmez ise, sınıf hafızada 
yüklü kaldığı müddetçe yer kaplayacaktır. Java'da yüklenen sınıfların unload edilmesi de söz konusu olmadığı için bu hafıza 
alanları JVM açık kaldığı müddetçe garbage collection'a tabi tutulmayacaktır.

Diğer bir problem ise güvenlik noktasında karşımıza çıkar. Web uygulamaları çoğunlukla bir uygulama sunucusuna deploy 
edilirler ve sunucu, uygulamaya gelen web isteklerinin ayrı ayrı thread'ler tarafından ele alınmasını sağlar. Uygulama 
sunucusu istekleri hızlı biçimde ele alabilmek için çoğunlukla bir thread havuzu kullanır. Bir isteği karşılayan thread, 
sonrasında tamamen farklı bir kullanıcının web isteğini karşılamak için görevlendirilebilir. Bu görevlendirme aynı uygulama 
için olabileceği gibi tamamen farklı bir web uygulamasına gelen isteği cevaplamak için de olabilir. Eğer web isteği
cevaplanırken ThreadLocal değişkenin içeriği, istek sonunda uygulama tarafından temizlenmez ise, aynı thread sonrasında 
farklı bir web isteğini ele almak için görevlendirildiğinde, içerik diğer kullanıcı veya uygulama tarafından erişilebilir 
vaziyette olacaktır.

Uzun lafın kısası siz siz olun, ThreadLocal değişkenlerden yararlanırken işiniz bittiğinde bu değişkenlerin mutlaka 
temizlendiğinden, kullandığınız framework ve kütüphanelerin de varsa ThreadLocal değişkenlerinin uygun biçimde ele 
alındıklarından kesinlikle emin olun.

**Not**: Bu yazı ilk olarak 16 Ekim 2011 tarihinde TÜBİTAK'ın şimdi mevcut olmayan www.bilgiguvenligi.gov.tr sitesinde 
[yayımlanmıştır](http://www.bilgiguvenligi.gov.tr/yazilim-guvenligi/threadlocal-degisken-kullananlar-aman-dikkat.html).

