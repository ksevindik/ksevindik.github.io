# JPA/Hibernate'de Flush ve Transaction

JPA/Hibernate ile ilgili en çok kafa karıştıran noktalardan birisi de *flush* işlemi ve bunun *transaction* ile olan 
ilişkisidir. Yakın bir zamanda konu ile ilgili aldığım bir soru üzerine önemli gördüğüm noktaları buradan sizinle paylaşmak 
istiyorum.

*Flush*, Hibernate tarafında `Session`, JPA’da ise `EntityManager` üzerinden yönetilen `PersistenceContext` içerisinde 
mevcut entity’ler ile ilgili değişiklikleri (bu değişiklikler `insert`, `update` veya `delete` olabilir) veritabanına SQL 
ifadeleri ile aktaran operasyondur.

*Transaction* ise başlangıcı ve bitişi (*commit*) arasında veritabanında gerçekleştirilen persistence işlemlerinin 
(`insert`, `update` veya `delete`) “all-or-nothing” mantığı (atomik özelliği) ile kalıcı hale gelmesini sağlar.

JPA/Hibernate ile çalışırken `PersistenceContext` üzerinde gerçekleştirilen `persist`, `merge` ve `remove`/`delete` 
işlemlerinin SQL karşılıkları hemen o anda DB’ye yansıtılmaz. Bu değişiklikler `PersistenceContext`’de biriktirilir. 
Buna ORM’in *transactional write-behind* özelliği denmektedir.

Biriken bu değişiklikler *flush* operasyonu ile DB’ye yansıtılır. Ancak bu değişikliklerin kalıcı hale gelmesi için mutlaka 
o andaki transaction’ın başarılı biçimde sonlanmış olması (*commit*) gerekir. *Transaction rollback* durumunda bu 
değişikliklerin hepsi geri alınır.

*Flush* operasyonu normal şartlarda *transaction commit* edildiği vakit arka planda otomatik olarak çalıştırılır. Normal 
şartlarda `PersistenceContext` üzerinde manuel *flush* çalıştırmaya gerek yoktur.

`FlushMode` ile *flush* işleminin ne zaman çalışacağı kontrol edilebilir. JPA’da `AUTO` ve `COMMIT`, Hibernate’de ise 
`AUTO`, `COMMIT`, `ALWAYS` ve `MANUAL` modları vardır. Varsayılan durumda `FlushMode` `AUTO`’dur. Bu durumda `PersistenceContext` 
üzerinde değişiklik yapılmış entity’lerle ilgili çalıştırılan ORM sorgularından hemen önce ve *transaction commit* sırasında 
*flush* işlemi otomatik olarak tetiklenir.

`flush` metodu herhangi bir aşamada manuel olarak çalıştırılırsa `PersistenceContext` üzerindeki değişiklikler tespit edilip 
veritabanına `INSERT`, `UPDATE`, `DELETE` SQL ifadeleri olarak yansıtılır. Fakat bu değişiklikler ancak ve ancak 
*transaction commit* olursa kalıcı hale gelebilir.

Eğer veritabanının isolation düzeyi `READ_UNCOMMITTED` değilse (normalde çoğu veritabanı varsayılan durumda `READ_COMMITTED` 
veya üzeridir), *transaction commit* olmadan, bu değişiklikleri diğer kullanıcılar veya *transaction*’lar göremez.

Hibernate’de `FlushMode`’u `MANUAL` yaparsanız, *transaction commit* aşamasında *flush* tetiklenmeyeceği için, eğer siz 
de manuel olarak *flush* işlemini tetiklememiş iseniz *transaction commit* ardından veritabanına yansıyan hiçbir değişiklik 
göremezsiniz.
