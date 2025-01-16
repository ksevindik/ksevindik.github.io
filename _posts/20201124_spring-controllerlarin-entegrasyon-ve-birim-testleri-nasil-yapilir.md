# Spring Controller'ların Entegrasyon ve Birim Testleri Nasıl Yapılır?

Spring Application Framework ile çalışırken uygulamaya ait sınıflarımızı yazmanın yanı sıra, ApplicationContext olarak 
tabir edilen Spring Container konfigürasyonunu gerçekleştirdikten sonra, entegrasyon testlerimizde genel olarak iki veya 
daha fazla katmanı bir arada testlere tabi tutarız. Örneğin Service ve Repository katmanlarını ApplicationContext’i 
yaratarak ayağa kaldırır ve servis metot çağrıları sonucu iş mantığının düzgün biçimde implement edilip edilmediğini, 
iş mantığının işletilmesi sırasında persistence işlemlerinin sağlıklı biçimde gerçekleşip gerçekleşmediğini teste tabi 
tutarız. Bu katmanların önüne Controller katmanını da ilave edebiliriz. Bu durumda servis metodunu çağırmak için 
Controller’ın ilgili handler metoduna bir HTTP web isteği göndeririz, yine benzer biçimde dönen sonucu teyit edebilmek 
için de HTTP web cevabını ele alıp kontrol ederiz.

Bu tür iki veya daha fazla katmanın Spring ApplicationContext ile birlikte ayağa kaldırılıp test edildiği senaryolara 
“entegrasyon test” adı verilmektedir. Çünkü teste tabi tutulan ilgili bileşenin dışında başka bir takım bileşenlerde 
ortamda yaratılıp, konfigüre edilip kullanılmaktadır ve test sürecine dahil olmaktadır. Controller katmanından itibaren 
yapılan bu test ile ilgili senaryonun akışının kontrolü gerçekleştirilmiş olur, ancak entegrasyon testlerinin 
çalıştırılması ve bu testlerin data fixture’larının oluşturulması zaman alır ve test driven development yaklaşımı 
sergilemek için de çok uygun bir granülaritede değillerdir.

```kotlin
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.DEFINED_PORT)
class PetClinicControllerTests {
    @Autowired
    private lateinit var testRestTemplate: TestRestTemplate

    @Autowired
    private lateinit var ownerRepository: OwnerRepository

    @Test
    fun `owners should return all existing owners`() {
        //given
        ownerRepository.save(Owner("A", "B"))
        //when
        val response = testRestTemplate.getForEntity(
            "http://localhost:8080/owners", Array<OwnerDTO>::class.java
        )
        //then
        MatcherAssert.assertThat(response.statusCode, Matchers.equalTo(HttpStatus.OK))

        MatcherAssert.assertThat(
            response.body?.toList(), Matchers.contains(
                OwnerDTO("A","B")
            )
        )
    }
}

@RestController
class PetClinicController @Autowired constructor(private val petClinicService: PetClinicService) {

    @GetMapping("/owners")
    @ResponseStatus(HttpStatus.OK)
    fun handleGetOwners(): List<OwnerDTO> {
        return petClinicService.getOwners().map {
            OwnerDTO(it.firstName,it.lastName)
        }
    }
}

@Service
class PetClinicService {

    @Autowired
    private lateinit var ownerRepository: OwnerRepository

    fun getOwners(): List<Owner> {
        return ownerRepository.findAll().toList()
    }
}

interface OwnerRepository : CrudRepository<Owner, Long> {
}

@Entity
class Owner(var firstName: String, var lastName: String) {

    @Id
    @GeneratedValue
    var id: Long? = null
}

data class OwnerDTO(val firstName: String, val lastName: String)
```

