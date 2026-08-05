typedef BengaliDynamicTranslator = String Function(String source);

String translateBengaliReviewedDynamic(
  String source,
  BengaliDynamicTranslator translate,
) {
  for (final pattern in _bengaliPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _bengaliPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

int _number(String value) => int.tryParse(value) ?? 0;

String _days(String value) => '${_number(value)} দিন';
String _items(String value) => '${_number(value)} রেকর্ড';
String _openItems(String value) => '${_number(value)} খোলা রেকর্ড';
String _payments(String value) => '${_number(value)} পরিশোধ';
String _expenses(String value) => '${_number(value)} খরচ';
String _months(String value) => switch (_number(value)) {
  1 => '1 মাস',
  _ => '${_number(value)} মাস',
};
String _selectedPeople(String value) => switch (_number(value)) {
  0 => 'কোন ব্যক্তি নির্বাচিত নয়',
  1 => '1 জনকে নির্বাচিত করা হয়েছে।',
  _ => '${_number(value)} লোক নির্বাচিত',
};
String _remaining(String value) => '$value বিশ্রাম';
String _remainingDays(String value) => switch (_number(value)) {
  0 => 'শেষ পরিশোধ আজ',
  1 => '১ দিন বাকি',
  _ => '${_number(value)} দিন বাকি',
};
String _remainingInstallments(String value) => switch (_number(value)) {
  0 => 'কোন কিস্তি বাকি নেই',
  1 => '১টি কিস্তি বাকি',
  _ => '${_number(value)} কিস্তি বাকি',
};
String _dailyExpenses(String value) => '${_number(value)} দৈনিক খরচ';
String _expenseRecords(String value) => switch (_number(value)) {
  1 => '1 খরচের রেকর্ড',
  _ => '${_number(value)} খরচের রেকর্ড',
};
String _newItems(String value) => switch (_number(value)) {
  1 => '1টি নতুন রেকর্ড',
  _ => '${_number(value)} নতুন রেকর্ড',
};
String _updatedLinks(String value) => switch (_number(value)) {
  1 => '1টি সম্পর্ক আপডেট করা হয়েছে',
  _ => '${_number(value)} সম্পর্ক আপডেট করা হয়েছে',
};
String _androidWriteFailure(String value, String error) =>
    'প্ল্যানের তথ্য ${_items(value)} Android সিস্টেমে লেখা যাবে না। প্রথম ত্রুটি: $error';
String _androidMissing(String value) =>
    'তথ্য পরিকল্পনা যাচাই করা যায়নি; ${_items(value)} Android এ পাওয়া যায়নি।';

final List<_BengaliPattern> _bengaliPatterns = <_BengaliPattern>[
  _BengaliPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'MİZAN ${t(m[1]!)} প্রতিবেদন',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => '${m[1]} এর আর্থিক প্রতিবেদন',
  ),
  _BengaliPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN পৃষ্ঠা ${m[1]}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · প্রকাশিত হয়েছে',
  ),
  _BengaliPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'সময়কাল: ${m[1]}'),
  _BengaliPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'জড়িত ব্যক্তি: ${t(m[1]!)}',
  ),
  _BengaliPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'তারিখ তৈরি করুন: ${m[1]}',
  ),
  _BengaliPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => '${m[1]} খোলা প্ল্যান · ${m[2]} এই মাসে সম্পন্ন হয়েছে',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => '${m[1]} এর পরিশোধের স্থিতি',
  ),
  _BengaliPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _BengaliPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _BengaliPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _BengaliPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _BengaliPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _BengaliPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _BengaliPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'আরও দিন দেখান (${_remaining(m[1]!)})',
  ),
  _BengaliPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'আরও পরিশোধ দিন দেখান (${_remaining(m[1]!)})',
  ),
  _BengaliPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'আরও ব্যয়ের দিন দেখান (${_remaining(m[1]!)})',
  ),
  _BengaliPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'এই দিনের জন্য আরও রেকর্ড দেখান (${_remaining(m[1]!)})',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => '${_remainingDays(m[2]!)} এর জন্য ${m[1]}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} আজ প্রত্যাশিত',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]}-এ ${_days(m[2]!)}-এর বিলম্ব আছে',
  ),
  _BengaliPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'সর্বশেষ প্রাপ্তি: ${m[1]} · নির্ধারিত: ${m[2]}',
  ),
  _BengaliPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        '${m[2]} এ প্রাপ্ত হিসাবে স্থির ${m[1]} সময়কাল রেকর্ড করা হয়েছে। ফিক্সড ডিপোজিটের দিন পরিবর্তন হয়নি।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => '${m[1]} এর প্রকৃত বিলের পরিমাণ',
  ),
  _BengaliPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'ব্যালেন্স: ${m[1]}',
  ),
  _BengaliPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _BengaliPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => '${m[1]} খরচ রেকর্ড মুছে ফেলা উচিত?',
  ),
  _BengaliPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        '${m[1]} বিভাগ এবং শুধুমাত্র এর সাথে সম্পর্কিত খরচগুলি সরানো হবে।',
  ),
  _BengaliPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} এবং এই ব্যক্তির সাথে সম্পর্কিত সমস্ত রেকর্ড মুছে ফেলা হবে। স্পষ্ট নিশ্চিত হওয়ার পরই এই ব্যবস্থা নেওয়া হবে।',
  ),
  _BengaliPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'PDF প্রতিবেদন সংরক্ষণ করা যায়নি: ${m[1]}',
  ),
  _BengaliPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'PDF প্রতিবেদন শেয়ার করা যায়নি: ${m[1]}',
  ),
  _BengaliPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => _androidWriteFailure(m[1]!, m[2]!),
  ),
  _BengaliPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => _androidMissing(m[1]!),
  ),
  _BengaliPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'পরিশোধ অনুস্মারক ${m[1]}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) =>
        '${_newItems(m[1]!)}, ${_updatedLinks(m[2]!)}${m[3]} যোগ করা হয়েছে।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'রেকর্ড আইডি ${m[1]} অবৈধ বা সদৃশ।',
  ),
  _BengaliPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => _remainingDays(m[1]!),
  ),
  _BengaliPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => '${_days(m[1]!)} বিলম্ব',
  ),
  _BengaliPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => '${_days(m[1]!)} পরিশোধে বিলম্ব হচ্ছে।',
  ),
  _BengaliPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'শেষ পরিশোধের তারিখ: ${m[1]}।',
  ),
  _BengaliPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'মাসের ${m[1]} তারিখ',
  ),
  _BengaliPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'প্রতি মাসের ${m[1]} তারিখ',
  ),
  _BengaliPattern(RegExp(r'^Her (.+)$'), (m, t) => 'প্রতি ${t(m[1]!)}'),
  _BengaliPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'শুরু: ${m[1]}'),
  _BengaliPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => '${m[1]} শুরু করুন'),
  _BengaliPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'মোট ${t(m[1]!)}'),
  _BengaliPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'বাকি ${t(m[1]!)}'),
  _BengaliPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => 'এই সময়ের ${t(m[1]!)}',
  ),
  _BengaliPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'তারিখ: ${m[1]}'),
  _BengaliPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'দ্রষ্টব্য: ${m[1]}'),
  _BengaliPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} খালি রাখা যাবে না।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => '${t(m[1]!)} সর্বাধিক ${m[2]} অক্ষর থাকতে পারে।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} অবশ্যই শূন্যের বেশি হতে হবে।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} অবশ্যই শূন্যের বেশি হতে হবে।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} নেতিবাচক হতে পারে না।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} একটি ধনাত্মক পূর্ণসংখ্যা হতে হবে।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} অবশ্যই শূন্য বা একটি ধনাত্মক পূর্ণসংখ্যা হতে হবে।',
  ),
  _BengaliPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _BengaliPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _BengaliPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _BengaliPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _BengaliPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _BengaliPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _BengaliPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => _selectedPeople(m[1]!),
  ),
  _BengaliPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_newItems(m[1]!)} যোগ করা হয়েছে; বিদ্যমান তথ্য নিরাপদ ছিল।',
  ),
  _BengaliPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => '${m[1]}-এর পরীক্ষা নিখুঁত সময়ে নির্ধারিত ছিল।',
  ),
  _BengaliPattern(
    RegExp(r'^Test planlanamadı: (.+)$'),
    (m, t) => 'পরীক্ষা নির্ধারিত করা যায়নি: ${m[1]}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) planlanamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} নির্ধারণ করা যায়নি: ${m[2]}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => '${t(m[1]!)} সংরক্ষণ করা যায়নি: ${m[2]}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} তৈরি করা যায়নি: ${m[2]}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} শেয়ার করা যায়নি: ${m[2]}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => '${t(m[1]!)} মিশ্রিত করা যায়নি: ${m[2]}',
  ),
];

