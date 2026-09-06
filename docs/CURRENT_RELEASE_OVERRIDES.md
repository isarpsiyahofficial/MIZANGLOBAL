# MİZAN GLOBAL — Güncel Release Kararları

Bu belge, daha eski şartname, rapor, PR açıklaması veya test sözleşmesiyle çelişen en güncel bağlayıcı ürün kararlarını sabitler. Çalışan mevcut yapı korunur; eski bir belge güncel kararla çelişiyorsa uygulama eski davranışa döndürülmez, belge veya sözleşme güncel karara uyarlanır.

## Talimat önceliği

1. En yeni açık kullanıcı talimatı aynı konudaki eski kararların önündedir.
2. Çalışan mevcut yapı gereksiz yere yeniden yazılmaz, geniş kapsamlı rollback yapılmaz.
3. Düzeltmeler yalnız kanıtlanmış kapsamı değiştirir; bağımsız çalışan özellikler korunur.
4. Shipping kaynakta geçici onarım workflow'u, AI/provenance notu, gizli signing materyali veya kullanıcıya görünmemesi gereken geliştirme izi bırakılmaz.

## Bildirimler — bu release'te yok

- Shipping release bildirim özelliği içermez.
- Android bildirim izni, receiver, yerel bildirim paketi, runtime bildirim servisi ve kullanıcıya açık bildirim ayarı bulunmaz.
- Bildirimler yalnız daha sonra açıkça yeniden istenirse ayrı bir özellik olarak değerlendirilir.

## Sunucusuz monetizasyon ve promosyon

- Yayıncı tarafından işletilen monetizasyon/promo Worker, D1, özel entitlement API veya billing backend yoktur.
- Google Play Billing ve Google Mobile Ads doğrudan platform/provider entegrasyonlarıdır.
- Promosyon doğrulaması uygulama içinde yerel HMAC-SHA256 fingerprint yaklaşımıyla yürür.
- Güncel shipping tabloda dört geçici kampanya vardır: 7 gün, 3 gün, 7 gün ve 30 gün PRO.
- Kalıcı PRO veren shipping promo kampanyası yoktur.
- Eski ESMANUR veya IBRAHIM permanent promo davranışı güncel release'e ait değildir.

## Güncel PRO / ücretsiz davranışı

- Kalıcı PRO tek seferlik `premium_lifetime` Google Play ürünüdür; abonelik ve otomatik yenileme yoktur.
- Görünür restore düğmesi yoktur; Google Play sahipliği uygun olduğunda sessiz senkronize edilir.
- Kalıcı veya geçici aktif PRO çevrimdışı kullanabilir, gerçek PDF dışa aktarabilir ve uygulama reklamları bastırılır.
- CSV yedek export/import yalnız Kalıcı PRO içindir; geçici PRO CSV yedeğini açmaz.
- Kalıcı PRO kullanıcıya lifetime satın alma alanı gösterilmez.
- Geçici PRO kullanıcısı isterse süre bitmeden `premium_lifetime` satın alabilir.
- Rewarded ve promo teklifleri aktif PRO sırasında üst üste bindirilmez.
- Ücretsiz kullanım gerçek internet erişimine bağlıdır.
- Gerçek PDF dışa aktarma aktif PRO gerektirir; ücretsiz kullanıcı yalnız örnek/önizleme yüzeyini kullanabilir.
- Ödüllü reklam akışında 3 başarılı provider ödülü = 24 saat geçici PRO.
- Full-screen reklam global cooldown değeri 60 saniyedir.
- Davranış tetikleyici eşiği 3 tamamlanmış anlamlı işlemdir ve aynı 60 saniyelik global cooldown'a tabidir.

## Hukuk ve kullanıcı sorumluluğu

- Tam hukuki master belgeler Türkçe ve İngilizcedir; diğer 27 dilde belge adı, okuma/yönlendirme ve kabul arayüzü yerelleştirilir, bağımsız hukuki özet üretilmez.
- Gizlilik Politikası ve Kullanım Koşulları ilk kullanım gate'inde ayrı ayrı okunur/kabul edilir.
- Kalıcı PRO Satın Alma Koşulları yalnız satın alma öncesinde ayrıca okunur ve kabul edilir.
- `Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.` uyarısı bilinçli kullanıcı-sorumluluğu metnidir; form ve PDF yüzeyinden kaldırılmaz.

## Globalizasyon ve veri bütünlüğü

- Görünür kullanıcı dili sayısı 29'dur.
- Her dil diğer 28 dile karşı izolasyon mantığıyla korunur; kullanıcı yazdığı metinler otomatik çevrilmez.
- Dil, ülke/borç bölgesi ve varsayılan para birimi birbirinden bağımsızdır.
- Her finans kaydı kendi para birimini saklar; kur dönüşümü yokken farklı para birimleri tek toplam gibi birleştirilmez.
- PDF/rapor/CSV yüzeylerinde aynı çoklu-para-birimi kimliği korunur.

## Android ve veri güvenliği

- Package ID: `com.lefferionprime.mizanglobal`.
- Shipping manifestte yalnız gerekli ağ izinleri bulunur; bildirim izinleri yoktur.
- Android otomatik cloud/device-transfer backup kapalıdır; kontrollü CSV yedek mekanizmasının dışından finans kayıtları veya entitlement state taşınmaz.
- Production release kapısı targetSdk 36 doğrular.
- Flutter release hattı mevcut çalışan yapı için 3.44.6'ya sabitlenmiştir; sırf daha yeni sürüm çıktı diye riskli toolchain yükseltmesi yapılmaz.
- Production workflow, Play Billing 8 destek ufku aşıldığında eski billing sürümüyle yayın yapılmasını fail-closed olarak engeller.

## CI ve yayın öncesi çalışma kuralı

- Ağır Flutter test/analyze, APK/AAB build ve reklam testleri kullanıcı açıkça yayın/test aşamasını başlatana kadar çalıştırılmaz.
- Kaynak-only statik denetimler, görünür metin/dil taramaları ve sözleşme kontrolleri build/test çalıştırmadan yapılabilir.
- Tüm ağır workflow'lar yalnız `workflow_dispatch` ile manueldir; push/PR ile otomatik başlamaz.
- Production build yalnız gerçek AdMob kimlikleri ve release signing secrets mevcut olduğunda çalışır; Google sample ID veya eksik signing ile production release fail-closed durur.

## Yayın aşamasında dış hesap girdileri

Kod tamamlanmış olsa bile gerçek yayına geçmek için hesap tarafında gerçek AdMob App/Interstitial/Rewarded ID'leri, UMP/privacy ayarları, `app-ads.txt`, release signing secrets, Google Play `premium_lifetime` ürünü, store listing/Data Safety/ads declarations ve kullanılmamış bir versionCode gerekir. Bunlar kaynak kodda açık geliştirme maddesi değil, yayın hesabı girdileridir.
