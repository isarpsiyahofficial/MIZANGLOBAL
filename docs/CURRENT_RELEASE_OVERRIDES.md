# MİZAN GLOBAL — Güncel Release Kararları

Bu belge, daha eski şartname ve kontrol dokümanlarıyla çelişen son kullanıcı kararlarının öncelik sırasını sabitler. Tarihsel şartnameler silinmez; ancak daha yeni ve açık bir kullanıcı kararıyla değiştirilen maddeler güncel release için bağlayıcı değildir.

## Talimat önceliği

1. En yeni açık kullanıcı talimatı, aynı konuda daha eski şartname, rapor, test adı veya geliştirme kararından üstündür.
2. Çalışan mevcut yapı gereksiz yere yeniden yazılmaz, geri alınmaz veya geniş kapsamlı rollback ile değiştirilmez.
3. Bir düzeltme yalnız ilgili kapsamı değiştirir; bağımsız çalışan özellikler korunur ve regresyon testleriyle doğrulanır.
4. Eski bir belge veya test güncel kararla çelişiyorsa uygulama eski davranışa döndürülmez; belge/test güncel karara uyarlanır.

## Bildirimler — bu release için ertelendi

- Mevcut shipping release bildirim özelliği içermez.
- Android bildirim izni, bildirim receiver'ı, yerel bildirim paketi, runtime bildirim servisi, PRO bildirim koordinatörü ve kullanıcıya açık bildirim ayarları shipping yapıda bulunmayacaktır.
- Eski şartnamelerdeki bildirim maddeleri tarihsel gereksinim olarak korunur fakat bu release için uygulanmaz.
- Veri uyumluluğunu veya ileride yeniden ekleme ihtimalini koruyan pasif model/hesaplama alanları, shipping runtime'a bağlı olmadıkları sürece sırf isimleri nedeniyle silinmez.
- Bildirimler yalnız kullanıcı daha sonra açıkça yeniden istediğinde ayrı bir değişiklik olarak ele alınabilir.

## Sunucusuz monetizasyon ve promosyon

- Uygulamanın yayıncı tarafından işletilen monetizasyon/promo Worker, D1 veya özel backend ihtiyacı yoktur.
- Google Play satın alma ve Google Mobile Ads sağlayıcı entegrasyonları bu sunucusuz kararın istisnası değil, doğrudan platform entegrasyonlarıdır.
- Promosyon doğrulaması uygulama içinde yerel olarak yürür; mevcut yerel fingerprint/HMAC yaklaşımı korunur.
- Eski şartnamelerde promosyon için sunucu zorunluluğu getiren maddeler güncel mimariyi geri döndürmez.

## Güncel PRO / ücretsiz davranışı

- Kalıcı PRO tek seferlik `premium_lifetime` Google Play ürünüdür; abonelik yoktur.
- Görünür restore düğmesi yoktur; uygun olduğunda Google Play sahipliği sessiz biçimde senkronize edilir.
- PRO kullanıcı uygulamayı çevrimdışı kullanabilir ve uygulama reklamları PRO için bastırılır.
- Ücretsiz kullanım gerçek internet erişimine bağlıdır.
- Gerçek PDF dışa aktarma yalnız aktif PRO için açıktır; ücretsiz kullanıcı örnek PDF önizlemesini görebilir.
- Ödüllü reklam akışı aynı ödül gününde 3 tamamlanmış ödül ile 24 saat geçici PRO verir.
- Mevcut yerel promosyon kampanyalarının 7 gün ve 3 gün geçici PRO süreleri korunur.

## Globalizasyon ve veri bütünlüğü

- Desteklenen görünür kullanıcı dili sayısı 29'dur.
- Her dil diğer 28 dile karşı yönlü izolasyonla kontrol edilir; sabit sistem metinlerinde bir dilden diğerine sızıntı kabul edilmez.
- Kullanıcının yazdığı ad, kurum, banka, not ve benzeri veriler otomatik çevrilmez.
- Kayıt bazlı para birimleri birbirinden bağımsız saklanır; farklı para birimleri kur dönüşümü yokken tek toplam gibi birleştirilmez.
- Dil, ülke/borç bölgesi ve varsayılan para birimi birbirinden bağımsız kalır.

## Kaynak hijyeni

- Shipping kaynakta veya proje metin dosyalarında yapay zekâ aracı/model izi, üretim kaynağında açıklama amaçlı `//` satırları ve geçici onarım workflow'ları bırakılmaz.
- Test/CI kapıları bu kararların yeniden bozulmasını engelleyecek şekilde korunur.

## Final kabul

Bir commit ancak aynı exact SHA üzerinde format, statik analiz, tam Flutter regresyonu, 29 dil derin testleri, 29×28 dil izolasyonu, monetizasyon/PRO/PDF/backup/çoklu para birimi sözleşmeleri, kaynak hijyeni ve Android APK build kapıları başarılıysa final aday sayılır. PR, bu kontroller bitmeden merge edilmiş kabul edilmez.
