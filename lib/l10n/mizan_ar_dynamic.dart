typedef ArabicDynamicTranslator = String Function(String source);

String translateArabicReviewedDynamic(
  String source,
  ArabicDynamicTranslator translate,
) {
  for (final pattern in _arabicPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _arabicPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

enum _ArabicPlural { zero, one, two, few, many, other }

int _number(String value) => int.tryParse(value) ?? 0;
_ArabicPlural _category(String value) {
  final number = _number(value).abs();
  if (number == 0) return _ArabicPlural.zero;
  if (number == 1) return _ArabicPlural.one;
  if (number == 2) return _ArabicPlural.two;
  final mod100 = number % 100;
  if (mod100 >= 3 && mod100 <= 10) return _ArabicPlural.few;
  if (mod100 >= 11 && mod100 <= 99) return _ArabicPlural.many;
  return _ArabicPlural.other;
}

String _count(
  String value, {
  required String zero,
  required String one,
  required String two,
  required String few,
  required String many,
  required String other,
}) => switch (_category(value)) {
  _ArabicPlural.zero => zero,
  _ArabicPlural.one => one,
  _ArabicPlural.two => two,
  _ArabicPlural.few => '$value $few',
  _ArabicPlural.many => '$value $many',
  _ArabicPlural.other => '$value $other',
};

String _days(String value) => _count(
  value,
  zero: '0 يوم',
  one: 'يوم واحد',
  two: 'يومان',
  few: 'أيام',
  many: 'يوما',
  other: 'يوم',
);
String _items(String value) => _count(
  value,
  zero: 'لا سجلات',
  one: 'سجل واحد',
  two: 'سجلان',
  few: 'سجلات',
  many: 'سجلا',
  other: 'سجل',
);
String _openItems(String value) => _count(
  value,
  zero: 'لا سجلات مفتوحة',
  one: 'سجل مفتوح واحد',
  two: 'سجلان مفتوحان',
  few: 'سجلات مفتوحة',
  many: 'سجلا مفتوحا',
  other: 'سجل مفتوح',
);
String _payments(String value) => _count(
  value,
  zero: 'لا دفعات',
  one: 'دفعة واحدة',
  two: 'دفعتان',
  few: 'دفعات',
  many: 'دفعة',
  other: 'دفعة',
);
String _expenses(String value) => _count(
  value,
  zero: 'لا مصروفات',
  one: 'مصروف واحد',
  two: 'مصروفان',
  few: 'مصروفات',
  many: 'مصروفا',
  other: 'مصروف',
);
String _months(String value) => _count(
  value,
  zero: '0 شهر',
  one: 'شهر واحد',
  two: 'شهران',
  few: 'أشهر',
  many: 'شهرا',
  other: 'شهر',
);
String _people(String value) => _count(
  value,
  zero: 'لا أشخاص',
  one: 'شخص واحد',
  two: 'شخصان',
  few: 'أشخاص',
  many: 'شخصا',
  other: 'شخص',
);
String _selectedPeople(String value) => 'تم تحديد ${_people(value)}';
String _remaining(String value) => 'المتبقي: $value';
String _remainingDays(String value) => switch (_category(value)) {
  _ArabicPlural.zero => 'موعد الاستحقاق اليوم',
  _ArabicPlural.one => 'يتبقى يوم واحد',
  _ArabicPlural.two => 'يتبقى يومان',
  _ArabicPlural.few => 'يتبقى ${_days(value)}',
  _ArabicPlural.many => 'يتبقى ${_days(value)}',
  _ArabicPlural.other => 'يتبقى ${_days(value)}',
};
String _remainingInstallments(String value) => 'الأقساط المتبقية: $value';
String _dailyExpenses(String value) => _count(
  value,
  zero: 'لا مصروفات يومية',
  one: 'مصروف يومي واحد',
  two: 'مصروفان يوميان',
  few: 'مصروفات يومية',
  many: 'مصروفا يوميا',
  other: 'مصروف يومي',
);
String _expenseRecords(String value) => _count(
  value,
  zero: 'لا سجلات مصروفات',
  one: 'سجل مصروف واحد',
  two: 'سجلا مصروف',
  few: 'سجلات مصروفات',
  many: 'سجل مصروف',
  other: 'سجل مصروف',
);
String _newItems(String value) => _count(
  value,
  zero: 'لا سجلات جديدة',
  one: 'سجل جديد واحد',
  two: 'سجلان جديدان',
  few: 'سجلات جديدة',
  many: 'سجلا جديدا',
  other: 'سجل جديد',
);
String _updatedLinks(String value) => _count(
  value,
  zero: 'لم يتم تحديث أي علاقة',
  one: 'تم تحديث علاقة واحدة',
  two: 'تم تحديث علاقتين',
  few: 'علاقات محدثة',
  many: 'علاقة محدثة',
  other: 'علاقة محدثة',
);
String _androidWriteFailure(String value, String error) =>
    'تعذرت كتابة ${_items(value)} من جدول الإشعارات إلى Android. الخطأ الأول: $error';
String _androidMissing(String value) =>
    'تعذر التحقق من جدول الإشعارات؛ لا يحتوي Android على ${_items(value)}.';

final List<_ArabicPattern> _arabicPatterns = <_ArabicPattern>[
  _ArabicPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'تقرير MİZAN: ${t(m[1]!)}',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => 'تقرير مالي: ${m[1]}',
  ),
  _ArabicPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · الصفحة ${m[1]}',
  ),
  _ArabicPattern(RegExp(r'^(.+) · devam$'), (m, t) => '${t(m[1]!)} · متابعة'),
  _ArabicPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'الفترة: ${m[1]}'),
  _ArabicPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'نطاق الأشخاص: ${t(m[1]!)}',
  ),
  _ArabicPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'تاريخ الإنشاء: ${m[1]}',
  ),
  _ArabicPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'الخطة المفتوحة ${m[1]} · المنفذ هذا الشهر ${m[2]}',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'حالة الدفعات: ${m[1]}',
  ),
  _ArabicPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _ArabicPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _ArabicPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _ArabicPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _ArabicPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _ArabicPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _ArabicPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'عرض أيام إضافية (${_remaining(m[1]!)})',
  ),
  _ArabicPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'عرض أيام دفعات إضافية (${_remaining(m[1]!)})',
  ),
  _ArabicPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'عرض أيام مصروفات إضافية (${_remaining(m[1]!)})',
  ),
  _ArabicPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'عرض سجلات إضافية من هذا اليوم (${_remaining(m[1]!)})',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => '${_remainingDays(m[2]!)} حتى ${m[1]}',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} مستحق اليوم',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => 'تأخر ${m[1]} لمدة ${_days(m[2]!)}',
  ),
  _ArabicPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'آخر استلام: ${m[1]} · المخطط: ${m[2]}',
  ),
  _ArabicPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'تم تسجيل الفترة المخططة ${m[1]} على أنها مستلمة بتاريخ ${m[2]}. لم يتغير يوم الإيداع الثابت.',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'مبلغ الفاتورة الفعلي: ${m[1]}',
  ),
  _ArabicPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'المبلغ المتبقي: ${m[1]}',
  ),
  _ArabicPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _ArabicPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'هل تريد حذف سجل المصروف ${m[1]}؟',
  ),
  _ArabicPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) => 'سيتم حذف الفئة ${m[1]} والمصروفات المرتبطة بها فقط.',
  ),
  _ArabicPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        'سيتم حذف ${m[1]} وجميع السجلات المرتبطة بهذا الشخص. يتطلب هذا الإجراء تأكيدا صريحا.',
  ),
  _ArabicPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'تعذر حفظ تقرير PDF: ${m[1]}',
  ),
  _ArabicPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'تعذرت مشاركة تقرير PDF: ${m[1]}',
  ),
  _ArabicPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => _androidWriteFailure(m[1]!, m[2]!),
  ),
  _ArabicPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => _androidMissing(m[1]!),
  ),
  _ArabicPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'تذكير الدفعة ${m[1]}',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)}, ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'معرف السجل ${m[1]} غير صالح أو مكرر.',
  ),
  _ArabicPattern(RegExp(r'^(\d+) gün kaldı$'), (m, t) => _remainingDays(m[1]!)),
  _ArabicPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'متأخر لمدة ${_days(m[1]!)}',
  ),
  _ArabicPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'تأخرت الدفعة لمدة ${_days(m[1]!)}.',
  ),
  _ArabicPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'تاريخ الاستحقاق: ${m[1]}.',
  ),
  _ArabicPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'اليوم ${m[1]} من الشهر',
  ),
  _ArabicPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'اليوم ${m[1]} من كل شهر',
  ),
  _ArabicPattern(RegExp(r'^Her (.+)$'), (m, t) => 'كل ${t(m[1]!)}'),
  _ArabicPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'البداية: ${m[1]}'),
  _ArabicPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'البداية ${m[1]}'),
  _ArabicPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'الإجمالي: ${t(m[1]!)}'),
  _ArabicPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'المتبقي: ${t(m[1]!)}'),
  _ArabicPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} لهذه الفترة',
  ),
  _ArabicPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'التاريخ: ${m[1]}'),
  _ArabicPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'ملاحظة: ${m[1]}'),
  _ArabicPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => 'لا يمكن ترك حقل «${t(m[1]!)}» فارغا.',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => 'يمكن أن يحتوي حقل «${t(m[1]!)}» على ${m[2]} حرفا كحد أقصى.',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => 'يجب أن تكون قيمة حقل «${t(m[1]!)}» أكبر من صفر.',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => 'يجب أن تكون قيمة حقل «${t(m[1]!)}» أكبر من صفر.',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => 'لا يمكن أن تكون قيمة حقل «${t(m[1]!)}» سالبة.',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => 'يجب أن يحتوي حقل «${t(m[1]!)}» على عدد صحيح موجب.',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => 'يجب أن يحتوي حقل «${t(m[1]!)}» على صفر أو عدد صحيح موجب.',
  ),
  _ArabicPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _ArabicPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _ArabicPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _ArabicPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _ArabicPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _ArabicPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _ArabicPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => _selectedPeople(m[1]!),
  ),
  _ArabicPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => 'تمت إضافة ${_newItems(m[1]!)} مع الاحتفاظ بالبيانات الحالية.',
  ),
  _ArabicPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'تمت جدولة الاختبار بدقة للوقت ${m[1]}.',
  ),
  _ArabicPattern(
    RegExp(r'^Test planlanamadı: (.+)$'),
    (m, t) => 'تعذرت جدولة الاختبار: ${m[1]}',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) planlanamadı: (.+)$'),
    (m, t) => 'تعذرت جدولة «${t(m[1]!)}»: ${m[2]}',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'تعذر حفظ «${t(m[1]!)}»: ${m[2]}',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'تعذر إنشاء «${t(m[1]!)}»: ${m[2]}',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'تعذرت مشاركة «${t(m[1]!)}»: ${m[2]}',
  ),
  _ArabicPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'تعذر دمج «${t(m[1]!)}»: ${m[2]}',
  ),
];

