# MİZAN GLOBAL — 29 Dil Entegrasyon Adayı

29 dilin tamamı artık birleşik aday kaynakta runtime seçeneği olarak tanımlıdır:

1. Türkçe (`tr`)
2. English (`en`)
3. Español (`es`)
4. Português — Brasil (`pt-BR`)
5. Português — Portugal (`pt-PT`)
6. Français (`fr`)
7. Deutsch (`de`)
8. Italiano (`it`)
9. Nederlands (`nl`)
10. Polski (`pl`)
11. Română (`ro`)
12. Ελληνικά (`el`)
13. Русский (`ru`)
14. Українська (`uk`)
15. العربية (`ar`)
16. فارسی (`fa`)
17. עברית (`he`)
18. हिन्दी (`hi`)
19. বাংলা (`bn`)
20. اردو (`ur`)
21. Bahasa Indonesia (`id`)
22. Bahasa Melayu (`ms`)
23. Filipino (`fil`)
24. Tiếng Việt (`vi`, `vi-VN`)
25. ไทย (`th`, `th-TH`)
26. Kiswahili (`sw`, `sw-TZ`, `sw-KE`)
27. 简体中文 (`zh`, `zh-CN`)
28. 日本語 (`ja`, `ja-JP`)
29. 한국어 (`ko`, `ko-KR`)

Bu belge final kabul beyanı değildir. Her seçenek 791 sabit sistem anahtarı sözleşmesine, ayrı dinamik dil katmanına, seçili dile özgü locale biçimlendirmesine ve 29 dil + 161 ülke + 154 para birimi çevrimdışı katalog katmanına bağlanmıştır. Vietnamca, Tayca ve Svahili kaynakları kullanıcıya açılan runtime kümesine atomik olarak eklenmiştir; final merge ancak 29/29 derin final denetiminin aynı temiz SHA üzerinde tamamlanmasından sonra yapılabilir.

Bağlayıcı izolasyon sınırları korunur: Korean sistem kopyasında Japanese Kana/Chinese sistem etiketi; Japanese sistem kopyasında Korean Hangul/Chinese sistem etiketi; Simplified Chinese sistem kopyasında Hangul/Kana/Japanese sistem cümlesi kabul edilmez. Thai kritik görünür ürün metni Thai script kullanır. Vietnamese, Swahili, Indonesian, Malay ve Filipino için komşu-dil sızıntı kapıları uygulanır. Kullanıcının kendi çok dilli metni sistem çevirisinden ayrıdır ve olduğu gibi korunur.

Final kabul için ayrıca rapor/PDF/bildirim/CSV/storage, çoklu para birimi ayrımı, locale geçişleri, katalog araması, responsive görünümler, lifecycle/persistence, randomized/differential kontroller, temiz kaynak ağacı ve aynı exact SHA'dan dört release APK doğrulaması zorunludur.
