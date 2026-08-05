# MİZAN GLOBAL — Hintçe (`hi-IN`) bağlayıcı kalite sözleşmesi

Bu belge, İbranice entegrasyonundan sonra gelen Hintçe ürün dilinin kabul koşullarını tanımlar. Çalışma; İngilizce veya başka bir dildeki arayüz metinlerinin sözcük sözcük dönüştürülmesi değildir. Hindistan'da günlük finans takibinde anlaşılır olan doğal, sade ve tutarlı Modern Hintçe ile bağımsız hazırlanır.

## 1. Kapsam ve etkinleştirme kilidi

- Kararlı Türkçe anahtar kümesindeki 791/791 sabit sistem metni Hintçe karşılığa sahip olmadan `hi` runtime etkinleştirilemez.
- `hi`, `hi-IN` ve `hi_IN` yalnız bütün kabul kapıları tamamlandıktan sonra güvenli biçimde `hi` olarak normalize edilir.
- Dil seçicisinde Hintçe; statik metinler, dinamik cümleler, kataloglar, biçimlendiriciler, rapor/PDF, bildirim ve responsive testleri geçmeden seçilebilir hâle getirilemez.
- Kullanıcının yazdığı kişi, banka, başlık, açıklama, not, IBAN, telefon, dosya adı ve özel bildirim metni çevrilmez veya kalıcı veride değiştirilmez.
- İbranice dâhil önceki 17 dilin runtime, veri, rapor, bildirim, responsive ve görsel davranışı korunur.

## 2. Dil çeşidi ve ürün üslubu

- Hedef dil Hindistan odaklı, sade ve tarafsız Modern Hintçedir.
- Sanskritçe ağırlıklı bürokratik dil, aşırı İngilizce karışımı, bölgesel argo ve kelime kelime çeviri kabul edilmez.
- Kullanıcıya hitap eden eylemler saygılı ve nötr biçimde yazılır: `सहेजें`, `हटाएँ`, `चुनें`, `जोड़ें`, `जारी रखें`.
- Kısa düğmeler kısa kalır; açıklama metinleri dar ekranda kolay taranacak cümlelere bölünür.
- Finansal anlamlar karıştırılmaz: genel borç `कर्ज़`, banka ürünü/loan `लोन`, ödeme `भुगतान`, gider `खर्च`, gelir `आय`, bakiye `शेष राशि`, vade `अंतिम भुगतान तिथि`, gecikmiş/bekleyen tutar bağlama göre `बकाया` veya `देय तिथि पार`.

## 3. Devanagari ve görünür dil saflığı

- Sistem metinleri doğal Devanagari Hintçesiyle yazılır.
- Latin metin yalnız marka, ISO kodu, Android, CSV, PDF, IBAN ve yaygın ürün terimlerinde gerçekten gerekli olduğunda kullanılır.
- Türkçe, Arapça, Farsça, İbranice, Urduca veya başka ürün dillerinden görünür metin sızıntısı kabul edilmez.
- Nukta, matra, virama ve doğal birleşik harfler korunur; metin NFC olarak kararlı kalır.
- Literal bidi kontrol karakteri, sıfır genişlikli boşluk, görünmez yön işareti ve gereksiz ZWJ/ZWNJ kabul edilmez.
- `हिन्दी` dil adı, `भारत` ülke adı ve `₹` işareti katalog ve runtime boyunca tutarlı kullanılır.

## 4. LTR, karma yazı ve kullanıcı verisi

- Hintçe uygulama kabuğu `TextDirection.ltr` ile çalışır; İbranice/Arapça/Farsça RTL davranışı Hintçeye taşınmaz.
- ISO kodu, IBAN, telefon, tarih-saat, dosya adı ve Latin kullanıcı metni doğal LTR sırasını korur.
- Kullanıcı verisi yalnız görünür çıktı için işlenir; depolanan byte içeriğine yön işareti veya çeviri eklenmez.
- Noktalama, eksi işareti, ondalık değer, yüzde ve para kodu satır başında ya da sonunda yanlış konuma sıçramaz.

## 5. Sayı, para ve tarih

- Finansal görünümde Hindistan'da yaygın Batı rakamları (`0–9`) kullanılır.
- INR için `₹1,23,456.78` biçimi uygulanır; lakh/crore tabanlı Hindistan gruplaması korunur.
- Diğer para birimleri ISO koduyla ayrılır; aynı sembole dayanarak para birimleri birleştirilmez.
- Girdi ayrıştırıcısı Batı, Arapça ve Farsça rakam desteğini kaybetmez; depolama sayısal değer olarak kalır.
- Tarih motoru Gregoryen takvimi kullanmaya devam eder. Hintçe seçimi takvimi veya vade hesabını değiştirmez.
- Ay adları Hintçeleştirilir; gerçek `DateTime`, gecikme günü ve bildirim planı değişmez.

