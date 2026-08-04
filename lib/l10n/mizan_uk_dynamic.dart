typedef UkrainianDynamicTranslator = String Function(String source);

String translateUkrainianReviewedDynamic(
  String source,
  UkrainianDynamicTranslator translate,
) {
  for (final pattern in _ukrainianPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _ukrainianPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

int _number(String value) => int.tryParse(value) ?? 0;
String _plural(String value, String one, String few, String many) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  final form = mod10 == 1 && mod100 != 11
      ? one
      : (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)
            ? few
            : many);
  return '$value $form';
}

String _lowerFirst(String value) =>
    value.isEmpty ? value : '${value[0].toLowerCase()}${value.substring(1)}';
String _days(String value) => _plural(value, 'день', 'дні', 'днів');
String _items(String value) => _plural(value, 'запис', 'записи', 'записів');
String _openItems(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return '$value відкритий запис';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return '$value відкриті записи';
  }
  return '$value відкритих записів';
}
String _payments(String value) =>
    _plural(value, 'платіж', 'платежі', 'платежів');
String _expenses(String value) =>
    _plural(value, 'витрата', 'витрати', 'витрат');
String _months(String value) => _plural(value, 'місяць', 'місяці', 'місяців');
String _people(String value) =>
    _plural(value, 'людина', 'людини', 'людей');
String _selectedPeople(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return 'Вибрано $value особу';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'Вибрано $value особи';
  }
  return 'Вибрано $value осіб';
}
String _remaining(String value) => 'залишилося $value';
String _remainingDays(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return 'Залишився $value день';
  return 'Залишилося ${_days(value)}';
}
String _remainingDaysLower(String value) {
  final result = _remainingDays(value);
  return _lowerFirst(result);
}
String _remainingInstallments(String value) =>
    'Залишилося внесків: $value';
String _androidWriteFailure(String value, String error) =>
    'Не вдалося записати в Android ${_items(value)} з плану сповіщень. Перша помилка: $error';
String _androidMissing(String value) =>
    'Не вдалося перевірити план сповіщень: Android не містить ${_items(value)}.';
String _dailyExpenses(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return '$value щоденна витрата';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return '$value щоденні витрати';
  }
  return '$value щоденних витрат';
}
String _expenseRecords(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return '$value запис витрати';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return '$value записи витрат';
  }
  return '$value записів витрат';
}
String _newItems(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return '$value новий запис';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return '$value нові записи';
  }
  return '$value нових записів';
}
String _addedItems(String value) => 'Додано ${_newItems(value)}';
String _updatedLinks(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return 'оновлено $value зв’язок';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'оновлено $value зв’язки';
  }
  return 'оновлено $value зв’язків';
}

