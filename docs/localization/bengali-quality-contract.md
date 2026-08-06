# MİZAN GLOBAL — Bengalce (`bn`) bağlayıcı kalite sözleşmesi

## Kaynak ve çalışma sınırı

- Kesin başlangıç kaynağı: Hintçe ürün birleştirme commit’i `64b6a7d71170fe933905165f67235a506c2d6e5b`.
- Ürün dalı: `agent/mizanglobal-globalization`.
- Çalışma dalı: `agent/bengali-localization`.
- Başlangıçta doğrulanmış ürün runtime’ı: 18 dil.
- Katalogdaki sıradaki dil: Bengalce; kod `bn`, yerel ad `বাংলা`, ülke kapsamı Bangladeş ve Hindistan.
- Bu çalışma tamamlanmadan, bütün kabul kapıları geçmeden ve kaynak ağacı temizlenmeden ürün dalına alınmayacaktır.

## Dil kalitesi

1. Sabit uygulama metinlerinin tamamı kaynak anahtarlarla birebir eşleşen **791/791** Bengalce değere sahip olacaktır.
2. Metinler çeviri kokan, sözcük sözcük aktarılmış veya Hintçe/İngilizce kalıbına bağlı ifadeler değil; doğal, açık ve finans uygulamasına uygun ana dil seviyesinde Bengalce olacaktır.
3. Dil; Bangladeş ve Hindistan’daki Bengalce kullanıcıların anlayacağı tarafsız standart Bengalceyi esas alacaktır. Bölgesel terimler anlam kaybına yol açıyorsa ortak ve açıklayıcı karşılık kullanılacaktır.
4. Borç, alacak, ödeme, taksit, vade, gecikmiş ödeme, kalan ödeme yükü, gider, gelir, bakiye, rapor, yedek ve bildirim kavramları birbirine karıştırılmayacaktır.
5. “Kalan”, “gecikmiş”, “yaklaşan”, “ödenmiş” ve “ödenmemiş” durumları ayrı ve tutarlı terimlerle kilitlenecektir.
6. Menü, buton, form, doğrulama, hata, uyarı, boş durum, ayar, rapor, grafik, PDF ve bildirim metinlerinde başka ürün dili görünmeyecektir.
7. Marka adları, ISO kodları ve `Android`, `CSV`, `PDF`, `IBAN`, `WhatsApp`, `BDT`, `INR` gibi güvenli teknik terimler dışında görünür Latin ürün metni bırakılmayacaktır.

## Yazı, Unicode ve yön

- Bengalce metinler Bengali Unicode bloğu ve gerekli ortak noktalama işaretleriyle NFC-normalize tutulacaktır.
- Görünmez bidi kontrol karakterleri, başka ürün alfabeleri ve bozuk birleşik karakterler statik sözlüğe sızmayacaktır.
- Bengalce runtime **LTR** olacaktır; rakam, ISO para birimi kodu, e-posta, URL, IBAN ve kullanıcı metni karışık yazıda güvenli kalacaktır.
- Kullanıcının girdiği kişi adı, not, kategori, borç adı ve serbest alanlar çevrilmeyecek, sadeleştirilmeyecek veya alfabe dönüşümüne uğratılmayacaktır.

## Runtime ve dilbilgisi

- `bn`, `bn-BD` ve `bn-IN` güvenli biçimde `bn` runtime’ına normalize edilecektir.
- Dinamik cümleler sabit ek birleştirmesiyle değil, Bengalceye uygun tam cümle şablonlarıyla üretilecektir.
- Tekil/çoğul davranışı projede sabitlenen CLDR sürümünden türetilecek; `0`, `1`, `2`, büyük sayılar ve ondalık değerler ayrı test edilecektir.
- Tarih ve saat ifadeleri doğal Bengalce söz dizimiyle üretilecek; seçilen tarihin veya bildirimin anlamı değişmeyecektir.
- Uygulama dili değişince ülke, borç bölgesi, varsayılan para birimi veya kayıt bazlı para birimleri değişmeyecektir.

## Kataloglar ve arama

- 29 dil, 161 ülke ve 154 para birimi kataloğunun tümünde Bengalce görünür adlar tamamlanacaktır.
- Arama; Bengalce ad, yerel/native ad, İngilizce ad, ISO kodu, sembol, güvenli transliterasyon ve doğrulanmış aliaslar üzerinden çalışmaya devam edecektir.
- Bengalce görünümde satırlar başka dil adı göstermeyecek; aynı sembolü paylaşan para birimleri ISO kodu ve tam adla ayrılacaktır.
- Dil, ülke ve para birimi katalog sırası değişmeyecek; mevcut 18 dilin katalog verisi bozulmayacaktır.

