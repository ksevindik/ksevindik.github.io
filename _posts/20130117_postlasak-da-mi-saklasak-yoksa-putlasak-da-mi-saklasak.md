# POST’lasak da mı saklasak yoksa PUT’lasak da mı saklasak?

Sarımsaklasak da mı saklasak, yoksa sarımsaklamasak da mı saklasak… Yok yok hayır, REST tabanlı bir servis geliştirirken 
yeni bir resource ekleme ve güncelleme işlemleri için hangi HTTP metodunun tercih edileceğine karar vermek bu tekerlemeyi 
söylemek kadar zor değil. Yalnızca bu iki metot ile ilgili bilmemiz gereken birkaç temel noktaya odaklanarak hangi metodu 
nerede tercih edeceğimizi kolaylıkla tespit edebiliriz. Öncelikle şunu söyleyelim: HTTP spesifikasyonunda hem POST, hem 
de PUT metodu ile yeni bir resource oluşturma veya mevcut bir resource’u değiştirme işlemi yapılabileceği söyleniyor. 
Ancak ikisi arasında şu temel farklar söz konusu:

* PUT metodu “idempotent” olarak tanımlanmıştır. Yani aynı resource path üzerinde gerçekleştirilen birden fazla PUT request’i server tarafında ilk PUT request’inin yaptığından başka bir state değişikliğine neden olmaz. Oysa durum POST için bundan çok farklıdır. POST ile aynı resource path’ine yapılan birden fazla request her seferinde server tarafında bir state değişikliğine neden olacaktır.

```json
POST /companies
{
  "companyName":"Harezmi",
  "companyLocation":"Ankara"
}
```
Ard arda iki defa aynı POST request’i server’da aynı içerikte iki farklı resource oluşturulmasına neden olabilir.

```json
PUT /companies/1
{
  "companyName":"Harezmi",
  "companyLocation":"Ankara"
}
```

Ard arda iki defa aynı PUT request’i geldiğinde ise server ilk seferde resource’u yaratır, ikinci ve diğer PUT 
request’lerinde ise belirtilen path’deki resource’un içeriği güncellenecektir. Request’lerde her seferinde aynı içerik 
submit edildiği için server tarafında da bir state değişikliği söz konusu olmayacaktır. Yeni bir resource yaratılması da 
söz konusu değildir.

İkinci fark ise POST ve PUT metoduna parametre olarak verilen resource path’i ile ilgilidir. POST metoduna yeni yaratılacak 
olan resource path’ini verirseniz 404 resource not found hatası alırsınız. POST ile yeni bir resource yaratırken resource 
path’inin ait olacağı parent resource path’ini vermeniz yeterlidir. Başka bir ifade ile yeni resource path’inin ne olacağına 
server tarafı karar vermektedir. PUT metodunda ise yaratılacak yeni resource’un path’ini de request’de vermek gereklidir. 
Yani PUT metodunda yaratılacak resource path’ine client karar vermektedir.

```json
POST /companies/1
{
  "companyName":"Harezmi",
  "companyLocation":"Ankara"
}
```

/companies/1 isimli bir resource mevcut değil ise yukarıdaki HTTP request’i hata verecektir. Yeni bir resource yaratmak 
için POST’un kullanımı aşağıdaki gibi olmalıdır.

```json
POST /companies
{
  "companyName":"Harezmi",
  "companyLocation":"Ankara"
}
```

Bu request ile yeni bir resource, path’i server tarafından belirlenerek yaratılacaktır. PUT metodu ile çalışırken ise 
request’i ilgili resource’u client’in belirttiği path’de yaratacaktır.

```json
PUT /companies/1
{
  "companyName":"Harezmi",
  "companyLocation":"Ankara"
}
```

Yukarıdaki iki temel farklılığa göre POST ve PUT metotlarının kullanımlarını şu şekilde de ifade edebiliriz:

**POST:** “Elimde yeni oluşacak bir resource’a ait veri var, al bu veriyi ve bana yeni bir resource oluştur, yeni resource’un path’ini de (belki id’si) sen belirle.”

**PUT:** “Elimde yeni oluşacak, path’i de şu olan resource’a ait veri var, al bu veriyi ve bana bu path’de yeni bir resource oluştur. Eğer daha önce bir resource oluşturulmuş ise bu veriyi ilgili resource’un içeriğini güncellemek için kullan.”