Yukarıdaki kod örneği bu tür bir entegrasyon testinin ve ilgili bileşenlerin nasıl geliştirilebileceğini örneklemektedir. 
Bu testi yazabilmek için OwnerRepository ve Owner sınıflarına kadar ilerlemek PetClinicService’i implement etmek gerekecektir. 
Kıscası bu senaryonun gerçekleştirimi top-down’dan bottom-up’a dönüşecektir. Önce OwnerRepository arayüzünü ve Owner 
domain sınıfını oluşturmak zorunda kalacağız, JPA/Hibernate mapping’lerini yapacağız, ardından PetClinicService’i yazacağız 
ve daha sonra PetClinicController’ın handler metodunu geliştirmeye başlayabileceğiz.

Oysa, Controller katmanından başlayarak TDD perspektifi ile kod geliştirirken öncelikle sadece Controller’ın ilgili 
handler metoduna odaklanmalı, bu handler metodunun düzgün biçimde web isteğini ele alabilidiği, web isteğini iş mantığına 
uygun bir yapıya dönüştürebildiği, servis katmanına işi havale edebildiği, ve dönen sonucu da yine düzgün biçimde bir web 
cevabına dönüştürebildiği, diğer katmanları ve tabi ki de Spring ApplicationContext’i ayağa kaldırmadan test edilebilmelidir.

Spring bize, Controller sınıflarının birim testleri için MockMvc isimli bir yapı sunmaktadır ve bu yapı vasıtası ile 
Controller sınıflarımızın handler metotlarının request mapping’lerinin yapılıp yapılmadığı, web isteğinin servis katmanına 
delegasyonu ve dönen sonucun web cevabına dönüştürülmesi rahatlıkla test edilebilmektedir.

```kotlin
class PetClinicControllerUnitTests {
    @Test
    fun `owners should return all existing owners`() {
        //given
        val petClinicService = Mockito.mock(PetClinicService::class.java)
        val petClinicController = PetClinicController(petClinicService)
        Mockito.doReturn(listOf(Owner("A", "B"))).`when`(petClinicService).getOwners()

        val mockMvc = MockMvcBuilders.standaloneSetup(petClinicController).build()
        //when, then
        mockMvc.perform(MockMvcRequestBuilders.get("/owners"))
            .andExpect(MockMvcResultMatchers.status().isOk)
            .andExpect(
                MockMvcResultMatchers.content().json(
                """
                [{
                "firstName":"A",
                "lastName":"B"
                }]
                """.trimIndent()
                )
            )
    }
}
```

MockMvc sayesinde yapmamız gereken, PetClinicController’ın handler metodunun ve PetClinicService’in kontratlarını 
belirlemekten ibaret olacaktır. Yukarıdaki örnekten de anlaşılacağı üzere, PetClinicController geliştirilirken 
PetClinicService’in hazır olmasına gerek yoktur, onun yerine PetClinicService’den bir mock nesne yaratıp, senaryoya göre 
getOwners() metodu çağrıldığı vakit ne şekilde davranacağının tanımlanması yeterlidir. Ardından PetClinicController 
nesnesi bu PetClinicService instance’ı ile yaratılabilir. Spring’in MockMvc nesnesi standalone ortamda HTTP web istekleri 
oluşturup, bunları göndermemizi ve dönen sonuçları incelememizi ve kontrol etmemizi sağlamaktadır. Bunun için MockMvc’nin 
PetClinicController nesnesi ile standalone bir konfigürasyonunu yapmamız yeterli olacaktır. Yukarıda gördüğünüz test 
klasik bir “birim test” olup, hiçbir şekilde Spring ApplicationContext oluşturmamakta ve veritabanı vs ile de etkileşime 
girmemektedir.

Günümüzde Spring uygulamaları geliştirmek için de-fakto Spring Boot’dan yararlanılmaktadır ve Spring Boot’da Meb MVC 
katmanına ait bileşenleri kolay bir biçimde test edebilmek için @WebMvcTest anotasyonunu sunmaktadır. @WebMvcTest 
sayesinde sadece Web MVC katmanına ait bileşenleri, sadece ilgili Controller bean’ini ayağa kaldırarak yukarıda 
örneklediğimiz birim testine yakın bir test yazabiliriz ve bu sayede TDD sürecine de uygun bir geliştirme yapabiliriz.

