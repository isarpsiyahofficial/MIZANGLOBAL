typedef HebrewDynamicTranslator = String Function(String source);

String translateHebrewReviewedDynamic(
  String source,
  HebrewDynamicTranslator translate,
) {
  for (final pattern in _hebrewPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _hebrewPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

enum _HebrewPlural { one, two, other }

int _number(String value) => int.tryParse(value) ?? 0;
_HebrewPlural _category(String value) => switch (_number(value).abs()) {
  1 => _HebrewPlural.one,
  2 => _HebrewPlural.two,
  _ => _HebrewPlural.other,
};

String _count(
  String value, {
  required String zero,
  required String one,
  required String two,
  required String otherUnit,
}) {
  final number = _number(value);
  if (number == 0) return zero;
  return switch (_category(value)) {
    _HebrewPlural.one => one,
    _HebrewPlural.two => two,
    _HebrewPlural.other => '$value $otherUnit',
  };
}

String _days(String value) => _count(
  value,
  zero: '0 ימים',
  one: 'יום אחד',
  two: 'יומיים',
  otherUnit: 'ימים',
);
String _items(String value) => _count(
  value,
  zero: 'ללא רשומות',
  one: 'רשומה אחת',
  two: 'שתי רשומות',
  otherUnit: 'רשומות',
);
String _openItems(String value) => _count(
  value,
  zero: 'ללא רשומות פתוחות',
  one: 'רשומה פתוחה אחת',
  two: 'שתי רשומות פתוחות',
  otherUnit: 'רשומות פתוחות',
);
String _payments(String value) => _count(
  value,
  zero: 'ללא תשלומים',
  one: 'תשלום אחד',
  two: 'שני תשלומים',
  otherUnit: 'תשלומים',
);
String _expenses(String value) => _count(
  value,
  zero: 'ללא הוצאות',
  one: 'הוצאה אחת',
  two: 'שתי הוצאות',
  otherUnit: 'הוצאות',
);
String _months(String value) => _count(
  value,
  zero: '0 חודשים',
  one: 'חודש אחד',
  two: 'חודשיים',
  otherUnit: 'חודשים',
);
String _people(String value) => _count(
  value,
  zero: 'ללא אנשים',
  one: 'אדם אחד',
  two: 'שני אנשים',
  otherUnit: 'אנשים',
);
String _selectedPeople(String value) => switch (_category(value)) {
  _HebrewPlural.one => 'נבחר אדם אחד',
  _HebrewPlural.two => 'נבחרו שני אנשים',
  _HebrewPlural.other => _number(value) == 0
      ? 'לא נבחרו אנשים'
      : 'נבחרו $value אנשים',
};
String _remaining(String value) => 'נותרו: $value';
String _remainingDays(String value) {
  final number = _number(value);
  if (number == 0) return 'מועד הפירעון היום';
  if (number == 1) return 'נותר יום אחד';
  if (number == 2) return 'נותרו יומיים';
  return 'נותרו $value ימים';
}

String _remainingInstallments(String value) => switch (_category(value)) {
  _HebrewPlural.one => 'נותר תשלום אחד',
  _HebrewPlural.two => 'נותרו שני תשלומים',
  _HebrewPlural.other => 'נותרו $value תשלומים',
};
String _dailyExpenses(String value) => _count(
  value,
  zero: 'ללא הוצאות יומיות',
  one: 'הוצאה יומית אחת',
  two: 'שתי הוצאות יומיות',
  otherUnit: 'הוצאות יומיות',
);
String _expenseRecords(String value) => _count(
  value,
  zero: 'ללא רשומות הוצאה',
  one: 'רשומת הוצאה אחת',
  two: 'שתי רשומות הוצאה',
  otherUnit: 'רשומות הוצאה',
);
String _newItems(String value) => _count(
  value,
  zero: 'ללא רשומות חדשות',
  one: 'רשומה חדשה אחת',
  two: 'שתי רשומות חדשות',
  otherUnit: 'רשומות חדשות',
);
String _updatedLinks(String value) => _count(
  value,
  zero: 'לא עודכנו קישורים',
  one: 'קישור אחד עודכן',
  two: 'שני קישורים עודכנו',
  otherUnit: 'קישורים עודכנו',
);
String _androidWriteFailure(String value, String error) =>
    '${_items(value)} מתוכנית ההתראות לא נכתבו למערכת Android. השגיאה הראשונה: $error';
String _androidMissing(String value) =>
    'לא ניתן לאמת את תוכנית ההתראות; ${_items(value)} חסרות במערכת Android.';

final List<_HebrewPattern> _hebrewPatterns = <_HebrewPattern>[
  _HebrewPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'דוח MİZAN: ${t(m[1]!)}',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => 'דוח פיננסי: ${m[1]}',
  ),
  _HebrewPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · עמוד ${m[1]}',
  ),
  _HebrewPattern(RegExp(r'^(.+) · devam$'), (m, t) => '${t(m[1]!)} · המשך'),
  _HebrewPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'תקופה: ${m[1]}'),
  _HebrewPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'טווח אנשים: ${t(m[1]!)}',
  ),
  _HebrewPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'נוצר בתאריך: ${m[1]}',
  ),
  _HebrewPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'תוכנית פתוחה ${m[1]} · בוצע החודש ${m[2]}',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'מצב תשלום: ${m[1]}',
  ),
  _HebrewPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _HebrewPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _HebrewPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _HebrewPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _HebrewPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _HebrewPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _HebrewPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'הצגת ימים נוספים (${_remaining(m[1]!)})',
  ),
  _HebrewPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'הצגת ימי תשלום נוספים (${_remaining(m[1]!)})',
  ),
  _HebrewPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'הצגת ימי הוצאה נוספים (${_remaining(m[1]!)})',
  ),
  _HebrewPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'הצגת רשומות נוספות מהיום הזה (${_remaining(m[1]!)})',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => 'עד ${m[1]}: ${_remainingDays(m[2]!)}',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} צפוי היום',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} באיחור של ${_days(m[2]!)}',
  ),
  _HebrewPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'התקבל לאחרונה: ${m[1]} · מתוכנן: ${m[2]}',
  ),
  _HebrewPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'התקופה המתוכננת ${m[1]} נרשמה כהתקבלה בתאריך ${m[2]}. יום ההפקדה הקבוע לא השתנה.',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'סכום החשבון בפועל: ${m[1]}',
  ),
  _HebrewPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'סכום שנותר: ${m[1]}',
  ),
  _HebrewPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _HebrewPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'למחוק את רשומת ההוצאה ${m[1]}?',
  ),
  _HebrewPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) => 'הקטגוריה ${m[1]} ורק ההוצאות המקושרות אליה יימחקו.',
  ),
  _HebrewPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} וכל הרשומות המקושרות לאדם הזה יימחקו. הפעולה דורשת אישור מפורש.',
  ),
  _HebrewPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'לא ניתן לשמור את דוח ה-PDF: ${m[1]}',
  ),
  _HebrewPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'לא ניתן לשתף את דוח ה-PDF: ${m[1]}',
  ),
  _HebrewPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => _androidWriteFailure(m[1]!, m[2]!),
  ),
  _HebrewPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => _androidMissing(m[1]!),
  ),
  _HebrewPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'תזכורת תשלום ${m[1]}',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)}, ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'מזהה הרשומה ${m[1]} אינו תקין או כפול.',
  ),
  _HebrewPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => _remainingDays(m[1]!),
  ),
  _HebrewPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'איחור של ${_days(m[1]!)}',
  ),
  _HebrewPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'התשלום באיחור של ${_days(m[1]!)}.',
  ),
  _HebrewPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'מועד פירעון: ${m[1]}.',
  ),
  _HebrewPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'היום ה-${m[1]} בחודש',
  ),
  _HebrewPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'היום ה-${m[1]} בכל חודש',
  ),
  _HebrewPattern(RegExp(r'^Her (.+)$'), (m, t) => 'כל ${t(m[1]!)}'),
  _HebrewPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'התחלה: ${m[1]}'),
  _HebrewPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'התחלה ${m[1]}'),
  _HebrewPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'סך הכול: ${t(m[1]!)}'),
  _HebrewPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'נותר: ${t(m[1]!)}'),
  _HebrewPattern(RegExp(r'^Bu dönem (.+)$'), (m, t) => '${t(m[1]!)} בתקופה הזאת'),
  _HebrewPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'תאריך: ${m[1]}'),
  _HebrewPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'הערה: ${m[1]}'),
  _HebrewPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => 'השדה „${t(m[1]!)}” אינו יכול להיות ריק.',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => 'השדה „${t(m[1]!)}” יכול להכיל עד ${m[2]} תווים.',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => 'הערך בשדה „${t(m[1]!)}” חייב להיות גדול מאפס.',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => 'הערך בשדה „${t(m[1]!)}” חייב להיות גדול מאפס.',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => 'הערך בשדה „${t(m[1]!)}” אינו יכול להיות שלילי.',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => 'השדה „${t(m[1]!)}” חייב להיות מספר שלם חיובי.',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => 'השדה „${t(m[1]!)}” חייב להיות אפס או מספר שלם חיובי.',
  ),
  _HebrewPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _HebrewPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _HebrewPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _HebrewPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _HebrewPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _HebrewPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _HebrewPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => _selectedPeople(m[1]!),
  ),
  _HebrewPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_newItems(m[1]!)} נוספו והנתונים הקיימים נשמרו.',
  ),
  _HebrewPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'הבדיקה תוזמנה במדויק עבור ${m[1]}.',
  ),
  _HebrewPattern(
    RegExp(r'^Test planlanamadı: (.+)$'),
    (m, t) => 'לא ניתן לתזמן את הבדיקה: ${m[1]}',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) planlanamadı: (.+)$'),
    (m, t) => 'לא ניתן לתזמן את „${t(m[1]!)}”: ${m[2]}',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'לא ניתן לשמור את „${t(m[1]!)}”: ${m[2]}',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'לא ניתן ליצור את „${t(m[1]!)}”: ${m[2]}',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'לא ניתן לשתף את „${t(m[1]!)}”: ${m[2]}',
  ),
  _HebrewPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'לא ניתן למזג את „${t(m[1]!)}”: ${m[2]}',
  ),
];

