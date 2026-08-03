typedef DutchDynamicTranslator = String Function(String source);

String translateDutchReviewedDynamic(
  String source,
  DutchDynamicTranslator translate,
) {
  for (final pattern in _dutchPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _dutchPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

String _lowerFirst(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toLowerCase()}${value.substring(1)}';
}

String _count(String value, String singular, String plural) =>
    value == '1' ? '$value $singular' : '$value $plural';

String _days(String value) => _count(value, 'dag', 'dagen');
String _items(String value) => _count(value, 'registratie', 'registraties');
String _payments(String value) => _count(value, 'betaling', 'betalingen');
String _expenses(String value) => _count(value, 'uitgave', 'uitgaven');
String _months(String value) => _count(value, 'maand', 'maanden');
String _people(String value) => _count(value, 'persoon', 'personen');
String _remaining(String value) => 'nog $value';
String _dailyExpenses(String value) =>
    value == '1' ? '1 dagelijkse uitgave' : '$value dagelijkse uitgaven';
String _expenseRecords(String value) =>
    value == '1' ? '1 uitgavenregistratie' : '$value uitgavenregistraties';
String _newItems(String value) =>
    value == '1' ? '1 nieuwe registratie' : '$value nieuwe registraties';
String _addedItems(String value) => value == '1'
    ? 'Er is 1 nieuwe registratie toegevoegd'
    : 'Er zijn $value nieuwe registraties toegevoegd';
String _updatedLinks(String value) => value == '1'
    ? '1 koppeling bijgewerkt'
    : '$value koppelingen bijgewerkt';

final List<_DutchPattern> _dutchPatterns = <_DutchPattern>[
  _DutchPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'MİZAN-rapport: ${t(m[1]!)}',
  ),
  _DutchPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => '${m[1]} – financieel rapport',
  ),
  _DutchPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MIZAN · Pagina ${m[1]}',
  ),
  _DutchPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · vervolg',
  ),
  _DutchPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Periode: ${m[1]}'),
  _DutchPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Persoonsbereik: ${t(m[1]!)}',
  ),
  _DutchPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Aangemaakt: ${m[1]}',
  ),
  _DutchPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Openstaand plan ${m[1]} · Deze maand uitgevoerd ${m[2]}',
  ),
  _DutchPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Betalingsstatus – ${m[1]}',
  ),
  _DutchPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_items(m[1]!)} openstaand · ${m[2]}',
  ),
  _DutchPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _DutchPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _DutchPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _DutchPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _DutchPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _DutchPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Meer dagen tonen (${_remaining(m[1]!)})',
  ),
  _DutchPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Meer betalingsdagen tonen (${_remaining(m[1]!)})',
  ),
  _DutchPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Meer uitgavendagen tonen (${_remaining(m[1]!)})',
  ),
  _DutchPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Meer van deze dag tonen (${_remaining(m[1]!)})',
  ),
  _DutchPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => m[2] == '1'
        ? 'Nog 1 dag tot ${m[1]}'
        : 'Nog ${_days(m[2]!)} tot ${m[1]}',
  ),
  _DutchPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} wordt vandaag verwacht',
  ),
  _DutchPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} is ${_days(m[2]!)} te laat',
  ),
  _DutchPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Laatst ontvangen: ${m[1]} · Gepland ${m[2]}',
  ),
  _DutchPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'De geplande periode ${m[1]} is op ${m[2]} als ontvangen geregistreerd. De vaste bijschrijvingsdag is niet gewijzigd.',
  ),
  _DutchPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Werkelijk factuurbedrag – ${m[1]}',
  ),
  _DutchPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Resterend bedrag: ${m[1]}',
  ),
  _DutchPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => 'Resterende termijnen: ${m[1]}',
  ),
  _DutchPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Uitgave ${m[1]} verwijderen?',
  ),
  _DutchPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'De categorie ${m[1]} en uitsluitend de eraan gekoppelde uitgaven worden verwijderd.',
  ),
  _DutchPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} en alle aan deze persoon gekoppelde registraties worden verwijderd. Deze actie vereist uitdrukkelijke bevestiging.',
  ),
  _DutchPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Het PDF-rapport kon niet worden opgeslagen: ${m[1]}',
  ),
  _DutchPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Het PDF-rapport kon niet worden gedeeld: ${m[1]}',
  ),
  _DutchPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) =>
        '${_items(m[1]!)} uit het meldingsschema konden niet naar Android worden geschreven. Eerste fout: ${m[2]}',
  ),
  _DutchPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) =>
        'Het meldingsschema kon niet worden geverifieerd; in Android ontbreken ${_items(m[1]!)}.',
  ),
  _DutchPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Betalingsherinnering ${m[1]}',
  ),
  _DutchPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)}; ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _DutchPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) =>
        'De registratie-id van ${m[1]} is ongeldig of komt meer dan eenmaal voor.',
  ),
  _DutchPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => m[1] == '1' ? 'Nog 1 dag' : 'Nog ${_days(m[1]!)}',
  ),
  _DutchPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => '${_days(m[1]!)} achterstallig',
  ),
  _DutchPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'De betaling is ${_days(m[1]!)} te laat.',
  ),
  _DutchPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Vervaldatum: ${m[1]}.',
  ),
  _DutchPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'Dag ${m[1]} van de maand',
  ),
  _DutchPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'Dag ${m[1]} van elke maand',
  ),
  _DutchPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'Elke ${_lowerFirst(t(m[1]!))}',
  ),
  _DutchPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Start: ${m[1]}'),
  _DutchPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Start ${m[1]}'),
  _DutchPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'Totaal: ${t(m[1]!)}'),
  _DutchPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'Resterend: ${t(m[1]!)}'),
  _DutchPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} in deze periode',
  ),
  _DutchPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Datum: ${m[1]}'),
  _DutchPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Notitie: ${m[1]}'),
  _DutchPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => 'Het veld ${_lowerFirst(t(m[1]!))} mag niet leeg zijn.',
  ),
  _DutchPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) =>
        'Het veld ${_lowerFirst(t(m[1]!))} mag maximaal ${m[2]} tekens bevatten.',
  ),
  _DutchPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => 'De waarde van ${_lowerFirst(t(m[1]!))} moet groter zijn dan nul.',
  ),
  _DutchPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => 'De waarde van ${_lowerFirst(t(m[1]!))} moet groter zijn dan nul.',
  ),
  _DutchPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => 'De waarde van ${_lowerFirst(t(m[1]!))} mag niet negatief zijn.',
  ),
  _DutchPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) =>
        'De waarde van ${_lowerFirst(t(m[1]!))} moet een positief geheel getal zijn.',
  ),
  _DutchPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) =>
        'De waarde van ${_lowerFirst(t(m[1]!))} moet nul of een positief geheel getal zijn.',
  ),
  _DutchPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _DutchPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _DutchPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _DutchPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _DutchPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _DutchPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _DutchPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _DutchPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => m[1] == '1'
        ? '1 persoon geselecteerd'
        : '${_people(m[1]!)} geselecteerd',
  ),
  _DutchPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_addedItems(m[1]!)}; de bestaande gegevens zijn behouden.',
  ),
  _DutchPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'De test is exact gepland voor ${m[1]}.',
  ),
  _DutchPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) =>
        '${t(m[1]!)} kon niet worden opgeslagen: ${m[2]}',
  ),
  _DutchPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} kon niet worden aangemaakt: ${m[2]}',
  ),
  _DutchPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} kon niet worden gedeeld: ${m[2]}',
  ),
  _DutchPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => '${t(m[1]!)} kon niet worden samengevoegd: ${m[2]}',
  ),
];