```kotlin
@WebMvcTest(controllers = [PetClinicController::class])
class PetClinicControllerWebMvcTests {
    @MockBean
    private lateinit var petClinicService: PetClinicService

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Test
    fun `owners should return all existing owners`() {
        //given
        Mockito.doReturn(listOf(Owner("A", "B"))).`when`(petClinicService).getOwners()
        //when, then
        mockMvc.perform(MockMvcRequestBuilders.get("/owners"))
            .andExpect(MockMvcResultMatchers.status().isOk)
            .andExpect(
                MockMvcResultMatchers.content().json(
                """
                [{
                "firstName":"A",
                "lastName":"B"
                }]
                """.trimIndent()
                )
            )
    }
}
```

Yukarıdaki örnek, @WebMvcTest ile PetClinicController’ın handler metodunun nasıl test edilebileceğini örneklemektedir. 
Görüleceği üzere bir önceki “mock mvc standalone test setup” daki işlemlerin hemen hemen hiçbirisine gerek kalmaksızın 
handler metodunu test etmek mümkün olmuştur. Öncelikle @WebMvcTest’e sadece PetClinicController sınıfından bir controller 
bileşeni oluşturmasını söyledik, daha sonra PetClinicService bağımlılığının @MockBean anotasyonu ile işaretlenmiş bir 
tanım ile karşılanmasını sağladık. Son olarak da kullanıma hazır MockMvc nesnesini testin içerisine @Autowired ile enjekte 
ettik. Test metodumuzda ise, bir öncesi test metoduna kıyasla, sadece petClinicService.getOwners() metodunu eğitip, diğer 
test gibi handler metodunun mockMvc üzerinden invokasyonunu test ettik.

@WebMvcTest ile çalışırken dikkat etmemiz gereken nokta, her ne kadar sadece bizim belirttiğimiz Controller sınıfına ait 
bir bileşen yaratılıyor gözükse de aslında Spring Boot burada uygulamanın Web MVC katmanına karşılık gelen konfigürasyonunu 
ayağa kaldırmaktadır, ve bu konfigürasyona uygulamada mevcut olan ControllerAdvice, WebMvcConfigurer, Filter gibi tanımlar 
da dahildir. Hatta uygulamamızda Spring Security kullanılıyor ise Spring Security’ye ait konfigürasyon da dahil edilecektir, 
HtmlUnit ve Selenium uygulamanın classpath’inde mevcut ise WebClient ve WebDriver bileşenleri de yine ayağa kaldırılacaktır. 
Kısacası @WebMvcTest ile yazdığımız testlerimiz tam manası ile klasik “birim test” kategorisine girmemektedir, tabi bütün 
Spring ApplicationContext’i ayağa kaldıran “entegrasyon test”lerinden de daha hızlı çalışacaktır.

```kotlin
@Configuration
class PetClinicSecurityConfig : WebSecurityConfigurerAdapter() {

    override fun configure(http: HttpSecurity?) {
        http!!.authorizeRequests().anyRequest().hasAuthority("OWNER")
        http.httpBasic()
    }

    override fun configure(auth: AuthenticationManagerBuilder?) {
        val encoder =
            PasswordEncoderFactories.createDelegatingPasswordEncoder()

        auth!!.inMemoryAuthentication()
            .withUser("user1")
            .password(encoder.encode("secret"))
            .accountExpired(false)
            .accountLocked(false)
            .authorities("OWNER")
    }

    @Bean
    override fun userDetailsServiceBean(): UserDetailsService {
        return super.userDetailsServiceBean()
    }
}
```

Örneğin yukarıdaki gibi bir Spring Security konfigürasyonumuz mevcut ise @WebMvcTest bu Spring Security konfigürasyonunu 
da yükleyecektir. Dolayısı ile testimizin çalışabilmesi için Spring SecurityContext’e uygun yetkiye sahip bir Authentication 
token’ın set edilmesi gerekecektir. Spring Secyrity’nin test kütüphanesi bunun için bize @WithMockUser ve @WithUserDetails 
gibi anotasyonlar sunmaktadır.

