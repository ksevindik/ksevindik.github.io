# Spring AOP ile Performans Takibi

Spring Application Framework’ün en sevdiğim özelliklerden birisi de aspect oriented programlamayı oldukça kolay yapılabilir 
bir hale getirmesidir. Spring, hem kendi AOP framework’üne sahiptir, hem de AspectJ ile sağlam bir entegrasyon sunar. 
Spring AOP kendi çözümüdür, tam bir AOP framework olma iddiasında değildir. Proxy tabanlı bir framework’dür. Sadece 
“method execution join point”leri destekler. Ancak ünlü Pareto prensibine de atıf yapacak olursak, kurumsal uygulamalardaki 
AOP problemlerinin neredeyse pek çoğu Spring AOP ile çözülebilmektedir. Geriye kalan ve Spring AOP ile çözülemeyen problemlerde 
ise AspectJ’yi yine Spring içerisinden çok kolay biçimde kullanabilirsiniz.

Gelelim bugünkü konumuza. Geçenlerde Spring AOP ile performans monitor işlemi yapmak isteyen bir arkadaştan bir mesaj geldi. 
Mesajda üç tane Spring managed bean tanımlanmış ve bu bean’lerdeki metotların çalışma zamanları ile ilgili belirli bir 
formatta çıktı üretme işlemi Spring AOP ile yapılmak istenmiş.

```java
@Component
public class A {
	@Autowired
	private B b;
	public void performX() {
		b.x();
		b.xy();
	}
}

@Component
public class B {
	@Autowired
	private C c;
	public void x() {
		c.abc();
		c.xyz();
	}
	public void xy() {
	}
}

@Component
public class C {
	public void abc() {
	}
	public void xyz() {
	}
}
```

```console
    A.performX() took 50 ms
     B.x() took 33 ms
          C.abc() took 18 ms
          C.xyz() took 0 ms
     B.xy() took 0 ms
```

Transaction yönetimi, security, loglama, auditing, cache işlemleri gibi ihtiyaçlar, uygulamaların iş mantığından tamamen 
bağımsız ve uygulama geneline yayılan altyapısal ihtiyaçlardır. AOP ile bu tür altyapısal ihtiyaçları rahatlıkla modülerize 
edebiliriz. Performans amaçlı metot çağrılarının trace edilmesi, metot çalışma sürelerinin belirlenmesi de AOP ile 
rahatlıkla implement edilebilecek ihtiyaçlardan birisidir.

Spring AOP ile aspect geliştirirken AspectJ annotasyonlarını kullanabilmek de Spring’in artılarından birisidir. Böylece 
geliştirdiğimiz aspect’leri değişiklik yapmadan rahatlıkla AspectJ ortamında da çalıştırma imkanımız oluyor. Sınıf 
düzeyindeki `@Aspect` annotasyonu ile sınıfımızın bir aspect olduğunu belirtmemiz yeterlidir. Metotların öncesinde ve 
sonrasında devreye girecek olan performans trace “advice”ımızı ise aşağıdaki gibi bir metot ile ifade edebiliriz.

```java
@Around("execution(* *(..))")
public Object doTrace(ProceedingJoinPoint pjp) throws Throwable {

	TraceData child = createAndSetNewTraceData(pjp);

	try {
		return pjp.proceed();
	} finally {
		TraceData parent = revertToParentTraceData(child);
		if(parent == null) {
			displayTraceData(child);
		}
	}
}
```

Buradaki `execution(* *(..))` ifadesine AOP terminolojisinde **pointcut designator** adı verilmektedir ve kod içerisinde 
performans advice’ımızın uygulanacağı yerleri tanımlamamızı sağlar. Buradaki PCD’nin anlamı “bütün sınıfların bütün 
metotlarında, input argümanları ve return tipleri ne olursa olsun devreye gir” demektir. `@Around` annotasyonu ise 
advice’ımızın metot öncesinde ve sonrasında devreye gireceğini belirtmektedir. Asıl metot çağrısına erişim `ProceedingJoinPoint` 
ile sağlanmaktadır. `pjp.proceed()` çağrısından evvel trace ile ilgili veri toplanmakta, başlama zamanı tespit edilmekte, 
ardından `pjp.proceed()` ile iş asıl metoda delege edilmekte, return değeri alınıp istemciye dönülmeden evvel trace datası 
güncellenmekte, metot bitiş zamanı tespit edilmekte, eğer metot çağrısı hiyerarşide en üstte kalan bir metot çağrısı ise 
trace datası yukarıda belirtilen formatta yazdırılmaktadır.

