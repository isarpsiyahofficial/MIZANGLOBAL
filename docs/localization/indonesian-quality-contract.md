# Kontrak Mutu Final Bahasa Indonesia

Lokalisasi Bahasa Indonesia hanya dapat dinyatakan final apabila seluruh syarat berikut dipenuhi pada SHA yang sama:

- Seluruh 791 teks sistem tersedia dalam Bahasa Indonesia yang alami, konsisten, dan sesuai konteks produk keuangan.
- `id`, `id-ID`, `id_ID`, serta tag lama Android `in-ID` dinormalisasi ke runtime Bahasa Indonesia tanpa memengaruhi bahasa lain.
- Nama, catatan, deskripsi, nomor rekening, nama bank, dan data lain yang ditulis pengguna tidak diterjemahkan atau diubah.
- Menu, formulir, validasi, status kosong, kesalahan, peringatan, notifikasi, CSV, laporan, grafik, dan PDF tidak menampilkan fallback bahasa Turki, Inggris, Arab, Persia, Ibrani, Hindi, Bengali, atau bahasa lain.
- Pengeluaran rutin dan pembayaran tetap menjadi sumber data terpisah. Keduanya hanya boleh digabungkan pada total yang memang didefinisikan sebagai total gabungan.
- Setiap mata uang tetap berada pada bagian laporannya sendiri; tidak ada konversi kurs atau penggabungan nominal antar-mata uang.
- IDR menggunakan pemisah ribuan titik, desimal koma, dan awalan `Rp`; mata uang lain tetap menampilkan kode ISO secara jelas.
- Tanggal menggunakan kalender Gregorius dan nama bulan Bahasa Indonesia.
- Nama tampilan serta pencarian offline tersedia dalam Bahasa Indonesia untuk seluruh bahasa, 161 negara, dan 154 mata uang pada katalog produk.
- Seluruh bahasa yang telah diselesaikan sebelumnya tetap lulus regresi dan tidak menerima teks Bahasa Indonesia saat bahasa lain dipilih.
- Tampilan 320×568 pada skala teks 1,4 dan 412×915 pada skala teks 2,0 tidak mengalami overflow atau perubahan arah teks yang salah.
- Analisis statis, audit sumber, pengujian bahasa/runtime, laporan/PDF/notifikasi, seluruh pengujian terisolasi, visual baseline, serta APK Universal, ARM64, ARMv7, dan x86_64 harus lulus.
- Commit yang diuji, commit yang menghasilkan APK, dan commit yang akan digabungkan harus memiliki SHA yang sama persis.

Status final tidak diberikan hanya karena jumlah kunci, skema, atau satu kelompok pengujian berhasil.