# Fractal Project

Son zamanlarda fraktalların programlamaya uygulanması üzerine kafa yoruyorum. Daha önceki yazımda da bahsettiğim gibi 
fraktal model ile composite örüntü arasında bire bir örtüşme söz konusu. Bu konuyla ilgili yazılmış çizilmiş başka neler 
var diye biraz etrafta araştırma yapmak istedim. Karşıma açık kaynak kodlu middleware sistemler için bir konsorsiyum olan 
[ow2 (ObjectWeb)](http://www.ow2.org/)‘nin bir çalışması çıktı; [fractal project](http://fractal.ow2.org/).

Fraktal projesinin amacı, program dillerinden bağımsız, modülerite ve adaptability konularını ön plana çıkaran bir 
component model ortaya koymak. Tabii burada interface-implementation ayrımını da unutmamak lazım, ama o neredeyse 
programlamada her şeyin temeli. Bu component modelin özellikle middleware sistemlerde uygulama alanlarının olduğunu 
belirtiyorlar. Adının da fractal olmasını sağlayan temel özelliklerinden birisi composite component yapısı üzerine kurulu 
olması. Component modelin C, Java, Python gibi dillerde implementasyonları mevcutmuş. Component modeli “hello world” 
örneğine nasıl uyguladıklarını görmek için hemen bir Java örneğini inceledim. Tahmin ettiğim gibi composite component 
kavramı burada temel soyutlama birimi olmuş. Program, en üst seviyeden, en alt bileşenine kadar bir component hiyerarşisi 
(composite örüntü) olarak tasarlanıyor ve geliştiriliyor. Nasıl ki değişik programlama dilleri dünyayı belirli bir olgu 
etrafında, örneğin, LISP’in her şeyi bir liste olarak görmesi, Prolog’un her şeyi bir kural (rule) olarak görmesi, OOP’un 
da her şeyi bir nesne olarak görmesi gibi, fraktal projesi de her şeyi composite olarak görüyor. Yani bir bakıma çekiç-çivi 
meselesi.

Doğanın hemen her yerinde olan fractal kavramı bence programlama dünyamıza da yeni kapılar aralayabilir. Bence incelemeye 
değer bir proje…
