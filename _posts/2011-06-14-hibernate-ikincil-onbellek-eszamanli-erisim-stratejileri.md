# Hibernate İkincil Önbellek Eşzamanlı Erişim Stratejileri

Hibernate ikincil önbellek yapısı, değişik eşzamanlı erişim stratejilerini desteklemektedir. Bunlar daha önce de belirttiğimiz 
gibi transaction isolation düzeylerine benzemektedir. Bu stratejilerin kısıtları azaldıkça performansları artar, ancak 
uygulamanın stale veri ile karşılaşma ihtimali de aynı şekilde fazlalaşır. Dört adet eşzamanlı erişim stratejisi vardır.

### Transactional

* Senkron bir eşzamanlı erişim stratejisidir. Başka bir deyişle, önbellek üzerindeki veri güncellemeleri transaction ile 
* birlikte gerçekleştirilir.  
* JBoss TreeCache gibi çözümler bu stratejiyi desteklemektedir.  
* Repeatable read izolasyon düzeyine karşılık gelmektedir.  
* Eğer entity önbellekte yoksa, öncelikle önbelleğe yerleştirilir. Eğer önbellekte mevcut ise buradan dönülür.  
* Önbellekte tutulan entity ile ilgili yapılan insert veya update, önbelleğe transaction sırasında yansıtılır.

### Read-write

* Asenkron bir eşzamanlı erişim stratejisidir. Yani önbellek üzerindeki veri güncelleme işlemleri transaction sonlandıktan sonra yürütülür.  
* Read committed izolasyon düzeyine karşılık gelir.  
* Cache erişimi `synchronized` metotlar ile gerçekleştirilir ve cache lock’lanır.  
* Güncelleme yapılan entity için transaction sırasında soft lock oluşturulur. Her transaction, entity üzerindeki lock count değerini bir artırır.  
* Entity ile ilgili insert ve update işlemleri önbellek tarafına, transaction sonunda yansıtılır. Bu aşamadan sonra soft-lock salıverilir. Entity üzerindeki değişikliklerin önbelleğe yansıtılabilmesi için o anda tek bir soft lock’un olması gerekir.  
* Eğer transaction’ın timestamp’i (Session’ın yaratılma anına denk gelmektedir) entity’nin önbellekteki timestamp değerinden küçük ise, yani Session entity önbelleğe konmadan evvel oluşturulmuş ise entity’ye önbellek yerine veritabanından erişilir.  
* Yine entity üzerinde herhangi bir soft lock söz konusu ise entity’ye erişim yine önbellek yerine veritabanından gerçekleşir.  
* Entity önbellekte mevcut değilse doğrudan önbelleğe konur. Ancak önbellekte mevcut ise, entity’nin önbellekte güncellenebilmesi için de transaction timestamp’in entity’nin önbellekteki timestamp değerinden, ya da yeni version değerinin eskisinden büyük olması gerekir.

### Nonstrict-read-write

* Read-write erişim stratejisinin benzeridir. Ancak read-write gibi önbellek-db senkronizasyonu sağlamayı hedeflemez.  
* Önbellek erişim metotları `synchronized` değildir, önbelleğe erişimin lock’lanması veya soft lock gibi bir mekanizma da yoktur. Bu nedenle read-write’dan daha hızlıdır.  
* Bu erişim stratejisinde “stale veri” ile karşılaşmak ihtimal dahilindedir.  
* Eğer entity önbellekte ise herhangi bir kontrole tabi tutulmadan dönülür.  
* Eğer entity önbellekte mevcut değil ise DB’den okunur, ardından herhangi bir kontrole tabi tutmadan önbelleğe yerleştirilir.  
* Entity üzerinde güncelleme söz konusu ise transaction sonunda, entity önbellekten çıkarılır.  
* Insert edilen entity, önbelleğe konmaz.

### Read-only

* Bu erişim stratejisi sadece immutable entity’ler için uygundur. Entity üzerinde değişiklik yapmaya izin vermez.  
* Eğer entity cache’de mevcut ise dönülür, yoksa DB’den yüklenir ve önbelleğe yerleştirilir.  
* Entity, insert işlemi sırasında önbelleğe de konur.


Bu erişim stratejileri sadece entity ve collection’lar içindir. Sorgularda ise sonuç eğer sorgu önbelleği aktif ise ve 
sorgunun kendisi cache’lenmiş ise doğrudan önbellekteki sorgu bölümü üzerinden gelir. Eğer sorgu önbelleği aktif değilse 
veya sorgu üzerinde cache tanımlı değilse bu durumda sorgu mutlaka DB’ye gider ve sorgu sonucu DB’den dönen içerik olur. 
Sorgu entity sorgusu ise dönen entity içeriği DB’den dönen veri ile oluşacaktır. Ayrıca collection’lar üzerinde yapılan 
değişiklikler de collection önbelleğinin doğrudan invalidate edilmesine neden olur.

Bir sonraki konumuz ikincil önbelleğin konfigürasyonu ve kullanımı olacak.
