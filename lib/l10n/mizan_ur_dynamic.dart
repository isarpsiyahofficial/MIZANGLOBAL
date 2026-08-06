typedef UrduDynamicTranslator = String Function(String source);

String translateUrduReviewedDynamic(
  String source,
  UrduDynamicTranslator translate,
) {
  for (final pattern in _urduPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _urduPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

int _number(String value) => int.tryParse(value) ?? 0;

String _days(String value) => '${_number(value)} دن';
String _items(String value) => '${_number(value)} ریکارڈ';
String _openItems(String value) => '${_number(value)} کھلے ریکارڈ';
String _payments(String value) => '${_number(value)} ادائیگیاں';
String _expenses(String value) => '${_number(value)} اخراجات';
String _months(String value) => '${_number(value)} ماہ';
String _selectedPeople(String value) => switch (_number(value)) {
  0 => 'کوئی فرد منتخب نہیں',
  1 => '1 فرد منتخب',
  _ => '${_number(value)} افراد منتخب',
};
String _remaining(String value) => '$value باقی';
String _remainingDays(String value) => switch (_number(value)) {
  0 => 'آخری ادائیگی آج ہے',
  1 => '1 دن باقی',
  _ => '${_number(value)} دن باقی',
};
String _remainingInstallments(String value) => switch (_number(value)) {
  0 => 'کوئی قسط باقی نہیں',
  1 => '1 قسط باقی',
  _ => '${_number(value)} اقساط باقی',
};
String _dailyExpenses(String value) => '${_number(value)} روزانہ اخراجات';
String _expenseRecords(String value) => '${_number(value)} خرچ کے ریکارڈ';
String _newItems(String value) => '${_number(value)} نئے ریکارڈ';
String _updatedLinks(String value) => '${_number(value)} تعلقات اپ ڈیٹ ہوئے';
String _androidWriteFailure(String value, String error) =>
    'نوٹیفکیشن منصوبے کے ${_items(value)} Android نظام میں درج نہیں کیے جا سکے۔ پہلی خرابی: $error';
String _androidMissing(String value) =>
    'نوٹیفکیشن منصوبے کی توثیق نہیں ہو سکی؛ Android میں ${_items(value)} موجود نہیں ہیں۔';

final List<_UrduPattern> _urduPatterns = <_UrduPattern>[
  _UrduPattern(RegExp(r'^MİZAN (.+) Raporu$'), (m, t) => 'MİZAN ${t(m[1]!)} رپورٹ'),
  _UrduPattern(RegExp(r'^(.+) finans raporu$'), (m, t) => '${m[1]} کی مالی رپورٹ'),
  _UrduPattern(RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'), (m, t) => 'LEFFERION PRIME - MİZAN · صفحہ ${m[1]}'),
  _UrduPattern(RegExp(r'^(.+) · devam$'), (m, t) => '${t(m[1]!)} · جاری'),
  _UrduPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'مدت: ${m[1]}'),
  _UrduPattern(RegExp(r'^Kişi kapsamı: (.+)$'), (m, t) => 'شامل افراد: ${t(m[1]!)}'),
  _UrduPattern(RegExp(r'^Oluşturulma: (.+)$'), (m, t) => 'تیاری کی تاریخ: ${m[1]}'),
  _UrduPattern(RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'), (m, t) => 'کھلا منصوبہ ${m[1]} · اس ماہ ادا کیا گیا ${m[2]}'),
  _UrduPattern(RegExp(r'^(.+) Ödeme Durumu$'), (m, t) => '${m[1]} کی ادائیگی کی حالت'),
  _UrduPattern(RegExp(r'^(\d+) açık kayıt · (.+)$'), (m, t) => '${_openItems(m[1]!)} · ${m[2]}'),
  _UrduPattern(RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'), (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}'),
  _UrduPattern(RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'), (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}'),
  _UrduPattern(RegExp(r'^(\d+) ödeme · (.+)$'), (m, t) => '${_payments(m[1]!)} · ${m[2]}'),
  _UrduPattern(RegExp(r'^(\d+) gider · (.+)$'), (m, t) => '${_expenses(m[1]!)} · ${m[2]}'),
  _UrduPattern(RegExp(r'^(\d+) gider kaydı$'), (m, t) => _expenseRecords(m[1]!)),
  _UrduPattern(RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'), (m, t) => 'اور دن دکھائیں (${_remaining(m[1]!)})'),
  _UrduPattern(RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'), (m, t) => 'ادائیگی کے مزید دن دکھائیں (${_remaining(m[1]!)})'),
  _UrduPattern(RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'), (m, t) => 'اخراجات کے مزید دن دکھائیں (${_remaining(m[1]!)})'),
  _UrduPattern(RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'), (m, t) => 'اس دن کے مزید ریکارڈ دکھائیں (${_remaining(m[1]!)})'),
  _UrduPattern(RegExp(r'^(.+) için (\d+) gün kaldı$'), (m, t) => '${m[1]} کے لیے ${_remainingDays(m[2]!)}'),
  _UrduPattern(RegExp(r'^(.+) bugün bekleniyor$'), (m, t) => '${m[1]} آج متوقع ہے'),
  _UrduPattern(RegExp(r'^(.+) (\d+) gün gecikti$'), (m, t) => '${m[1]} میں ${_days(m[2]!)} کی تاخیر ہے'),
  _UrduPattern(RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'), (m, t) => 'آخری وصولی: ${m[1]} · طے شدہ: ${m[2]}'),
  _UrduPattern(RegExp(r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$'), (m, t) => 'طے شدہ ${m[1]} مدت کو ${m[2]} کو موصول شدہ کے طور پر درج کیا گیا۔ مقررہ وصولی کا دن تبدیل نہیں ہوا۔'),
  _UrduPattern(RegExp(r'^(.+) gerçek fatura tutarı$'), (m, t) => '${m[1]} کے بل کی حقیقی رقم'),
  _UrduPattern(RegExp(r'^Kalan tutar: (.+)$'), (m, t) => 'باقی رقم: ${m[1]}'),
  _UrduPattern(RegExp(r'^Kalan taksit: (\d+)$'), (m, t) => _remainingInstallments(m[1]!)),
  _UrduPattern(RegExp(r'^(.+) gider kaydı silinsin mi\?$'), (m, t) => 'کیا ${m[1]} خرچ کا ریکارڈ حذف کر دیا جائے؟'),
  _UrduPattern(RegExp(r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$'), (m, t) => '${m[1]} زمرہ اور صرف اس سے منسلک اخراجات حذف کیے جائیں گے۔'),
  _UrduPattern(RegExp(r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$'), (m, t) => '${m[1]} اور اس فرد سے منسلک تمام ریکارڈ حذف کیے جائیں گے۔ یہ کارروائی واضح تصدیق کے بعد ہی ہوگی۔'),
  _UrduPattern(RegExp(r'^PDF raporu kaydedilemedi: (.+)$'), (m, t) => 'PDF رپورٹ محفوظ نہیں کی جا سکی: ${m[1]}'),
  _UrduPattern(RegExp(r'^PDF raporu paylaşılamadı: (.+)$'), (m, t) => 'PDF رپورٹ شیئر نہیں کی جا سکی: ${m[1]}'),
  _UrduPattern(RegExp(r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$'), (m, t) => _androidWriteFailure(m[1]!, m[2]!)),
  _UrduPattern(RegExp(r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$'), (m, t) => _androidMissing(m[1]!)),
  _UrduPattern(RegExp(r'^Ödeme hatırlatması (\d+)$'), (m, t) => 'ادائیگی کی یاددہانی ${m[1]}'),
  _UrduPattern(RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'), (m, t) => '${_newItems(m[1]!)} شامل کیے گئے، ${_updatedLinks(m[2]!)}${m[3]}۔'),
  _UrduPattern(RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'), (m, t) => 'ریکارڈ آئی ڈی ${m[1]} نامعتبر ہے یا دہرائی گئی ہے۔'),
  _UrduPattern(RegExp(r'^(\d+) gün kaldı$'), (m, t) => _remainingDays(m[1]!)),
  _UrduPattern(RegExp(r'^(\d+) gün gecikmede$'), (m, t) => '${_days(m[1]!)} کی تاخیر'),
  _UrduPattern(RegExp(r'^Ödeme (\d+) gün gecikti\.$'), (m, t) => 'ادائیگی میں ${_days(m[1]!)} کی تاخیر ہے۔'),
  _UrduPattern(RegExp(r'^Son ödeme (.+)\.$'), (m, t) => 'آخری ادائیگی کی تاریخ: ${m[1]}۔'),
  _UrduPattern(RegExp(r'^Ayın (\d+)\. günü$'), (m, t) => 'ماہ کا ${m[1]}واں دن'),
  _UrduPattern(RegExp(r'^Her ayın (\d+)\. günü$'), (m, t) => 'ہر ماہ کا ${m[1]}واں دن'),
  _UrduPattern(RegExp(r'^Her (.+)$'), (m, t) => 'ہر ${t(m[1]!)}'),
  _UrduPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'آغاز: ${m[1]}'),
  _UrduPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'آغاز ${m[1]}'),
  _UrduPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'کل ${t(m[1]!)}'),
  _UrduPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'باقی ${t(m[1]!)}'),
  _UrduPattern(RegExp(r'^Bu dönem (.+)$'), (m, t) => 'اس مدت کا ${t(m[1]!)}'),
  _UrduPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'تاریخ: ${m[1]}'),
  _UrduPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'نوٹ: ${m[1]}'),
  _UrduPattern(RegExp(r'^(.+) boş bırakılamaz\.$'), (m, t) => '${t(m[1]!)} خالی نہیں چھوڑا جا سکتا۔'),
  _UrduPattern(RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'), (m, t) => '${t(m[1]!)} میں زیادہ سے زیادہ ${m[2]} حروف ہو سکتے ہیں۔'),
  _UrduPattern(RegExp(r'^(.+) sıfırdan büyük olmalı\.$'), (m, t) => '${t(m[1]!)} صفر سے زیادہ ہونا چاہیے۔'),
  _UrduPattern(RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'), (m, t) => '${t(m[1]!)} صفر سے زیادہ ہونا چاہیے۔'),
  _UrduPattern(RegExp(r'^(.+) negatif olamaz\.$'), (m, t) => '${t(m[1]!)} منفی نہیں ہو سکتا۔'),
  _UrduPattern(RegExp(r'^(.+) pozitif tam sayı olmalı\.$'), (m, t) => '${t(m[1]!)} مثبت صحیح عدد ہونا چاہیے۔'),
  _UrduPattern(RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'), (m, t) => '${t(m[1]!)} صفر یا مثبت صحیح عدد ہونا چاہیے۔'),
  _UrduPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _UrduPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _UrduPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _UrduPattern(RegExp(r'^(.+) · (\d+) kayıt$'), (m, t) => '${m[1]} · ${_items(m[2]!)}'),
  _UrduPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _UrduPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _UrduPattern(RegExp(r'^(.+) kişi seçili$'), (m, t) => _selectedPeople(m[1]!)),
  _UrduPattern(RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'), (m, t) => '${_newItems(m[1]!)} شامل کیے گئے؛ موجودہ ڈیٹا محفوظ رہا۔'),
  _UrduPattern(RegExp(r'^Test (.+) için dakik olarak planlandı\.$'), (m, t) => '${m[1]} کے لیے عین وقت کا ٹیسٹ مقرر کیا گیا۔'),
  _UrduPattern(RegExp(r'^Test planlanamadı: (.+)$'), (m, t) => 'ٹیسٹ مقرر نہیں کیا جا سکا: ${m[1]}'),
  _UrduPattern(RegExp(r'^(.+) planlanamadı: (.+)$'), (m, t) => '${t(m[1]!)} مقرر نہیں کیا جا سکا: ${m[2]}'),
  _UrduPattern(RegExp(r'^(.+) kaydedilemedi: (.+)$'), (m, t) => '${t(m[1]!)} محفوظ نہیں کیا جا سکا: ${m[2]}'),
  _UrduPattern(RegExp(r'^(.+) oluşturulamadı: (.+)$'), (m, t) => '${t(m[1]!)} بنایا نہیں جا سکا: ${m[2]}'),
  _UrduPattern(RegExp(r'^(.+) paylaşılamadı: (.+)$'), (m, t) => '${t(m[1]!)} شیئر نہیں کیا جا سکا: ${m[2]}'),
  _UrduPattern(RegExp(r'^(.+) birleştirilemedi: (.+)$'), (m, t) => '${t(m[1]!)} ضم نہیں کیا جا سکا: ${m[2]}'),
];

const List<(String, String)> _urduPhrases = <(String, String)>[
  ('Banka borcu', 'بینک کا قرض'),
  ('Kişisel ve kurumsal borçlar', 'ذاتی اور کاروباری قرض'),
  ('Kişisel / kurumsal borç', 'ذاتی / کاروباری قرض'),
  ('Kişisel/kurumsal borç', 'ذاتی / کاروباری قرض'),
  ('Ödemelere yapılan gider', 'کی گئی ادائیگیاں'),
  ('Bu ay yapılan', 'اس ماہ ادا کیا گیا'),
  ('Açık plan', 'کھلا منصوبہ'),
  ('Kalan tutar', 'باقی رقم'),
  ('Kalan toplam borç', 'کل باقی قرض'),
  ('Gecikmiş toplam', 'کل تاخیر کا شکار رقم'),
  ('Önümüzdeki 7 gün', 'اگلے 7 دن'),
  ('Son ödeme bugün', 'آخری ادائیگی آج ہے'),
  ('Banka borçları', 'بینک قرض'),
  ('Kira ve taksitler', 'کرایہ اور اقساط'),
  ('Günlük harcamalar', 'روزانہ اخراجات'),
  ('Gider ayrıntıları', 'اخراجات کی تفصیل'),
  ('Ödeme ayrıntıları', 'ادائیگی کی تفصیل'),
  ('Gerçekleşen ödeme', 'کی گئی ادائیگی'),
  ('Ödeme kayıtları', 'ادائیگی کے ریکارڈ'),
  ('Normal giderler', 'معمول کے اخراجات'),
  ('Toplam gider', 'کل اخراجات'),
  ('Kalan ödeme yükü', 'باقی ادائیگی کا بوجھ'),
  ('Gecikmiş ödeme yükü', 'تاخیر کا شکار ادائیگی کا بوجھ'),
  ('Yaklaşan ödeme yükü', 'آنے والی ادائیگی کا بوجھ'),
  ('Kişi kapsamı', 'شامل افراد'),
  ('Oluşturulma', 'تیاری کی تاریخ'),
  ('Dönem', 'مدت'),
  ('devam', 'جاری'),
];

class _UrduPattern {
  const _UrduPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, UrduDynamicTranslator translate) builder;
}
