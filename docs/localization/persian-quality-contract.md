# MİZAN GLOBAL — Farsça (`fa-IR`) bağlayıcı kalite sözleşmesi

Bu belge, Arapça entegrasyonundan sonra gelen Farsça ürün dilinin kabul koşullarını tanımlar. Farsça çalışma Arapça metinlerin mekanik dönüştürülmesi değildir; İran’da kullanılan doğal, sade ve finansal bağlamı doğru Farsça ile bağımsız hazırlanır.

## 1. Kapsam ve etkinleştirme kilidi

- Kararlı Türkçe anahtar kümesindeki 791/791 sabit sistem metni Farsça karşılığa sahip olmadan `fa` runtime etkinleştirilemez.
- `fa`, `fa-IR`, `fa_IR` ve diğer güvenli bölgesel etiketler yalnız tam kabul kapılarından sonra `fa` olarak normalize edilir.
- Dil seçicisinde Farsça, 791 metin, dinamik cümleler, kataloglar, RTL, biçimlendiriciler, rapor/PDF, bildirim ve responsive testleri geçmeden seçilebilir hâle getirilemez.
- Kullanıcı tarafından yazılan kişi, banka, başlık, açıklama, not, IBAN, telefon, dosya adı ve özel bildirim metni çevrilmez veya kalıcı veride değiştirilmez.

## 2. Dil çeşidi ve üslup

- Hedef dil İran odaklı, anlaşılır ve nötr Modern Farsçadır.
- Resmî fakat ağır bürokratik olmayan ürün dili kullanılır.
- Arapça cümle yapısı, Urduca kelimeler, Türkçe veya İngilizce arayüz kalıntıları kabul edilmez.
- Kullanıcıya gereksiz cinsiyet ataması yapılmaz.
- Düğmeler kısa ve eylem odaklıdır: `ذخیره` (Kaydet), `حذف` (Sil), `ویرایش` (Düzenle), `ادامه` (Devam et), `انصراف` (Vazgeç).
- Finansal bağlamda anlam ayrımı korunur: borç `بدهی`, ödeme `پرداخت`, gider `هزینه`, gelir `درآمد`, kalan bakiye `مانده`, vade `سررسید`, gecikmiş `معوق` veya bağlama göre `از سررسید گذشته`.

## 3. Farsça karakter saflığı

- Farsça metinde Farsça `ی` (U+06CC) ve `ک` (U+06A9) kullanılır.
- Arapça `ي` (U+064A), `ى` (U+0649) ve `ك` (U+0643) sistem metinlerinde yasaktır; yalnız değişmeden korunan kullanıcı verisi istisnadır.
- Urduca/Pehlevi’ye özgü `ے`, `ہ`, `ھ`, `ں`, `ٹ`, `ڈ`, `ڑ` gibi karakterler sistem metnine karışamaz.
- İbranice karakterler ve başka ürün dillerine ait görünür metinler kabul edilmez.
- ZWNJ (U+200C) yalnız doğru Farsça birleşiklerde kullanılır: `می‌شود`, `پرداخت‌ها`, `یادآوری‌ها`. Rastgele veya satır başında kullanılamaz.
- Görünmez bidi kontrol karakterleri kaynak dosyaya literal olarak yazılmaz; gerektiğinde yalnız `\u2066`, `\u2068`, `\u2069` kaçışları kullanılır.

## 4. RTL ve bidi güvenliği

- Uygulama kabuğu `TextDirection.rtl` ile çalışır; widget listeleri elle ters çevrilmez.
- ISO dil/ülke/para birimi kodu, IBAN, telefon, tarih-saat, kimlik, dosya adı ve Latin kullanıcı metni LTR/FSI izolasyonuyla gösterilir.
- Bidi izolasyonu yalnız görünür çıktı katmanında uygulanır; depolanan kullanıcı metninin byte içeriği değişmez.
- Noktalama işaretleri, para kodları ve sayılar RTL içinde yanlış tarafa sıçramamalıdır.
- PDF ve paylaşım metinleri de aynı bidi korumasını kullanır.

## 5. Sayı, para ve tarih