const List<(String, String)> _bengaliPhrases = <(String, String)>[
  ('Banka borcu', 'ব্যাংক ঋণ'),
  ('Kişisel ve kurumsal borçlar', 'ব্যক্তিগত এবং ব্যবসা ঋণ'),
  ('Kişisel / kurumsal borç', 'ব্যক্তিগত/ব্যবসায়িক ঋণ'),
  ('Kişisel/kurumsal borç', 'ব্যক্তিগত/ব্যবসায়িক ঋণ'),
  ('Ödemelere yapılan gider', 'পরিশোধ করা'),
  ('Bu ay yapılan', 'এই মাসে করা হয়েছে'),
  ('Açık plan', 'খোলা পরিকল্পনা'),
  ('Kalan tutar', 'অবশিষ্ট পরিমাণ'),
  ('Kalan toplam borç', 'মোট অবশিষ্ট ঋণ'),
  ('Gecikmiş toplam', 'অসামান্য মোট'),
  ('Önümüzdeki 7 gün', 'পরবর্তী 7 দিন'),
  ('Son ödeme bugün', 'শেষ পরিশোধ আজ'),
  ('Banka borçları', 'ব্যাংক ঋণ'),
  ('Kira ve taksitler', 'ভাড়া এবং কিস্তি'),
  ('Günlük harcamalar', 'দৈনিক খরচ'),
  ('Gider ayrıntıları', 'ব্যয়ের বিবরণ'),
  ('Ödeme ayrıntıları', 'পরিশোধ বিবরণ'),
  ('Gerçekleşen ödeme', 'পরিশোধ করা হয়েছে'),
  ('Ödeme kayıtları', 'পরিশোধ রেকর্ড'),
  ('Normal giderler', 'নিয়মিত খরচ'),
  ('Toplam gider', 'মোট খরচ'),
  ('Kalan ödeme yükü', 'অবশিষ্ট পরিশোধ বাধ্যবাধকতা'),
  ('Gecikmiş ödeme yükü', 'অসামান্য পরিশোধ বাধ্যবাধকতা'),
  ('Yaklaşan ödeme yükü', 'আসন্ন পরিশোধ বাধ্যবাধকতা'),
  ('Kişi kapsamı', 'জড়িত মানুষ'),
  ('Oluşturulma', 'সৃষ্টির তারিখ'),
  ('Dönem', 'সময়কাল'),
  ('devam', 'চলমান'),
];

class _BengaliPattern {
  const _BengaliPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, BengaliDynamicTranslator translate)
  builder;
}
