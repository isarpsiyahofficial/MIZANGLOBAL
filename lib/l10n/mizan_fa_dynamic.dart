typedef PersianDynamicTranslator = String Function(String source);

String translatePersianReviewedDynamic(
  String source,
  PersianDynamicTranslator translate,
) {
  for (final pattern in _persianPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _persianPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

enum _PersianPlural { one, other }

int _number(String value) => int.tryParse(value) ?? 0;
_PersianPlural _category(String value) =>
    _number(value).abs() == 1 ? _PersianPlural.one : _PersianPlural.other;

String _persianDigits(String value) {
  const western = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result.replaceAll(western[index], persian[index]);
  }
  return result;
}

String _count(
  String value, {
  required String zero,
  required String one,
  required String unit,
}) {
  final number = _number(value);
  if (number == 0) return zero;
  if (_category(value) == _PersianPlural.one) return one;
  return '${_persianDigits(value)} $unit';
}

String _days(String value) =>
    _count(value, zero: '۰ روز', one: 'یک روز', unit: 'روز');
String _items(String value) =>
    _count(value, zero: 'بدون رکورد', one: 'یک رکورد', unit: 'رکورد');
String _openItems(String value) => _count(
  value,
  zero: 'بدون رکورد باز',
  one: 'یک رکورد باز',
  unit: 'رکورد باز',
);
String _payments(String value) =>
    _count(value, zero: 'بدون پرداخت', one: 'یک پرداخت', unit: 'پرداخت');
String _expenses(String value) =>
    _count(value, zero: 'بدون هزینه', one: 'یک هزینه', unit: 'هزینه');
String _months(String value) =>
    _count(value, zero: '۰ ماه', one: 'یک ماه', unit: 'ماه');
String _people(String value) =>
    _count(value, zero: 'بدون شخص', one: 'یک شخص', unit: 'شخص');
String _selectedPeople(String value) => '${_people(value)} انتخاب شده';
String _remaining(String value) => 'باقی‌مانده: ${_persianDigits(value)}';
String _remainingDays(String value) {
  final number = _number(value);
  if (number == 0) return 'سررسید امروز است';
  if (number == 1) return 'یک روز باقی مانده';
  return '${_persianDigits(value)} روز باقی مانده';
}

String _remainingInstallments(String value) =>
    'اقساط باقی‌مانده: ${_persianDigits(value)}';
String _dailyExpenses(String value) => _count(
  value,
  zero: 'بدون هزینه روزانه',
  one: 'یک هزینه روزانه',
  unit: 'هزینه روزانه',
);
String _expenseRecords(String value) => _count(
  value,
  zero: 'بدون رکورد هزینه',
  one: 'یک رکورد هزینه',
  unit: 'رکورد هزینه',
);
String _newItems(String value) => _count(
  value,
  zero: 'بدون رکورد جدید',
  one: 'یک رکورد جدید',
  unit: 'رکورد جدید',
);
String _updatedLinks(String value) => _count(
  value,
  zero: 'هیچ ارتباطی به‌روزرسانی نشد',
  one: 'یک ارتباط به‌روزرسانی شد',
  unit: 'ارتباط به‌روزرسانی‌شده',
);
String _androidWriteFailure(String value, String error) =>
    '${_items(value)} از برنامه اعلان در Android نوشته نشد. نخستین خطا: $error';
String _androidMissing(String value) =>
    'برنامه اعلان اعتبارسنجی نشد؛ ${_items(value)} در Android وجود ندارد.';

final List<_PersianPattern> _persianPatterns = <_PersianPattern>[
  _PersianPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'گزارش MİZAN: ${t(m[1]!)}',
  ),
  _PersianPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => 'گزارش مالی: ${m[1]}',
  ),
  _PersianPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · صفحه ${_persianDigits(m[1]!)}',
  ),
  _PersianPattern(RegExp(r'^(.+) · devam$'), (m, t) => '${t(m[1]!)} · ادامه'),
  _PersianPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'دوره: ${m[1]}'),
  _PersianPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'محدوده اشخاص: ${t(m[1]!)}',
  ),
  _PersianPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'تاریخ ایجاد: ${m[1]}',
  ),
  _PersianPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'برنامه باز ${m[1]} · انجام‌شده این ماه ${m[2]}',
  ),
  _PersianPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'وضعیت پرداخت: ${m[1]}',
  ),
  _PersianPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _PersianPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _PersianPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _PersianPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _PersianPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _PersianPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _PersianPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'نمایش روزهای بیشتر (${_remaining(m[1]!)})',
  ),
  _PersianPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'نمایش روزهای پرداخت بیشتر (${_remaining(m[1]!)})',
  ),
  _PersianPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'نمایش روزهای هزینه بیشتر (${_remaining(m[1]!)})',
  ),
  _PersianPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'نمایش رکوردهای بیشتر از این روز (${_remaining(m[1]!)})',
  ),
  _PersianPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => 'تا ${m[1]}، ${_remainingDays(m[2]!)}',
  ),
  _PersianPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} امروز سررسید می‌شود',
  ),
  _PersianPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} به مدت ${_days(m[2]!)} معوق شده است',
  ),
  _PersianPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'آخرین دریافت: ${m[1]} · برنامه‌ریزی‌شده: ${m[2]}',
  ),
  _PersianPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'دوره برنامه‌ریزی‌شده ${m[1]} در تاریخ ${m[2]} دریافت‌شده ثبت شد. روز ثابت واریز تغییر نکرد.',
  ),
  _PersianPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'مبلغ واقعی قبض: ${m[1]}',
  ),
  _PersianPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'مبلغ باقی‌مانده: ${m[1]}',
  ),
  _PersianPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _PersianPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'رکورد هزینه ${m[1]} حذف شود؟',
  ),
  _PersianPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) => 'دسته ${m[1]} و فقط هزینه‌های وابسته به آن حذف می‌شوند.',
  ),
  _PersianPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} و همه رکوردهای مرتبط با این شخص حذف می‌شوند. این عملیات به تأیید صریح نیاز دارد.',
  ),
  _PersianPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'گزارش PDF ذخیره نشد: ${m[1]}',
  ),
  _PersianPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'گزارش PDF به اشتراک گذاشته نشد: ${m[1]}',
  ),
  _PersianPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => _androidWriteFailure(m[1]!, m[2]!),
  ),
  _PersianPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => _androidMissing(m[1]!),
  ),
  _PersianPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'یادآوری پرداخت ${_persianDigits(m[1]!)}',
  ),
  _PersianPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)}, ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _PersianPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'شناسه رکورد ${m[1]} نامعتبر یا تکراری است.',
  ),
  _PersianPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => _remainingDays(m[1]!),
  ),
  _PersianPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => '${_days(m[1]!)} تأخیر',
  ),
  _PersianPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'پرداخت ${_days(m[1]!)} به تأخیر افتاد.',
  ),
  _PersianPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'تاریخ سررسید: ${m[1]}.',
  ),
  _PersianPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'روز ${_persianDigits(m[1]!)} ماه',
  ),
  _PersianPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'روز ${_persianDigits(m[1]!)} هر ماه',
  ),
  _PersianPattern(RegExp(r'^Her (.+)$'), (m, t) => 'هر ${t(m[1]!)}'),
  _PersianPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'شروع: ${m[1]}'),
  _PersianPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'شروع ${m[1]}'),
  _PersianPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'مجموع: ${t(m[1]!)}'),
  _PersianPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'باقی‌مانده: ${t(m[1]!)}'),
  _PersianPattern(RegExp(r'^Bu dönem (.+)$'), (m, t) => '${t(m[1]!)} این دوره'),
  _PersianPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'تاریخ: ${m[1]}'),
  _PersianPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'یادداشت: ${m[1]}'),
  _PersianPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => 'فیلد «${t(m[1]!)}» نمی‌تواند خالی باشد.',
  ),
  _PersianPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) =>
        'فیلد «${t(m[1]!)}» حداکثر می‌تواند ${_persianDigits(m[2]!)} نویسه داشته باشد.',
  ),
  _PersianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => 'مقدار فیلد «${t(m[1]!)}» باید بیشتر از صفر باشد.',
  ),
  _PersianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => 'مقدار فیلد «${t(m[1]!)}» باید بیشتر از صفر باشد.',
  ),
  _PersianPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => 'مقدار فیلد «${t(m[1]!)}» نمی‌تواند منفی باشد.',
  ),
  _PersianPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => 'فیلد «${t(m[1]!)}» باید یک عدد صحیح مثبت باشد.',
  ),
  _PersianPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => 'فیلد «${t(m[1]!)}» باید صفر یا یک عدد صحیح مثبت باشد.',
  ),
  _PersianPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _PersianPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _PersianPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _PersianPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _PersianPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _PersianPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _PersianPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => _selectedPeople(m[1]!),
  ),
  _PersianPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_newItems(m[1]!)} افزوده شد و داده‌های موجود حفظ شدند.',
  ),
  _PersianPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'آزمون به‌صورت دقیق برای ${m[1]} برنامه‌ریزی شد.',
  ),
  _PersianPattern(
    RegExp(r'^Test planlanamadı: (.+)$'),
    (m, t) => 'آزمون برنامه‌ریزی نشد: ${m[1]}',
  ),
  _PersianPattern(
    RegExp(r'^(.+) planlanamadı: (.+)$'),
    (m, t) => '«${t(m[1]!)}» برنامه‌ریزی نشد: ${m[2]}',
  ),
  _PersianPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => '«${t(m[1]!)}» ذخیره نشد: ${m[2]}',
  ),
  _PersianPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => '«${t(m[1]!)}» ساخته نشد: ${m[2]}',
  ),
  _PersianPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => '«${t(m[1]!)}» به اشتراک گذاشته نشد: ${m[2]}',
  ),
  _PersianPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => '«${t(m[1]!)}» ادغام نشد: ${m[2]}',
  ),
];

