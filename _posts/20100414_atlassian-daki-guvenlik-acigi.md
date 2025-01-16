# Atlassian daki Guvenlik Acigi

Pazartesi günü Atlassian’dan bir mesaj geldi. Mesajda kısaca Temmuz 2008’den önce Atlassian’da hesap açtıran kullanıcıların 
şifrelerinin, sistemlerinde “plain text” halde tutulmasından dolayı ele geçirilmiş olabileceğinden bahsediyordu. Aslında 
bu durum web sitelerinde oluşturduğumuz kullanıcı hesaplarında, online banka veya benzeri kritik öneme sahip hesaplarımızda 
kullandığımız parola ve şifreleri kullanmanın ne kadar riskli olabileceğinin yeni bir kanıtı oldu. Maalesef pek çok web 
uygulamasında kullanıcı şifreleri veritabanında “plain text” halde tutuluyor ve siz “şifremi unuttum” şeklinde bir istekte 
bulunduğunuzda bu siteler güzel güzel size o unuttuğunuz şifreyi e-posta ile gönderiveriyorlar. Bu şekilde tutulan bilgiler 
arasında şifrelerin yanında kredi kart numaralarının da olduğunu hemen hepimiz biliyoruz. Bir sistemin güvenliği, zincirin 
en zayıf halkası kadardır sözü İnternet üzerindeki bütün sistemler için de geçerli. Sonuçta Atlassian’da tutulan plain text 
şifre benim Google hesabımın şifresi ile aynı olabilir ve Atlassian’ın hacklenmesi bir nevi Google’ın hacklenmesi gibi de 
değerlendirilebilir.

Atlassian’ın durumuna geri dönersek, adamlar hatalarını fark ettikten sonra bütün hesaplara bu uyarı mesajını gönderdiler. 
Birden binlerce kullanıcının sistemlerine erişip şifrelerini değiştirmek istemesi sunucularının da göçmesine sebep oldu. 
Belki hatalarını hiç yokuşa sürmeden kabul etmeleri takdir edilebilir, ancak Crowd gibi bir “SSO ve Identity Management” 
ürününü de sunan bir yazılım firmasında böyle temel bir güvenlik zaafiyetinin görülmesi insanların kafalarında firma ile 
ilgili sanırım büyük bir soru işareti uyandırmıştır. Detayları 
[bloglarından](http://blogs.atlassian.com/news/2010/04/oh_man_what_a_day_an_update_on_our_security_breach.html) takip edebilirsiniz.
