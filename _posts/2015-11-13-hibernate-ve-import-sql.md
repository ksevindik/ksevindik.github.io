# Hibernate ve import.sql

Hibernate’in dokümante edilmemiş özelliklerden birisi de import.sql kabiliyetidir. Eğer root classpath’e import.sql 
isimli bir dosya eklerseniz ve bu dosya içerisine de SQL ifadeleri yazarsanız Hibernate şema export adımından sonra bu 
SQL ifadelerini çalıştıracaktır. Bu yöntem ile test veya development sırasında örnek verinin DB’ye eklenmesi mümkündür. 
import.sql kullanırken dikkat edilmesi gereken bir iki husus söz konusudur. Bunlardan birisi yazılacak SQL ifadeleri DB 
spesifik olacaktır. Diğeri ise import.sql‘in çalıştırılabilmesi için hibernate.hbm2ddl.auto property değerinin ya “create” 
ya da “create-drop” olmasıdır.

Tabi Spring kullanıcıları için bu tür örnek veri populate etme kabiliyetleri çok primitif gelecektir. Spring tarafında 
jdbc:embedded-database veya jdbc:initialize-database gibi namespace elemanları ile bırakın uygulama düzeyinde veri 
yüklemeyi, test sınıflarına özel örnek veri yüklemek bile çok kolay bir iştir.

```xml
<jdbc:embedded-database id="dataSource">
    <jdbc:script location="classpath:schema.sql"/>
    <jdbc:script location="classpath:test-data.sql"/>
</jdbc:embedded-database>

<jdbc:initialize-database data-source="dataSource">
    <jdbc:script location="classpath:com/foo/sql/db-schema.sql"/>
    <jdbc:script location="classpath:com/foo/sql/db-test-data.sql"/>
</jdbc:initialize-database>
```