const List<(String, String)> _persianPhrases = <(String, String)>[
  ('Banka borcu', 'بدهی بانکی'),
  ('Kişisel ve kurumsal borçlar', 'بدهی‌های شخصی و سازمانی'),
  ('Kişisel / kurumsal borç', 'بدهی شخصی یا سازمانی'),
  ('Kişisel/kurumsal borç', 'بدهی شخصی یا سازمانی'),
  ('Ödemelere yapılan gider', 'مبالغ پرداخت‌شده'),
  ('Bu ay yapılan', 'انجام‌شده این ماه'),
  ('Açık plan', 'برنامه باز'),
  ('Kalan tutar', 'مبلغ باقی‌مانده'),
  ('Kalan toplam borç', 'مجموع بدهی باقی‌مانده'),
  ('Gecikmiş toplam', 'مجموع معوق'),
  ('Önümüzdeki 7 gün', 'هفت روز آینده'),
  ('Son ödeme bugün', 'سررسید امروز'),
  ('Banka borçları', 'بدهی‌های بانکی'),
  ('Kira ve taksitler', 'اجاره و اقساط'),
  ('Günlük harcamalar', 'مخارج روزانه'),
  ('Gider ayrıntıları', 'جزئیات هزینه'),
  ('Ödeme ayrıntıları', 'جزئیات پرداخت'),
  ('Gerçekleşen ödeme', 'پرداخت انجام‌شده'),
  ('Ödeme kayıtları', 'رکوردهای پرداخت'),
  ('Normal giderler', 'هزینه‌های عادی'),
  ('Toplam gider', 'مجموع هزینه'),
  ('Kalan ödeme yükü', 'تعهدات پرداخت باقی‌مانده'),
  ('Gecikmiş ödeme yükü', 'تعهد پرداخت معوق'),
  ('Yaklaşan ödeme yükü', 'تعهدات پرداخت نزدیک به سررسید'),
  ('Kişi kapsamı', 'محدوده اشخاص'),
  ('Oluşturulma', 'تاریخ ایجاد'),
  ('Dönem', 'دوره'),
  ('devam', 'ادامه'),
];

class _PersianPattern {
  const _PersianPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, PersianDynamicTranslator translate)
  builder;
}
