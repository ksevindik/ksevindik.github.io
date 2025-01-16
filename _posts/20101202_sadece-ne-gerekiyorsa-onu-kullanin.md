# Sadece Ne Gerekiyorsa Onu Kullanın

2004 yılının başlarında askerliğimi yaptığım yerde bizden bir yazılım geliştirmemizi istemişlerdi. İnternet bağlantısının 
bile çok sorunlu olduğu, hiyerarşinin ve bürokrasinin yoğun olduğu bir ortamda sıfırdan enterprise Java geliştirme ortamını 
toparlamak, değişik enterprise Java frameworklerini ve kütüphanelerini bir araya getirip uygulamayı geliştirmeye başlamak 
daha zor olacağı için, daha önce hiç proje geliştirmeme rağmen hazır ve entegre bir geliştirme ve runtime ortamı sunduğundan 
ötürü, üstlerime `.NET`'i kullanmayı önerdim. Projeyi geliştirmeden sorumlu diğer asteğmen arkadaşım Visual Studio konusunda, 
bende uygulamanın tasarımı, mimarisi, altyapı servisleri noktasında konuya gayet hakim olduğumuzdan, birkaç haftada uygulamayı 
gayet başarılı biçimde geliştirdik, deploy ettik. Geliştirme süresince de Visual Studio ve C# dışında da herhangi bir framework, 
kütüphane veya araç kullanmadık. Zaten daha `.NET` dünyasında `Spring.NET`, `NHibernate`, `NAnt`, `Maverick` vb frameworkler’de 
ya hiç çıkmamıştı, ya da yeni yeni ortalıkta belirmeye başlıyordu. Bu framework ve araçların çoğu Java dünyasında bile o 
dönemlerde yeni sayılırdı.

Bu başarılı proje çalışmasından sonra görev yaptığım şubedeki üstlerim ikinci bir projeyi daha geliştirmemi istediler. 
İlk projedeki başarının getirdiği özgüven ve rahatlık ile bu projeyi de `.NET` ile yapmaya karar verdik. Ancak bu sefer 
ilk projede kullanmadığımız hemen hemen bütün bu framework, kütüphane ve araçları ikinci projede kullanmaya karar verdim. 
Projenin çok basit bir domain modeli olmasına rağmen persistence framework olarak `NHibernate`, `ASP.NET` ile tam manası 
ile uyuşmamasına rağmen MVC framework olarak `Maverick`, build aracı olarak `NAnt`'ı günler boyu uğraşarak bir araya 
getirerek entegre ettim. Uygulamanın iskeletini oluşturdum ve vertical bir slice’ı da örnek senaryo olarak implement 
ettim. Ortaya çıkan durum tam olarak “[Second System Effect](http://en.wikipedia.org/wiki/Second-system_effect)” kavramı ile özetlenebilirdi. Fred Brooks’un ünlü kitabı, 
*Mythical Man Month*’da bahsettiği gibi hemen her mühendis gibi bende bu tuzağa düşüvermiştim. Ortaya çıkan mimari ve 
tasarım da bu basit projeyi efektif biçimde geliştirmekten uzaktı. Uzun lafın kısası, kısa bir dönem sonra da terhis 
olacağım için projeyi o hali ile benden sonraki asteğmen arkadaşıma devrettim. Maalesef bu arkadaşım da haklı olarak bu 
“overdesign” ile uğraşmak yerine projeyi sıfırdan geliştirmek zorunda kaldı.  

Geçenlerde InfoQ’da Dan North’un “[Simplicity The Way Of The Unusual Architect](http://www.infoq.com/presentations/Simplicity-Architect)” isimli çok hoş sunumu ile karşılaşınca 
aklıma hemen yukarıdaki macera geliverdi. Sunumun içerisinde bir problemi çözmek için sisteme herhangi bir teknoloji veya 
aracı dahil ettiğimizde elimizdeki problem sayısının birden ikiye çıktığından bahsediliyor. Gerçekten de sadece kullanmış 
olmak için hiçbir framework, kütüphane veya araç uygulama içerisinde kullanılmamalı. Bunlardan herhangi birini kullanmayı 
düşündüğümüzde öncelikle ulaşmaya çalıştığımız hedefi, hangi problemi çözmeye çalıştığımızı ve kullanacağımız teknoloji 
veya aracın hedeflediğimiz noktaya ulaşmada işimizi ne kadar kolaylaştıracağını dikkatli biçimde etüt etmemiz şart. 
Başarılı bir projenin ardından başlayan her yeni projenin mutlaka bir “second system effect” riski taşıdığını unutmayalım.
