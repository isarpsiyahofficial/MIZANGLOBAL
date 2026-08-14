typedef GermanDynamicTranslator = String Function(String source);

String translateGermanReviewedDynamic(
  String source,
  GermanDynamicTranslator translate,
) {
  for (final pattern in _germanPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _germanPhrases) {
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

String _days(String value) => _count(value, 'Tag', 'Tage');
String _items(String value) => _count(value, 'Eintrag', 'Einträge');
String _payments(String value) => _count(value, 'Zahlung', 'Zahlungen');
String _expenses(String value) => _count(value, 'Ausgabe', 'Ausgaben');
String _months(String value) => _count(value, 'Monat', 'Monate');
String _people(String value) => _count(value, 'Person', 'Personen');
String _remaining(String value) => '$value verbleibend';
String _dailyExpenses(String value) =>
    value == '1' ? '$value tägliche Ausgabe' : '$value tägliche Ausgaben';
String _expenseRecords(String value) =>
    value == '1' ? '$value Ausgabeneintrag' : '$value Ausgabeneinträge';
String _newItems(String value) =>
    value == '1' ? '1 neuer Eintrag' : '$value neue Einträge';
String _addedItems(String value) => value == '1'
    ? '1 neuer Eintrag wurde hinzugefügt'
    : '$value neue Einträge wurden hinzugefügt';
String _updatedLinks(String value) => value == '1'
    ? '1 Beziehung aktualisiert'
    : '$value Beziehungen aktualisiert';

final List<_GermanPattern> _germanPatterns = <_GermanPattern>[
  _GermanPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'MİZAN-Bericht: ${t(m[1]!)}',
  ),
  _GermanPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => '${m[1]} – Finanzbericht',
  ),
  _GermanPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MIZAN · Seite ${m[1]}',
  ),
  _GermanPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · Fortsetzung',
  ),
  _GermanPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Zeitraum: ${m[1]}'),
  _GermanPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Personenumfang: ${t(m[1]!)}',
  ),
  _GermanPattern(RegExp(r'^Oluşturulma: (.+)$'), (m, t) => 'Erstellt: ${m[1]}'),
  _GermanPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Offener Plan ${m[1]} · Diesen Monat geleistet ${m[2]}',
  ),
  _GermanPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Zahlungsstatus – ${m[1]}',
  ),
  _GermanPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_items(m[1]!)} offen · ${m[2]}',
  ),
  _GermanPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _GermanPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _GermanPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _GermanPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _GermanPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _GermanPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Weitere Tage anzeigen (${_remaining(m[1]!)})',
  ),
  _GermanPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Weitere Zahlungstage anzeigen (${_remaining(m[1]!)})',
  ),
  _GermanPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Weitere Ausgabentage anzeigen (${_remaining(m[1]!)})',
  ),
  _GermanPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Ab diesem Tag mehr anzeigen (${_remaining(m[1]!)})',
  ),
  _GermanPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => m[2] == '1'
        ? 'Bis ${m[1]} verbleibt 1 Tag'
        : 'Bis ${m[1]} verbleiben ${_days(m[2]!)}',
  ),
  _GermanPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} wird heute erwartet',
  ),
  _GermanPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} ist seit ${_days(m[2]!)} überfällig',
  ),
  _GermanPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Zuletzt eingegangen: ${m[1]} · Geplant ${m[2]}',
  ),
  _GermanPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'Der geplante Zeitraum ${m[1]} wurde am ${m[2]} als eingegangen erfasst. Der feste Eingangstag blieb unverändert.',
  ),
  _GermanPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Tatsächlicher Rechnungsbetrag – ${m[1]}',
  ),
  _GermanPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Restbetrag: ${m[1]}',
  ),
  _GermanPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => 'Verbleibende Raten: ${m[1]}',
  ),
  _GermanPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Ausgabe ${m[1]} löschen?',
  ),
  _GermanPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'Die Kategorie ${m[1]} und ausschließlich die ihr zugeordneten Ausgaben werden gelöscht.',
  ),
  _GermanPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} und alle dieser Person zugeordneten Einträge werden gelöscht. Diese Aktion erfordert eine ausdrückliche Bestätigung.',
  ),
  _GermanPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Der PDF-Bericht konnte nicht gespeichert werden: ${m[1]}',
  ),
  _GermanPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Der PDF-Bericht konnte nicht geteilt werden: ${m[1]}',
  ),
  _GermanPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => m[1] == '1'
        ? '1 Eintrag aus dem Benachrichtigungsplan konnte nicht in Android geschrieben werden. Erster Fehler: ${m[2]}'
        : '${_items(m[1]!)} aus dem Benachrichtigungsplan konnten nicht in Android geschrieben werden. Erster Fehler: ${m[2]}',
  ),
  _GermanPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => m[1] == '1'
        ? 'Der Benachrichtigungsplan konnte nicht geprüft werden; in Android fehlt 1 Eintrag.'
        : 'Der Benachrichtigungsplan konnte nicht geprüft werden; in Android fehlen ${_items(m[1]!)}.',
  ),
  _GermanPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Zahlungserinnerung ${m[1]}',
  ),
  _GermanPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)}; ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _GermanPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) => 'Die Eintrags-ID ${m[1]} ist ungültig oder doppelt vorhanden.',
  ),
  _GermanPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => 'Noch ${_days(m[1]!)}',
  ),
  _GermanPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'Seit ${_days(m[1]!)} überfällig',
  ),
  _GermanPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'Die Zahlung ist seit ${_days(m[1]!)} überfällig.',
  ),
  _GermanPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Fälligkeit: ${m[1]}.',
  ),
  _GermanPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'Am ${m[1]}. des Monats',
  ),
  _GermanPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'Am ${m[1]}. jedes Monats',
  ),
  _GermanPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'Jeden ${_lowerFirst(t(m[1]!))}',
  ),
  _GermanPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Beginn: ${m[1]}'),
  _GermanPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Beginn ${m[1]}'),
  _GermanPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'Gesamt: ${t(m[1]!)}'),
  _GermanPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'Verbleibend: ${t(m[1]!)}'),
  _GermanPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} in diesem Zeitraum',
  ),
  _GermanPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Datum: ${m[1]}'),
  _GermanPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Notiz: ${m[1]}'),
  _GermanPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} darf nicht leer sein.',
  ),
  _GermanPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => '${t(m[1]!)} darf höchstens ${m[2]} Zeichen enthalten.',
  ),
  _GermanPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} muss größer als null sein.',
  ),
  _GermanPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} muss größer als null sein.',
  ),
  _GermanPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} darf nicht negativ sein.',
  ),
  _GermanPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} muss eine positive ganze Zahl sein.',
  ),
  _GermanPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} muss null oder eine positive ganze Zahl sein.',
  ),
  _GermanPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _GermanPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _GermanPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _GermanPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _GermanPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _GermanPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _GermanPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _GermanPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => '${_people(m[1]!)} ausgewählt',
  ),
  _GermanPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_addedItems(m[1]!)}; vorhandene Daten blieben erhalten.',
  ),
  _GermanPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'Der Test wurde exakt für ${m[1]} geplant.',
  ),
  _GermanPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => '${t(m[1]!)} konnte nicht gespeichert werden: ${m[2]}',
  ),
  _GermanPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} konnte nicht erstellt werden: ${m[2]}',
  ),
  _GermanPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} konnte nicht geteilt werden: ${m[2]}',
  ),
  _GermanPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => '${t(m[1]!)} konnte nicht zusammengeführt werden: ${m[2]}',
  ),
];

