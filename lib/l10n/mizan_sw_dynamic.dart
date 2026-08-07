typedef SwahiliDynamicTranslator = String Function(String source);

String translateSwahiliReviewedDynamic(
  String source,
  SwahiliDynamicTranslator translate,
) {
  for (final pattern in _swahiliPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _swahiliPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

int _number(String value) => int.tryParse(value) ?? 0;
String _days(String value) => '${_number(value)} siku';
String _items(String value) => '${_number(value)} rekodi';
String _openItems(String value) => '${_number(value)} rekodi zilizo wazi';
String _payments(String value) => '${_number(value)} malipo';
String _expenses(String value) => '${_number(value)} matumizi';
String _months(String value) => '${_number(value)} miezi';
String _selectedPeople(String value) => switch (_number(value)) {
  0 => 'Hakuna mtu aliyechaguliwa',
  1 => 'Mtu 1 amechaguliwa',
  _ => 'Watu ${_number(value)} wamechaguliwa',
};
String _remaining(String value) => '${_number(value)} zimebaki';
String _remainingDays(String value) => switch (_number(value)) {
  0 => 'Tarehe ya mwisho ni leo',
  1 => 'Siku 1 imebaki',
  _ => 'Siku ${_number(value)} zimebaki',
};
String _remainingInstallments(String value) => switch (_number(value)) {
  0 => 'Hakuna awamu iliyobaki',
  1 => 'Awamu 1 imebaki',
  _ => 'Awamu ${_number(value)} zimebaki',
};
String _dailyExpenses(String value) => '${_number(value)} matumizi ya kila siku';
String _expenseRecords(String value) => '${_number(value)} rekodi za matumizi';
String _newItems(String value) => '${_number(value)} rekodi mpya';
String _updatedLinks(String value) => '${_number(value)} mahusiano yamesasishwa';
String _androidWriteFailure(String value, String error) =>
    '${_items(value)} kwenye ratiba ya arifa hazikuweza kuandikwa kwenye mfumo wa Android. Hitilafu ya kwanza: $error';
String _androidMissing(String value) =>
    'Ratiba ya arifa haikuweza kuthibitishwa; ${_items(value)} hazipo upande wa Android.';

final List<_SwahiliPattern> _swahiliPatterns = <_SwahiliPattern>[
  _SwahiliPattern(RegExp(r'^MİZAN (.+) Raporu$'), (m, t) => 'Ripoti ya ${t(m[1]!)} ya MİZAN'),
  _SwahiliPattern(RegExp(r'^(.+) finans raporu$'), (m, t) => 'Ripoti ya fedha ya ${m[1]}'),
  _SwahiliPattern(RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'), (m, t) => 'LEFFERION PRIME - MİZAN · Ukurasa ${_number(m[1]!)}'),
  _SwahiliPattern(RegExp(r'^(.+) · devam$'), (m, t) => '${t(m[1]!)} · inaendelea'),
  _SwahiliPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Kipindi: ${m[1]}'),
  _SwahiliPattern(RegExp(r'^Kişi kapsamı: (.+)$'), (m, t) => 'Wigo wa watu: ${t(m[1]!)}'),
  _SwahiliPattern(RegExp(r'^Oluşturulma: (.+)$'), (m, t) => 'Imeundwa: ${m[1]}'),
  _SwahiliPattern(RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'), (m, t) => 'Mpango wazi ${m[1]} · Yaliyofanyika mwezi huu ${m[2]}'),
  _SwahiliPattern(RegExp(r'^(.+) Ödeme Durumu$'), (m, t) => 'Hali ya Malipo ya ${m[1]}'),
  _SwahiliPattern(RegExp(r'^(\d+) açık kayıt · (.+)$'), (m, t) => '${_openItems(m[1]!)} · ${m[2]}'),
  _SwahiliPattern(RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'), (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}'),
  _SwahiliPattern(RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'), (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}'),
  _SwahiliPattern(RegExp(r'^(\d+) ödeme · (.+)$'), (m, t) => '${_payments(m[1]!)} · ${m[2]}'),
  _SwahiliPattern(RegExp(r'^(\d+) gider · (.+)$'), (m, t) => '${_expenses(m[1]!)} · ${m[2]}'),
  _SwahiliPattern(RegExp(r'^(\d+) gider kaydı$'), (m, t) => _expenseRecords(m[1]!)),
  _SwahiliPattern(RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'), (m, t) => 'Onyesha siku zaidi (${_remaining(m[1]!)})'),
  _SwahiliPattern(RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'), (m, t) => 'Onyesha siku zaidi za malipo (${_remaining(m[1]!)})'),
  _SwahiliPattern(RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'), (m, t) => 'Onyesha siku zaidi za matumizi (${_remaining(m[1]!)})'),
  _SwahiliPattern(RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'), (m, t) => 'Onyesha rekodi zaidi za siku hii (${_remaining(m[1]!)})'),
  _SwahiliPattern(RegExp(r'^(.+) için (\d+) gün kaldı$'), (m, t) => '${_remainingDays(m[2]!)} hadi ${m[1]}'),
  _SwahiliPattern(RegExp(r'^(.+) bugün bekleniyor$'), (m, t) => '${m[1]} yanatarajiwa leo'),
  _SwahiliPattern(RegExp(r'^(.+) (\d+) gün gecikti$'), (m, t) => '${m[1]} imechelewa ${_days(m[2]!)}'),
  _SwahiliPattern(RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'), (m, t) => 'Ilipokelewa mwisho: ${m[1]} · Iliyopangwa: ${m[2]}'),
  _SwahiliPattern(
    RegExp(r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$'),
    (m, t) => 'Kipindi kilichopangwa cha ${m[1]} kimerekodiwa kuwa kimepokelewa tarehe ${m[2]}. Siku ya kawaida ya kupokea haijabadilika.',
  ),
  _SwahiliPattern(RegExp(r'^(.+) gerçek fatura tutarı$'), (m, t) => 'Kiasi halisi cha bili ya ${m[1]}'),
  _SwahiliPattern(RegExp(r'^Kalan tutar: (.+)$'), (m, t) => 'Kiasi kilichobaki: ${m[1]}'),
  _SwahiliPattern(RegExp(r'^Kalan taksit: (\d+)$'), (m, t) => _remainingInstallments(m[1]!)),
  _SwahiliPattern(RegExp(r'^(.+) gider kaydı silinsin mi\?$'), (m, t) => 'Futa rekodi ya matumizi ${m[1]}?'),
  _SwahiliPattern(RegExp(r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$'), (m, t) => 'Kategoria ${m[1]} na matumizi yaliyounganishwa na kategoria hii pekee yatafutwa.'),
  _SwahiliPattern(RegExp(r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$'), (m, t) => '${m[1]} na rekodi zote zinazohusishwa na mtu huyu zitafutwa. Kitendo hiki kinahitaji uthibitisho wa wazi.'),
  _SwahiliPattern(RegExp(r'^PDF raporu kaydedilemedi: (.+)$'), (m, t) => 'Ripoti ya PDF haikuweza kuhifadhiwa: ${m[1]}'),
  _SwahiliPattern(RegExp(r'^PDF raporu paylaşılamadı: (.+)$'), (m, t) => 'Ripoti ya PDF haikuweza kushirikiwa: ${m[1]}'),
  _SwahiliPattern(RegExp(r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$'), (m, t) => _androidWriteFailure(m[1]!, m[2]!)),
  _SwahiliPattern(RegExp(r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$'), (m, t) => _androidMissing(m[1]!)),
  _SwahiliPattern(RegExp(r'^Ödeme hatırlatması (\d+)$'), (m, t) => 'Kikumbusho cha malipo ${_number(m[1]!)}'),
  _SwahiliPattern(RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'), (m, t) => '${_newItems(m[1]!)} zimeongezwa na ${_updatedLinks(m[2]!)}${m[3]}.'),
  _SwahiliPattern(RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'), (m, t) => 'Kitambulisho cha rekodi ${m[1]} si halali au kimerudiwa.'),
  _SwahiliPattern(RegExp(r'^(\d+) gün kaldı$'), (m, t) => _remainingDays(m[1]!)),
  _SwahiliPattern(RegExp(r'^(\d+) gün gecikmede$'), (m, t) => 'Imechelewa ${_days(m[1]!)}'),
  _SwahiliPattern(RegExp(r'^Ödeme (\d+) gün gecikti\.$'), (m, t) => 'Malipo yamechelewa ${_days(m[1]!)}.'),
  _SwahiliPattern(RegExp(r'^Son ödeme (.+)\.$'), (m, t) => 'Tarehe ya mwisho ${m[1]}.'),
  _SwahiliPattern(RegExp(r'^Ayın (\d+)\. günü$'), (m, t) => 'Tarehe ${_number(m[1]!)} ya mwezi'),
  _SwahiliPattern(RegExp(r'^Her ayın (\d+)\. günü$'), (m, t) => 'Tarehe ${_number(m[1]!)} ya kila mwezi'),
  _SwahiliPattern(RegExp(r'^Her (.+)$'), (m, t) => 'Kila ${t(m[1]!)}'),
  _SwahiliPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Mwanzo: ${m[1]}'),
  _SwahiliPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Mwanzo ${m[1]}'),
  _SwahiliPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'Jumla ya ${t(m[1]!)}'),
  _SwahiliPattern(RegExp(r'^Kalan (.+)$'), (m, t) => '${t(m[1]!)} iliyobaki'),
  _SwahiliPattern(RegExp(r'^Bu dönem (.+)$'), (m, t) => '${t(m[1]!)} kipindi hiki'),
  _SwahiliPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Tarehe: ${m[1]}'),
  _SwahiliPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Dokezo: ${m[1]}'),
  _SwahiliPattern(RegExp(r'^(.+) boş bırakılamaz\.$'), (m, t) => '${t(m[1]!)} haiwezi kuachwa wazi.'),
  _SwahiliPattern(RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'), (m, t) => '${t(m[1]!)} inaweza kuwa na herufi zisizozidi ${_number(m[2]!)}.'),
  _SwahiliPattern(RegExp(r'^(.+) sıfırdan büyük olmalı\.$'), (m, t) => '${t(m[1]!)} lazima iwe zaidi ya sifuri.'),
  _SwahiliPattern(RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'), (m, t) => '${t(m[1]!)} lazima iwe zaidi ya sifuri.'),
  _SwahiliPattern(RegExp(r'^(.+) negatif olamaz\.$'), (m, t) => '${t(m[1]!)} haiwezi kuwa hasi.'),
  _SwahiliPattern(RegExp(r'^(.+) pozitif tam sayı olmalı\.$'), (m, t) => '${t(m[1]!)} lazima iwe namba kamili chanya.'),
  _SwahiliPattern(RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'), (m, t) => '${t(m[1]!)} lazima iwe sifuri au namba kamili chanya.'),
  _SwahiliPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _SwahiliPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _SwahiliPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _SwahiliPattern(RegExp(r'^(.+) · (\d+) kayıt$'), (m, t) => '${m[1]} · ${_items(m[2]!)}'),
  _SwahiliPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _SwahiliPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _SwahiliPattern(RegExp(r'^(.+) kişi seçili$'), (m, t) => _selectedPeople(m[1]!)),
  _SwahiliPattern(RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'), (m, t) => '${_newItems(m[1]!)} zimeongezwa; data iliyopo imehifadhiwa.'),
  _SwahiliPattern(RegExp(r'^Test (.+) için dakik olarak planlandı\.$'), (m, t) => 'Jaribio la ${m[1]} limepangwa kwa muda sahihi.'),
  _SwahiliPattern(RegExp(r'^Test planlanamadı: (.+)$'), (m, t) => 'Jaribio halikuweza kupangwa: ${m[1]}'),
  _SwahiliPattern(RegExp(r'^(.+) planlanamadı: (.+)$'), (m, t) => '${t(m[1]!)} haikuweza kupangwa: ${m[2]}'),
  _SwahiliPattern(RegExp(r'^(.+) kaydedilemedi: (.+)$'), (m, t) => '${t(m[1]!)} haikuweza kuhifadhiwa: ${m[2]}'),
  _SwahiliPattern(RegExp(r'^(.+) oluşturulamadı: (.+)$'), (m, t) => '${t(m[1]!)} haikuweza kuundwa: ${m[2]}'),
  _SwahiliPattern(RegExp(r'^(.+) paylaşılamadı: (.+)$'), (m, t) => '${t(m[1]!)} haikuweza kushirikiwa: ${m[2]}'),
  _SwahiliPattern(RegExp(r'^(.+) birleştirilemedi: (.+)$'), (m, t) => '${t(m[1]!)} haikuweza kuunganishwa: ${m[2]}'),
];

const List<(String, String)> _swahiliPhrases = <(String, String)>[
  ('Banka borcu', 'Deni la benki'),
  ('Kişisel ve kurumsal borçlar', 'Madeni ya binafsi na taasisi'),
  ('Kişisel / kurumsal borç', 'Deni la binafsi / taasisi'),
  ('Kişisel/kurumsal borç', 'Deni la binafsi/taasisi'),
  ('Ödemelere yapılan gider', 'Matumizi ya malipo'),
  ('Bu ay yapılan', 'Yaliyofanyika mwezi huu'),
  ('Açık plan', 'Mpango wazi'),
  ('Kalan tutar', 'Kiasi kilichobaki'),
  ('Kalan toplam borç', 'Jumla ya deni lililobaki'),
  ('Gecikmiş toplam', 'Jumla iliyochelewa'),
  ('Önümüzdeki 7 gün', 'Siku 7 zijazo'),
  ('Son ödeme bugün', 'Tarehe ya mwisho ni leo'),
  ('Banka borçları', 'Madeni ya benki'),
  ('Kira ve taksitler', 'Kodi na awamu'),
  ('Günlük harcamalar', 'Matumizi ya kila siku'),
  ('Gider ayrıntıları', 'Maelezo ya matumizi'),
  ('Ödeme ayrıntıları', 'Maelezo ya malipo'),
  ('Gerçekleşen ödeme', 'Malipo yaliyofanyika'),
  ('Ödeme kayıtları', 'Rekodi za malipo'),
  ('Normal giderler', 'Matumizi ya kawaida'),
  ('Toplam gider', 'Jumla ya matumizi'),
  ('Kalan ödeme yükü', 'Wajibu wa malipo uliobaki'),
  ('Gecikmiş ödeme yükü', 'Wajibu wa malipo uliochelewa'),
  ('Yaklaşan ödeme yükü', 'Wajibu wa malipo unaokaribia'),
  ('Kişi kapsamı', 'Wigo wa watu'),
  ('Oluşturulma', 'Imeundwa'),
  ('Dönem', 'Kipindi'),
  ('devam', 'inaendelea'),
];

class _SwahiliPattern {
  const _SwahiliPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, SwahiliDynamicTranslator translate) builder;
}