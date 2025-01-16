# Kotlin ve NPE

Kotlin’in öne çıkan özelliklerinden birisi de uygulama içerisinde null referansların önüne geçmeye çalışmasıdır. Kotlin’in 
tip sistemi, uygulamalarımızdan NullPointerException hatalarını ortadan kaldırma hedefi ile tasarlanmıştır. Buna 
“null safety” adı da verilmektedir.

Peki NPE hatası Kotlin’de nasıl engelleniyor? Bunun için Kotlin’de tanımlanan değişkenler ve return tipleri varsayılan 
durumda null değer alamayacak veya dönemeyecek biçimde tanımlanıyorlar. Örneğin,

```kotlin
class Person(var email:String)
```

yukarıda tanımladığımız Person sınıfı email isimli String property ile yaratılmak zorunda ve

```kotlin
val p = Person(null)
```

şeklinde bir tanım derleme sırasında hataya sebebiyet verecektir. Person nesnesini mutlaka null olmayan bir email değeri 
ile oluşturmak zorundayız ve daha sonra email property’sine set edeceğimiz değerler de not-null olmak zorunda. Yani,

```kotlin
p.email = null
```

şeklinde bir atama yine derleme zamanında hata ile sonuçlanır. Bu sayede değişkenlerimizdeki değerlerin çalışma zamanında 
null değere sahip olma ihtimali olmayacağı için bu değişkenlere erişirken NullPointerException alma ihtimalimiz ortadan
kalkmış oluyor. Örneğin,

```kotlin
val person = Person("ksevindik@gmail.com")
//...
val isValid = person.email.matches(Regex("^(.+)@(.+)$"))
```

şeklinde bir kod parçacığında iki ifade arasında başka hangi ifadeler olursa olsun person.email değerinin null olma 
ihtimali olmayacağı için email validasyon işlemi sırasında null kontrolü yapmamıza gerek yoktur ve kesinlikle NPE hatası 
almayacağımızı da biliriz.

Peki null olabilecek senaryolar için değişkenlerimizi nasıl tanımlarız? Kotlinde bunun için değişkenin tipinden sonra ? 
işareti koymamız gerekiyor. Örneğin,

```kotlin
class Person(var email:String?)
```

Person sınıfımızın email parametresinin opsiyonel olması için String tipinin yanına ? işareti koyduk. Bu durumda email 
property’sine kod içerisinde de null değer atayabiliriz.

```kotlin
p.email = null
```

Biraz evvel derleme zamanında hataya sebep olan değer atama işlemini bu sefer yapabiliriz.

Ancak bu durumda, email validasyon işlemimiz öncesinde Kotlin derleyicisi bizden null kontrolü yapmamızı istemektedir.

```kotlin
val person = Person("ksevindik@gmail.com")
//...
val isValid = if(person.email !=null) person.email.matches(Regex("^(.+)@(.+)$")) else false
```

Aksi takdirde derleyici hata verecektir. Null kontrolü yapmak yerine validasyon adımına kadar gerçekleşen adımlardan 
dolayı email property’sine hiç null değer atanmadığını garanti etmeyi de tercih edebiliriz. Bunun için email property’sinden 
sonra !! ifadesini koymamız gerekir.

```kotlin
val person = Person("ksevindik@gmail.com")
//...
val isValid = person.email!!.matches(Regex("^(.+)@(.+)$"))
```

Tabi bu garanti sonrası, çalışma zamanında bu adıma kadarki blok içerisinde herhangi bir biçimde person.email değişkenine 
null değer atanır ise bu durumda NullPointerException almamız kaçınılmazdır.

Buraya kadar ki anlattığımız işleyiş metot return değerlerinde de aynıdır.

```kotlin
interface PersonRepository:JpaRepository<Person,Long>{
    findByEmail(email:String):Person?
}
```

Yukarıdaki PersonRepository arayüzünde tanımladığımız findByEmail() metodunun return değeri null dönebilecek biçimde 
tanımlanmıştır. Bu durumda,

```kotlin
val person = personRepository.findByEmail("ksevindik@gmail.com")
//...
val isValid = person!!.email.matches(Regex("^(.+)@(.+)$"))
```

personRepository.findByEmail() metot çağrısı sonucu elde ettiğimiz person nesnesi üzerinden email değerine erişmeden evvel 
null kontrolü yapmamız, yada bu örnekte olduğu gibi person değişkenine bu aşamaya kadar herhangi bir biçimde null değer 
atanmadığını garanti etmemiz gerekir.

!! operatörünü kullanırken ortaya çıkabilecek NPE hatasının dışında, NPE hatasını almak için kod içerisinde açık biçimde 
NullPointerException’ı bizim fırlatmamız gerekir. Bunu kim yapmak isteyebilir ki? 😉

Peki bunların dışında Kotlin’de hiç mi NPE hatası ile karşılaşmayız? Zor ama imkansız değil. Gelin diğer ihtimalleri de 
bir sonraki yazımızda inceleyelim.