## 6. Dinamik dilbilgisi

- Unicode CLDR Hintçe kardinal kapsamındaki `one` ve `other` davranışı doğrulanır; ancak doğal Hintçe isim biçimleri bağlama göre bağımsız yazılır.
- `0`, `1`, `2`, `3`, `11`, `21`, `100` değerleri gün, kayıt, ödeme, gider, ay ve kişi bağlamlarında test edilir.
- `1 दिन / 2 दिन`, `1 भुगतान / 2 भुगतान`, `1 महीना / 2 महीने`, `1 व्यक्ति / 2 लोग` gibi doğal kalıplar ayrı tanımlanır.
- Sayı ile isim arasında gereksiz İngilizce çoğul mantığı kurulmaz.
- Kalan gün, gecikme, açık kayıt, yedek birleştirme ve Android planlama hata cümleleri bağımsız dinamik kalıplarla üretilir.

## 7. Bağlamlı ürün terminolojisi

Aşağıdaki kavramlar ayrı tutulur:

- banka borcu: `बैंक का कर्ज़`
- kişisel/kurumsal borç: `व्यक्तिगत / व्यावसायिक कर्ज़`
- kredi/loan: `लोन`
- fatura: `बिल`
- abonelik: `सदस्यता`
- kira/taksit: `किराया / किस्त`
- gider: `खर्च`
- gelir: `आय`
- ödeme geçmişi: `भुगतान इतिहास`
- kalan ödeme yükü: `बाकी भुगतान दायित्व`
- gecikmiş ödeme: `बकाया भुगतान`
- son ödeme tarihi: `अंतिम भुगतान तिथि`
- hatırlatma: `रिमाइंडर`
- bildirim izni: `सूचना की अनुमति`
- dakik alarm izni: `सटीक अलार्म की अनुमति`
- yedek: `बैकअप`
- rapor: `रिपोर्ट`
- ayarlar: `सेटिंग्स`

## 8. Veri, rapor ve bildirim bütünlüğü

- Dil değişimi kişi, borç, fatura, abonelik, kira, taksit, ödeme, gelir, gider, not veya bildirim saatini değiştiremez.
- Raporlarda para birimleri birleştirilmez ve kur dönüşümü yapılmaz.
- Ekran ve PDF dönem/kişi filtreleri aynı sonucu üretir.
- Bildirim metinleri gerçek Android davranışını doğru açıklar; dakik izin yoksa yaklaşık planlama, izin varsa dakik planlama uygulanır.
- Android zamanlama motorundaki `exactAllowWhileIdle` ve `inexactAllowWhileIdle` yolları korunur ve ayrı ayrı test edilir.
- Bildirim planlama ödeme, gider veya geçmiş kaydı oluşturamaz.
- CSV dışa aktarma, geri yükleme ve birleştirme ilişkileri ile kullanıcı metnini byte düzeyinde korur.

## 9. Zorunlu kabul kapıları

Hintçe tamamlandı sayılmadan önce aşağıdakilerin tamamı geçer:

1. 791/791 statik anahtar ve doğal Hintçe saflığı.
2. Dinamik tekil/çoğul, sayı ve bağlam denetimi.
3. Devanagari/NFC/görünmez karakter saflığı ve kullanıcı verisinin korunması.
4. 29 dil, 161 ülke ve 154 para birimi için Hintçe katalog adları ve arama aliasları.
5. Hintçe Hindistan sayı gruplaması, INR, tarih-saat ve Gregoryen takvim regresyonları.
6. Ana sayfa, kayıtlar, giderler, raporlar, PDF, ayarlar, bildirim ve CSV uçtan uca testleri.
7. 320×568 / 1,4× ve 412×915 / 2,0× LTR responsive testleri.
8. Önceki 17 dil ile gecikme günü ve Android bildirim düzeltmeleri.
9. Bütün test dosyaları ve görsel golden baseline.
10. Universal, ARM64, ARMv7 ve x86_64 release APK'ları, byte ve SHA-256 raporu.
11. Geçici aday üretim araçları kaldırılmış ve çalışma ağacı temiz kesin head.

## 10. Normatif veri kaynağı

- Çoğul kategorileri, locale adları ve sayı biçimleri Unicode CLDR'nin güncel `hi` verisiyle doğrulanır.
- Katalog adları sabitlenmiş CLDR sürümünden üretilir ve ürün bağlamı açısından ayrıca denetlenir.
- CLDR dil kalıbını belirler; nihai ürün cümleleri doğal Hindistan Hintçesi incelemesinden geçer.