const List<(String, String)> _germanPhrases = <(String, String)>[
  ('Kişisel ve kurumsal borçlar', 'Private und geschäftliche Schulden'),
  ('Kişisel / kurumsal borç', 'Private / geschäftliche Schuld'),
  ('Kişisel/kurumsal borç', 'Private/geschäftliche Schuld'),
  ('Ödemelere yapılan gider', 'Ausgaben für Zahlungen'),
  ('Bu ay yapılan', 'Diesen Monat geleistet'),
  ('Açık plan', 'Offener Plan'),
  ('Kalan tutar', 'Restbetrag'),
  ('Kalan toplam borç', 'Verbleibende Gesamtschuld'),
  ('Gecikmiş toplam', 'Überfällige Gesamtsumme'),
  ('Önümüzdeki 7 gün', 'Nächste 7 Tage'),
  ('Son ödeme bugün', 'Heute fällig'),
  ('Banka borçları', 'Bankschulden'),
  ('Kira ve taksitler', 'Mieten und Raten'),
  ('Günlük harcamalar', 'Tägliche Ausgaben'),
  ('Gider ayrıntıları', 'Ausgabendetails'),
  ('Ödeme ayrıntıları', 'Zahlungsdetails'),
  ('Gerçekleşen ödeme', 'Geleistete Zahlung'),
  ('Ödeme kayıtları', 'Erfasste Zahlungen'),
  ('Normal giderler', 'Laufende Ausgaben'),
  ('Toplam gider', 'Gesamtausgaben'),
  ('Kalan ödeme yükü', 'Offene Zahlungsverpflichtungen'),
  ('Gecikmiş ödeme yükü', 'Überfällige Zahlungsverpflichtungen'),
  ('Yaklaşan ödeme yükü', 'Bevorstehende Zahlungsverpflichtungen'),
  ('Kişi kapsamı', 'Personenumfang'),
  ('Oluşturulma', 'Erstellt'),
  ('Dönem', 'Zeitraum'),
  ('devam', 'Fortsetzung'),
];

class _GermanPattern {
  const _GermanPattern(this.regExp, this.builder);

  final RegExp regExp;
  final String Function(RegExpMatch match, GermanDynamicTranslator translate)
  builder;
}
