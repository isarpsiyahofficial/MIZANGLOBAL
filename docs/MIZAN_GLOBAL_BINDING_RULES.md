# MİZAN GLOBAL — Bağlayıcı Proje Kuralları

Bu kurallar MİZAN GLOBAL geliştirmesinin değiştirilemez kabul ölçütleridir. Bir işlem bu kurallardan birini ihlal ediyorsa tamamlanmış sayılmaz.

## Kural 1 — Mevcut yapı korunacak

Globale geçiş sırasında MİZAN’ın çalışan mevcut yapısı hiçbir şekilde bozulmayacak.

## Kural 2 — Türkiye düzeni aynen korunacak

Türkiye seçildiğinde mevcut MİZAN’ın Türkiye düzeni, hazır borç türleri, ekran akışları, hesaplamaları ve davranışları aynen korunacak. Türkiye dışındaki bir ülke veya borç bölgesi seçildiğinde Türkiye’ye özgü `Kredi Kartı`, `KMH` ve benzeri hazır adlandırmalar yerine kullanıcı borcun adını veya niteliğini kendi diliyle serbest metin olarak yazabilecek. Bu ayrım gereksiz ülke katalogları veya karmaşık özel akışlarla büyütülmeyecek.

## Kural 3 — Globalleştirme önce, monetizasyon en son

Önce globalleştirme eksiksiz tamamlanacak. Reklam, Pro, monetizasyon, lisans, promosyon, restore ve bunlarla ilgili hukuk metinleri en son aşamada; kullanıcı tarafından sağlanacak hâlihazırda kurulmuş program kaynaklarından MİZAN’a kontrollü biçimde uyarlanacak.

## Kural 4 — Ana dil seviyesinde çeviri

Desteklenen her dil ana dil seviyesinde hazırlanacak ve beş ayrı kalite kontrolünden geçirilmeden tamamlanmış kabul edilmeyecek.

## Kural 5 — Sözleşme ve hukuk metinleri ayrı son aşama

Sözleşme, hukuki bilgilendirme ve reklamla ilgili metinler monetizasyon aşamasında sağlanacak programdan uyarlanacak. Bu metinlerin çift dil kullanımı ayrıca kullanıcı tarafından tarif edilecek.

## Kural 6 — Testler ayrı ayrı yapılacak

Her test ayrı yürütülecek. Responsive düzen, SafeArea, küçük/büyük telefon, tablet, yatay/dikey ekran, uzun metin, font ölçekleme ve RTL kontrolleri korunacak. Taşma, kayma, üst üste binme veya görünmez alan kabul edilmeyecek.

## Kural 7 — İlk teknik iş para birimi entegrasyonu

Global uyarlamadaki ilk teknik iş, 466 maddelik şartnamedeki bütün para birimi gereksinimlerinin ayrıntılı ve güvenli biçimde uygulanmasıdır.

## Kural 8 — 466 maddenin tamamı uygulanacak

Nihai teslimde 466 maddenin 466’sı da eksiksiz ve doğru uygulanmış olacak. Monetizasyonla ilgili maddeler belirlenen sıra gereği son aşamada tamamlanacak.

## Kural 9 — Sürekli şartname denetimi

466 madde çalışma boyunca düzenli aralıklarla tekrar karşılaştırılacak. Atlanan, yüzeysel kalan, hatalı bağlanan veya sağlıksız çalışan her madde düzeltilmeden ilerleme tamamlanmış sayılmayacak.

## Kural 10 — Yüzeysel uygulama yasak

Hiçbir madde yalnız ekranda görünür hâle getirilerek tamamlanmış kabul edilmeyecek. Veri modeli, kayıt, düzenleme, silme, içe/dışa aktarma, raporlama, hesaplama, hata durumu, responsive davranış ve geriye dönük uyumluluk ayrıntılı işlenecek.

## Kural 11 — Mevcut özellik yeniden yazılıp bozulmayacak

466 maddenin önemli bir kısmı mevcut MİZAN’da zaten çalışmaktadır. Önce mevcut karşılığı tespit ve doğrulama yapılacak. Doğru çalışan özellik gereksiz yere yeniden yazılmayacak, değiştirilmayacak veya eksiltilmeyecek. Global uyarlama için yalnız zorunlu ve kontrollü eklemeler yapılacak; eski davranışlar regresyon testleriyle korunacak.

