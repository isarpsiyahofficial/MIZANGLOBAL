typedef IndonesianDynamicTranslator = String Function(String source);

String translateIndonesianReviewedDynamic(
  String source,
  IndonesianDynamicTranslator translate,
) {
  for (final pattern in _indonesianPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _indonesianPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

int _number(String value) => int.tryParse(value) ?? 0;
String _days(String value) => '${_number(value)} hari';
String _items(String value) => '${_number(value)} catatan';
String _openItems(String value) => '${_number(value)} catatan terbuka';
String _payments(String value) => '${_number(value)} pembayaran';
String _expenses(String value) => '${_number(value)} pengeluaran';
String _months(String value) => '${_number(value)} bulan';
String _selectedPeople(String value) => switch (_number(value)) {
  0 => 'Tidak ada orang yang dipilih',
  1 => '1 orang dipilih',
  _ => '${_number(value)} orang dipilih',
};
String _remaining(String value) => '${_number(value)} tersisa';
String _remainingDays(String value) => switch (_number(value)) {
  0 => 'Jatuh tempo hari ini',
  1 => '1 hari lagi',
  _ => '${_number(value)} hari lagi',
};
String _remainingInstallments(String value) => switch (_number(value)) {
  0 => 'Tidak ada cicilan tersisa',
  1 => '1 cicilan tersisa',
  _ => '${_number(value)} cicilan tersisa',
};
String _dailyExpenses(String value) => '${_number(value)} pengeluaran harian';
String _expenseRecords(String value) => '${_number(value)} catatan pengeluaran';
String _newItems(String value) => '${_number(value)} catatan baru';
String _updatedLinks(String value) =>
    '${_number(value)} keterkaitan diperbarui';
String _androidWriteFailure(String value, String error) =>
    '${_items(value)} dalam jadwal notifikasi tidak dapat ditulis ke sistem Android. Kesalahan pertama: $error';
String _androidMissing(String value) =>
    'Jadwal notifikasi tidak dapat diverifikasi; ${_items(value)} tidak ditemukan di Android.';

final List<_IndonesianPattern> _indonesianPatterns = <_IndonesianPattern>[
  _IndonesianPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Laporan ${t(m[1]!)} MİZAN',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => 'Laporan keuangan ${m[1]}',
  ),
  _IndonesianPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · Halaman ${_number(m[1]!)}',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · lanjutan',
  ),
  _IndonesianPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Periode: ${m[1]}'),
  _IndonesianPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Cakupan orang: ${t(m[1]!)}',
  ),
  _IndonesianPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Dibuat: ${m[1]}',
  ),
  _IndonesianPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Jadwal terbuka ${m[1]} · Dilakukan bulan ini ${m[2]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Status Pembayaran ${m[1]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _IndonesianPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _IndonesianPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Tampilkan hari lainnya (${_remaining(m[1]!)})',
  ),
  _IndonesianPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Tampilkan hari pembayaran lainnya (${_remaining(m[1]!)})',
  ),
  _IndonesianPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Tampilkan hari pengeluaran lainnya (${_remaining(m[1]!)})',
  ),
  _IndonesianPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Tampilkan catatan lain pada hari ini (${_remaining(m[1]!)})',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => '${_remainingDays(m[2]!)} untuk ${m[1]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} diperkirakan diterima hari ini',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} terlambat ${_days(m[2]!)}',
  ),
  _IndonesianPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Terakhir diterima: ${m[1]} · Dijadwalkan: ${m[2]}',
  ),
  _IndonesianPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'Periode ${m[1]} yang dijadwalkan telah dicatat sebagai diterima pada ${m[2]}. Hari penerimaan tetap tidak berubah.',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Jumlah tagihan aktual ${m[1]}',
  ),
  _IndonesianPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Jumlah tersisa: ${m[1]}',
  ),
  _IndonesianPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Hapus catatan pengeluaran ${m[1]}?',
  ),
  _IndonesianPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'Kategori ${m[1]} dan hanya pengeluaran yang terkait dengannya akan dihapus.',
  ),
  _IndonesianPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} dan semua catatan yang terkait dengan orang ini akan dihapus. Tindakan ini memerlukan konfirmasi yang jelas.',
  ),
  _IndonesianPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Laporan PDF tidak dapat disimpan: ${m[1]}',
  ),
  _IndonesianPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Laporan PDF tidak dapat dibagikan: ${m[1]}',
  ),
  _IndonesianPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => _androidWriteFailure(m[1]!, m[2]!),
  ),
  _IndonesianPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => _androidMissing(m[1]!),
  ),
  _IndonesianPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Pengingat pembayaran ${_number(m[1]!)}',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) =>
        '${_newItems(m[1]!)} ditambahkan dan ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'Identitas catatan ${m[1]} tidak valid atau berulang.',
  ),
  _IndonesianPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => _remainingDays(m[1]!),
  ),
  _IndonesianPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'Terlambat ${_days(m[1]!)}',
  ),
  _IndonesianPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'Pembayaran terlambat ${_days(m[1]!)}.',
  ),
  _IndonesianPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Jatuh tempo ${m[1]}.',
  ),
  _IndonesianPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'Tanggal ${_number(m[1]!)} bulan ini',
  ),
  _IndonesianPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'Setiap tanggal ${_number(m[1]!)}',
  ),
  _IndonesianPattern(RegExp(r'^Her (.+)$'), (m, t) => 'Setiap ${t(m[1]!)}'),
  _IndonesianPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Mulai: ${m[1]}'),
  _IndonesianPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Mulai ${m[1]}'),
  _IndonesianPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'Total ${t(m[1]!)}'),
  _IndonesianPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'Sisa ${t(m[1]!)}'),
  _IndonesianPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} periode ini',
  ),
  _IndonesianPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Tanggal: ${m[1]}'),
  _IndonesianPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Catatan: ${m[1]}'),
  _IndonesianPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} tidak boleh kosong.',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => '${t(m[1]!)} maksimal ${_number(m[2]!)} karakter.',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} harus lebih besar dari nol.',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} harus lebih besar dari nol.',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} tidak boleh negatif.',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} harus berupa bilangan bulat positif.',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} harus nol atau bilangan bulat positif.',
  ),
  _IndonesianPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _IndonesianPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _IndonesianPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _IndonesianPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _IndonesianPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _IndonesianPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _IndonesianPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => _selectedPeople(m[1]!),
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_newItems(m[1]!)} ditambahkan; data yang ada tetap disimpan.',
  ),
  _IndonesianPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'Uji untuk ${m[1]} dijadwalkan tepat waktu.',
  ),
  _IndonesianPattern(
    RegExp(r'^Test planlanamadı: (.+)$'),
    (m, t) => 'Uji tidak dapat dijadwalkan: ${m[1]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) planlanamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} tidak dapat dijadwalkan: ${m[2]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => '${t(m[1]!)} tidak dapat disimpan: ${m[2]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} tidak dapat dibuat: ${m[2]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} tidak dapat dibagikan: ${m[2]}',
  ),
  _IndonesianPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => '${t(m[1]!)} tidak dapat digabungkan: ${m[2]}',
  ),
];

