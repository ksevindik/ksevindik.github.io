# Pozitif ve Negatif Kimlik Dogrulama

Geçenlerde katıldığım bir eğitimde gördüğüm bir kod parçası üzerinde birkaç noktayı sizinle paylaşmak istiyorum. Eğitimde 
bir web uygulamasına login olmaya çalışan kullanıcıların kimlik denetimlerinin pozitif ve negatif kimlik doğrulama 
yaklaşımları ile yapılması karşılaştırılıyor ve negatif kimlik doğrulama yaklaşımının sağlamlığını ifade etmek için de 
bu kod parçacıkları kullanılıyordu. Şimdi kod parçacıklarına bakalım. (Örneklerde anlatılmak istenen asıl konudan sapmadan 
kodlar üzerinde küçük oynamalar yaptığımı söylemeliyim.)

```java
private boolean authenticatePositively(String username, String password) {
    boolean authenticated = true;
    try {
        User user = null; //find user with given username
        if(user.getPassword() != password)
            authenticated = false;
            if(!user.isAccountNonLocked())
            authenticated = false;
    } catch(Exception ex) {
        authenticated = false;
    }
    return authenticated;
}
```

Yukarıdaki örnek, pozitif kimlik doğrulama yaklaşımını gösteriyor. Pozitif kimlik doğrulama ile anlatılmak istenen, 
`authenticated` değişkeninin daha metodun başında `true` olarak set edilip, ancak kimlik doğrulama algoritmasındaki 
adımlardan herhangi birinde başarısızlık söz konusu olduğunda değişkenin `false` olarak set edilmesidir. Ancak bu durumlarda 
kullanıcının sisteme girişi engellenir. Diğer bütün durumlar için kullanıcı sisteme girmeye hak kazanacaktır.

```java
private boolean authenticateNegatively(String username, String password) {
    boolean authenticated = false;
    try {
        User user = null; //find user with given username
        if(user.getPassword() != password)
            throw new Exception("error");
        if(!user.isAccountNonLocked())
            throw new Exception("error");
        authenticated = true;
    } catch(Exception ex) {
        authenticated = false;
    }
    return authenticated;
}
```

Bu örnek ise negatif kimlik doğrulamayı anlatıyor. Burada ise `authenticated` değişkeni başlangıçta `false` olarak set 
ediliyor. Daha sonra kimlik doğrulama algoritmasının adımları birer birer işletiliyor. Herhangi bir adımda hata olursa 
bir `Exception` fırlatılıyor, `Exception` aynı metod içerisinde yakalanıyor ve kullanıcının sisteme girmeye hak kazanması 
engelleniyor. Hata olmazsa son adımda `authenticated` değişkeni `true` olarak set ediliyor.

İlk örnekteki problemler gayet nettir. Eğer kimlik denetimi adımlarından herhangi birisinde beklenmedik bir hata meydana 
gelirse ve bu hata `Exception` bloğunda ele alınırken `authenticated` değişkeni `false` olarak set edilmezse, kullanıcı 
yeterli bir denetime tabi tutulmadan sisteme erişmeye hak kazanabilir. Bir diğer problem de `exception handling` kısmındadır. 
Eğer metod içerisinde daha spesifik bir `exception` yakalamak gerekirse, önceki `exception` bloğundaki `authenticated = false` 
ifadesi erişilmez olacaktır. Programcı, yeni eklenecek her `exception catch` bloğuna da `authenticated = false` ifadesini 
eklemeyi hatırlamalıdır. Bu, kısmen implicit bilgi olduğundan, kod üzerinde değişiklik yaparken rahatlıkla gözden kaçabilir.

Metod sonucunu tutan değişkenlerin daha metodun başında, her zaman olumsuz/negatif bir değer ile initialize edilmesi, 
sadece kimlik doğrulama ile ilgili kodlarda değil, geliştirilen herhangi bir kod parçası için izlenmesi gereken bir 
yaklaşımdır. İkinci örnekte bu hata düzeltiliyor ve `authenticated` değişkeni daha metodun başında `false` olarak set 
edilip, ancak mevcut kimlik doğrulama adımları başarılı biçimde sonlanırsa `true`ya çevriliyor. Ancak ikinci örnekte 
başka bir kötü programlama pratiğine de kapı aralanmış: ikinci metod içerisinde kimlik denetim adımlarındaki herhangi 
bir başarısız durum `Exception` fırlatılarak belirleniyor ve aynı metodun içerisinde bu `exception`lar `catch` bloğu ile 
ele alınıyor.

Buradaki kötü pratik, `exception`ların program kontrol akışını (control flow) yönetmek için kullanılmasıdır. 
`Exception`ların bir nevi `GOTO` ifadesi yerine kullanılması söz konusu oluyor. `Exception`ların beklenmedik ve ele 
alınması mümkün olmayan durumları ifade etmek için tasarlandığını aklımızdan çıkarmamak gerekir. Bunların program kontrol 
akışını yönetmek için kullanılması, her ne kadar günümüz derleyicileri ve yorumlayıcıları için çok büyük problem olmasa 
da uygulama içerisinde gereksiz bir “overhead” yaratması da söz konusudur.

```java
private boolean authenticateNegatively2(String username, String password) {
     boolean authenticated = false;
     User user = null; //find user with given username
     if(user.getPassword() == password && user.isAccountNonLocked())
         authenticated = true;
     return authenticated;
 }
```

Yukarıda kimlik doğrulama metodunun yeniden düzenlenmiş halini görüyorsunuz. Burada `authenticated` değişkenine defansif 
biçimde önce `false` değeri set ediliyor. Ardından kimlik doğrulama kontrolleri tek bir `if` ifadesinde gerçekleştiriliyor. 
Ancak ifade doğru olduğunda `authenticated` değişkeni `true`ya set ediliyor. Kısacası, basitlik ile kaliteli kod arasında 
da yakın bir ilişki olduğunu buradan da görebiliriz. Sizce bu kimlik değerlendirme metodu daha fazla nasıl iyileştirilebilir?