## Kural 12 — Diller arasında kayma kesinlikle olmayacak

Seçilen uygulama dili, bütün uygulamada tek ve tutarlı kullanıcı arayüzü dili olacaktır. Ana ekran, kayıt formları, ayarlar, raporlar, PDF/dışa aktarma, hata mesajları, doğrulamalar, bildirimler, durum etiketleri, filtreler, grafik açıklamaları, erişilebilirlik metinleri ve bütün diğer kullanıcıya görünen sabit metinler aynı seçili dile bağlı çalışacaktır.

- Türkçe seçen kullanıcıya başka bir arayüz dilinin sabit metni gösterilmeyecek.
- İngilizce seçen kullanıcıya Türkçe, Arapça, Çince veya başka bir dilin sabit metni gösterilmeyecek.
- Arapça seçen kullanıcıya İngilizce, Türkçe, Çince veya başka bir dilin sabit metni gösterilmeyecek.
- Eksik çeviri nedeniyle farklı dillerin aynı ekranda karışması kabul edilmeyecek.
- Kullanıcının kendi yazdığı banka, kurum, kişi, borç adı ve not gibi veriler otomatik çevrilmeyecek; kullanıcı verisi olduğu hâliyle korunacak.
- Sözleşme ve hukuki bilgilendirmede kullanılacak özel çift dil düzeni yalnız son aşamada kullanıcı tarafından ayrıca tarif edildiğinde uygulanacak.

Dil izolasyonu için her desteklenen dil; ekran, rapor, PDF, bildirim, boş durum, hata durumu ve RTL/LTR yönü açısından ayrı test edilecek.

## Kural 12.1 — Ülke ve dönem bilgileri araştırılarak, kaynağı doğrulanarak uygulanacak

Ülke, bölge, para birimi, sayı-tarih biçimi, hafta başlangıcı, ödeme sıklığı, raporlama dönemi ve borç dönemiyle ilgili hiçbir bilgi yüzeysel bir veri listesinden otomatik olarak doğru kabul edilmeyecek.

- `249 ülke` ifadesi kullanılmayacak; ISO listelerinde ülke kodları yanında bağımlı bölgeler ve özel coğrafi alanlar da bulunduğu için kullanıcıya sunulacak kapsam, ülke/bölge statüsü belirtilerek yetkili kaynaklardan teyit edilecek.
- Her ülke veya desteklenen borç bölgesi için gerekli bilgiler güvenilir ve mümkün olduğunda resmî kaynaklardan araştırılacak.
- Bir kaynaktan alınan veri ikinci bir güvenilir kaynakla karşılaştırılacak; çelişki varsa çözülmeden uygulamaya alınmayacak.
- Günlük, haftalık, iki haftalık, aylık, dört haftalık, üç aylık, altı aylık, yıllık ve kullanıcı tanımlı dönemler veri modelinde açık biçimde desteklenecek.
- Gecikme hesabı sabit olarak `30 gün = 1 dönem` varsayımına bağlanmayacak. İlgili kaydın seçili sıklığı, gerçek vade tarihi ve kullanıcı tarafından tanımlanan dönem esas alınacak.
- Ülkeye göre farklı olabilen hafta başlangıcı, tarih biçimi, sayı ayırıcıları ve para gösterimi yerel kurallara uygun olacak.
- Ülke seçimi, kullanıcının uygulama dilini veya para birimini zorla değiştirmeyecek.
- Bir ülke için tek ve zorunlu ödeme periyodu varsayılmayacak; ülke araştırması uygun varsayılanları veya önerileri belirleyebilir, ancak kullanıcının gerçek sözleşmesi ve seçtiği dönem nihai hesaplama kaynağı olacaktır.
- Raporlama, seçilen dönem türü ve gerçek işlem tarihleri üzerinden doğru çalışacak; farklı sıklıklar aylık düzene zorlanmayacak.
- Her ülke/bölge veri kaydında kaynak, doğrulama tarihi ve manuel kontrol durumu sürümlü olarak tutulacak.

## Uygulama kabulü

Bu kuralların ihlal edildiği bir branch, commit, APK veya rapor final kabul edilmeyecek. Her değişiklik kaynak karşılaştırması, şartname karşılaştırması, regresyon kontrolü ve beş ayrı doğrulama turundan geçecektir.