## Sayı, para ve tarih

- Sayı ve para biçimleme seçili ülke/para biriminden bağımsızlaştırılmayacaktır.
- Bangladeş senaryolarında `BDT`, Hindistan senaryolarında `INR`; ayrıca kayıt bazlı `USD`, `EUR`, `TRY` ve diğer para birimleri ayrı ayrı doğrulanacaktır.
- Raporlar farklı para birimlerini kur dönüşümüyle birleştirmeyecek; yalnız kullanılan para birimleri için ayrı bölümler üretecektir.
- Gregoryen tarih davranışı korunacak; uygulamaya örtük Bengal takvimi eklenmeyecektir.
- Kaydetme, yeniden açma, CSV dışa/içe aktarma, yedekleme ve geri yükleme sonrasında tutar, para birimi ve tarih değişmeyecektir.

## Rapor, PDF ve bildirim kabulü

- Ekrandaki dönem ve kişi filtreleri PDF ile birebir aynı sonucu verecektir.
- Normal giderler, ödeme kayıtları, gelir, güncel kalan borç, gecikmiş yük ve yaklaşan yük kaynakları karıştırılmadan hesaplanacaktır.
- PDF’de Bengalce glifler eksiksiz gömülecek; kare kutu, kesik karakter, satır taşması veya yanlış yön oluşmayacaktır.
- Grafik başlıkları, açıklamalar, lejantlar, boş durumlar ve paylaşım metinleri Bengalce olacaktır.
- Bildirim başlığı/gövdesi, kesin alarm izni, yaklaşık zamanlama açıklaması ve arka plan güvenilirliği Bengalce seçiliyken doğal ve doğru çalışacaktır.
- Günlük üç bildirim düzeni, aç/kapa davranışı ve kayıt güncellemelerindeki otomatik yeniden planlama bozulmayacaktır.

## Responsive ve erişilebilirlik

- Küçük Android ekranı, büyük yazı ölçeği, klavye açık durumu, uzun kişi/kategori adı, uzun para birimi adı ve uzun hata metni senaryoları taşmasız test edilecektir.
- Menü, sekme, dialog, dropdown, form, rapor kartı, grafik açıklaması ve PDF önizlemesinde metin kesilmesi olmayacaktır.
- Dokunma hedefleri, odak sırası, ekran okuyucu etiketleri ve anlamlı kontrast mevcut ürün davranışını koruyacaktır.

## Miras regresyonu ve final kapıları

Bengalce ancak aşağıdaki üç bağımsız kapının tamamı aynı kesin head üzerinde geçtiğinde final sayılabilir:

### Kapı 1 — Dil ve işlev

- 791/791 sabit metin ve dinamik Bengalce dilbilgisi
- Bengali yazı/NFC/başka dil sızıntısı denetimi
- `bn` runtime, LTR ve karışık yazı güvenliği
- kataloglar, arama, sayı/para/tarih biçimleri
- depolama, CSV, yedek, rapor, PDF ve bildirim testleri
- önceki 18 dilin doğrulayıcıları ve hedefli regresyonları

### Kapı 2 — Tam regresyon ve görseller

- Her test dosyasının izole yaşam döngüsüyle tam regresyonu
- Bütün görsel senaryoların yeniden üretilmesi
- Onaylı baseline dışında piksel sürüklenmesi olmaması
- Responsive, font, taşma ve yön kontrolleri

### Kapı 3 — Release ve temiz kaynak

- Universal release APK
- ARM64, ARMv7 ve x86_64 split APK’lar
- Her artifact için kesin bayt ve SHA-256 raporu
- Üretimden sonra kaynak ağacının değişmemesi
- Son commit, test edilen ve artifact üreten kaynakla birebir aynı olması

Otomatik kontroller yalnız kayıt sayısı ve şema doğruladığı için ana dil kalitesinin yerine geçmez. “Final” etiketi; bağımsız doğal dil incelemesi, finansal anlam denetimi, görünür dil saflığı, rapor/PDF/bildirim doğruluğu ve üç final kapısı birlikte geçmeden kullanılmayacaktır.