```kotlin
@Test
@WithUserDetails("user1")
fun `owners should return all existing owners`() {
//...
}
```

Spring Security konfigürasyonunun hiç yüklenmesini istemiyorsak bu da mümkündür.

```kotlin
@Configuration
@Profile("!web_mvc_tests")
class PetClinicSecurityConfig : WebSecurityConfigurerAdapter() {
//...
}

@WebMvcTest(controllers = [PetClinicController::class])
@ActiveProfiles("web_mvc_tests")
@ImportAutoConfiguration(exclude = [SecurityAutoConfiguration::class, UserDetailsServiceAutoConfiguration::class])
class PetClinicControllerWebMvcTests {
//...
}
```

Bunun için öncelikle “web_mvc_tests” isimli bir profil tanımlayıp, Security konfigürasyon sınıfımızın bu profil dışındaki 
durumlarda yüklenmesini sağlamalıyız. Daha sonrasında ayrıca @WebMvcTest’in default SecurityAutoConfiguration ve 
UserDetailsServiceAutoConfiguration sınıflarını da, yüklenen auto-configuration sınıflarından hariç tutmasını sağlamamız 
gerekecektir. Bu sayede @WebMvcTest’imizi Spring Security konfigürasyonu ve dolayısı ile @WithUserDetails anotasyonu 
olmadan da çalıştırabiliriz.

@WebMvcTest’in yaptığı ana iş uygulamaya ait Web MVC konfigürasyonunu ve MockMvc nesnesini otomatik olarak konfigüre 
etmektir. Dolayısı ile @SpringBootTest, @AutoConfigureMockMvc ve @MockBean anotasyonları ile, mock ServletContext ortamı 
ve Spring ApplicationContext ayağa kaldırılarak da Controller’larımızı TDD yaklaşımına uygun biçimde geliştirebiliriz.

```kotlin
@SpringBootTest
@AutoConfigureMockMvc
class PetClinicControllerTests {

    @MockBean
    private lateinit var petClinicService: PetClinicService

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Test
    @WithUserDetails("user1")
    fun `owners should return all existing owners`() {
        val auth = SecurityContextHolder.getContext().authentication
        //given
        Mockito.doReturn(listOf(Owner("A", "B"))).`when`(petClinicService).getOwners()
        //when, then
        mockMvc.perform(MockMvcRequestBuilders.get("/owners"))
            .andExpect(MockMvcResultMatchers.status().isOk)
            .andExpect(
                MockMvcResultMatchers.content().json(
                    """
                [{
                "firstName":"A",
                "lastName":"B"
                }]
                """.trimIndent()
                )
            )
    }
}
```

Tabi burada Spring ApplicationContext’in tamamının ayağa kalktığını unutmamak lazım. Dolayısı ile testlerimiz klasik 
“birim test” değil, “entegrasyon test” kategorisine girmektedir. Ancak davranış olarak ilk verdiğimiz örnekten farklı 
olarak top-down ve TDD’ye uygun bir akış ile çalışmamıza da olanak vermektedir.

Not: Bu yazının örneklerini hazırladığım projede GraphQL’de mevcuttu ve malesef GraphQL konfigürasyonu mock ServletContext 
ile ayağa kalkmamaktadır. Bu nedenle ya @SpringBootTest anotasyonunda webEnvironment’ı DEFINED_PORT veya RANDOM_PORT 
tanımlayarak gerçek bir ServletContext ortamının yaratılmasını sağlamalısınız, ya da testinizde GraphQL auto-configuration 
sınıfılarını exclude etmelisiniz.

```kotlin
@TestPropertySource(properties = ["spring.autoconfigure.exclude=com.oembedler.moon.graphql.boot.GraphQLWebAutoConfiguration"])
```