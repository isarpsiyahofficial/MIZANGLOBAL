# MİZAN GLOBAL Bengalce final aday durumu

Bu dosya, otomatik biçimlendirme ve entegrasyon temizliğinden sonra kullanıcı yetkili kesin aday head’ini ve değişmez kabul kapsamını kaydeder.

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

## Entegrasyon temizliği

- Para biçimleyicisindeki yinelenen Bengalce çalışma blokları kaldırıldı.
- Tarih ve ondalık biçimleyicisindeki yinelenen Bengalce koşulları kaldırıldı.
- BDT ayrıştırıcısındaki yinelenen sembol/kod temizliği tek kurala indirildi.
- Katalog arama dizilerindeki yinelenen Bengalce alanları kaldırıldı.
- Temizlik sonrasında statik analiz ve Bengalce smoke testleri yeniden geçti.

## Final kabul kapıları

Aynı kesin head üzerinde aşağıdaki kapıların tamamı geçmeden PR ürün dalına alınamaz:

1. Bengalce ana dil, Unicode/NFC, görünür dil saflığı, runtime, katalog, rapor, PDF, bildirim ve responsive testleri; ayrıca önceki 18 dilin doğrulayıcıları.
2. Bütün Flutter test dosyalarının izole regresyonu ve görsel baseline karşılaştırması.
3. Universal, ARM64, ARMv7 ve x86_64 release APK üretimi; kesin bayt/SHA-256 raporu ve temiz kaynak ağacı.

Temizlenmiş aday kaynak: `1813f11b3d47560904e0fa23887f518f54a4891b`.

Bu kullanıcı yetkili commit, üç final kapısını tek kesin head üzerinde yeniden başlatır. Final etiketi yalnız üç kapı başarıyla tamamlanıp test edilen head ürün dalına birleştirildiğinde verilecektir.
