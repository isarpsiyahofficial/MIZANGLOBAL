typedef FilipinoDynamicTranslator = String Function(String source);

String translateFilipinoReviewedDynamic(
  String source,
  FilipinoDynamicTranslator translate,
) {
  for (final pattern in _filipinoPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _filipinoPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

int _number(String value) => int.tryParse(value) ?? 0;
String _days(String value) => '${_number(value)} araw';
String _items(String value) => '${_number(value)} tala';
String _openItems(String value) => '${_number(value)} bukas na tala';
String _payments(String value) => '${_number(value)} bayad';
String _expenses(String value) => '${_number(value)} gastusin';
String _months(String value) => '${_number(value)} buwan';
String _selectedPeople(String value) => switch (_number(value)) {
  0 => 'Walang napiling tao',
  1 => '1 tao ang napili',
  _ => '${_number(value)} tao ang napili',
};
String _remaining(String value) => '${_number(value)} ang natitira';
String _remainingDays(String value) => switch (_number(value)) {
  0 => 'Due ngayong araw',
  1 => '1 araw na lang',
  _ => '${_number(value)} araw na lang',
};
String _remainingInstallments(String value) => switch (_number(value)) {
  0 => 'Wala nang natitirang hulog',
  1 => '1 hulog ang natitira',
  _ => '${_number(value)} hulog ang natitira',
};
String _dailyExpenses(String value) => '${_number(value)} araw-araw na gastusin';
String _expenseRecords(String value) => '${_number(value)} tala ng gastusin';
String _newItems(String value) => '${_number(value)} bagong tala';
String _updatedLinks(String value) => '${_number(value)} ugnayan ang na-update';
String _androidWriteFailure(String value, String error) =>
    '${_items(value)} sa notification schedule ang hindi maisulat sa Android system. Unang error: $error';
String _androidMissing(String value) =>
    'Hindi ma-verify ang notification schedule; ${_items(value)} ang nawawala sa Android.';

final List<_FilipinoPattern> _filipinoPatterns = <_FilipinoPattern>[
  _FilipinoPattern(RegExp(r'^MİZAN (.+) Raporu$'), (m, t) => 'Ulat ng MİZAN — ${t(m[1]!)}'),
  _FilipinoPattern(RegExp(r'^(.+) finans raporu$'), (m, t) => 'Ulat sa pananalapi ng ${m[1]}'),
  _FilipinoPattern(RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'), (m, t) => 'LEFFERION PRIME - MİZAN · Pahina ${_number(m[1]!)}'),
  _FilipinoPattern(RegExp(r'^(.+) · devam$'), (m, t) => '${t(m[1]!)} · kasunod'),
  _FilipinoPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Period: ${m[1]}'),
  _FilipinoPattern(RegExp(r'^Kişi kapsamı: (.+)$'), (m, t) => 'Saklaw ng mga tao: ${t(m[1]!)}'),
  _FilipinoPattern(RegExp(r'^Oluşturulma: (.+)$'), (m, t) => 'Ginawa: ${m[1]}'),
  _FilipinoPattern(RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'), (m, t) => 'Bukas na plano ${m[1]} · Ginawa ngayong buwan ${m[2]}'),
  _FilipinoPattern(RegExp(r'^(.+) Ödeme Durumu$'), (m, t) => 'Status ng Pagbabayad — ${m[1]}'),
  _FilipinoPattern(RegExp(r'^(\d+) açık kayıt · (.+)$'), (m, t) => '${_openItems(m[1]!)} · ${m[2]}'),
  _FilipinoPattern(RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'), (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}'),
  _FilipinoPattern(RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'), (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}'),
  _FilipinoPattern(RegExp(r'^(\d+) ödeme · (.+)$'), (m, t) => '${_payments(m[1]!)} · ${m[2]}'),
  _FilipinoPattern(RegExp(r'^(\d+) gider · (.+)$'), (m, t) => '${_expenses(m[1]!)} · ${m[2]}'),
  _FilipinoPattern(RegExp(r'^(\d+) gider kaydı$'), (m, t) => _expenseRecords(m[1]!)),
  _FilipinoPattern(RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'), (m, t) => 'Magpakita pa ng mga araw (${_remaining(m[1]!)})'),
  _FilipinoPattern(RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'), (m, t) => 'Magpakita pa ng mga araw ng pagbabayad (${_remaining(m[1]!)})'),
  _FilipinoPattern(RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'), (m, t) => 'Magpakita pa ng mga araw ng gastusin (${_remaining(m[1]!)})'),
  _FilipinoPattern(RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'), (m, t) => 'Magpakita pa ng mga tala sa araw na ito (${_remaining(m[1]!)})'),
  _FilipinoPattern(RegExp(r'^(.+) için (\d+) gün kaldı$'), (m, t) => '${_remainingDays(m[2]!)} para sa ${m[1]}'),
  _FilipinoPattern(RegExp(r'^(.+) bugün bekleniyor$'), (m, t) => 'Inaasahang matatanggap ngayon ang ${m[1]}'),
  _FilipinoPattern(RegExp(r'^(.+) (\d+) gün gecikti$'), (m, t) => 'Overdue ng ${_days(m[2]!)} ang ${m[1]}'),
  _FilipinoPattern(RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'), (m, t) => 'Huling natanggap: ${m[1]} · Naka-iskedyul: ${m[2]}'),
  _FilipinoPattern(RegExp(r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$'), (m, t) => 'Ang nakaplanong period na ${m[1]} ay naitalang natanggap noong ${m[2]}. Hindi nagbago ang nakatakdang araw ng pagtanggap.'),
  _FilipinoPattern(RegExp(r'^(.+) gerçek fatura tutarı$'), (m, t) => 'Aktuwal na halaga ng bayarin para sa ${m[1]}'),
  _FilipinoPattern(RegExp(r'^Kalan tutar: (.+)$'), (m, t) => 'Natitirang halaga: ${m[1]}'),
  _FilipinoPattern(RegExp(r'^Kalan taksit: (\d+)$'), (m, t) => _remainingInstallments(m[1]!)),
  _FilipinoPattern(RegExp(r'^(.+) gider kaydı silinsin mi\?$'), (m, t) => 'Burahin ang tala ng gastusin na ${m[1]}?'),
  _FilipinoPattern(RegExp(r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$'), (m, t) => 'Buburahin ang kategoryang ${m[1]} at ang mga gastusing nakakabit lamang dito.'),
  _FilipinoPattern(RegExp(r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$'), (m, t) => 'Buburahin ang ${m[1]} at lahat ng talang nakakabit sa taong ito. Kailangan ng malinaw na kumpirmasyon para sa aksyong ito.'),
  _FilipinoPattern(RegExp(r'^PDF raporu kaydedilemedi: (.+)$'), (m, t) => 'Hindi ma-save ang PDF report: ${m[1]}'),
  _FilipinoPattern(RegExp(r'^PDF raporu paylaşılamadı: (.+)$'), (m, t) => 'Hindi ma-share ang PDF report: ${m[1]}'),
  _FilipinoPattern(RegExp(r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$'), (m, t) => _androidWriteFailure(m[1]!, m[2]!)),
  _FilipinoPattern(RegExp(r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$'), (m, t) => _androidMissing(m[1]!)),
  _FilipinoPattern(RegExp(r'^Ödeme hatırlatması (\d+)$'), (m, t) => 'Paalala sa pagbabayad ${_number(m[1]!)}'),
  _FilipinoPattern(RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'), (m, t) => '${_newItems(m[1]!)} ang idinagdag at ${_updatedLinks(m[2]!)}${m[3]}.'),
  _FilipinoPattern(RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'), (m, t) => 'Hindi valid o duplicate ang record ID na ${m[1]}.'),
  _FilipinoPattern(RegExp(r'^(\d+) gün kaldı$'), (m, t) => _remainingDays(m[1]!)),
  _FilipinoPattern(RegExp(r'^(\d+) gün gecikmede$'), (m, t) => '${_days(m[1]!)} nang overdue'),
  _FilipinoPattern(RegExp(r'^Ödeme (\d+) gün gecikti\.$'), (m, t) => 'Overdue ng ${_days(m[1]!)} ang bayad.'),
  _FilipinoPattern(RegExp(r'^Son ödeme (.+)\.$'), (m, t) => 'Due ${m[1]}.'),
  _FilipinoPattern(RegExp(r'^Ayın (\d+)\. günü$'), (m, t) => 'Ika-${_number(m[1]!)} araw ng buwan'),
  _FilipinoPattern(RegExp(r'^Her ayın (\d+)\. günü$'), (m, t) => 'Tuwing ika-${_number(m[1]!)} ng buwan'),
  _FilipinoPattern(RegExp(r'^Her (.+)$'), (m, t) => 'Bawat ${t(m[1]!)}'),
  _FilipinoPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Simula: ${m[1]}'),
  _FilipinoPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Simula ${m[1]}'),
  _FilipinoPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'Kabuuang ${t(m[1]!)}'),
  _FilipinoPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'Natitirang ${t(m[1]!)}'),
  _FilipinoPattern(RegExp(r'^Bu dönem (.+)$'), (m, t) => '${t(m[1]!)} sa period na ito'),
  _FilipinoPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Petsa: ${m[1]}'),
  _FilipinoPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Tala: ${m[1]}'),
  _FilipinoPattern(RegExp(r'^(.+) boş bırakılamaz\.$'), (m, t) => 'Hindi maaaring walang laman ang ${t(m[1]!)}.'),
  _FilipinoPattern(RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'), (m, t) => 'Hanggang ${_number(m[2]!)} character lamang ang ${t(m[1]!)}.'),
  _FilipinoPattern(RegExp(r'^(.+) sıfırdan büyük olmalı\.$'), (m, t) => 'Dapat mas mataas sa zero ang ${t(m[1]!)}.'),
  _FilipinoPattern(RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'), (m, t) => 'Dapat mas mataas sa zero ang ${t(m[1]!)}.'),
  _FilipinoPattern(RegExp(r'^(.+) negatif olamaz\.$'), (m, t) => 'Hindi maaaring negatibo ang ${t(m[1]!)}.'),
  _FilipinoPattern(RegExp(r'^(.+) pozitif tam sayı olmalı\.$'), (m, t) => 'Dapat positibong whole number ang ${t(m[1]!)}.'),
  _FilipinoPattern(RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'), (m, t) => 'Dapat zero o positibong whole number ang ${t(m[1]!)}.'),
  _FilipinoPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _FilipinoPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _FilipinoPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _FilipinoPattern(RegExp(r'^(.+) · (\d+) kayıt$'), (m, t) => '${m[1]} · ${_items(m[2]!)}'),
  _FilipinoPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _FilipinoPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _FilipinoPattern(RegExp(r'^(.+) kişi seçili$'), (m, t) => _selectedPeople(m[1]!)),
  _FilipinoPattern(RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'), (m, t) => '${_newItems(m[1]!)} ang idinagdag; nanatili ang kasalukuyang data.'),
  _FilipinoPattern(RegExp(r'^Test (.+) için dakik olarak planlandı\.$'), (m, t) => 'Eksaktong naka-iskedyul ang test para sa ${m[1]}.'),
  _FilipinoPattern(RegExp(r'^Test planlanamadı: (.+)$'), (m, t) => 'Hindi ma-iskedyul ang test: ${m[1]}'),
  _FilipinoPattern(RegExp(r'^(.+) planlanamadı: (.+)$'), (m, t) => 'Hindi ma-iskedyul ang ${t(m[1]!)}: ${m[2]}'),
  _FilipinoPattern(RegExp(r'^(.+) kaydedilemedi: (.+)$'), (m, t) => 'Hindi ma-save ang ${t(m[1]!)}: ${m[2]}'),
  _FilipinoPattern(RegExp(r'^(.+) oluşturulamadı: (.+)$'), (m, t) => 'Hindi magawa ang ${t(m[1]!)}: ${m[2]}'),
  _FilipinoPattern(RegExp(r'^(.+) paylaşılamadı: (.+)$'), (m, t) => 'Hindi ma-share ang ${t(m[1]!)}: ${m[2]}'),
  _FilipinoPattern(RegExp(r'^(.+) birleştirilemedi: (.+)$'), (m, t) => 'Hindi mapagsama ang ${t(m[1]!)}: ${m[2]}'),
];

const List<(String, String)> _filipinoPhrases = <(String, String)>[
  ('Banka borcu', 'Utang sa bangko'),
  ('Kişisel ve kurumsal borçlar', 'Personal at pangkumpanyang utang'),
  ('Kişisel / kurumsal borç', 'Personal / pangkumpanyang utang'),
  ('Kişisel/kurumsal borç', 'Personal/pangkumpanyang utang'),
  ('Ödemelere yapılan gider', 'Mga halagang ibinayad'),
  ('Bu ay yapılan', 'Ginawa ngayong buwan'),
  ('Açık plan', 'Bukas na plano'),
  ('Kalan tutar', 'Natitirang halaga'),
  ('Kalan toplam borç', 'Kabuuang natitirang utang'),
  ('Gecikmiş toplam', 'Kabuuang overdue'),
  ('Önümüzdeki 7 gün', 'Susunod na 7 araw'),
  ('Son ödeme bugün', 'Due ngayong araw'),
  ('Banka borçları', 'Mga utang sa bangko'),
  ('Kira ve taksitler', 'Upa at mga hulugan'),
  ('Günlük harcamalar', 'Araw-araw na gastusin'),
  ('Gider ayrıntıları', 'Detalye ng gastusin'),
  ('Ödeme ayrıntıları', 'Detalye ng mga bayad'),
  ('Gerçekleşen ödeme', 'Aktuwal na bayad'),
  ('Ödeme kayıtları', 'Mga tala ng bayad'),
  ('Normal giderler', 'Karaniwang gastusin'),
  ('Toplam gider', 'Kabuuang gastusin'),
  ('Kalan ödeme yükü', 'Natitirang obligasyon sa pagbabayad'),
  ('Gecikmiş ödeme yükü', 'Overdue na obligasyon sa pagbabayad'),
  ('Yaklaşan ödeme yükü', 'Paparating na obligasyon sa pagbabayad'),
  ('Kişi kapsamı', 'Saklaw ng mga tao'),
  ('Oluşturulma', 'Ginawa'),
  ('Dönem', 'Period'),
  ('devam', 'kasunod'),
];

class _FilipinoPattern {
  const _FilipinoPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, FilipinoDynamicTranslator translate) builder;
}
