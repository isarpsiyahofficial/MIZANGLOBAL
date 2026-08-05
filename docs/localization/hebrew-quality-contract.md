# MİZAN GLOBAL — İbranice (`he-IL`) bağlayıcı kalite sözleşmesi

Bu belge, Farsça entegrasyonundan sonra gelen İbranice ürün dilinin kabul koşullarını tanımlar. Çalışma; İngilizce, Arapça veya Farsça metinlerin sözcük sözcük dönüştürülmesi değildir. İsrail’de kullanılan doğal, sade ve finansal bağlamı doğru Modern İbranice ile bağımsız hazırlanır.

## 1. Kapsam ve etkinleştirme kilidi

- Kararlı Türkçe anahtar kümesindeki 791/791 sabit sistem metni İbranice karşılığa sahip olmadan `he` runtime etkinleştirilemez.
- `he`, `he-IL`, `he_IL` ve eski uyumluluk etiketi `iw` yalnız tam kabul kapılarından sonra güvenli biçimde `he` olarak normalize edilir.
- Dil seçicisinde İbranice; 791 metin, dinamik cümleler, kataloglar, RTL, biçimlendiriciler, rapor/PDF, bildirim ve responsive testleri geçmeden seçilebilir hâle getirilemez.
- Kullanıcı tarafından yazılan kişi, banka, başlık, açıklama, not, IBAN, telefon, dosya adı ve özel bildirim metni çevrilmez veya kalıcı veride değiştirilmez.
- Farsça dâhil önceki 16 dilin runtime, veri, rapor, bildirim ve görsel davranışı korunur.

## 2. Dil çeşidi ve ürün üslubu

- Hedef dil İsrail odaklı, anlaşılır ve nötr Modern İbranicedir.
- Resmî fakat ağır hukuk/bürokrasi dili olmayan kısa ürün cümleleri kullanılır.
- İngilizce arayüz kalıntıları, mekanik Arapça/Farsça cümle yapısı, Yidişçe ürün dili veya gereksiz transliterasyon kabul edilmez.
- İbranice doğal olarak cinsiyet işaretleyebildiği için kullanıcıya gereksiz erkek/kadın cinsiyeti atanmaz; mümkün olduğunda nötr isim yapıları ve kısa eylem etiketleri kullanılır.
- Düğmeler kısa ve eylem odaklıdır: `שמירה` (Kaydet), `מחיקה` (Sil), `עריכה` (Düzenle), `המשך` (Devam et), `ביטול` (Vazgeç).
- Finansal anlam ayrımı korunur: borç `חוב`, ödeme `תשלום`, gider `הוצאה`, gelir `הכנסה`, bakiye `יתרה`, vade tarihi `מועד פירעון`, gecikmiş `באיחור` veya bağlama göre `עבר מועד הפירעון`.

## 3. İbranice yazı ve görünür dil saflığı

- Sistem metinleri İbranice harflerle yazılır; Latin metin yalnız ISO kodu, marka, dosya biçimi veya teknik zorunluluk olduğunda kullanılır.
- Arapça/Farsça/Urduca karakterler, başka ürün dillerinden görünür kelimeler ve Türkçe arayüz kalıntıları kabul edilmez.
- Nikud/ünlü işaretleri günlük ürün arayüzünde kullanılmaz; yalnız kaçınılmaz dilsel gerekçeyle ve anadil incelemesiyle eklenebilir.
- Geresh (`׳`) ve gershayim (`״`) yalnız doğru kısaltma veya sayı bağlamında kullanılır; ASCII tek/çift tırnakla rastgele karıştırılmaz.
- Kaynak dosyalarda literal bidi kontrol karakterleri yasaktır; gerektiğinde yalnız görünür çıktı katmanında `\u2066`, `\u2067`, `\u2068`, `\u2069` kaçışları kullanılır.
- İbranice ürün metni NFC olarak kararlı kalır; görünmez karakter, sıfır genişlikli boşluk veya yön işaretiyle arama/karşılaştırma bozulamaz.

## 4. RTL ve bidi güvenliği

- Uygulama kabuğu `TextDirection.rtl` ile çalışır; widget listeleri veya veri koleksiyonları elle ters çevrilmez.
- ISO dil/ülke/para birimi kodu, IBAN, telefon, tarih-saat, kimlik, dosya adı, yüzde ve Latin kullanıcı metni LTR/FSI izolasyonuyla gösterilir.
- Bidi izolasyonu yalnız görünür çıktı katmanında uygulanır; depolanan kullanıcı metninin byte içeriği değişmez.
- Noktalama, eksi işareti, ondalık değer, para kodu ve tarih parçaları RTL içinde yanlış tarafa sıçramamalıdır.
- PDF, paylaşım metni, CSV önizlemesi, bildirim ve rapor başlıkları da aynı bidi korumasını kullanır.

## 5. Sayı, para ve tarih

