# Java ve Double Dispatch 2

İlk yazımızda Java’da “single dispatch“in nasıl çalıştığını ve “multiple dispatch” problemini incelemiştik. Eğer metot 
çözümleme sırasında input argümanında dikkate alınmasını istiyorsak izlememiz gereken yol “metot çözümlemeyi input 
argümanın kendisine delege etmek” olacaktır. Nasıl mı? Örnekle açıklayalım...

```java
Visitor v = new SubVisitor();
A a = new B();
v.visit(a);
```

Bir önceki örneğimizde Visitor’ün visit metodunu çağırıyor ve parametre olarak da A tipinde bir input argüman veriyorduk. 
Dolayısı ile input argümanın runtime tipine bakılmadığı için Visitor içerisindeki visit(B b) metodu yerine visit(A a) 
metodu çözümleniyordu. Eğer metot çözümleme işini input argümanın kendisine delege edebilirsek bu durumda Visitor’ün 
hangi metodunun çözümleneceğine B nesnesi içerisinden karar verilecek ve Visitor’ün visit(B b) metodunun çağrılma imkanı 
doğacaktır. Bunun için öncelikle metot çağrılarının sırasını değiştirmemiz gerekiyor. Visitor’ün visit metodunu çağırmak 
yerine A nesnesinin içerisinde “metot çözümleme işlemini” (dispatch) yapacak yeni bir metot tanımlayarak ilk önce bu 
metodu çağırmalıyız.

```java
public class A {
    public void accept(Visitor v) {
        v.visit(this);
    }
}

public class B extends A {
    @Override
    public void accept(Visitor v) {
        v.visit(this);
    }
}
```

Daha sonra

```java
Visitor v = new SubVisitor();
A a = new B();
a.accept(v);
```

şeklinde v.visit(a) demek yerine ilk metot çağrısını a.accept(v) şeklinde tetiklemeliyiz. accept metodu asıl çözümlemeyi 
yapacaktır. Öncelike a değişkeninin RTTI bilgisine bakılarak B sınıfı içerisindeki accept(Visitor v) metodu çalıştırılacaktır. 
Bu metot içerisinde de Visitor.visit(B b) metodu visit(this) ile çağrılmaktadır. Sonuç olarak

```console
Visiting B with SubVisitor
```

çıktısını console’da göreceğiz.

Bu işleme “double dispatch” adı verilmektedir ve Visitor örüntüsünün de temelini oluşturmaktadır. Dikkat edilmesi gereken 
bir husus accept(Visitor v) metodunun hem A hem de B sınıflarında yazılmış olmasıdır. Başka bir ifade ile accept metodu 
B sınıfında override edilmektedir. Aksi takdirde RTTI çözümlemesine göre A sınıfındaki accept metodu çalıştırılacak, buda 
Visitor.visit(A a) metoduna dispatch edilmesine neden olacaktır. Çünkü A sınıfındaki accept metodunda v.visit(this) metot 
çağrısına verilen “this” argümanının derleme zamanındaki tip bilgisi A olacaktır ve istediğimiz sonuç ortaya çıkmayacaktır.