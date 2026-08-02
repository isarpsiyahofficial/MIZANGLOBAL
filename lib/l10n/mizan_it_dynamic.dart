typedef ItalianDynamicTranslator = String Function(String source);

String translateItalianReviewedDynamic(
  String source,
  ItalianDynamicTranslator translate,
) {
  for (final pattern in _italianPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _italianPhrases) {
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

String _days(String value) => _count(value, 'giorno', 'giorni');
String _items(String value) => _count(value, 'registrazione', 'registrazioni');
String _payments(String value) => _count(value, 'pagamento', 'pagamenti');
String _expenses(String value) => _count(value, 'spesa', 'spese');
String _months(String value) => _count(value, 'mese', 'mesi');
String _people(String value) => _count(value, 'persona', 'persone');
String _remaining(String value) => value == '1' ? '1 rimanente' : '$value rimanenti';
String _dailyExpenses(String value) => value == '1'
    ? '1 spesa giornaliera'
    : '$value spese giornaliere';
String _expenseRecords(String value) => value == '1'
    ? '1 registrazione di spesa'
    : '$value registrazioni di spesa';
String _newItems(String value) => value == '1'
    ? '1 nuova registrazione'
    : '$value nuove registrazioni';
String _addedItems(String value) => value == '1'
    ? 'È stata aggiunta 1 nuova registrazione'
    : 'Sono state aggiunte $value nuove registrazioni';
String _updatedLinks(String value) => value == '1'
    ? '1 collegamento aggiornato'
    : '$value collegamenti aggiornati';

final List<_ItalianPattern> _italianPatterns = <_ItalianPattern>[
  _ItalianPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Report MİZAN: ${t(m[1]!)}',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => '${m[1]} – report finanziario',
  ),
  _ItalianPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MIZAN · Pagina ${m[1]}',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · continua',
  ),
  _ItalianPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Periodo: ${m[1]}'),
  _ItalianPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Ambito persone: ${t(m[1]!)}',
  ),
  _ItalianPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Creato: ${m[1]}',
  ),
  _ItalianPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Piano aperto ${m[1]} · Effettuato questo mese ${m[2]}',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Stato dei pagamenti – ${m[1]}',
  ),
  _ItalianPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_items(m[1]!)} aperte · ${m[2]}',
  ),
  _ItalianPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _ItalianPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _ItalianPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _ItalianPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _ItalianPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _ItalianPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostra altri giorni (${_remaining(m[1]!)})',
  ),
  _ItalianPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostra altri giorni di pagamento (${_remaining(m[1]!)})',
  ),
  _ItalianPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostra altri giorni di spesa (${_remaining(m[1]!)})',
  ),
  _ItalianPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostra altro da questo giorno (${_remaining(m[1]!)})',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => m[2] == '1'
        ? 'Manca 1 giorno per ${m[1]}'
        : 'Mancano ${_days(m[2]!)} per ${m[1]}',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} è previsto per oggi',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} è in ritardo di ${_days(m[2]!)}',
  ),
  _ItalianPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Ultima ricezione: ${m[1]} · Prevista ${m[2]}',
  ),
  _ItalianPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'Il periodo previsto ${m[1]} è stato registrato come ricevuto il ${m[2]}. Il giorno fisso di accredito non è cambiato.',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Importo effettivo della bolletta – ${m[1]}',
  ),
  _ItalianPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Importo residuo: ${m[1]}',
  ),
  _ItalianPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => 'Rate residue: ${m[1]}',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Eliminare la spesa ${m[1]}?',
  ),
  _ItalianPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'Verranno eliminate la categoria ${m[1]} e soltanto le spese ad essa collegate.',
  ),
  _ItalianPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        'Verranno eliminati ${m[1]} e tutte le registrazioni associate a questa persona. L’operazione richiede una conferma esplicita.',
  ),
  _ItalianPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Non è stato possibile salvare il report PDF: ${m[1]}',
  ),
  _ItalianPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Non è stato possibile condividere il report PDF: ${m[1]}',
  ),
  _ItalianPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => m[1] == '1'
        ? 'Non è stato possibile scrivere 1 registrazione del piano notifiche nel sistema Android. Primo errore: ${m[2]}'
        : 'Non è stato possibile scrivere ${_items(m[1]!)} del piano notifiche nel sistema Android. Primo errore: ${m[2]}',
  ),
  _ItalianPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => m[1] == '1'
        ? 'Non è stato possibile verificare il piano notifiche; in Android manca 1 registrazione.'
        : 'Non è stato possibile verificare il piano notifiche; in Android mancano ${_items(m[1]!)}.',
  ),
  _ItalianPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Promemoria di pagamento ${m[1]}',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)}; ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) =>
        'L’identificativo della registrazione ${m[1]} non è valido oppure è duplicato.',
  ),
  _ItalianPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => m[1] == '1' ? 'Manca 1 giorno' : 'Mancano ${_days(m[1]!)}',
  ),
  _ItalianPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'In ritardo di ${_days(m[1]!)}',
  ),
  _ItalianPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'Il pagamento è in ritardo di ${_days(m[1]!)}.',
  ),
  _ItalianPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Scadenza: ${m[1]}.',
  ),
  _ItalianPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'Il giorno ${m[1]} del mese',
  ),
  _ItalianPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'Il giorno ${m[1]} di ogni mese',
  ),
  _ItalianPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'Ogni ${_lowerFirst(t(m[1]!))}',
  ),
  _ItalianPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Inizio: ${m[1]}'),
  _ItalianPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Inizio ${m[1]}'),
  _ItalianPattern(
    RegExp(r'^Toplam (.+)$'),
    (m, t) => 'Totale: ${t(m[1]!)}',
  ),
  _ItalianPattern(
    RegExp(r'^Kalan (.+)$'),
    (m, t) => 'Residuo: ${t(m[1]!)}',
  ),
  _ItalianPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} in questo periodo',
  ),
  _ItalianPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Data: ${m[1]}'),
  _ItalianPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Nota: ${m[1]}'),
  _ItalianPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} non può essere vuoto.',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => '${t(m[1]!)} può contenere al massimo ${m[2]} caratteri.',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} deve essere maggiore di zero.',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} deve essere maggiore di zero.',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} non può essere negativo.',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} deve essere un numero intero positivo.',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} deve essere zero o un numero intero positivo.',
  ),
  _ItalianPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _ItalianPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _ItalianPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _ItalianPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _ItalianPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _ItalianPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _ItalianPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _ItalianPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => '${_people(m[1]!)} selezionate',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_addedItems(m[1]!)}; i dati esistenti sono stati mantenuti.',
  ),
  _ItalianPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'Il test è stato pianificato esattamente per le ${m[1]}.',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'Non è stato possibile salvare ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'Non è stato possibile creare ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'Non è stato possibile condividere ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _ItalianPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'Non è stato possibile unire ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
];

