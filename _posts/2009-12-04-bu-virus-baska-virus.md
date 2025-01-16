# Bu virüs başka virüs

Artık hemen her sene değişik bir hastalık veya grip virüsü ile karşılaşıyoruz. Deli dana derken ardından kuş gribi 
çıkıvermişti. Şimdilerde de domuz gribi ile başa çıkmaya çalışıyoruz. İşte böyle virüslü bir dönemde kayınpederim de 
gazeteleri okumak ve müzik dinlemek için kullandığı dizüstü bilgisayarının oldukça yavaşladığından şikayet etti. 
Söylediğine göre Internet Explorer tarayıcısı ile herhangi bir siteye girmesi oldukça vakit alıyordu. Bilgisayarın 
güvenlik ayarlarına baktım, herhangi bir anti-virüs yazılımı çalışmıyordu. Bağlantı ayarlarını da kontrol ettikten sonra 
tanıyı koymakta zorlanmadım. Yavaşlık muhtemelen virüs, trojan veya spyware gibi zararlı yazılımlardan kaynaklanıyordu. 
Anlaşılan bilgisayarda domuz gribi salgınından nasibini almıştı. Vakit geçirmeden bilgisayara bulaşan bu zararlıları 
temizlemek için gerekli programları İnternet’ten indirdim ve tedaviye başladım. Ancak ufak bir dikkatsizlik sonucu virüs 
bulaşmış sistem dosyalarından bazılarını, onarmak yerine silince malesef bilgisayarı formatlamak ve işletim sistemini 
yeniden kurmak zorunda kaldım. Bu olay beni birden yıllar öncesine götürüverdi…

90lı yılların ortalarında daha acemi bir bilgisayar mühendisliği öğrencisi iken bir akşam çok sevdiğim bir komşum, 
arkadaşının bilgisayarının bilgisayarında garip birşeyler olduğunu söyleyerek yardım istedi. Bilgisayarda tamamlanmış, 
baskıya hazır bir doktora tezi varmış ve tezin başka bir yerde yedeği de yokmuş.Tariflerine göre bilgisayarda CrazyBoot 
isimli bir virüs vardı. Şimdilerde ortalıklarda pek görülmeyen “stealth” tarzı virüslerden olan CrazyBoot, sistemdeki 
verilere bir zarar vermemesine rağmen, eğer virüs bulaşmamış bir disket ile bilgisayarınızı açarsanız sabit diskin 
okunmasına izin vermiyor ve

```terminal
DON’T PLAY WITH THE PC!
OTHERWISE YOU WILL GET IN ‘DEEP, DEEP’ TROUBLE!. . .
CRAZY BOOT VER. 1.0
```

şeklinde bir mesajla bilgisayar kullanıcılarında haklı olarak panik yaratıyordu. CrazyBoot virüsünü temizleyen, o zamanların 
ünlü, anti-virüs yazılımı F-Prot içeren bir disketle arkadaşının evine gittik. Malesef hazırladığım disket bir “bad sector” 
hatası nedeniyle virüslü bilgisayarda çalışmadı. CrazyBoot virüsü diskin hemen başında yer alan MBR olarak adlandırılan 
açılış kayıtlarının yerini değiştirip kendisini diskin bu bölümüne yazarak bilgisayara yerleşir. Açılış sırasında da bu 
alandaki virüs, diğer bütün programlardan önce hafızaya yüklenerek gizlenir ve gelecek kurbanlarını beklemeye başlardı. 
Aslında MBR olarak adlandırılan açılış kayıtlarından, bilgisayarın diskinde ikici bir yedek kopya daha vardır ve siz bu 
yedek MBR’yi kullanarak, CrazyBoot virüsünü “fdisk /mbr” komutu ile de temizleyebilirdiniz. Ancak bu çözüm için sistemi 
temiz bir disket ile açmanız şarttı. O anda aklıma bu çözüm geldi, fakat bilgisayarı temiz bir disketle açmadan virüs 
aktif iken “fdisk /mbr” komutunu çalıştırdım. İkinci kopya düzgün biçimde ilkinin yerine kopyalanamadı ve bilgisayar hiç 
açılmaz bir hale geliverdi. İçerisinde tamamlanmış ve baskıya hazır ve yedeğide olmayan doktora tezini barındıran diske 
erişemeyince bütün gece üçümüzün gözüne de uyku girmedi, mide kırampları ile sabahı ettik. Ertesi gün erkenden bir 
bilgisayarcı bulup, diski başka bir sisteme bağlayıp “fdisk /mbr” komutu ile tekrar erişilebilir hale getirdik.

CrazyBoot, “stealth” olarak tabir edilen açılışta bilgisayar hafızasına yerleşip kendini gizleyen türde virüslerden 
biriydi. O zamanlar yaygın biçimde kullanılan ancak şimdilerde yerini usb flash belleklere bırakan floppy disketler 
vasıtası ile diğer bilgisayarlara kolayca bulaşırdı. Bugünlerde artık stealth virüslerini ortalıklarda nedense pek 
görmüyoruz. Artık varsa yoksa spyware, trojan, adware gibi zararlılar ortalıkta cirit atıyor. Bunlarında genelde yaptığı 
iş bilgisayar kullanıcıları ile ilgili kişisel bilgileri ele geçirmeye çalışmak, kullanıcıların izni dışında değişik 
reklam sitelerini açmak, bilgisayar kaynaklarını değişik amaçlar için kullanmak oluyor. Aslında çoğunun gerçek virüsler 
gibi kendini kopyalayarak, yayma kabiliyeti bile yok. Bu tür zararlıları üretmek için eskiden olduğu gibi derin bir sistem 
ve programlama bilgisine de ihtiyaç kalmadı. Artık az çok bilgisayar okur yazarı olan herkes otomatik yazılımlar kullanarak 
bu tür zararlıları üretebiliyor ve İnternet’e salıyor. Artık ne stealth virüsleri kaldı, ne de açılış disketleri, insanın 
“Ahh, nerede o eski virüsler!” diyesi geliyor…

**Not:** Bu yazı ilk olarak 25 Kasım 2009 tarihinde www.skyturk.net haber sitesinde yayımlanmıştır.