final List<_UkrainianPattern> _ukrainianPatterns = <_UkrainianPattern>[
  _UkrainianPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Звіт MİZAN: ${t(m[1]!)}',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => '${m[1]} — фінансовий звіт',
  ),
  _UkrainianPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · Сторінка ${m[1]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · продовження',
  ),
  _UkrainianPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Період: ${m[1]}'),
  _UkrainianPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Обрані особи: ${t(m[1]!)}',
  ),
  _UkrainianPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Створено: ${m[1]}',
  ),
  _UkrainianPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Відкритий план ${m[1]} · Здійснено цього місяця ${m[2]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Стан платежів — ${m[1]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _UkrainianPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _UkrainianPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Показати більше днів (${_remaining(m[1]!)})',
  ),
  _UkrainianPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Показати більше днів із платежами (${_remaining(m[1]!)})',
  ),
  _UkrainianPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Показати більше днів із витратами (${_remaining(m[1]!)})',
  ),
  _UkrainianPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Показати більше записів за цей день (${_remaining(m[1]!)})',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => 'До ${m[1]} ${_remainingDaysLower(m[2]!)}',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} очікується сьогодні',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} прострочено на ${_days(m[2]!)}',
  ),
  _UkrainianPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Останнє отримання: ${m[1]} · Заплановано ${m[2]}',
  ),
  _UkrainianPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'Запланований період ${m[1]} позначено як отриманий ${m[2]}. Установлений день надходження не змінено.',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Фактична сума рахунку — ${m[1]}',
  ),
  _UkrainianPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Сума, що залишилася: ${m[1]}',
  ),
  _UkrainianPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Видалити запис витрати ${m[1]}?',
  ),
  _UkrainianPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'Буде видалено категорію ${m[1]} і лише пов’язані з нею витрати.',
  ),
  _UkrainianPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        'Буде видалено ${m[1]} і всі пов’язані записи. Ця дія потребує явного підтвердження.',
  ),
  _UkrainianPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Не вдалося зберегти PDF-звіт: ${m[1]}',
  ),
  _UkrainianPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Не вдалося поширити PDF-звіт: ${m[1]}',
  ),
  _UkrainianPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => _androidWriteFailure(m[1]!, m[2]!),
  ),
  _UkrainianPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => _androidMissing(m[1]!),
  ),
  _UkrainianPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Нагадування про платіж ${m[1]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)}, ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'Ідентифікатор запису ${m[1]} недійсний або повторюється.',
  ),
  _UkrainianPattern(RegExp(r'^(\d+) gün kaldı$'), (m, t) => _remainingDays(m[1]!)),
  _UkrainianPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'Прострочено на ${_days(m[1]!)}',
  ),
  _UkrainianPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'Платіж прострочено на ${_days(m[1]!)}.',
  ),
  _UkrainianPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Строк оплати: ${m[1]}.',
  ),
  _UkrainianPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => '${m[1]}-й день місяця',
  ),
  _UkrainianPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => '${m[1]}-го числа кожного місяця',
  ),
  _UkrainianPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'Кожен період: ${_lowerFirst(t(m[1]!))}',
  ),
  _UkrainianPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Початок: ${m[1]}'),
  _UkrainianPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Початок ${m[1]}'),
  _UkrainianPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'Усього: ${t(m[1]!)}'),
  _UkrainianPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'Залишок: ${t(m[1]!)}'),
  _UkrainianPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} за цей період',
  ),
  _UkrainianPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Дата: ${m[1]}'),
  _UkrainianPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Нотатка: ${m[1]}'),
  _UkrainianPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => 'Поле «${t(m[1]!)}» не може бути порожнім.',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => 'Поле «${t(m[1]!)}» може містити не більше ${m[2]} символів.',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => 'Значення поля «${t(m[1]!)}» має бути більшим за нуль.',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => 'Значення поля «${t(m[1]!)}» має бути більшим за нуль.',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => 'Значення поля «${t(m[1]!)}» не може бути від’ємним.',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => 'Поле «${t(m[1]!)}» має містити додатне ціле число.',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => 'Поле «${t(m[1]!)}» має містити нуль або додатне ціле число.',
  ),
  _UkrainianPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _UkrainianPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _UkrainianPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _UkrainianPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _UkrainianPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _UkrainianPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _UkrainianPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => _selectedPeople(m[1]!),
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_addedItems(m[1]!)}; наявні дані збережено.',
  ),
  _UkrainianPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'Тест точно заплановано на ${m[1]}.',
  ),
  _UkrainianPattern(
    RegExp(r'^Test planlanamadı: (.+)$'),
    (m, t) => 'Не вдалося запланувати тест: ${m[1]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) planlanamadı: (.+)$'),
    (m, t) => 'Не вдалося запланувати «${t(m[1]!)}»: ${m[2]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'Не вдалося зберегти «${t(m[1]!)}»: ${m[2]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'Не вдалося створити «${t(m[1]!)}»: ${m[2]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'Не вдалося поширити «${t(m[1]!)}»: ${m[2]}',
  ),
  _UkrainianPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'Не вдалося об’єднати «${t(m[1]!)}»: ${m[2]}',
  ),
];

const List<(String, String)> _ukrainianPhrases = <(String, String)>[
  ('Kişisel ve kurumsal borçlar', 'Особисті та корпоративні борги'),
  ('Kişisel / kurumsal borç', 'Особистий / корпоративний борг'),
  ('Kişisel/kurumsal borç', 'Особистий / корпоративний борг'),
  ('Ödemelere yapılan gider', 'Витрати на платежі'),
  ('Bu ay yapılan', 'Здійснено цього місяця'),
  ('Açık plan', 'Відкритий план'),
  ('Kalan tutar', 'Сума, що залишилася'),
  ('Kalan toplam borç', 'Загальний залишок боргу'),
  ('Gecikmiş toplam', 'Загальна прострочена сума'),
  ('Önümüzdeki 7 gün', 'Наступні 7 днів'),
  ('Son ödeme bugün', 'Строк оплати сьогодні'),
  ('Banka borçları', 'Банківські борги'),
  ('Kira ve taksitler', 'Оренда та розстрочки'),
  ('Günlük harcamalar', 'Щоденні витрати'),
  ('Gider ayrıntıları', 'Деталі витрат'),
  ('Ödeme ayrıntıları', 'Деталі платежів'),
  ('Gerçekleşen ödeme', 'Здійснений платіж'),
  ('Ödeme kayıtları', 'Записи про платежі'),
  ('Normal giderler', 'Звичайні витрати'),
  ('Toplam gider', 'Загальні витрати'),
  ('Kalan ödeme yükü', 'Невиконані платіжні зобов’язання'),
  ('Gecikmiş ödeme yükü', 'Прострочені платіжні зобов’язання'),
  ('Yaklaşan ödeme yükü', 'Майбутні платіжні зобов’язання'),
  ('Kişi kapsamı', 'Обрані особи'),
  ('Oluşturulma', 'Створено'),
  ('Dönem', 'Період'),
  ('devam', 'продовження'),
];

class _UkrainianPattern {
  const _UkrainianPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, UkrainianDynamicTranslator translate)
  builder;
}