const List<(String, String)> _dutchPhrases = <(String, String)>[
  ('Kişisel ve kurumsal borçlar', 'Particuliere en zakelijke schulden'),
  ('Kişisel / kurumsal borç', 'Particuliere / zakelijke schuld'),
  ('Kişisel/kurumsal borç', 'Particuliere/zakelijke schuld'),
  ('Ödemelere yapılan gider', 'Uitgaven aan betalingen'),
  ('Bu ay yapılan', 'Deze maand uitgevoerd'),
  ('Açık plan', 'Openstaand plan'),
  ('Kalan tutar', 'Resterend bedrag'),
  ('Kalan toplam borç', 'Totale resterende schuld'),
  ('Gecikmiş toplam', 'Totaal achterstallig'),
  ('Önümüzdeki 7 gün', 'Komende 7 dagen'),
  ('Son ödeme bugün', 'Vervalt vandaag'),
  ('Banka borçları', 'Bankschulden'),
  ('Kira ve taksitler', 'Huur en termijnen'),
  ('Günlük harcamalar', 'Dagelijkse uitgaven'),
  ('Gider ayrıntıları', 'Uitgavendetails'),
  ('Ödeme ayrıntıları', 'Betalingsdetails'),
  ('Gerçekleşen ödeme', 'Uitgevoerde betaling'),
  ('Ödeme kayıtları', 'Geregistreerde betalingen'),
  ('Normal giderler', 'Reguliere uitgaven'),
  ('Toplam gider', 'Totale uitgaven'),
  ('Kalan ödeme yükü', 'Resterende betalingsverplichtingen'),
  ('Gecikmiş ödeme yükü', 'Achterstallige betalingsverplichtingen'),
  ('Yaklaşan ödeme yükü', 'Binnenkort vervallende betalingsverplichtingen'),
  ('Kişi kapsamı', 'Persoonsbereik'),
  ('Oluşturulma', 'Aangemaakt'),
  ('Dönem', 'Periode'),
  ('devam', 'vervolg'),
];

class _DutchPattern {
  const _DutchPattern(this.regExp, this.builder);

  final RegExp regExp;
  final String Function(RegExpMatch match, DutchDynamicTranslator translate)
  builder;
}
