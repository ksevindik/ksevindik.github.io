# Java ve Double Dispatch 1

Hepimizin bildiği gibi Java polymorphic (çok formlu) bir dildir. Çok formluluk java uygulamasının içindeki metot 
çağrılarının spesifik olarak hangi sınıftaki metot tanımı ile yapılacağının çalışma zamanına kadar ötelenmesi ile 
gerçekleştirilmektedir. Bir örnek ile açıklayalım.

```java
public class Visitor {
	public void visit(A a) {
		System.out.println("Visiting A");
	}
}

public class SubVisitor extends Visitor {
	@Override
	public void visit(A a) {
		System.out.println("Visiting A with SubVisitor");
	}
}
```

Visitor sınıfı ve bu sınıftan türeyen bir SubVisitor sınıfımız olsun. Aşağıdaki gibi bir kod parçası çalıştırıldığı vakit

```java
Visitor v = new SubVisitor();
v.visit(new A());
```

çıktı olarak console’da

```console
Visiting A with SubVisitor
```

görülecektir. Hem Visitor, hem de SubVisitor sınıfında visit(A a) metodu tanımlı olmasına ve nesne Visitor tipinde bir 
değişkende tutulmasına rağmen Java SubVisitor sınıfındaki metodu çağırmaktadır. Bu derleyicinin metot çözümleme işini 
(dispatch) çalışma zamanına kadar öteleyerek, çalışma zamanında değişkenin işaret ettiği hangi nesne ise o nesnenin 
“concrete sınıf” bilgisini tespit etmesi ve o sınıftan itibaren metot tanımını araması ile gerçekleşir. Bu işleme 
“single dispatch polymorphism” adı da verilmektedir.

Ancak Java’da dinamik metot çözümleme metodu invoke edilen nesnenin runtime tipine bakılması ile sınırlı kalmaktadır. 
Diğer bazı dillerde metot çözümleme işi metoda input olarak verilen argümanların tipine bakarak bir adım daha ileriye 
taşınabilmektedir. Yine bir örnek ile açıklayalım;

```java
public class A {
}

public class B extends A {
}
```

A sınıfı ve bu sınıftan türeyen bir B sınıfımız olsun. Visitor ve SubVisitor sınıflarına da B sınıfı ile çalışacak visit 
metotlarını ekleyelim.

```java
public class Visitor {
    public void visit(A a) {
        System.out.println("Visiting A");
    }

	public void visit(B b) {
		System.out.println("Visiting B");
	}
}

public class SubVisitor extends Visitor {
    @Override
    public void visit(A a) {
        System.out.println("Visiting A with SubVisitor");
    }

	@Override
	public void visit(B b) {
		System.out.println("Visiting B with SubVisitor");
	}
}
```

Eğer aşağıdaki kod bloğunu çalıştırırsak

```java
Visitor v = new SubVisitor();
A a = new B();
v.visit(a);
```

elde edilecek sonuç şu olacaktır.

```console
Visiting A with SubVisitor
```

Eğer bu kodu “multiple dispatch” kabiliyetine sahip bir dil ile yazıp çalıştırmış olsaydık elde edeceğimiz sonuç

```console
Visiting B with SubVisitor
```

şeklinde olacaktı. Java’da metot çözümleme sırasında metodun çağrıldığı nesnenin çalışma zamanındaki tipine bakılmasına 
rağmen, metoda input argüman olarak verilen nesnelerin çalışma zamanındaki tiplerine bakılmaz. Input argümanların sadece
derleme zamanındaki tiplerine bakılır. Bizim örneğimizde de input argümanımız B tipinde bir nesne olmasına rağmen A 
tipindeki bir değişkene atandığı için derleme zamanında da A tipinde input argüman alan visit(A a) metodu çözümlenmekte, 
çalışma zamanında da SubVisitor sınıfının içinde override edilmiş visit(A a) metodu invoke edilmektedir.

Peki Java ile programlama yaparken “multiple dispatch” kabiliyetini nasıl elde edebiliriz? Bunun cevabı Visitor örüntüsünde 
yatıyor. Ona da bir sonraki yazımızda bakalım.