- Görünür ürün sayıları İsrail İbranicesinde yaygın Batı rakamlarıyla (`0–9`) gösterilir; İbranice harflerle sayı yazımı varsayılan yapılmaz.
- Girdi ayrıştırıcısı mevcut Batı, Arapça ve Farsça rakam desteğini kaybetmez; depolama sayısal değer olarak kalır.
- Ondalık ve binlik ayrımı locale davranışına göre uygulanır; para hesaplamasında agorot/ondalık kaybı olamaz.
- ILS seçildiğinde `₪` ve/veya bidi güvenli `ILS` bağlama göre doğru yerde gösterilir. Aynı sembole sahip varsayımlar yapılmaz; raporlar para birimlerini birleştirmez.
- Tarih motoru mevcut Gregoryen takvim davranışını korur. İbranice dil seçimi tek başına İbrani takvimine geçiş yapmaz.
- Ay ve gün adları İbraniceleştirilir; kayıtların gerçek `DateTime` değerleri, vade hesabı, gecikme günü ve bildirim planı değişmez.
- Saat gösterimi İsrail locale davranışıyla test edilir; depolanan saat/dakika ve zaman dilimi mantığına dokunulmaz.

## 6. Dinamik dilbilgisi ve sayılar

- Güncel Unicode CLDR kardinal kapsamındaki `one`, `two`, `other` kategorileri uygulanır; özellikle 1 ve 2 için doğal tekil/ikili yapılar mekanik çoğuldan ayrılır.
- `0`, `1`, `2`, `3`, `11`, `20`, `21`, `100` değerleri gün, kayıt, ödeme, gider, ay, kişi ve bağlantı bağlamlarında ayrı test edilir.
- İbranicedeki ikili biçimler yalnız doğal oldukları isimlerde kullanılır; her `2` değeri körlemesine ikili kalıba çevrilmez.
- Sayı ve isim sırası, eril/dişil sayı uyumu ve belirli artikel ürün cümlesinin bağlamına göre anadil incelemesinden geçer.
- Kalan gün, gecikme, açık kayıt, yedek birleştirme ve Android planlama hata cümleleri bağımsız dinamik kalıplarla üretilir.
- Ordinal ifadeler ve ayın günü kalıpları Türkçe ek mantığından türetilmez.

## 7. Bağlamlı ürün terminolojisi

Aşağıdaki kavramlar ayrı tutulur:

- banka borcu: `חוב בנקאי`
- kişisel/kurumsal borç: `חוב אישי / חוב עסקי`
- fatura/utility bill: `חשבון`
- subscription: `מנוי`
- rent/installment: `שכר דירה / תשלום בתשלומים`
- expense: `הוצאה`
- income: `הכנסה`
- payment history: `היסטוריית תשלומים`
- remaining payment burden: `התחייבויות תשלום שנותרו`
- overdue payment: `תשלום באיחור`
- due date: `מועד פירעון`
- reminder: `תזכורת`
- notification permission: `הרשאת התראות`
- exact alarm permission: `הרשאה לתזמון מדויק`
- backup: `גיבוי`
- merge backup: `מיזוג גיבוי`
- report: `דוח`
- settings: `הגדרות`

## 8. Veri, rapor ve bildirim bütünlüğü

- Dil değişimi kişi, borç, fatura, abonelik, kira, taksit, ödeme, gelir, gider, not veya bildirim saatini değiştiremez.
- Raporlarda para birimleri birleştirilmez; mevcut çoklu para birimi ayrımı korunur.
- Ekran ve PDF dönem/kişi filtreleri birebir aynı sonucu üretir.
- Bildirim metinleri gerçek Android davranışını açıklar: dakik alarm izni varsa `exactAllowWhileIdle`, yoksa yaklaşık planlama `inexactAllowWhileIdle` ile devam eder.
- Bildirim planlama ödeme, gider veya geçmiş kaydı oluşturamaz.
- CSV dışa aktarma, geri yükleme ve birleştirme ilişkileri ile kullanıcı metnini byte düzeyinde korur.

## 9. Zorunlu kabul kapıları

İbranice tamamlandı sayılmadan önce aşağıdakilerin tamamı geçer:

1. 791/791 statik anahtar ve anadil saflığı.
2. Dinamik `one/two/other` cümleleri, sayı-cinsiyet uyumu ve ikili yapı denetimi.
3. RTL/bidi izolasyonu ve kullanıcı verisinin byte düzeyinde korunması.
4. 29 dil, 161 ülke ve 154 para birimi için İbranice katalog adları ve arama aliasları.
5. İbranice sayı, ILS, tarih-saat ve Gregoryen takvim regresyonları.
6. Ana sayfa, kayıtlar, giderler, raporlar, PDF, ayarlar, bildirim ve CSV uçtan uca testleri.
7. 320×568 / 1,4× ve 412×915 / 2,0× RTL responsive testleri.
8. Önceki bütün diller ile gecikme günü ve Android bildirim düzeltmeleri.
9. Bütün test dosyaları ve görsel golden baseline.
10. Universal, ARM64, ARMv7 ve x86_64 release APK’ları, byte ve SHA-256 raporu.
11. Geçici entegrasyon araçları kaldırılmış ve çalışma ağacı temiz kesin head.

## 10. Normatif veri kaynağı

- Çoğul kategori ve locale biçimleri Unicode CLDR’nin güncel `he` verisiyle doğrulanır.
- `iw`, yalnız eski uyumluluk aliasıdır; ürünün kanonik dil kodu `he`, bölgesel etiketi `he-IL` olur.
- CLDR verisi dil kalıbını belirler; nihai ürün cümleleri yine doğal Modern İbranice anadil incelemesinden geçer.
