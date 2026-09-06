# MİZAN — Kaynak Kapanış Kontrol Listesi

Bu belge açık geliştirme backlog'u değildir. `main` üzerindeki mevcut source-complete durumun kısa kontrol özetidir. Yayın hesabı girdileri ayrı tutulur.

## Ürün ve veri yapısı

- [x] Banka adları hazır marka listesi olarak gelmez; kullanıcı kendi grup adını yazar.
- [x] Resmî banka logosu/marka temsili shipping UI'a gömülü değildir.
- [x] Finans kayıtları cihazda yerel saklanır ve doğrulanmış yerel yedek akışı korunur.
- [x] Kişi, banka grubu, borç, fatura, abonelik, kira/taksit, gider, gelir, ödeme, not ve kategori modülleri korunur.
- [x] Kısmi/tam ödeme ve kayıt geçmişi mevcut veri modelinde korunur.
- [x] Kayıt bazlı para birimi kimliği korunur; farklı para birimleri kur dönüşümü yokken tek toplamda birleştirilmez.
- [x] Dil, ülke/borç bölgesi ve varsayılan para birimi birbirinden bağımsızdır.

## Globalizasyon ve görünür yüzeyler

- [x] 29 görünür kullanıcı dili katalogda tanımlıdır.
- [x] Kullanıcının yazdığı metinler otomatik çevrilmez.
- [x] Hukuki tam master metinler Türkçe + İngilizcedir; diğer dillerde hukuki özet üretilmez.
- [x] Bilinçli kullanıcı-sorumluluğu uyarısı form ve PDF yüzeyinde korunur.
- [x] Final marka logosu 2048×2048 RGBA master/foreground kaynaklarından responsive ortak widget ile kullanılır.

## PRO, reklam ve satın alma

- [x] Kalıcı PRO ürünü `premium_lifetime`; abonelik/otomatik yenileme yoktur.
- [x] Kalıcı PRO kullanıcıya lifetime satın alma CTA'sı gösterilmez.
- [x] Geçici PRO isterse Kalıcı PRO satın alabilir.
- [x] Aktif PRO'da uygulama reklamları bastırılır ve offline kullanım açıktır.
- [x] Gerçek PDF export aktif PRO gerektirir.
- [x] CSV backup export/import yalnız Kalıcı PRO içindir.
- [x] 3 başarılı rewarded ödülü 24 saat geçici PRO verir.
- [x] Full-screen reklam global cooldown 60 saniye; davranış eşiği 3 anlamlı işlemdir.
- [x] Shipping promo tablosunda yalnız geçici 7/3/7/30 günlük kampanyalar vardır; kalıcı shipping promo yoktur.
- [x] Promo doğrulaması yerel HMAC fingerprint ile yapılır; yayıncı promo backend'i yoktur.

## Android, güvenlik ve repo hijyeni

- [x] Shipping release bildirim özelliği/izni/receiver'ı içermez.
- [x] Android manifest gerekli ağ izinleriyle sınırlıdır.
- [x] Android otomatik cloud/device-transfer backup finans kayıtları ve entitlement state için dışlanmıştır.
- [x] Production release gerçek AdMob ID'leri ve release signing olmadan fail-closed durur.
- [x] Production integrity gate package ID, targetSdk 36, final logo hash ve release imzasını doğrular.
- [x] Ağır CI/build workflow'ları yalnız manuel `workflow_dispatch` ile çalışır.
- [x] Geçici repair/audit workflow'u final tree'de bırakılmaz.
- [x] Açık GitHub PR ve issue bırakılmaz; tarihsel PR'lar merge edilmeden kapalı tutulur.
- [x] AI/ChatGPT/OpenAI provenance notu, plaintext signing materyali ve gereksiz TODO/FIXME backlog'u shipping kaynakta bırakılmaz.

## Yayın hesabı girdileri — kaynak geliştirme maddesi değildir

Gerçek yayına geçildiğinde hesap tarafında AdMob App/Interstitial/Rewarded ID'leri, UMP/privacy ayarları, `app-ads.txt`, GitHub release signing secrets, Play Console `premium_lifetime` ürünü, store listing/Data Safety/ads declarations ve kullanılmamış bir versionCode sağlanmalıdır. Bunlar repository kaynak kodunda kapanmamış geliştirme maddesi olarak değerlendirilmez.
