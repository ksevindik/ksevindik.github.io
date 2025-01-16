# Cold Boot Saldırısı ve Java

Daha önceki bir [yazımda](http://www.kenansevindik.com/veri-hirsizliginin-sonu-yok/) “cold booting” yöntemi ile kapanmasının 
üzerinden az bir zaman geçmiş olan bir bilgisayarın hafızasındaki verilerin kopyalanıp, bu veriler arasından sizin 
parolanızın ele geçirilebileceğini veya kişisel bilgilerinizin öğrenilebileceğini söylemiştim. “Cold boot” saldırılarına 
karşı değişik düzeylerde önlemler alınabilir. Peki programlama düzeyinde bu tür bir veri hırsızlığına karşı ne yapabiliriz?

Örneğin Java ile uygulama geliştiriyoruz diyelim. Uygulamamız kimliklendirme aşamasında kullanıcının girdiği kullanıcı 
adı ve şifre bilgilerini veritabanından elde ettiği bilgilerle karşılaştırıyor ve sonuca göre kullanıcının sisteme girişine 
izin veriyor. Burada kullanıcıdan alınan şifre bilgisinin hangi veri yapısında tutulduğu bir cold boot saldırısında önem 
arz etmektedir. Uygulama içerisindeki şifre, kredi kartı gibi kullanıcılarla ilgili hassas bilgilerin uygun veri yapılarına 
alınıp, bunlarla ilgili işlem sonlandıktan sonra bu veri yapıların içeriğinin hafızada temizlenmesi gerekmektedir.

Örnek olarak şöyle bir Java kodumuz olsun;

```java
String userPasswd = fetchPasswdFromUser();String userPasswdEnced = encryptPasswd(userPasswd);

userPasswd = ""; //just to be sure we get rid of passwduserPasswd = null;

String encPasswd = getEncPasswdForUser(username);

if(!encPasswd.equals(userPasswdEnced)) { 
    throw new AuthenticationException();
}

//let the user log into the system…
```


Sizce `userPasswd` ile işimiz bittikten hemen sonra önce değişkene boş bir String değer atamamız, ardından da bununla da 
yetinmeyip `null`’a set etmemiz hafızadan şifrenin silinmesi için yeterli midir? Java’da String nesnelerin immutable yani 
değiştirilemez, salt okunur olduklarını biliyoruz. Öyleyse `userPasswd` nesnesine atanan bir String nesne hiçbir şekilde 
scope’dan çıkana kadar değiştirilemeyecektir. Bu nesnenin tutulduğu değişkeni boş String’e veya `null`’a set etmemiz de 
ancak o değişkenin hafızada başka bir yeri göstermeye başlamasından öte bir işe yaramayacaktır. Değişken scope’dan çıktıktan 
sonra garbage collection tarafından ele alınana kadar hafızada öylece duracaktır. Garbage collection çalıştıktan sonra 
bile işgal ettiği hafıza alanı başka bir nesne tarafından tamamen yazılmadıkça şifre erişilebilir olacaktır. Problem, 
String değerin bir String sabiti olması durumunda daha da kötüdür. String sabitler için Java’da bir sabit havuzu mevcuttur 
ve uygulama çalıştığı müddetçe sabitler bu havuzda tutulmaya devam edecektir.

İşimiz bittiğinde şifre bilgisini hafızadan temizlemek için String değişkenlerin uygun olmadığını anladık. Bu amaca daha 
uygun bir değişken `char[]` array, ya da `CharBuffer`, `StringBuffer` veya `StringBuilder` tiplerinden birisi olabilir. 
Önemli olan String bilginin değiştirilebilmesidir. Örneğin;

```java
char[] userPasswd = fetchPasswdFromUser();
//...
for(int i = 0; i < userPasswd.length; i++) { 
    userPasswd[i] = 'x';
}
```

Tabi `CharBuffer`, `StringBuffer` veya `StringBuilder` kullanırken `toString()` metodunu çağırmamaya dikkat etmelisiniz. 
Aksi takdirde `StringBuffer` içerisinde `char[]` array değişkende tutulan şifre bilgisi String değişken olarak döndürülecektir 
ve yukarıdaki durum söz konusu olacaktır. Dikkat edilmesi gereken bir diğer nokta, bu değişkenlerin her birinin arka 
tarafta veriyi `char[]` array içerisinde tutmalarıdır. Herhangi bir kapasite artırımı durumunda eski array’in yeni bir 
array’e kopyalandığını bilmek gerekir. Array kopyalaması sonucunda hassas bilginin bir kısmı yine hafızada kalabilir.

Belki de bu şekilde programlama yapmak, cold boot saldırılarına karşı tedbirli olmak size paranoyakça gelmiş olabilir. 
Önceleri ben de aynı şekilde düşünmüştüm. Ancak YouTube’taki cold boot saldırı örneklerini izleyince bunun hiç de imkansız 
olmadığını anladım. Defansif web programlama böyle bir şey olsa gerek.
