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

String _bnNumber(int value) {
  const western = '0123456789';
  const bengali = '০১২৩৪৫৬৭৮৯';
  var result = value.toString();
  for (var index = 0; index < western.length; index++) {
    result = result.replaceAll(western[index], bengali[index]);
  }
  return result;
}

String _days(String value) => '${_bnNumber(_number(value))} দিন';
String _items(String value) => '${_bnNumber(_number(value))}টি রেকর্ড';
String _openItems(String value) => '${_bnNumber(_number(value))}টি খোলা রেকর্ড';
String _payments(String value) => '${_bnNumber(_number(value))}টি পরিশোধ';
String _expenses(String value) => '${_bnNumber(_number(value))}টি খরচ';
String _months(String value) => '${_bnNumber(_number(value))} মাস';
String _selectedPeople(String value) => switch (_number(value)) {
      0 => 'কোনো ব্যক্তি নির্বাচিত নয়',
      1 => '১ জন ব্যক্তি নির্বাচিত',
      _ => '${_bnNumber(_number(value))} জন ব্যক্তি নির্বাচিত',
    };
String _remaining(String value) => '${_bnNumber(_number(value))}টি বাকি';
String _remainingDays(String value) => switch (_number(value)) {
      0 => 'শেষ পরিশোধ আজ',
      1 => '১ দিন বাকি',
      _ => '${_bnNumber(_number(value))} দিন বাকি',
    };
String _remainingInstallments(String value) => switch (_number(value)) {
      0 => 'কোনো কিস্তি বাকি নেই',
      1 => '১টি কিস্তি বাকি',
      _ => '${_bnNumber(_number(value))}টি কিস্তি বাকি',
    };
String _dailyExpenses(String value) =>
    '${_bnNumber(_number(value))}টি দৈনিক খরচ';
String _expenseRecords(String value) =>
    '${_bnNumber(_number(value))}টি খরচের রেকর্ড';
String _newItems(String value) => '${_bnNumber(_number(value))}টি নতুন রেকর্ড';
String _updatedLinks(String value) =>
    '${_bnNumber(_number(value))}টি সম্পর্ক হালনাগাদ হয়েছে';
String _androidWriteFailure(String value, String error) =>
    'বিজ্ঞপ্তি পরিকল্পনার ${_items(value)} Android সিস্টেমে লেখা যায়নি। প্রথম ত্রুটি: $error';
String _androidMissing(String value) =>
    'বিজ্ঞপ্তি পরিকল্পনা যাচাই করা যায়নি; Android-এ ${_items(value)} অনুপস্থিত।';

