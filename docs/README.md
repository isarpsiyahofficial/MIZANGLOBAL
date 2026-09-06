# MİZAN documentation authority

Bu klasörde hem güncel release sözleşmeleri hem de projenin önceki aşamalarından kalan tarihsel şartname belgeleri bulunur. Tarihsel dosyalar izlenebilirlik için korunur; **güncel release kararlarını geri alamazlar**.

## Güncel / bağlayıcı belgeler

Aşağıdaki sıra aynı konuda çelişki olduğunda öncelik sırasıdır:

1. `CURRENT_RELEASE_OVERRIDES.md` — en güncel kullanıcı/release kararları; en yüksek doküman önceliği.
2. Gerçek `main` shipping kaynak kodu ve `tools/validate_project.py` statik sözleşmesi.
3. `MONETIZATION_RELEASE_GATE.md` — güncel PRO/reklam/promo/Play/production kapıları.
4. `LEGAL_ACCEPTANCE_ARCHITECTURE.md` — güncel hukuk okuma/kabul ve checkout akışı.
5. `QUALITY_CHECKLIST.md` — açık backlog değil, mevcut source-complete kapanış özeti.
6. `MIZAN_GLOBAL_COUNTRY_SCOPE_V1.md` ve `localization/` — 29 dil/ülke kapsamı için globalizasyon referansları; daha yeni release override ile çelişemez.

## Tarihsel / bağlayıcı olmayan belgeler

Aşağıdaki dosyalar projenin önceki aşamalarındaki şartnameyi ve tasarım kararlarını korur ancak güncel release için doğrudan talimat değildir:

- `MIZAN_GLOBAL_BINDING_RULES.md`
- `REQUIREMENTS_250_PLUS.md`

Bu tarihsel belgelerde bildirimler, eski offline yaklaşımı, eski test/build zamanlaması veya sonradan değiştirilmiş başka maddeler bulunabilir. Böyle bir madde güncel kaynak veya `CURRENT_RELEASE_OVERRIDES.md` ile çelişirse **tarihsel madde uygulanmaz**.

## Güncel kritik karar özeti

- Bildirim subsystem'i shipping release'te yoktur.
- Ücretsiz kullanım gerçek internet gerektirir; aktif PRO offline kullanılabilir.
- Kalıcı PRO `premium_lifetime` tek seferlik üründür; abonelik yoktur.
- Geçici PRO lifetime PRO satın alabilir; kalıcı PRO satın alma CTA'sını görmez.
- PDF aktif PRO, CSV backup ise yalnız Kalıcı PRO içindir.
- Reklam global cooldown 60 saniye, davranış eşiği 3 anlamlı işlemdir.
- 3 başarılı rewarded ödülü 24 saat Temporary PRO verir.
- Shipping promo tablosu yalnız geçici 7/3/7/30 günlük kampanyalar içerir; permanent shipping promo yoktur.
- Monetizasyon/promo için yayıncı Worker/D1/backend yoktur.
- 29 görünür kullanıcı dili korunur; tam hukuki master metinler yalnız Türkçe + İngilizcedir.
- Android otomatik cloud/device-transfer backup kapalıdır.
- Ağır Flutter test/build workflow'ları manuel-only'dir ve kullanıcı yayın/test aşamasını açıkça başlatmadan çalıştırılmaz.

## Repo kapanış durumu

`main` authoritative release ağacıdır. Eski draft PR'lar merge edilmeden kapatılır; tarihsel branch'ler yalnız geri dönüş/izlenebilirlik içindir ve release kaynağı değildir.