const List<(String, String)> _arabicPhrases = <(String, String)>[
  ('Banka borcu', 'دين بنكي'),
  ('Kişisel ve kurumsal borçlar', 'الديون الشخصية والمؤسسية'),
  ('Kişisel / kurumsal borç', 'دين شخصي أو مؤسسي'),
  ('Kişisel/kurumsal borç', 'دين شخصي أو مؤسسي'),
  ('Ödemelere yapılan gider', 'المبالغ المدفوعة'),
  ('Bu ay yapılan', 'المنفذ هذا الشهر'),
  ('Açık plan', 'الخطة المفتوحة'),
  ('Kalan tutar', 'المبلغ المتبقي'),
  ('Kalan toplam borç', 'إجمالي الدين المتبقي'),
  ('Gecikmiş toplam', 'إجمالي المبلغ المتأخر'),
  ('Önümüzdeki 7 gün', 'الأيام السبعة المقبلة'),
  ('Son ödeme bugün', 'الاستحقاق اليوم'),
  ('Banka borçları', 'الديون البنكية'),
  ('Kira ve taksitler', 'الإيجار والأقساط'),
  ('Günlük harcamalar', 'المصروفات اليومية'),
  ('Gider ayrıntıları', 'تفاصيل المصروفات'),
  ('Ödeme ayrıntıları', 'تفاصيل الدفعات'),
  ('Gerçekleşen ödeme', 'دفعة منفذة'),
  ('Ödeme kayıtları', 'سجلات الدفعات'),
  ('Normal giderler', 'المصروفات العادية'),
  ('Toplam gider', 'إجمالي المصروفات'),
  ('Kalan ödeme yükü', 'التزامات الدفع المتبقية'),
  ('Gecikmiş ödeme yükü', 'التزامات الدفع المتأخرة'),
  ('Yaklaşan ödeme yükü', 'التزامات الدفع القريبة'),
  ('Kişi kapsamı', 'نطاق الأشخاص'),
  ('Oluşturulma', 'تاريخ الإنشاء'),
  ('Dönem', 'الفترة'),
  ('devam', 'متابعة'),
];

class _ArabicPattern {
  const _ArabicPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, ArabicDynamicTranslator translate)
  builder;
}