final List<_BengaliPattern> _bengaliPatterns = <_BengaliPattern>[
  _BengaliPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'MİZAN ${t(m[1]!)} প্রতিবেদন',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => '${m[1]} আর্থিক প্রতিবেদন',
  ),
  _BengaliPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · পৃষ্ঠা ${_bnNumber(_number(m[1]!))}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · পরবর্তী অংশ',
  ),
  _BengaliPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'সময়পর্ব: ${m[1]}'),
  _BengaliPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'অন্তর্ভুক্ত ব্যক্তি: ${t(m[1]!)}',
  ),
  _BengaliPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'তৈরির সময়: ${m[1]}',
  ),
  _BengaliPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'খোলা পরিকল্পনা ${m[1]} · এই মাসে সম্পন্ন ${m[2]}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => '${m[1]}-এর পরিশোধের অবস্থা',
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
    (m, t) => 'পরিশোধের আরও দিন দেখান (${_remaining(m[1]!)})',
  ),
  _BengaliPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'খরচের আরও দিন দেখান (${_remaining(m[1]!)})',
  ),
  _BengaliPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'এই দিনের আরও রেকর্ড দেখান (${_remaining(m[1]!)})',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => '${m[1]}-এর জন্য ${_remainingDays(m[2]!)}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} আজ প্রত্যাশিত',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} ${_days(m[2]!)} মেয়াদোত্তীর্ণ',
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
        'নির্ধারিত ${m[1]} সময়পর্বটি ${m[2]} তারিখে প্রাপ্ত হিসেবে নথিভুক্ত হয়েছে। নির্ধারিত জমার দিন বদলায়নি।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => '${m[1]}-এর প্রকৃত বিলের পরিমাণ',
  ),
  _BengaliPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'অবশিষ্ট পরিমাণ: ${m[1]}',
  ),
  _BengaliPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _BengaliPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => '${m[1]} খরচের রেকর্ডটি মুছবেন?',
  ),
  _BengaliPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        '${m[1]} বিভাগ এবং শুধু এই বিভাগের সঙ্গে যুক্ত খরচগুলো মুছে যাবে।',
  ),
  _BengaliPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} এবং এই ব্যক্তির সঙ্গে যুক্ত সব রেকর্ড মুছে যাবে। এই কাজ শুধু স্পষ্ট সম্মতি দিয়ে করা যায়।',
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
    (m, t) => 'পরিশোধের অনুস্মারক ${_bnNumber(_number(m[1]!))}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) =>
        '${_newItems(m[1]!)} যোগ হয়েছে এবং ${_updatedLinks(m[2]!)}${m[3]}।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => '${m[1]} রেকর্ড পরিচয়টি বৈধ নয় বা পুনরাবৃত্ত হয়েছে।',
  ),
  _BengaliPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => _remainingDays(m[1]!),
  ),
  _BengaliPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => '${_days(m[1]!)} মেয়াদোত্তীর্ণ',
  ),
  _BengaliPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'পরিশোধটি ${_days(m[1]!)} মেয়াদোত্তীর্ণ।',
  ),
  _BengaliPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'শেষ পরিশোধের তারিখ ${m[1]}।',
  ),
  _BengaliPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'মাসের ${_bnNumber(_number(m[1]!))} তারিখ',
  ),
  _BengaliPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'প্রতি মাসের ${_bnNumber(_number(m[1]!))} তারিখ',
  ),
  _BengaliPattern(RegExp(r'^Her (.+)$'), (m, t) => 'প্রতি ${t(m[1]!)}'),
  _BengaliPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'শুরু: ${m[1]}'),
  _BengaliPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'শুরু ${m[1]}'),
  _BengaliPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'মোট ${t(m[1]!)}'),
  _BengaliPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'অবশিষ্ট ${t(m[1]!)}'),
  _BengaliPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => 'এই সময়পর্বের ${t(m[1]!)}',
  ),
  _BengaliPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'তারিখ: ${m[1]}'),
  _BengaliPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'নোট: ${m[1]}'),
  _BengaliPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} খালি রাখা যাবে না।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) =>
        '${t(m[1]!)} সর্বোচ্চ ${_bnNumber(_number(m[2]!))} অক্ষরের হতে পারে।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} শূন্যের চেয়ে বেশি হতে হবে।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} শূন্যের চেয়ে বেশি হতে হবে।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} ঋণাত্মক হতে পারে না।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} ধনাত্মক পূর্ণসংখ্যা হতে হবে।',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} শূন্য বা ধনাত্মক পূর্ণসংখ্যা হতে হবে।',
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
    (m, t) => '${_newItems(m[1]!)} যোগ হয়েছে; বিদ্যমান তথ্য সুরক্ষিত আছে।',
  ),
  _BengaliPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => '${m[1]}-এর পরীক্ষা সঠিক সময়ে নির্ধারিত হয়েছে।',
  ),
  _BengaliPattern(
    RegExp(r'^Test planlanamadı: (.+)$'),
    (m, t) => 'পরীক্ষার সময়সূচি তৈরি করা যায়নি: ${m[1]}',
  ),
  _BengaliPattern(
    RegExp(r'^(.+) planlanamadı: (.+)$'),
    (m, t) => '${t(m[1]!)}-এর সময়সূচি তৈরি করা যায়নি: ${m[2]}',
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
    (m, t) => '${t(m[1]!)} একত্র করা যায়নি: ${m[2]}',
  ),
];

const List<(String, String)> _bengaliPhrases = <(String, String)>[
  ('Banka borcu', 'ব্যাংক ঋণ'),
  ('Kişisel ve kurumsal borçlar', 'ব্যক্তিগত ও ব্যবসায়িক ঋণ'),
  ('Kişisel / kurumsal borç', 'ব্যক্তিগত / ব্যবসায়িক ঋণ'),
  ('Kişisel/kurumsal borç', 'ব্যক্তিগত / ব্যবসায়িক ঋণ'),
  ('Ödemelere yapılan gider', 'পরিশোধ বাবদ খরচ'),
  ('Bu ay yapılan', 'এই মাসে সম্পন্ন'),
  ('Açık plan', 'খোলা পরিকল্পনা'),
  ('Kalan tutar', 'অবশিষ্ট পরিমাণ'),
  ('Kalan toplam borç', 'মোট অবশিষ্ট ঋণ'),
  ('Gecikmiş toplam', 'মোট মেয়াদোত্তীর্ণ'),
  ('Önümüzdeki 7 gün', 'আগামী ৭ দিন'),
  ('Son ödeme bugün', 'শেষ পরিশোধ আজ'),
  ('Banka borçları', 'ব্যাংক ঋণ'),
  ('Kira ve taksitler', 'ভাড়া ও কিস্তি'),
  ('Günlük harcamalar', 'দৈনিক খরচ'),
  ('Gider ayrıntıları', 'খরচের বিস্তারিত'),
  ('Ödeme ayrıntıları', 'পরিশোধের বিস্তারিত'),
  ('Gerçekleşen ödeme', 'সম্পন্ন পরিশোধ'),
  ('Ödeme kayıtları', 'পরিশোধের রেকর্ড'),
  ('Normal giderler', 'সাধারণ খরচ'),
  ('Toplam gider', 'মোট খরচ'),
  ('Kalan ödeme yükü', 'অবশিষ্ট পরিশোধের দায়'),
  ('Gecikmiş ödeme yükü', 'মেয়াদোত্তীর্ণ পরিশোধের দায়'),
  ('Yaklaşan ödeme yükü', 'আসন্ন পরিশোধের দায়'),
  ('Kişi kapsamı', 'অন্তর্ভুক্ত ব্যক্তি'),
  ('Oluşturulma', 'তৈরির সময়'),
  ('Dönem', 'সময়পর্ব'),
  ('devam', 'পরবর্তী অংশ'),
];

class _BengaliPattern {
  const _BengaliPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, BengaliDynamicTranslator translate)
      builder;
}
