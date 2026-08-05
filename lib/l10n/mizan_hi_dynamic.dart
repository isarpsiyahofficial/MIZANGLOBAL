typedef HindiDynamicTranslator = String Function(String source);

String translateHindiReviewedDynamic(
  String source,
  HindiDynamicTranslator translate,
) {
  for (final pattern in _hindiPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _hindiPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

int _number(String value) => int.tryParse(value) ?? 0;

String _days(String value) => '${_number(value)} दिन';
String _items(String value) => '${_number(value)} रिकॉर्ड';
String _openItems(String value) => '${_number(value)} खुले रिकॉर्ड';
String _payments(String value) => '${_number(value)} भुगतान';
String _expenses(String value) => '${_number(value)} खर्च';
String _months(String value) => switch (_number(value)) {
  1 => '1 महीना',
  _ => '${_number(value)} महीने',
};
String _selectedPeople(String value) => switch (_number(value)) {
  0 => 'कोई व्यक्ति नहीं चुना गया',
  1 => '1 व्यक्ति चुना गया',
  _ => '${_number(value)} लोग चुने गए',
};
String _remaining(String value) => '$value बाकी';
String _remainingDays(String value) => switch (_number(value)) {
  0 => 'अंतिम भुगतान आज है',
  1 => '1 दिन बाकी',
  _ => '${_number(value)} दिन बाकी',
};
String _remainingInstallments(String value) => switch (_number(value)) {
  0 => 'कोई किस्त बाकी नहीं',
  1 => '1 किस्त बाकी',
  _ => '${_number(value)} किस्तें बाकी',
};
String _dailyExpenses(String value) => '${_number(value)} दैनिक खर्च';
String _expenseRecords(String value) => switch (_number(value)) {
  1 => 'खर्च का 1 रिकॉर्ड',
  _ => 'खर्च के ${_number(value)} रिकॉर्ड',
};
String _newItems(String value) => switch (_number(value)) {
  1 => '1 नया रिकॉर्ड',
  _ => '${_number(value)} नए रिकॉर्ड',
};
String _updatedLinks(String value) => switch (_number(value)) {
  1 => '1 संबंध अपडेट हुआ',
  _ => '${_number(value)} संबंध अपडेट हुए',
};
String _androidWriteFailure(String value, String error) =>
    'सूचना योजना के ${_items(value)} Android सिस्टम में नहीं लिखे जा सके। पहली त्रुटि: $error';
String _androidMissing(String value) =>
    'सूचना योजना सत्यापित नहीं हो सकी; Android में ${_items(value)} नहीं मिले।';

final List<_HindiPattern> _hindiPatterns = <_HindiPattern>[
  _HindiPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'MİZAN ${t(m[1]!)} रिपोर्ट',
  ),
  _HindiPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => '${m[1]} की वित्तीय रिपोर्ट',
  ),
  _HindiPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · पृष्ठ ${m[1]}',
  ),
  _HindiPattern(RegExp(r'^(.+) · devam$'), (m, t) => '${t(m[1]!)} · जारी'),
  _HindiPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'अवधि: ${m[1]}'),
  _HindiPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'शामिल लोग: ${t(m[1]!)}',
  ),
  _HindiPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'बनाने की तारीख: ${m[1]}',
  ),
  _HindiPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'खुली योजना ${m[1]} · इस महीने किया गया ${m[2]}',
  ),
  _HindiPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => '${m[1]} की भुगतान स्थिति',
  ),
  _HindiPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _HindiPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _HindiPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _HindiPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _HindiPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _HindiPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _HindiPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'और दिन दिखाएँ (${_remaining(m[1]!)})',
  ),
  _HindiPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'और भुगतान दिन दिखाएँ (${_remaining(m[1]!)})',
  ),
  _HindiPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'और खर्च वाले दिन दिखाएँ (${_remaining(m[1]!)})',
  ),
  _HindiPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'इस दिन के और रिकॉर्ड दिखाएँ (${_remaining(m[1]!)})',
  ),
  _HindiPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => '${m[1]} के लिए ${_remainingDays(m[2]!)}',
  ),
  _HindiPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} आज अपेक्षित है',
  ),
  _HindiPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} में ${_days(m[2]!)} की देरी है',
  ),
  _HindiPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'अंतिम प्राप्ति: ${m[1]} · निर्धारित: ${m[2]}',
  ),
  _HindiPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'निर्धारित ${m[1]} अवधि को ${m[2]} पर प्राप्त के रूप में दर्ज किया गया। तय जमा दिन नहीं बदला।',
  ),
  _HindiPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => '${m[1]} की वास्तविक बिल राशि',
  ),
  _HindiPattern(RegExp(r'^Kalan tutar: (.+)$'), (m, t) => 'बाकी राशि: ${m[1]}'),
  _HindiPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _HindiPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'क्या ${m[1]} खर्च रिकॉर्ड हटाया जाए?',
  ),
  _HindiPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) => '${m[1]} श्रेणी और केवल उससे जुड़े खर्च हटाए जाएँगे।',
  ),
  _HindiPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} और इस व्यक्ति से जुड़े सभी रिकॉर्ड हटाए जाएँगे। यह कार्रवाई स्पष्ट पुष्टि के बाद ही होगी।',
  ),
  _HindiPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'PDF रिपोर्ट सहेजी नहीं जा सकी: ${m[1]}',
  ),
  _HindiPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'PDF रिपोर्ट साझा नहीं की जा सकी: ${m[1]}',
  ),
  _HindiPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => _androidWriteFailure(m[1]!, m[2]!),
  ),
  _HindiPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => _androidMissing(m[1]!),
  ),
  _HindiPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'भुगतान रिमाइंडर ${m[1]}',
  ),
  _HindiPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)} जोड़े गए, ${_updatedLinks(m[2]!)}${m[3]}।',
  ),
  _HindiPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'रिकॉर्ड आईडी ${m[1]} अमान्य है या दोहराई गई है।',
  ),
  _HindiPattern(RegExp(r'^(\d+) gün kaldı$'), (m, t) => _remainingDays(m[1]!)),
  _HindiPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => '${_days(m[1]!)} की देरी',
  ),
  _HindiPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'भुगतान में ${_days(m[1]!)} की देरी है।',
  ),
  _HindiPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'अंतिम भुगतान तिथि: ${m[1]}।',
  ),
  _HindiPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'महीने की ${m[1]} तारीख',
  ),
  _HindiPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'हर महीने की ${m[1]} तारीख',
  ),
  _HindiPattern(RegExp(r'^Her (.+)$'), (m, t) => 'हर ${t(m[1]!)}'),
  _HindiPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'आरंभ: ${m[1]}'),
  _HindiPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'आरंभ ${m[1]}'),
  _HindiPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'कुल ${t(m[1]!)}'),
  _HindiPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'बाकी ${t(m[1]!)}'),
  _HindiPattern(RegExp(r'^Bu dönem (.+)$'), (m, t) => 'इस अवधि का ${t(m[1]!)}'),
  _HindiPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'तारीख: ${m[1]}'),
  _HindiPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'नोट: ${m[1]}'),
  _HindiPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} खाली नहीं छोड़ा जा सकता।',
  ),
  _HindiPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => '${t(m[1]!)} में अधिकतम ${m[2]} अक्षर हो सकते हैं।',
  ),
  _HindiPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} शून्य से बड़ा होना चाहिए।',
  ),
  _HindiPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} शून्य से बड़ा होना चाहिए।',
  ),
  _HindiPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} ऋणात्मक नहीं हो सकता।',
  ),
  _HindiPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} धनात्मक पूर्णांक होना चाहिए।',
  ),
  _HindiPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} शून्य या धनात्मक पूर्णांक होना चाहिए।',
  ),
  _HindiPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _HindiPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _HindiPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _HindiPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _HindiPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _HindiPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _HindiPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => _selectedPeople(m[1]!),
  ),
  _HindiPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_newItems(m[1]!)} जोड़े गए; मौजूदा डेटा सुरक्षित रहा।',
  ),
  _HindiPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => '${m[1]} के लिए परीक्षण सटीक समय पर निर्धारित किया गया।',
  ),
  _HindiPattern(
    RegExp(r'^Test planlanamadı: (.+)$'),
    (m, t) => 'परीक्षण निर्धारित नहीं किया जा सका: ${m[1]}',
  ),
  _HindiPattern(
    RegExp(r'^(.+) planlanamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} निर्धारित नहीं किया जा सका: ${m[2]}',
  ),
  _HindiPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => '${t(m[1]!)} सहेजा नहीं जा सका: ${m[2]}',
  ),
  _HindiPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} बनाया नहीं जा सका: ${m[2]}',
  ),
  _HindiPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} साझा नहीं किया जा सका: ${m[2]}',
  ),
  _HindiPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => '${t(m[1]!)} मिलाया नहीं जा सका: ${m[2]}',
  ),
];

