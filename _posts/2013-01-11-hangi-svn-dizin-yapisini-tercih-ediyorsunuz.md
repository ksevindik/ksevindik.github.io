# Hangi SVN Dizin Yapısını Tercih Ediyorsunuz?

SVN ile çalışırken iki dizin yapısı karşımıza çıkıyor. Bunlardan ilki

```shell
repo/
repo/trunk/project1
repo/trunk/project2
repo/tags
repo/tags/...
repo/branches
repo/branches/...
```

şeklindedir. Çoğunlukla da bu yapı tercih edilmektedir. Bu yapıda trunk, tags ve branches dizinlerini her proje için 
tekrar tekrar oluşturma külfeti ortadan kalkmaktadır. Ayrıca bütün trunk’ın bir komut ile tag’lenmesi veya branch’ının 
oluşturulması da oldukça kolaydır.

Diğeri ise

```shell
repo/project1
repo/project1/trunk
repo/project1/tags
repo/project1/branches
repo/project2
repo/project2/trunk
repo/project2/tags
repo/project2/branches
```

şeklindedir. Bu yapının diğer bir dezavantajı ise farklı iki projenin aynı isimli dosyaları varsa bunların tek bir branch 
veya tag altında toplanması zorlaşmaktadır.

İkinci dizin yapısını ilkine göre daha avantajlı kılan en önemli şey ise kullanıcıların SVN’e proje bazlı erişimlerinin 
sağlanmasıdır. SVN ile “path based” yetkilendirme uygulanabilmektedir. Bu apache üzerinden de mümkündür. Path based 
yetkilendirme de belirli bir dizin altına herhangi bir kullanıcı veya kullanıcı grubunun okuma veya yazma yetkileri ile 
erişimlerine imkan sağlanır. İkinci dizin yapısı sayesinde bir projeye ait trunk, tag ve braches dizinlerine tek seferde 
erişim yetkisi tanımlamak daha kolay hale gelmektedir.