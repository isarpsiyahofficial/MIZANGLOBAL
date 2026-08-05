# MİZAN GLOBAL Bengalce final aday durumu

Bu dosya, otomatik yazma adımlarından sonra kullanıcı yetkili kesin aday head’ini ve değişmez kabul kapsamını kaydeder.

## Gerçekleştirilen entegrasyon

- Ürün runtime’ı 18 dilden 19 dile çıkarıldı; yeni dil kodu `bn`.
- `bn`, `bn-BD` ve `bn-IN` aynı Bengalce runtime’a normalize edildi.
- 791/791 sabit sistem anahtarı Bengalce değerle tamamlandı.
- Menüler, formlar, doğrulamalar, hata/uyarı/boş durumlar, ayarlar, raporlar, PDF metinleri ve bildirimler Bengalceye alındı.
- 29 dil, 161 ülke ve 154 para birimi için Bengalce görünür katalog adları eklendi.
- BDT, INR ve kayıt bazlı diğer para birimleri; Bengalce rakamlar, Hindistan tipi gruplama ve Gregoryen tarihlerle desteklendi.
- Kullanıcının yazdığı kişi adı, not, kategori ve açıklamalar çevrilmeden korunur.

## Ana dil ve finansal anlam denetimi

Aşağıdaki kavramlar birbirinden ayrı ve bağlayıcıdır:

- Kalan ödeme yükü: `অবশিষ্ট পরিশোধের দায়`
- Gecikmiş ödeme yükü: `মেয়াদোত্তীর্ণ পরিশোধের দায়`
- Yaklaşan ödeme yükü: `আসন্ন পরিশোধের দায়`
- Destructive confirmation: `আমি নিশ্চিত করছি`
- CSV yedek birleştirme: `CSV ব্যাকআপ একত্র করুন`

Rapor ve PDF metinleri; mekanik İngilizce kalıplar, `payment`, `report`, `overdue`, `breakdown`, `merge`, `I CONFIRM` sızıntıları ve belirsiz finans terimleri açısından yeniden yazıldı ve yasaklı kalıp denetimine bağlandı.

## Final kabul kapıları

Aynı kesin head üzerinde aşağıdaki kapıların tamamı geçmeden PR ürün dalına alınamaz:

1. Bengalce ana dil, Unicode/NFC, görünür dil saflığı, runtime, katalog, rapor, PDF, bildirim ve responsive testleri; ayrıca önceki 18 dilin doğrulayıcıları.
2. Bütün Flutter test dosyalarının izole regresyonu ve görsel baseline karşılaştırması.
3. Universal, ARM64, ARMv7 ve x86_64 release APK üretimi; kesin bayt/SHA-256 raporu ve temiz kaynak ağacı.

Bu kayıt final etiketi değildir. Final etiketi yalnız üç kapı başarıyla tamamlanıp test edilen head ürün dalına birleştirildiğinde verilecektir.