const List<(String, String)> _hindiPhrases = <(String, String)>[
  ('Banka borcu', 'बैंक का कर्ज़'),
  ('Kişisel ve kurumsal borçlar', 'व्यक्तिगत और व्यावसायिक कर्ज़'),
  ('Kişisel / kurumsal borç', 'व्यक्तिगत / व्यावसायिक कर्ज़'),
  ('Kişisel/kurumsal borç', 'व्यक्तिगत / व्यावसायिक कर्ज़'),
  ('Ödemelere yapılan gider', 'किए गए भुगतान'),
  ('Bu ay yapılan', 'इस महीने किया गया'),
  ('Açık plan', 'खुली योजना'),
  ('Kalan tutar', 'बाकी राशि'),
  ('Kalan toplam borç', 'कुल बाकी कर्ज़'),
  ('Gecikmiş toplam', 'कुल बकाया'),
  ('Önümüzdeki 7 gün', 'अगले 7 दिन'),
  ('Son ödeme bugün', 'अंतिम भुगतान आज है'),
  ('Banka borçları', 'बैंक के कर्ज़'),
  ('Kira ve taksitler', 'किराया और किस्तें'),
  ('Günlük harcamalar', 'दैनिक खर्च'),
  ('Gider ayrıntıları', 'खर्च का विवरण'),
  ('Ödeme ayrıntıları', 'भुगतान का विवरण'),
  ('Gerçekleşen ödeme', 'किया गया भुगतान'),
  ('Ödeme kayıtları', 'भुगतान रिकॉर्ड'),
  ('Normal giderler', 'नियमित खर्च'),
  ('Toplam gider', 'कुल खर्च'),
  ('Kalan ödeme yükü', 'बाकी भुगतान दायित्व'),
  ('Gecikmiş ödeme yükü', 'बकाया भुगतान दायित्व'),
  ('Yaklaşan ödeme yükü', 'आगामी भुगतान दायित्व'),
  ('Kişi kapsamı', 'शामिल लोग'),
  ('Oluşturulma', 'बनाने की तारीख'),
  ('Dönem', 'अवधि'),
  ('devam', 'जारी'),
];

class _HindiPattern {
  const _HindiPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, HindiDynamicTranslator translate)
  builder;
}
