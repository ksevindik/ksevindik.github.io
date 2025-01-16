# Mockito ile Null Object

Dün bir iş arkadaşımla bir monitoring kabiliyeti üzerinde çalışırken, kendisinin “Null Object” örüntüsünü kullandığını 
gördüm. Hepimizin bildiği üzere Null Object örüntüsü, bizim kod içerisinde null referans ile karşılaşabilecek kısımların 
öncelikle null kontrolü yapma gereksinimini ortadan kaldırmaya çalışıyor. Herhangi bir metod null döndürmek yerine, return 
tipini implement eden veya ondan türeyen, ancak içerisinde herhangi bir davranış barındırmayan bir sınıftan oluşturulmuş 
nesneyi (Null Object) döner. Bu sayede metodu çağıran kod, dönen değerin hiçbir zaman null referans olmayacağını bilerek 
null kontrolü yapmadan dönen nesne üzerinde çalışabilir. Dönen nesnenin çağırılan metodları basitçe hiçbir şey yapmayacaktır. 
Kısacası az kod, daha rahat okunur kod...

Daha sonra bu arayüzü gerçekleyen bir de `RealOperation` isimli bir sınıf yazalım. Bu sınıf içerisinde basitçe bu 
metodlardan bazı değerler dönelim. Son olarak da bir `AbstractOperationFactory` sınıfını oluşturup, bunun `create` metodu 
içerisinde de belirli bir duruma göre ya `RealOperation` sınıfından bir nesne ya da Mockito’yu kullanarak Null Object 
oluşturalım. Artık testimizi gerçekleştirebiliriz.

Null Object örüntüsünü çok faydalı bulmakla beraber, Null Object’in arayüzü geliştirme sırasında sürekli olarak değişiyorsa, 
yani yeni metodlar ekleniyor veya çıkarılıyor, metod imzaları (signature) değişiyorsa, bu arayüzü implement eden sınıfların 
da sürekli olarak güncellenmesi zorunluluğu ortaya çıkıyor. Zaten Joshua Kerievsky de “Refactoring to Patterns” kitabının 
Null Object örüntüsünü anlattığı bölümde bu problemden bahsetmektedir. Geliştirme sırasında sürekli arayüzlerin değiştiği 
bir aşamada bir de Null Object sınıfını güncel tutmaya çalışmak can sıkıcı olabilmektedir. İşte bizim de monitoring 
çalışmamız sırasında tam olarak ortaya çıkan durum buydu.

Bu aşamada şunu düşündüm: Null Object, bir nevi birim testlerinde sürekli olarak kullandığımız “stub”’a benzer şekilde 
davranıyor. Sadece bir nesne olarak var oluyor, ancak hiçbir anlamlı davranış barındırmıyor; gelen metod çağrıları basitçe 
bir şey yapmadan dönüyor. Öyleyse birim testlerini geliştirirken mock nesneleri oluşturmakta kullandığımız bir mock 
kütüphanesini Null Object implementasyonunda da kullanamaz mıyız diye düşündüm. Burada hemen aklımıza şu sorun gelebilir: 
JMock ve EasyMock gibi mock kütüphanelerinde “expect-run-verify” şeklinde bir kullanıma zorlama söz konusu oluyordu, yani 
bu mock kütüphaneleri ile oluşturduğumuz bir Null Object nesnesine gelecek çağrılar için nesnenin öncelikle “train” 
edilmesi gerekecektir. Bu hali ile Null Object’in gerçek kod içerisinde kullanılmasına imkan yoktur. Ancak Mockito mock 
kütüphanesinde zorunlu “expect-run-verify” kullanım döngüsü söz konusu değildir. Yani rahatlıkla Mockito ile herhangi bir 
arayüzü gerçekleyen bir mock nesne oluşturup bunu Null Object olarak metodlarımızdan dönebiliriz. Dönen sonucu kullanacak 
olan kısımda bu nesneyi normal biçimde kullanabilir, üzerinde işlemler yapabilir. Mock nesneyi kullanım öncesinde ne 
gelebilecek çağrılar, ne de dönmesi gereken değerler konusunda hazırlamamız gerekmez. Mockito ile oluşturulan mock 
nesnelerin metodları varsayılan değerleri döndürmektedir. Örneğin, `List` dönmesi gereken bir nesne empty List, primitive 
`int` dönmesi gereken bir metod 0, `boolean` değer dönmesi gereken bir metod ise false dönmektedir.

Mockito’nun Null Object örüntüsünü gerçekleştirmek için kullanılıp kullanılmadığını öğrenmek için biraz googling yaptım, 
ancak Mockito’nun bu amaçla kullanıldığı yönünde bir bilgiye rastlamasam da Wikipedia’nın bir yerinde “The null object 
pattern can also be used to act as a stub for testing if a certain feature, such as a database, is not available for 
testing.” şeklinde bir ifade görünce bu şekilde bir kullanımın da olabileceği sonucuna vardım. Kısacası uzun zamandır 
önümüzde duran bir kullanım şeklinin ancak yeni farkına varmamız diyebiliriz.

Düşünceleri bir de örnek üzerinde sınama zamanı geldi, aşağıdaki basit modeli Mockito kullanarak gerçekleştirelim. 
Öncelikle `AbstractOperation` isimli bir arayüz tanımlayıp, bu arayüze `int`, `boolean` ve `List` tiplerinde değerler 
dönen üç tane metod ekleyelim.

```java
java public interface AbstractOperation { 
	public int method1(); 
	public List method2(); 
	public boolean method3(); 
}
```

Daha sonra bu arayüzü gerçekleyen bir de RealOperation isimli bir sınıf yazalım. Bu sınıf içerisinde basitçe bu metodlardan 
bazı değerler dönelim.

```java
java public class RealOperation implements AbstractOperation { 
	public int method1() { 
		return 10; 
	} 
	public List method2() { 
		List l = new ArrayList(); 
		l.add("kenan"); 
		return l; 
	} 
	public boolean method3() { 
		return true; 
	} 
}
```

Son olarak da bir AbstractOperationFactory sınıfını oluşturup, bunun create metodu içerisinde de belirli bir duruma göre 
ya RealOperation sınıfından bir nesne ya da Mockito’yu kullanarak Null Object oluşturalım.

```java
java public class AbstractOperationFactory { 
	public AbstractOperation create(boolean flag) { 
		return flag ? new RealOperation() : Mockito.mock(AbstractOperation.class); 
	} 
}
```

Artık testimizi gerçekleştirebiliriz.

```java
java public class AbstractOperationTests {

	private AbstractOperationFactory factory; 

	@Before 
	public void setUp() { 
		factory = new AbstractOperationFactory();
	} 

	@Test 
	public void testNullObject() { 
		AbstractOperation op = factory.create(false); 
		Assert.assertEquals(0, op.method1()); 
		Assert.assertTrue(op.method2().isEmpty()); 
		Assert.assertFalse(op.method3()); 
	} 
	
	@Test public void testRealObject() { 
		AbstractOperation op = factory.create(true); 
		Assert.assertEquals(10, op.method1()); 
		Assert.assertEquals(1,op.method2().size()); 
		Assert.assertTrue(op.method3()); 
	}
}
```
