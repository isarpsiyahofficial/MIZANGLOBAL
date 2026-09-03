# LEFFERION PRIME – MİZAN

MİZAN; banka borçları, kişisel ve kurumsal borçlar, faturalar, abonelikler, kira/taksitler ve günlük giderler için yerel çalışan Flutter Android uygulamasıdır.

## Temel kurallar

- İlk kurulum tamamen boş başlar; örnek kişi, ödeme veya gider oluşturulmaz.
- Banka marka adı ya da logosu hazır gelmez; kullanıcı kendi grup adını yazar.
- Her kayıt kendi benzersiz kimliği, ödeme geçmişi ve notlarıyla saklanır.
- Her kullanıcı işlemi doğrulandıktan sonra cihazdaki yerel dosyaya kaydedilir.
- Ana dosya atomik yazılır ve son sağlam kopya ayrıca korunur.
- Tüm state, ilişkileri korunarak CSV olarak dışa ve içe aktarılabilir.
- Mevcut release bildirim platformu, bildirim izni veya kullanıcı bildirim ayarı içermez.
- Telefon, büyük yazı ve tablet düzenleri otomatik test edilir.
- Daha eski şartname ve kontrol belgeleriyle çelişen güncel release kararları `docs/CURRENT_RELEASE_OVERRIDES.md` dosyasında sabitlenir.

## Ana kayıt grupları

1. Banka Borçları
2. Kişisel ve Kurumsal Borçlar
3. Faturalar
4. Abonelikler
5. Kira ve Taksitler
