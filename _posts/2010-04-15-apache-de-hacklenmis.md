# Apache de Hacklenmis

Dün Atlassian’ın şifreleriniz ele geçirilmiş olabilir mesajından [bahsetmiştim](http://www.kenansevindik.com/atlassian-daki-guvenlik-acigi.html). 
Atlassian hacklenmenin detaylarından çok 
bahsetmemişti. Ancak 6-9 Nisan tarihleri arasında Apache’de [hacklenmiş](https://blogs.apache.org/infra/entry/apache_org_04_09_2010). 
Özetlersek XSS ile başlayan bir saldırı ve 
Apache’nin JIRA sistemini hedef almış. Sonuçta da Apache’deki bir sunucunun root yetkileri ele geçirilmiş, JIRA, 
Confluence ve Bugzilla sistemleri ve veritabanları hallaç pamuğu gibi dağıtılmış. İşin ilginç yanı Atlassian’ın da 
hacklenmesi bu saldırı yöntemi ile gerçekleşmiş. Detaylara bakılırsa gerçekten “organize işler” olduğunu söyleyebiliriz. 
Tabi bu arada Apache’nin yaklaşımını da takdir etmek lazım, olayı bütün açıklığı ile ortaya koymuşlar ve başkalarının da 
ders çıkarmaları için tespitlerde bulunmuşlar.