const List<(String, String)> _hebrewPhrases = <(String, String)>[
  ('Banka borcu', 'חוב בנקאי'),
  ('Kişisel ve kurumsal borçlar', 'חובות אישיים ועסקיים'),
  ('Kişisel / kurumsal borç', 'חוב אישי או עסקי'),
  ('Kişisel/kurumsal borç', 'חוב אישי או עסקי'),
  ('Ödemelere yapılan gider', 'תשלומים שבוצעו'),
  ('Bu ay yapılan', 'בוצע החודש'),
  ('Açık plan', 'תוכנית פתוחה'),
  ('Kalan tutar', 'סכום שנותר'),
  ('Kalan toplam borç', 'סך החוב שנותר'),
  ('Gecikmiş toplam', 'סך הכול באיחור'),
  ('Önümüzdeki 7 gün', '7 הימים הקרובים'),
  ('Son ödeme bugün', 'מועד הפירעון היום'),
  ('Banka borçları', 'חובות בנקאיים'),
  ('Kira ve taksitler', 'שכר דירה ותשלומים'),
  ('Günlük harcamalar', 'הוצאות יומיות'),
  ('Gider ayrıntıları', 'פרטי הוצאות'),
  ('Ödeme ayrıntıları', 'פרטי תשלומים'),
  ('Gerçekleşen ödeme', 'תשלום שבוצע'),
  ('Ödeme kayıtları', 'רשומות תשלום'),
  ('Normal giderler', 'הוצאות רגילות'),
  ('Toplam gider', 'סך ההוצאות'),
  ('Kalan ödeme yükü', 'התחייבויות תשלום שנותרו'),
  ('Gecikmiş ödeme yükü', 'התחייבויות תשלום באיחור'),
  ('Yaklaşan ödeme yükü', 'התחייבויות תשלום קרובות'),
  ('Kişi kapsamı', 'טווח אנשים'),
  ('Oluşturulma', 'נוצר בתאריך'),
  ('Dönem', 'תקופה'),
  ('devam', 'המשך'),
];

class _HebrewPattern {
  const _HebrewPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, HebrewDynamicTranslator translate)
  builder;
}
