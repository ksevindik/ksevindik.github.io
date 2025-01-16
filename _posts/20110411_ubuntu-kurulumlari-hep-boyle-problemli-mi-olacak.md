# Ubuntu Kurulumları Hep Böyle Problemli mi Olacak?

Birkaç senedir dizüstü bilgisayarlarımda ubuntu linux işletim sistemini kullanıyorum. Ubuntu’ya geçiş kararım bir akşam 
üstü dizüstü bilgisayarımı kapatmaya çalıştığımda Windows XP’nin dakikalar boyunca uğraşması sonucu aniden oluvermişti. 
O gün bu bugündür de bu işletim sistemini severek kullanıyorum.

İşletim sisteminin performansına ve kurulduktan sonraki istikrarlı çalışmasına hiç bir diyeceğim yok. Ancak ne zaman ki 
bilgisayarımdaki sürümü yükseltmeye kalksam veya sıfırdan bir kurulum yapmak istesem bu işlemlerin ilk seferde düzgün 
biçimde gerçekleştiğine pek şahit olmadım. 9.10 sürümünü CD’den bir bilgisayarıma kurmak için defalarca uğraştığımı 
hatırlıyorum. Bir türlü internal CD ile kurulum yapamamıştım. En sonunda diski çıkarıp başka bir makinada kurulum 
yaptıktan diski tekrar eski makinaya takmıştım. 9.10’dan 10.10’a upgrade süreci de istediğim gibi gerçekleşmemişti. 
Sıfırdan kurulum yapmadan, önce 10.04 ardından da 10.10’a yükseltmeye çalışmıştım. Ama ya iso imajlarında checksum 
problemleri, ya da kurulumdan sonra işletim sisteminin düzgün biçimde açılmaması gibi problemlerden ötürü bir türlü 
10.10’a geçiş yapamamıştım.

Geçenlerde yeni bir dizüstü bilgisayar aldım. Sistem i7, 8 GB’da RAM’e sahip olunca 10.10’u sıfırdan kurmak ve 64 bit 
ubuntu’yu denemek istedim. Artık USB’den boot özelliği de iyice yaygınlaştığı için 10.10 64 bit imajını internetten 
indirip USB startup disk’i oluşturuverdim. Ardından da kuruluma başladım. Herşey gayet normal seyrederken birden yine bir 
hata penceresi karşıma çıkıverdi. apt installer bazı paketlerin kurulumuna devam edemiyordu, bir bug request’i gönderebilir, 
logları inceleyebilirdim. Sistemi reboot ettim, işletim sistemi bulunamıyordu, demek oluyordu ki grub loader’ın kopyalanması 
aşamasına da gelinmemişti. Logları incelemeden evvel hemen her bilgisayarcının yaptığı gibi kurulumu aynen bir kere daha 
başlattım. Önceki kurulumda seçenekler arasında olup seçtiğim flash player gibi 3rd party araçların kurulması seçeneğini 
bu sefer boş bırakmayı denedim. Evvet! bu sefer şansım yaver gitti ve kurulum başarılı biçimde sonlandı. Artık 10.10 ve 
64 bit bir ubuntu ile çalışıyorum. Bakalım 64 bit ubuntu ne kadar fark yaratacak…
