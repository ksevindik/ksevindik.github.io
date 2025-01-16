# Kotlin ve Spring MVC Validations

Kurumsal Java dünyasında pek çok framework ve çözüm, kabiliyetleri ile ilgili metadata tanımlarını Java anotasyonları 
şeklinde ele almaktadır. Bunlardan birisi de Java Bean Validation spesifikasyonudur. JSR-380 olarak da bilinen bu 
spesifikasyon ile domain sınıflarındaki validasyon ihtiyaçları Java anotasyonları ile field veya getter metotlar üzerinde 
tanımlanmaktadır. Çalışma zamanında da uygun bir Validator ile bu sınıflardan yaratılmış nesnelerin o anki durumları 
validasyona tabi tutulmaktadır. Spring MVC validasyon kabiliyeti de JSR-380’i kullanarak Controller ve RestController 
bean’larının handler metot parametrelerini ve return değerlerini validasyona tabi tutmaktadır.

Kotlin’de primary constructor ile sınıfların içerisinde yer alacak attribute’ları constructor parametreleri şeklinde 
tanımlamak yaygın bir pratiktir. Çünkü, Kotlin compiler bu constructor parametrelerinden hem instance değişkenlerini, 
hem de bunlara ait getter/setter metotlarını üretmektedir. Kotlin’de primary constructor içerisinde tanımlanmış constructor 
parametrelerine Java anotasyonlarını koyduğumuz vakit, Kotlin compiler bu anotasyonların üretilecek olan yapılardan 
hangisinde yer alacağına karar vermek için ilgili anotasyonların @Target tanımlarına bakmaktadır.

Kotlindeki sıralama parameter, property, field şeklindedir. @Target anotasyonunda da bu sıralamaya göre eşleşen bir 
target-source tanımı bulunduğu vakit, ilgili anotasyon bytecode ile üretilen yapının (field veya getter metot) üzerinde 
yer alacaktır.

```kotlin
data class Person(
    @NotEmpty val firstName: String,
    @NotEmpty val lastName: String,
    @NotNull @Email val email: String
)
```

Yukarıdaki örneğimizde Person isimli data class’ımızın constructor parametrelerinde @NotEmpty, @NotNull ve @Email Java 
validation anotasyonlarını tanımladığımız vakit, Kotlin compiler, bu anotasyonların @Target meta-anotasyonlarına bakacaktır. 
Bu anotasyonlarının @Target meta-anotasyonları ise şu şekilde tanımlanmıştır.

```kotlin
@Target({ METHOD, FIELD, ANNOTATION_TYPE, CONSTRUCTOR, PARAMETER, TYPE_USE })
```

Yukarıdaki @Target tanımlarına göre @NotEmpty, @NotNull ve @Email Java anotasyonlarının metot, field, constructor veya 
metot parametrelerinin üzerinde kullanılabileceğini görüyoruz.

İşte Kotlin compiler’da @Target meta-anotasyonundaki bu değerlere bakarak anotasyonu bytecode’da üreteceği yapıların 
hangisinin üzerine koyacağını tespit etmeye çalışmaktadır. Bu tespit sırasında Kotlin’in kendi anotasyonları için kullandığı 
öncelik parameter, property (Java için görünür değildir) ve field şeklindedir. Yani, eğer Java anotasyonunun @Target 
tanımında parameter var ise bu anotasyon constructor parametresinde yer alacaktır. Eğer @Target tanımında parameter 
olmasaydı, bu durumda anotasyon @Target’daki field tanımı nedeni ile instance değişkeninin üzerinde yer alacaktır.

Bu algoritmaya göre @NotEmpty, @NotNull ve @Email anotasyonları Person sınıfının constructor parametrelerinde kalacak ve 
ilgili parametrelere karşılık gelen, ne field ne de getter metotlarında mevcut olmayacaktır. İşte problemimiz de bu 
noktada ortaya çıkmaktadır.

Örneğin, Person domain sınıfını kullanarak submit işlemini ele alan aşağıdaki gibi basit bir RestController bean’imiz ve 
bunun bir handler metodu olduğunu varsayalım. Handler metodumuzda Person domain nesnesi request body’den elde ediliyor ve 
@Valid anotasyonu ile domain sınıfındaki validation constraint’lerin kontrol edilmesi isteniyor.

```kotlin
@RestController
class PersonController {
    @PostMapping("/persons")
    fun submitForm(@RequestBody @Valid person: Person): ResponseEntity<Void> {
        //handle submitted person data...
        return ResponseEntity.status(HttpStatus.CREATED).build()
    }
}
```

Uygulamamızı çalıştırıp aşağıdaki gibi CURL ile bir post request’i gönderdiğimiz vakit herhangi bir hata ile karşılaşmadan 
HTTP 201 statü kodu ile bir cevap alırız.

```shell
curl -X POST "http://localhost:8080/persons" -H "accept: /" -H "Content-Type: application/json" -d "{\"firstName\":\"\",\"lastName\":\"\",\"email\":\"xyz\"}"
```

Malesef burada Person domain nesnesinin validasyona tabi tutulmadığını görüyoruz. @Valid anotasyonunun olması Spring MVC’nin 
validasyon kabiliyetinin devreye girmesi için yeterlidir, ancak Person domain sınıfında kullanılan @NotEmpty, @NotNull ve 
@Email anotasyonları bytecode’da üretilen Java sınıfında ne field, ne de getter düzeyinde yer almadıkları için validasyona 
tabi tutulacak herhangi bir constraint bulunamıyor ve handler metodu da sorunsuz çalışıyor.

Bu anotasyonların field veya getter metotlar üzerine yerleştirilmesini sağlamak için, Kotlin compiler’a bu anotasyonları 
field düzeyinde mi, getter metot düzeyinde mi ele alacağını bizim söylememiz gerekiyor. Bunun için Person domain sınıfında 
ilgili anotasyonları aşağıdaki gibi tanımlamamız gerekiyor.

```kotlin
data class Person(
    @field:NotEmpty val firstName: String,
    @field:NotEmpty val lastName: String,
    @field:[NotNull Email] val email: String
)
```

Burada @field:<Annotation> şeklindeki tanım Kotlin compiler’a ilgili Java anotasyonunun üretilecek olan Java sınıfındaki 
field’ın üzerine konması gerektiğini belirtiyor. Benzer biçimde @field yerine @get:<Annotation> kullanarak ilgili 
anotasyonların getter metot üzerine konmasını da sağlayabilirdik.

Yukarıdaki değişiklikle birlikte CURL komutumuzu tekrar çalıştırdığımız vakit 
org.springframework.web.bind.MethodArgumentNotValidException hatasını aldığımızı göreceğiz.
