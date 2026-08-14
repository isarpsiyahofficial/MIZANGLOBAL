typedef RussianDynamicTranslator = String Function(String source);

String translateRussianReviewedDynamic(
  String source,
  RussianDynamicTranslator translate,
) {
  for (final pattern in _russianPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _russianPhrases) {
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
      : (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) ? few : many);
  return '$value $form';
}

String _lowerFirst(String value) =>
    value.isEmpty ? value : '${value[0].toLowerCase()}${value.substring(1)}';
String _days(String value) => _plural(value, 'день', 'дня', 'дней');
String _items(String value) => _plural(value, 'запись', 'записи', 'записей');
String _openItems(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return '$value открытая запись';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return '$value открытые записи';
  }
  return '$value открытых записей';
}

String _payments(String value) =>
    _plural(value, 'платёж', 'платежа', 'платежей');
String _expenses(String value) =>
    _plural(value, 'расход', 'расхода', 'расходов');
String _months(String value) => _plural(value, 'месяц', 'месяца', 'месяцев');
String _people(String value) =>
    _plural(value, 'человек', 'человека', 'человек');
String _remaining(String value) => 'осталось $value';
String _remainingDays(String value) => 'Осталось ${_days(value)}';
String _remainingInstallments(String value) => 'Осталось платежей: $value';
String _androidWriteFailure(String value, String error) =>
    '${_items(value)} из плана уведомлений не удалось записать в Android. Первая ошибка: $error';
String _androidMissing(String value) =>
    'Не удалось проверить план уведомлений: в Android отсутствует ${_items(value)}.';
String _dailyExpenses(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return '$value дневной расход';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return '$value дневных расхода';
  }
  return '$value дневных расходов';
}

String _expenseRecords(String value) =>
    _plural(value, 'запись расхода', 'записи расходов', 'записей расходов');
String _newItems(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return '$value новая запись';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return '$value новые записи';
  }
  return '$value новых записей';
}

String _addedItems(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return 'Добавлена $value новая запись';
  return 'Добавлено ${_newItems(value)}';
}

String _updatedLinks(String value) {
  final number = _number(value).abs();
  final mod10 = number % 10;
  final mod100 = number % 100;
  if (mod10 == 1 && mod100 != 11) return 'обновлена $value связь';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'обновлены $value связи';
  }
  return 'обновлено $value связей';
}

