# Serialization mı Memento mu?

Geçen hafta düzenlediğimiz ve hem benim hem de katılımcılar için oldukça verimli ve eğlenceli geçtiğini düşündüğüm 
uygulamalı “Nesne Yönelimli Tasarım Prensipleri ve Tasarım Örüntüleri Eğitimi”nde Memento örüntüsünü inceleyip Java’da 
nasıl implement edileceğini bir örnek ile açıklarken “Serialization varken Memento’ya neden ihtiyaç duyarız?” şeklinde 
bir soru soruldu.

Memento tasarım örüntüsü ile amaçlanan, bir nesnenin dahili state bilgisinin tamamını veya bir bölümünü “data encapsulation”ı 
ihlal etmeden dışarıya aktarmak ve daha sonraki bir zamanda bu state bilgisi ile nesnenin eski durumuna döndürülebilmesidir.

Çoğu UI frameworkünün binding kabiliyetinden yararlanabilmek için ve domain modeli doğrudan UI katmanında kullanmaya 
kalkışmanın etkisi ile günümüzde pek bir yaygın olsa da bir sınıf içindeki attribute’ların hepsi için setter/getter 
metotları tanımlanırsa, bu işlemin attribute’ların private yerine public tanımlanmasından çok bir farkı olmayacaktır.

Setter/getter metotlarını iş mantığının gerektirdiği durumların dışında kullanmaktan kaçınırsak, bir nesnenin state 
bilgisinin herhangi bir başka nesne tarafından erişilip saklanabilmesi için nesnenin serialization’a tabi tutulması tek 
ve en makul çözüm olarak karşımızda durmaktadır. Java’da herhangi bir nesnenin state’inin serialize edilerek object 
stream’e ve daha sonra tekrar nesneye dönüştürülmesi sınıfın `java.io.Serializable` arayüzünü implement etmesi ile 
olabilir. Serialization, nesnenin içindeki bütün alanları ve diğer nesne referanslarını da serialize etmek isteyecektir. 
Bu nedenle serialization’a tabi tutulan nesnenin içerdiği bütün diğer nesnelerin de `Serializable` olması önemlidir. 
Bazı alanların serialization’dan muaf tutulması için `transient` modifier’ı ilgili attribute(lar)a eklenebilir.

Eğer nesnenin serialization ve deserialization sürecini kendimize göre şekillendirmek veya state bilgisinin bir bölümünü 
serialize etmek istiyorsak `transient`'den daha kapsamlı yöntem `java.io.Externalizable` arayüzünün implement edilmesidir. 
`Externalizable` arayüzünü implement eden bir sınıf `writeExternal()` ve `readExternal()` metotları içerisinde 
serialization/deserialization’ı kendine özgü biçimde yapar.

Dolayısı ile `Serializable` veya `Externalizable`, bir sınıf memento örüntüsü ile çözülmeye çalışılan state bilgisinin 
encapsulation bozulmadan dışarıya aktarılması ve daha sonraki bir zamanda nesnenin bu state bilgisi ile restore edilmesi 
problemini kendiliğinden halletmektedir. Öyleyse Java programlama dili ile çalışanlar için memento örüntüsünün kendi 
başına bir yapı olarak implement edilmeye çalışılması gereksiz bir efordan öteye gitmeyecektir.

Gerçekten de Memento’yu Java’da implement etmek için (eğer nesnenin sınıfını `Serializable` yapmazsak) izleyebileceğimiz 
iki yol vardır. Bunlardan biri state’i dışarıya aktarılacak nesnenin attribute’larının görünürlüğünü en az paket düzeyine 
çekmektir. Diğeri ise Memento nesnesinin sınıfını `statik inner class` olarak asıl nesnenin sınıfı içerisinde 
`Serializable` olarak tanımlamaktır. Bunların dışında da pratik bir başka çözüm daha görünmemektedir. İkinci yöntem eğer 
asıl nesne herhangi bir nedenden ötürü `Serializable` veya `Externalizable` yapılamıyor veya restore işleminin state’in 
mevcut bir nesneye input olarak verilerek gerçekleştirilmesi isteniyorsa kullanılabilir bir yöntemdir.

```java
public class Form {
    private String ad;
    private String soyad;

    public Form(FormMemento memento) {
        this.ad = memento.ad;
        this.soyad = memento.soyad;
    }

    public Form(String ad, String soyad) {
        super();
        this.ad = ad;
        this.soyad = soyad;
    }

    public void submit() {
        //submit form input...
        System.out.println("submitting form data :" + ad + "," + soyad);
    }

    public FormMemento createMemento() {
        return new FormMemento(this.ad,this.soyad);
    }

    public void restoreMemento(FormMemento memento) {
        this.ad = memento.ad;
        this.soyad = memento.soyad;
    }

    public static class FormMemento implements Serializable {
        private String ad;
        private String soyad;

        private FormMemento(String ad, String soyad) {
            super();
            this.ad = ad;
            this.soyad = soyad;
        }
    }
}
```

Sözün özü, bazı örüntüler dilin içerisinde mevcut özellik ve kabiliyetlerden dolayı ayrı birer yapı olarak bizim 
tarafımızdan implement edilmezler veya implement edilmeleri çok da anlamlı değildir. Ya da Memento’nun Java’daki ismi 
“serialization” diyebiliriz.