- Farsça rakamlar `۰۱۲۳۴۵۶۷۸۹` görünür çıktıda desteklenir.
- Girdi ayrıştırıcısı Batı rakamlarını, Farsça rakamları ve güvenli biçimde Arapça rakamları kabul eder; depolama sayısal değer olarak kalır.
- Farsça ondalık ve binlik işaretleri güvenli biçimde desteklenir; para hesaplamasında kuruş/ondalık kaybı olamaz.
- IRR seçildiğinde resmî para birimi `ریال` veya bağlama göre bidi güvenli `IRR` gösterilir. Uygulama otomatik olarak tümen dönüşümü yapmaz; tümen ayrı ürün özelliği olmadan varsayılmaz.
- Diğer para birimleri ISO koduyla açıkça ayrılır; aynı sembole güvenilmez.
- Tarih motoru mevcut Gregoryen takvim davranışını korur. Farsça dil seçimi tek başına Şemsi/Jalali takvime geçiş yapmaz.
- Ay ve gün adları Farsçalaştırılır; kayıtların gerçek `DateTime` değerleri ve vade hesabı değişmez.

## 6. Dinamik dilbilgisi

- Farsçada sayıdan sonra isim çoğunlukla tekil kalır; Türkçe veya Arapça çoğul kalıbı mekanik uygulanmaz.
- CLDR kardinal kapsamı `one/other` olsa da ürün cümleleri sıfır, bir ve diğer sayılar için doğal bağlamla ayrı test edilir.
- `۰ روز`, `۱ روز`, `۲ روز`, `۱۱ روز`, `۱۰۲ روز`; kayıt, ödeme, gider, ay, kişi ve bağlantı sayıları ayrı doğrulanır.
- `یک پرداخت`, `۲ پرداخت`, `هیچ پرداختی` gibi yapılar cümle bağlamına göre kurulmalıdır.
- Kalan gün, gecikme, açık kayıt, yedek birleştirme ve Android planlama hata cümleleri bağımsız dinamik kalıplarla üretilir.

## 7. Bağlamlı ürün terminolojisi

Aşağıdaki kavramlar ayrı tutulur:

- banka borcu: `بدهی بانکی`
- kişisel/kurumsal borç: `بدهی شخصی / سازمانی`
- fatura/utility bill: `قبض`
- subscription: `اشتراک`
- rent/installment: `اجاره / قسط`
- expense: `هزینه`
- income: `درآمد`
- payment history: `سابقه پرداخت‌ها`
- remaining payment burden: `تعهدات پرداخت باقی‌مانده`
- overdue payment: `پرداخت معوق`
- due date: `تاریخ سررسید`
- reminder: `یادآوری`
- notification permission: `مجوز اعلان‌ها`
- exact alarm permission: `مجوز زمان‌بندی دقیق`
- backup: `نسخه پشتیبان`
- merge backup: `ادغام نسخه پشتیبان`
- report: `گزارش`
- settings: `تنظیمات`

## 8. Veri, rapor ve bildirim bütünlüğü

- Dil değişimi kişi, borç, fatura, abonelik, kira, taksit, ödeme, gelir, gider, not veya bildirim saatini değiştiremez.
- Raporlarda para birimleri birleştirilmez; mevcut çoklu para birimi ayrımı korunur.
- Ekran ve PDF dönem/kişi filtreleri birebir aynı sonucu üretir.
- Bildirim metinleri gerçek Android davranışını açıklar: dakik alarm izni varsa `exactAllowWhileIdle`, yoksa yaklaşık planlama `inexactAllowWhileIdle` ile devam eder.
- Bildirim planlama ödeme, gider veya geçmiş kaydı oluşturamaz.
- CSV dışa aktarma, geri yükleme ve birleştirme ilişkileri ve kullanıcı metnini korur.

## 9. Zorunlu kabul kapıları

Farsça tamamlandı sayılmadan önce aşağıdakilerin tamamı geçer:

1. 791/791 statik anahtar ve anadil saflığı.
2. Dinamik sayı/cümle, Farsça karakter ve ZWNJ denetimi.
3. RTL/bidi izolasyonu ve kullanıcı verisinin byte düzeyinde korunması.
4. 29 dil, 161 ülke ve 154 para birimi Farsça katalog adları ve arama aliasları.
5. Farsça sayı, para, tarih ve Gregoryen takvim regresyonları.
6. Ana sayfa, kayıtlar, giderler, raporlar, PDF, ayarlar, bildirim ve CSV uçtan uca testleri.
7. 320×568 / 1,4× ve 412×915 / 2,0× RTL responsive testleri.
8. Önceki bütün diller ile gecikme günü ve Android bildirim düzeltmeleri.
9. Bütün test dosyaları ve görsel golden baseline.
10. Universal, ARM64, ARMv7 ve x86_64 release APK’ları, byte ve SHA-256 raporu.
11. Geçici entegrasyon araçları kaldırılmış ve çalışma ağacı temiz kesin head.
