typedef PolishDynamicTranslator = String Function(String source);

String translatePolishReviewedDynamic(
  String source,
  PolishDynamicTranslator translate,
) {
  for (final pattern in _polishPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _polishPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

String _lowerFirst(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toLowerCase()}${value.substring(1)}';
}

int _number(String value) => int.tryParse(value) ?? 0;

String _plural(
  String value,
  String singular,
  String paucal,
  String plural,
) {
  final number = _number(value).abs();
  if (number == 1) return '$value $singular';
  final lastTwo = number % 100;
  final last = number % 10;
  if (last >= 2 && last <= 4 && !(lastTwo >= 12 && lastTwo <= 14)) {
    return '$value $paucal';
  }
  return '$value $plural';
}

String _days(String value) => _plural(value, 'dzień', 'dni', 'dni');
String _items(String value) => _plural(value, 'wpis', 'wpisy', 'wpisów');
String _openItems(String value) {
  if (value == '1') return '1 otwarty wpis';
  final number = _number(value).abs();
  final lastTwo = number % 100;
  final last = number % 10;
  if (last >= 2 && last <= 4 && !(lastTwo >= 12 && lastTwo <= 14)) {
    return '$value otwarte wpisy';
  }
  return '$value otwartych wpisów';
}
String _payments(String value) =>
    _plural(value, 'płatność', 'płatności', 'płatności');
String _expenses(String value) =>
    _plural(value, 'wydatek', 'wydatki', 'wydatków');
String _months(String value) =>
    _plural(value, 'miesiąc', 'miesiące', 'miesięcy');
String _people(String value) => _plural(value, 'osoba', 'osoby', 'osób');
String _remaining(String value) => 'pozostało $value';
String _remainingDays(String value) {
  if (value == '1') return 'Pozostał 1 dzień';
  final number = _number(value).abs();
  final lastTwo = number % 100;
  final last = number % 10;
  if (last >= 2 && last <= 4 && !(lastTwo >= 12 && lastTwo <= 14)) {
    return 'Pozostały $value dni';
  }
  return 'Pozostało $value dni';
}
String _dailyExpenses(String value) => value == '1'
    ? '1 dzienny wydatek'
    : _plural(value, 'dzienny wydatek', 'dzienne wydatki', 'dziennych wydatków');
String _expenseRecords(String value) => value == '1'
    ? '1 wpis wydatku'
    : _plural(value, 'wpis wydatku', 'wpisy wydatków', 'wpisów wydatków');
String _newItems(String value) => value == '1'
    ? '1 nowy wpis'
    : _plural(value, 'nowy wpis', 'nowe wpisy', 'nowych wpisów');
String _addedItems(String value) => value == '1'
    ? 'Dodano 1 nowy wpis'
    : 'Dodano ${_plural(value, 'nowy wpis', 'nowe wpisy', 'nowych wpisów')}';
String _updatedLinks(String value) => value == '1'
    ? 'zaktualizowano 1 powiązanie'
    : 'zaktualizowano ${_plural(value, 'powiązanie', 'powiązania', 'powiązań')}';

final List<_PolishPattern> _polishPatterns = <_PolishPattern>[
  _PolishPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Raport MİZAN: ${t(m[1]!)}',
  ),
  _PolishPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => '${m[1]} — raport finansowy',
  ),
  _PolishPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · Strona ${m[1]}',
  ),
  _PolishPattern(RegExp(r'^(.+) · devam$'), (m, t) => '${t(m[1]!)} · ciąg dalszy'),
  _PolishPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Okres: ${m[1]}'),
  _PolishPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Zakres osób: ${t(m[1]!)}',
  ),
  _PolishPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Utworzono: ${m[1]}',
  ),
  _PolishPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Plan otwarty ${m[1]} · Wykonano w tym miesiącu ${m[2]}',
  ),
  _PolishPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Status płatności — ${m[1]}',
  ),
  _PolishPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _PolishPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _PolishPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _PolishPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _PolishPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _PolishPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _PolishPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Pokaż więcej dni (${_remaining(m[1]!)})',
  ),
  _PolishPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Pokaż więcej dni płatności (${_remaining(m[1]!)})',
  ),
  _PolishPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Pokaż więcej dni wydatków (${_remaining(m[1]!)})',
  ),
  _PolishPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Pokaż więcej z tego dnia (${_remaining(m[1]!)})',
  ),
  _PolishPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => m[2] == '1'
        ? 'Do ${m[1]} pozostał 1 dzień'
        : 'Do ${m[1]} pozostało ${_days(m[2]!)}',
  ),
  _PolishPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} oczekiwane dzisiaj',
  ),
  _PolishPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} jest opóźnione o ${_days(m[2]!)}',
  ),
  _PolishPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Ostatnio otrzymano: ${m[1]} · Planowano ${m[2]}',
  ),
  _PolishPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'Planowany okres ${m[1]} oznaczono jako otrzymany dnia ${m[2]}. Stały dzień wpływu nie uległ zmianie.',
  ),
  _PolishPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Rzeczywista kwota rachunku — ${m[1]}',
  ),
  _PolishPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Pozostała kwota: ${m[1]}',
  ),
  _PolishPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => 'Pozostałe raty: ${m[1]}',
  ),
  _PolishPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Usunąć wydatek ${m[1]}?',
  ),
  _PolishPattern(
    RegExp(r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$'),
    (m, t) =>
        'Kategoria ${m[1]} oraz wyłącznie powiązane z nią wydatki zostaną usunięte.',
  ),
  _PolishPattern(
    RegExp(r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$'),
    (m, t) =>
        '${m[1]} i wszystkie wpisy powiązane z tą osobą zostaną usunięte. Ta czynność wymaga wyraźnego potwierdzenia.',
  ),
  _PolishPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Nie udało się zapisać raportu PDF: ${m[1]}',
  ),
  _PolishPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Nie udało się udostępnić raportu PDF: ${m[1]}',
  ),
  _PolishPattern(
    RegExp(r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$'),
    (m, t) =>
        'Nie udało się zapisać ${_items(m[1]!)} z harmonogramu powiadomień w systemie Android. Pierwszy błąd: ${m[2]}',
  ),
  _PolishPattern(
    RegExp(r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$'),
    (m, t) =>
        'Nie udało się zweryfikować harmonogramu powiadomień; w systemie Android brakuje ${_items(m[1]!)}.',
  ),
  _PolishPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Przypomnienie o płatności ${m[1]}',
  ),
  _PolishPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)}; ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _PolishPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'Identyfikator wpisu ${m[1]} jest nieprawidłowy lub zduplikowany.',
  ),
  _PolishPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => _remainingDays(m[1]!),
  ),
  _PolishPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'Po terminie o ${_days(m[1]!)}',
  ),
  _PolishPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'Płatność jest opóźniona o ${_days(m[1]!)}.',
  ),
  _PolishPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Termin płatności: ${m[1]}.',
  ),
  _PolishPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => '${m[1]}. dzień miesiąca',
  ),
  _PolishPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => '${m[1]}. dnia każdego miesiąca',
  ),
  _PolishPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'Co ${_lowerFirst(t(m[1]!))}',
  ),
  _PolishPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Początek: ${m[1]}'),
  _PolishPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Początek ${m[1]}'),
  _PolishPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'Łącznie: ${t(m[1]!)}'),
  _PolishPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'Pozostało: ${t(m[1]!)}'),
  _PolishPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} w tym okresie',
  ),
  _PolishPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Data: ${m[1]}'),
  _PolishPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Notatka: ${m[1]}'),
  _PolishPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => 'Pole ${_lowerFirst(t(m[1]!))} nie może być puste.',
  ),
  _PolishPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => 'Pole ${_lowerFirst(t(m[1]!))} może zawierać maksymalnie ${m[2]} znaków.',
  ),
  _PolishPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => 'Wartość pola ${_lowerFirst(t(m[1]!))} musi być większa od zera.',
  ),
  _PolishPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => 'Wartość pola ${_lowerFirst(t(m[1]!))} musi być większa od zera.',
  ),
  _PolishPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => 'Wartość pola ${_lowerFirst(t(m[1]!))} nie może być ujemna.',
  ),
  _PolishPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => 'Wartość pola ${_lowerFirst(t(m[1]!))} musi być dodatnią liczbą całkowitą.',
  ),
  _PolishPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => 'Wartość pola ${_lowerFirst(t(m[1]!))} musi być zerem lub dodatnią liczbą całkowitą.',
  ),
  _PolishPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _PolishPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _PolishPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _PolishPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _PolishPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _PolishPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _PolishPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _PolishPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => m[1] == '1'
        ? 'Wybrano 1 osobę'
        : 'Wybrano ${_people(m[1]!)}',
  ),
  _PolishPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_addedItems(m[1]!)}; istniejące dane zostały zachowane.',
  ),
  _PolishPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'Test został dokładnie zaplanowany na ${m[1]}.',
  ),
  _PolishPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'Nie udało się zapisać ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _PolishPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'Nie udało się utworzyć ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _PolishPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'Nie udało się udostępnić ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _PolishPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'Nie udało się scalić ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
];

