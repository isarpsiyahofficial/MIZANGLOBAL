# LEFFERION PRIME – MİZAN

MİZAN; banka borçları, kişisel ve kurumsal borçlar, faturalar, abonelikler, kira/taksitler ve günlük giderler için yerel çalışan Flutter Android uygulamasıdır.

## Temel kurallar

- İlk kurulum tamamen boş başlar; örnek kişi, ödeme veya gider oluşturulmaz.
- Banka marka adı ya da logosu hazır gelmez; kullanıcı kendi grup adını yazar.
- Her kayıt kendi benzersiz kimliği, ödeme geçmişi ve notlarıyla saklanır.
- Her kullanıcı işlemi doğrulandıktan sonra cihazdaki yerel dosyaya kaydedilir.
- Ana dosya atomik yazılır ve son sağlam kopya ayrıca korunur.
- Tüm state, ilişkileri korunarak CSV olarak dışa ve içe aktarılabilir.
- Bildirim planlaması ödeme geçmişi oluşturmaz veya bakiyeleri değiştirmez.
- Telefon, büyük yazı ve tablet düzenleri otomatik test edilir.

## Ana kayıt grupları

1. Banka Borçları
2. Kişisel ve Kurumsal Borçlar
3. Faturalar
4. Abonelikler
5. Kira ve Taksitler

## CI çıktıları

GitHub Actions; analyzer, 288 maddelik yapısal doğrulama, birim/widget testleri, gerçek Flutter ekran görüntüleri ve imzasız release APK üretimini birlikte çalıştırır.