final List<_RussianPattern> _russianPatterns = <_RussianPattern>[
  _RussianPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Отчёт MİZAN: ${t(m[1]!)}',
  ),
  _RussianPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => '${m[1]} — финансовый отчёт',
  ),
  _RussianPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · Страница ${m[1]}',
  ),
  _RussianPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · продолжение',
  ),
  _RussianPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Период: ${m[1]}'),
  _RussianPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Выбранные лица: ${t(m[1]!)}',
  ),
  _RussianPattern(RegExp(r'^Oluşturulma: (.+)$'), (m, t) => 'Создано: ${m[1]}'),
  _RussianPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Открытый план ${m[1]} · Выполнено в этом месяце ${m[2]}',
  ),
  _RussianPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Статус платежей — ${m[1]}',
  ),
  _RussianPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _RussianPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _RussianPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _RussianPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _RussianPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _RussianPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _RussianPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Показать больше дней (${_remaining(m[1]!)})',
  ),
  _RussianPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Показать больше дней оплаты (${_remaining(m[1]!)})',
  ),
  _RussianPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Показать больше дней с расходами (${_remaining(m[1]!)})',
  ),
  _RussianPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Показать больше записей за этот день (${_remaining(m[1]!)})',
  ),
  _RussianPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => 'До ${m[1]} осталось ${_days(m[2]!)}',
  ),
  _RussianPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} ожидается сегодня',
  ),
  _RussianPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} просрочено на ${_days(m[2]!)}',
  ),
  _RussianPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Последнее получение: ${m[1]} · Запланировано ${m[2]}',
  ),
  _RussianPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'Запланированный период ${m[1]} отмечен как полученный ${m[2]}. Установленный день поступления не изменён.',
  ),
  _RussianPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Фактическая сумма счёта — ${m[1]}',
  ),
  _RussianPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Оставшаяся сумма: ${m[1]}',
  ),
  _RussianPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _RussianPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Удалить запись расхода ${m[1]}?',
  ),
  _RussianPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'Будет удалена категория ${m[1]} и только связанные с ней расходы.',
  ),
  _RussianPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        'Будут удалены ${m[1]} и все связанные записи. Для этого действия требуется явное подтверждение.',
  ),
  _RussianPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Не удалось сохранить отчёт PDF: ${m[1]}',
  ),
  _RussianPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Не удалось поделиться отчётом PDF: ${m[1]}',
  ),
  _RussianPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => _androidWriteFailure(m[1]!, m[2]!),
  ),
  _RussianPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => _androidMissing(m[1]!),
  ),
  _RussianPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Напоминание о платеже ${m[1]}',
  ),
  _RussianPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)}, ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _RussianPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'Идентификатор записи ${m[1]} недействителен или повторяется.',
  ),
  _RussianPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => _remainingDays(m[1]!),
  ),
  _RussianPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'Просрочка: ${_days(m[1]!)}',
  ),
  _RussianPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'Платёж просрочен на ${_days(m[1]!)}.',
  ),
  _RussianPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Срок оплаты: ${m[1]}.',
  ),
  _RussianPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => '${m[1]}-й день месяца',
  ),
  _RussianPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => '${m[1]}-го числа каждого месяца',
  ),
  _RussianPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'Каждый период: ${_lowerFirst(t(m[1]!))}',
  ),
  _RussianPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Начало: ${m[1]}'),
  _RussianPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Начало ${m[1]}'),
  _RussianPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'Всего: ${t(m[1]!)}'),
  _RussianPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'Остаток: ${t(m[1]!)}'),
  _RussianPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} за этот период',
  ),
  _RussianPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Дата: ${m[1]}'),
  _RussianPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Примечание: ${m[1]}'),
  _RussianPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => 'Поле «${t(m[1]!)}» не может быть пустым.',
  ),
  _RussianPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => 'Поле «${t(m[1]!)}» может содержать не более ${m[2]} символов.',
  ),
  _RussianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => 'Значение поля «${t(m[1]!)}» должно быть больше нуля.',
  ),
  _RussianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => 'Значение поля «${t(m[1]!)}» должно быть больше нуля.',
  ),
  _RussianPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => 'Значение поля «${t(m[1]!)}» не может быть отрицательным.',
  ),
  _RussianPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => 'Поле «${t(m[1]!)}» должно содержать положительное целое число.',
  ),
  _RussianPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) =>
        'Поле «${t(m[1]!)}» должно содержать ноль или положительное целое число.',
  ),
  _RussianPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _RussianPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _RussianPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _RussianPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _RussianPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _RussianPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _RussianPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => m[1] == '1' ? 'Выбран 1 человек' : 'Выбрано ${_people(m[1]!)}',
  ),
  _RussianPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_addedItems(m[1]!)}; существующие данные сохранены.',
  ),
  _RussianPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'Тест точно запланирован на ${m[1]}.',
  ),
  _RussianPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'Не удалось сохранить «${t(m[1]!)}»: ${m[2]}',
  ),
  _RussianPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'Не удалось создать «${t(m[1]!)}»: ${m[2]}',
  ),
  _RussianPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'Не удалось поделиться «${t(m[1]!)}»: ${m[2]}',
  ),
  _RussianPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'Не удалось объединить «${t(m[1]!)}»: ${m[2]}',
  ),
];

const List<(String, String)> _russianPhrases = <(String, String)>[
  ('Kişisel ve kurumsal borçlar', 'Личные и корпоративные долги'),
  ('Kişisel / kurumsal borç', 'Личная / корпоративная задолженность'),
  ('Kişisel/kurumsal borç', 'Личная/корпоративная задолженность'),
  ('Ödemelere yapılan gider', 'Расходы на платежи'),
  ('Bu ay yapılan', 'Выполнено в этом месяце'),
  ('Açık plan', 'Открытый план'),
  ('Kalan tutar', 'Оставшаяся сумма'),
  ('Kalan toplam borç', 'Общая непогашенная задолженность'),
  ('Gecikmiş toplam', 'Общая просроченная сумма'),
  ('Önümüzdeki 7 gün', 'Следующие 7 дней'),
  ('Son ödeme bugün', 'Срок оплаты сегодня'),
  ('Banka borçları', 'Банковские долги'),
  ('Kira ve taksitler', 'Аренда и рассрочки'),
  ('Günlük harcamalar', 'Ежедневные расходы'),
  ('Gider ayrıntıları', 'Сведения о расходах'),
  ('Ödeme ayrıntıları', 'Сведения о платежах'),
  ('Gerçekleşen ödeme', 'Выполненный платёж'),
  ('Ödeme kayıtları', 'Записи платежей'),
  ('Normal giderler', 'Обычные расходы'),
  ('Toplam gider', 'Общие расходы'),
  ('Kalan ödeme yükü', 'Оставшаяся платёжная нагрузка'),
  ('Gecikmiş ödeme yükü', 'Просроченная платёжная нагрузка'),
  ('Yaklaşan ödeme yükü', 'Предстоящая платёжная нагрузка'),
  ('Kişi kapsamı', 'Выбранные лица'),
  ('Oluşturulma', 'Создано'),
  ('Dönem', 'Период'),
  ('devam', 'продолжение'),
];

class _RussianPattern {
  const _RussianPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, RussianDynamicTranslator translate)
  builder;
}
