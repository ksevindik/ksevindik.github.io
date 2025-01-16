# Kotlin ve Spring

Kotlin deneyimlerimi paylaşmaya devam ediyorum. Bu yazımızda da Kotlin ile kurumsal yazılım geliştirirken Spring 
Framework’ün kullanımından bahsedeceğim.

Geçen yazımda da belirttiğim gibi Kotlin’in JVM uyumlu bir dil olması sayesinde mevcut Java kütüphanelerini Kotlin 
projelerimizde de kullanabiliyoruz. Ancak Hibernate örneğinde olduğu gibi Spring ve Spring Boot Framework açısından da, 
Kotlin’in varsayılan durumda sınıfları ve metotları final olarak işaretlemesi temel bir sorun teşkil ediyor.

Çünkü Spring Framework transaction yönetiminden, caching’e, scope’lardan, aspect oriented programlamaya pek çok altyapısal 
kabiliyetini “proxy örüntüsü” üzerine bina etmiştir. Dolayısıyla Spring ile çalışırken, Spring managed bean sınıflar 
üzerinde her ne zaman bu tür altyapısal kabiliyetlerden birisini kullanacağımız durumda, ki buna hemen her zaman diyebiliriz, 
bu sınıfları ve metotları “open” olarak işaretlemek zorundayız. Aksi takdirde Hibernate’den farklı olarak daha bootstrap 
aşamasında Spring ApplicationContext’i oluştururken dahi hata ile karşılaşma ihtimalimiz büyük.

JetBrains ekibinin geliştirdiği `allopen` plugin’ini kullanarak Spring’in `@Service`, `@Component`, `@Repository`, 
`@Controller`, `@Configuration` gibi anotasyonlarına sahip sınıfların open yapılmasını sağlayabiliriz.

```gradle
plugins {
  id "org.jetbrains.kotlin.plugin.allopen" version "1.3.71"
}
allOpen {
    annotation("org.springframework.stereotype.Component")
    annotation("org.springframework.scheduling.annotation.Async")
    annotation("org.springframework.cache.annotation.Cacheable")
    annotation("org.springframework.transaction.annotation.Transactional")
annotation("org.springframework.boot.test.context.SpringBootTest")
}
```

Ya da yine JetBrains ekibinin, Hibernate için olduğu gibi Spring kullanacak yazılım geliştiricilerin de işini kolaylaştırmak 
için geliştirdiği `kotlin-spring` compiler plugin’ini kullanabiliriz.  

```gradle
plugins {
    kotlin("plugin.spring") version "1.3.71"
}
```

`kotlin-spring` plugin’i sayesinde Spring anotasyonlarından herhangi birisini build script’imizde tanımlamamıza gerek 
kalmadan çalışabiliriz.

