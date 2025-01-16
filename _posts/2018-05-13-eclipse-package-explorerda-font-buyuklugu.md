# Eclipse Package Explorer'da Font Büyüklüğü

Uzun zamandır geliştirme platformu olarak Eclipse/Spring Tool Suite’i tercih ediyorum ve Kurumsal Java Eğitimleri’mizde 
de bunu kullanıyorum. Eğitimler sırasında Eclipse içerisinde açılan editor’lerin fontlarını 
Window>Preferences>Appearance>Colors and Fonts bölümünden değiştirebiliyoruz. Ancak geçen bir eğitimde projeksiyon 
cihazının netlik probleminden dolayı Package Explorer’daki paket, sınıf ve dosya isimlerinin de fontlarını büyütmek 
gerekti. Eclipse’in ayarlarını biraz kurcaladıktan sonra böyle birşeyin Eclipse içerisinden mümkün olmadığını anladım. 
Kısa bir “googling seansı” ardından cözümün plugins/org.eclipse.ui.themes_XXX/css altındaki css dosyalarını değiştirmekten 
geçtiğini anladım. Package Explorer’ın font ebatını değiştirmek için hangi temayı kullıyor iseniz ona karşılık gelen css 
dosyasının içerisine

```css
.MPart Tree { font-size: 16; }
```

şeklinde bir css kuralı eklemeniz yeterli olacaktır. Bu işlemin ardından Eclipse/STS’i kapatıp açmayı unutmayın 🙂
