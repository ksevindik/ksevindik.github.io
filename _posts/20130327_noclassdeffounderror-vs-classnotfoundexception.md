# NoClassDefFoundError vs ClassNotFoundException

Her ikisi de biz java programcılarının karşısına sıklıkla çıkan hatalardandır. Her ikisi de uygulamamızın runtime’da 
ihtiyaç duyduğu bir class’ın bulunamadığını anlatmaktadır. Ancak aralarındaki farkları bilmek sorunun ana nedenini tespit 
etmek ve çözüm getirmek için önemli olabilir.

`NoClassDefFoundError` uygulama kodunun ihtiyaç duyduğu ve derleme sırasında mevcut olan bir sınıfın runtime’da bulunamadığını 
veya düzgün biçimde okunamadığını veya yüklenemediğini anlatır. Bu durum ya doğrudan o sınıfın uygulamanın classpath’inde 
olmamasından ya da onun bağımlı olduğu başka bir class’ın yokluğundan kaynaklanıyor olabilir.

`ClassNotFoundException` ise String ile ifade edilen bir java sınıfının runtime’da muhtemelen de `Class.forName()` gibi bir 
metot çağrısı ile yüklenmeye çalışılırken classpath’de bulunamadığını anlatmaktadır.

JDK’yı tasarlayanlar `Error` sınıflarını JVM’e has uygulama tarafından üstesinden gelinemeycek “fatal” hatalar için 
tasarladıklarından, `NoClassDefFoundError` hatası da derleme sırasında işler yolunda iken runtime’da ilgili class(lar)ın 
kaybolması uygulamanın bir hatası olmaktan çok çevresel bir hata olarak görüldüğünden `Error` olarak ifade edilmiştir.

`ClassNotFoundException` ise muhtemelen uygulama geliştiricinin veya kullanıcının bir hatasından kaynaklanmaktadır ve 
uygulama tarafından “recover” edilmeye çalışılabilir bir hata olarak görüldüğü için `Exception` olarak tasarlanmıştır.