const List<(String, String)> _indonesianPhrases = <(String, String)>[
  ('Banka borcu', 'Utang bank'),
  ('Kişisel ve kurumsal borçlar', 'Utang pribadi dan perusahaan'),
  ('Kişisel / kurumsal borç', 'Utang pribadi / perusahaan'),
  ('Kişisel/kurumsal borç', 'Utang pribadi/perusahaan'),
  ('Ödemelere yapılan gider', 'Pengeluaran untuk pembayaran'),
  ('Bu ay yapılan', 'Dilakukan bulan ini'),
  ('Açık plan', 'Jadwal terbuka'),
  ('Kalan tutar', 'Jumlah tersisa'),
  ('Kalan toplam borç', 'Total sisa utang'),
  ('Gecikmiş toplam', 'Total terlambat'),
  ('Önümüzdeki 7 gün', '7 hari ke depan'),
  ('Son ödeme bugün', 'Jatuh tempo hari ini'),
  ('Banka borçları', 'Utang bank'),
  ('Kira ve taksitler', 'Sewa dan cicilan'),
  ('Günlük harcamalar', 'Pengeluaran harian'),
  ('Gider ayrıntıları', 'Detail pengeluaran'),
  ('Ödeme ayrıntıları', 'Detail pembayaran'),
  ('Gerçekleşen ödeme', 'Pembayaran aktual'),
  ('Ödeme kayıtları', 'Catatan pembayaran'),
  ('Normal giderler', 'Pengeluaran rutin'),
  ('Toplam gider', 'Total pengeluaran'),
  ('Kalan ödeme yükü', 'Sisa kewajiban pembayaran'),
  ('Gecikmiş ödeme yükü', 'Kewajiban pembayaran terlambat'),
  ('Yaklaşan ödeme yükü', 'Kewajiban pembayaran mendatang'),
  ('Kişi kapsamı', 'Cakupan orang'),
  ('Oluşturulma', 'Dibuat'),
  ('Dönem', 'Periode'),
  ('devam', 'lanjutan'),
];

class _IndonesianPattern {
  const _IndonesianPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(
    RegExpMatch match,
    IndonesianDynamicTranslator translate,
  )
  builder;
}