const List<(String, String)> _polishPhrases = <(String, String)>[
  ('Kişisel ve kurumsal borçlar', 'Zadłużenia osobiste i firmowe'),
  ('Kişisel / kurumsal borç', 'Zadłużenie osobiste / firmowe'),
  ('Kişisel/kurumsal borç', 'Zadłużenie osobiste/firmowe'),
  ('Ödemelere yapılan gider', 'Wydatki na płatności'),
  ('Bu ay yapılan', 'Wykonano w tym miesiącu'),
  ('Açık plan', 'Plan otwarty'),
  ('Kalan tutar', 'Pozostała kwota'),
  ('Kalan toplam borç', 'Łączne pozostałe zadłużenie'),
  ('Gecikmiş toplam', 'Łącznie po terminie'),
  ('Önümüzdeki 7 gün', 'Najbliższe 7 dni'),
  ('Son ödeme bugün', 'Termin płatności dzisiaj'),
  ('Banka borçları', 'Zadłużenia bankowe'),
  ('Kira ve taksitler', 'Czynsze i raty'),
  ('Günlük harcamalar', 'Wydatki dzienne'),
  ('Gider ayrıntıları', 'Szczegóły wydatków'),
  ('Ödeme ayrıntıları', 'Szczegóły płatności'),
  ('Gerçekleşen ödeme', 'Zrealizowana płatność'),
  ('Ödeme kayıtları', 'Rejestr płatności'),
  ('Normal giderler', 'Pozostałe wydatki'),
  ('Toplam gider', 'Łączne wydatki'),
  ('Kalan ödeme yükü', 'Pozostałe zobowiązania płatnicze'),
  ('Gecikmiş ödeme yükü', 'Zaległe zobowiązania płatnicze'),
  ('Yaklaşan ödeme yükü', 'Nadchodzące zobowiązania płatnicze'),
  ('Kişi kapsamı', 'Zakres osób'),
  ('Oluşturulma', 'Utworzono'),
  ('Dönem', 'Okres'),
  ('devam', 'ciąg dalszy'),
];

class _PolishPattern {
  const _PolishPattern(this.regExp, this.builder);

  final RegExp regExp;
  final String Function(RegExpMatch match, PolishDynamicTranslator translate)
      builder;
}