Bana gelen bu problemdeki “trick” ise trace datasının istenilen formatta yazılabilmesi için datasının iç içe geçen metot 
çağrıları boyunca biriktirilip en dıştaki metottan dönerken yazılmasıdır.

Bunun için farklı nesnelerin metot çağrıları sırasında devreye giren advice içerisinden trace datasının ortak bir veri 
yapısında biriktirilebilmesi için **ThreadLocal** değişkene ihtiyacımız vardır.

```java
private final static ThreadLocal traceDataHolder = new ThreadLocal();
```

ThreadLocal değişkenler genellikle `static` olarak tanımlanırlar ve Java’daki “global değişkenler” olarak da adlandırılırlar. 
Herhangi bir metot içerisinden doğrudan erişilebilirler ve içerisinde tuttukları değerler o andaki “thread” nesnesine 
özgüdür. Başka bir ifade ile `traceDataHolder`’ın değeri iki farklı thread tarafından execute edilen iki metot için de 
farklı olacaktır.

Gelelim `createAndSetNewTraceData()`, `revertToParentTraceData()` ve `displayTraceData()` metotlarının neler yaptığına. 
`createAndSetNewTraceData` metodu asıl metot çağrısından evvel yeni bir `TraceData` nesnesi oluşturur, o anda çalıştırılacak 
metodun bulunduğu sınıf ve metot ismini `TraceData` içerisine set eder ve aynı zamanda `traceDataHolder` içerisinde mevcut 
bir `TraceData` nesnesi olup olmadığına bakar. Eğer yoksa bu ilk metot çağrısıdır, varsa yeni `TraceData` nesnesi mevcudun 
child nesnesi olarak set edildikten sonra `traceDataHolder`’a yeni değer olarak set edilir. `revertToParentTraceData` 
metodu ise metot çalışmasından sonra `traceDataHolder`’daki nesnenin parent’ını alıp onu `traceDataHolder`’a set eder. 
Böylece `TraceData` metot çağrısından önceki nesneye geri döner. Eğer metot çalışması sonucunda parent `TraceData` nesnesi 
`NULL` ise hiyerarşideki ilk metot olduğumuzu anlarız ve `displayTraceData` ile `TraceData` hiyerarşisini istediğimiz 
formatta bastırabiliriz. Aşağıda bu metotlara ait kod örnekleri de yer almaktadır.

```java
private TraceData createAndSetNewTraceData(ProceedingJoinPoint pjp) {
	TraceData childTraceData = new TraceData(pjp.getSignature().getDeclaringType(), pjp.getSignature().getName());
	childTraceData.start();

	TraceData parent = traceDataHolder.get();
	if(parent != null) {
		parent.addChild(childTraceData);
	}

	traceDataHolder.set(childTraceData);
	return childTraceData;
}

private TraceData revertToParentTraceData(TraceData child) {
	child.end();
	TraceData parent = traceDataHolder.get().getParent();
	traceDataHolder.set(parent);
	return parent;
}

private void displayTraceData(TraceData traceData) {
	String message = "";
	for(int i = 0; i < traceData.getLevel(); i++) {
		message += "t";
	}

	System.out.println(message + traceData.getMessage());

	for(TraceData child:traceData.getChilds()) {
		displayTraceData(child);
	}
}
```

Görüldüğü üzere AOP ile asıl kodumuzun içerisinde herhangi bir değişiklik yapmadan performans takibi ile ilgili ihtiyacımızı 
ayrı bir modül olarak implement edebildik. Bu açıdan AOP, object oriented programlamayı tamamlayan bir çözümdür.

Harezmi Bilişim Çözümleri olarak düzenlediğimiz Kurumsal Java Eğitimleri serisinden olan Spring Application Framework 
Eğitimi’mizde hem genel aspect oriented programlama kavram ve konseptleri üzerinde duruyoruz, hem de Spring AOP ve AspectJ 
kullanarak AOP programlama yapmayı anlatıyoruz. Katılımcılarımız için eğitimden sonra AOP’un, kurumsal uygulama geliştirme 
faaliyetlerinde vazgeçilmez bir araç olduğuna eminiz.

