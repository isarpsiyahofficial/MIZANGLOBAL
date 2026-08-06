# MİZAN GLOBAL Bengalce final aday durumu

Bu dosya, otomatik biçimlendirme adımlarından sonra kullanıcı yetkili kesin aday head’ini ve değişmez kabul kapsamını kaydeder.

## Gerçekleştirilen entegrasyon

- Ürün runtime’ı 18 dilden 19 dile çıkarıldı; yeni dil kodu `bn`.
- `bn`, `bn-BD` ve `bn-IN` aynı Bengalce runtime’a normalize edildi.
- 791/791 sabit sistem anahtarı Bengalce değerle tamamlandı.
- Menüler, formlar, doğrulamalar, hata/uyarı/boş durumlar, ayarlar, raporlar, PDF metinleri ve bildirimler Bengalceye alındı.
- 29 dil, 161 ülke ve 154 para birimi için Bengalce görünür katalog adları eklendi.
- BDT, INR ve kayıt bazlı diğer para birimleri; Bengalce rakamlar, Hindistan tipi gruplama ve Gregoryen tarihlerle desteklendi.
- Kullanıcının yazdığı kişi adı, not, kategori ve açıklamalar çevrilmeden korunur.

## Manuel ana dil incelemesi

Aşağıdaki yedi kaynak bölümü dosya düzeyinde yeniden gözden geçirildi ve mekanik cümleleri doğal Bengalceyle değiştirildi:

- Çekirdek uygulama ve ilk kurulum metinleri
- Ana ekran, giderler ve gelir yönetimi
- Borç, banka, fatura, abonelik, kira, taksit ve ödeme kayıtları
- Ayarlar, bildirimler, CSV yedekleme ve geri yükleme
- Doğrulama, hata ve veri güvenliği metinleri
- Rapor, grafik açıklaması ve PDF metinleri
- Dinamik sayı, gün, ay, ödeme, gecikme ve kullanıcı kapsamı cümleleri

Aşağıdaki kavramlar birbirinden ayrı ve bağlayıcıdır:

- Kalan ödeme yükü: `অবশিষ্ট পরিশোধের দায়`
- Gecikmiş ödeme yükü: `মেয়াদোত্তীর্ণ পরিশোধের দায়`
- Yaklaşan ödeme yükü: `আসন্ন পরিশোধের দায়`
- Yıkıcı işlem onayı: `আমি নিশ্চিত করছি`
- CSV yedek birleştirme: `CSV ব্যাকআপ একত্র করুন`
- Dakik alarm izni: `সঠিক সময়ের অ্যালার্মের অনুমতি`

Rapor ve PDF metinleri; mekanik İngilizce kalıplar, `payment`, `report`, `overdue`, `breakdown`, `merge`, `Payday`, `I CONFIRM` sızıntıları ve belirsiz finans terimleri açısından yeniden yazıldı ve yasaklı kalıp denetimine bağlandı.

## Final kabul kapıları

Aynı kesin head üzerinde aşağıdaki kapıların tamamı geçmeden PR ürün dalına alınamaz:

1. Bengalce ana dil, Unicode/NFC, görünür dil saflığı, runtime, katalog, rapor, PDF, bildirim ve responsive testleri; ayrıca önceki 18 dilin doğrulayıcıları.
2. Bütün Flutter test dosylarının izole regresyonu ve görsel baseline karşılaştırması.
3. Universal, ARM64, ARMv7 ve x86_64 release APK üretimi; kesin bayt/SHA-256 raporu ve temiz kaynak ağacı.

Otomatik biçimlendirme ve test düzeltmelerinden sonraki aday kaynak: `c171120925dea7d2c44980007e6f8ed81f9073c5`.

Bu commit kullanıcı yetkili final doğrulama koşularını tek kesin head üzerinde başlatır. Final etiketi yalnız üç kapı başarıyla tamamlanıp test edilen head ürün dalına birleştirildiğinde verilecektir.