const List<(String, String)> _italianPhrases = <(String, String)>[
  ('Kişisel ve kurumsal borçlar', 'Debiti personali e aziendali'),
  ('Kişisel / kurumsal borç', 'Debito personale / aziendale'),
  ('Kişisel/kurumsal borç', 'Debito personale/aziendale'),
  ('Ödemelere yapılan gider', 'Spese per pagamenti'),
  ('Bu ay yapılan', 'Effettuato questo mese'),
  ('Açık plan', 'Piano aperto'),
  ('Kalan tutar', 'Importo residuo'),
  ('Kalan toplam borç', 'Debito residuo totale'),
  ('Gecikmiş toplam', 'Totale scaduto'),
  ('Önümüzdeki 7 gün', 'Prossimi 7 giorni'),
  ('Son ödeme bugün', 'Scadenza oggi'),
  ('Banka borçları', 'Debiti bancari'),
  ('Kira ve taksitler', 'Affitti e rate'),
  ('Günlük harcamalar', 'Spese giornaliere'),
  ('Gider ayrıntıları', 'Dettagli delle spese'),
  ('Ödeme ayrıntıları', 'Dettagli dei pagamenti'),
  ('Gerçekleşen ödeme', 'Pagamento effettuato'),
  ('Ödeme kayıtları', 'Pagamenti registrati'),
  ('Normal giderler', 'Spese ordinarie'),
  ('Toplam gider', 'Spese totali'),
  ('Kalan ödeme yükü', 'Pagamenti ancora dovuti'),
  ('Gecikmiş ödeme yükü', 'Pagamenti scaduti ancora dovuti'),
  ('Yaklaşan ödeme yükü', 'Pagamenti in scadenza ancora dovuti'),
  ('Kişi kapsamı', 'Ambito persone'),
  ('Oluşturulma', 'Creato'),
  ('Dönem', 'Periodo'),
  ('devam', 'continua'),
];

class _ItalianPattern {
  const _ItalianPattern(this.regExp, this.builder);

  final RegExp regExp;
  final String Function(RegExpMatch match, ItalianDynamicTranslator translate)
  builder;
}
