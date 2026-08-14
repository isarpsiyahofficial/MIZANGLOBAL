typedef GreekDynamicTranslator = String Function(String source);

String translateGreekReviewedDynamic(
  String source,
  GreekDynamicTranslator translate,
) {
  for (final pattern in _greekPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _greekPhrases) {
    value = value.replaceAll(entry.$1, entry.$2);
  }
  return value;
}

String _lowerFirst(String value) =>
    value.isEmpty ? value : '${value[0].toLowerCase()}${value.substring(1)}';
String _count(String value, String singular, String plural) =>
    value == '1' ? '$value $singular' : '$value $plural';
String _days(String value) => _count(value, 'ημέρα', 'ημέρες');
String _items(String value) => _count(value, 'εγγραφή', 'εγγραφές');
String _openItems(String value) =>
    value == '1' ? '1 ανοιχτή εγγραφή' : '$value ανοιχτές εγγραφές';
String _payments(String value) => _count(value, 'πληρωμή', 'πληρωμές');
String _expenses(String value) => _count(value, 'έξοδο', 'έξοδα');
String _months(String value) => _count(value, 'μήνας', 'μήνες');
String _people(String value) => _count(value, 'πρόσωπο', 'πρόσωπα');
String _remaining(String value) =>
    value == '1' ? 'απομένει 1' : 'απομένουν $value';
String _remainingDays(String value) =>
    value == '1' ? 'Απομένει 1 ημέρα' : 'Απομένουν $value ημέρες';
String _remainingInstallments(String value) =>
    value == '1' ? 'Υπόλοιπη δόση: 1' : 'Υπόλοιπες δόσεις: $value';
String _androidWriteFailure(String value, String error) => value == '1'
    ? '1 εγγραφή του προγράμματος ειδοποιήσεων δεν μπόρεσε να καταχωριστεί στο Android. Πρώτο σφάλμα: $error'
    : '$value εγγραφές του προγράμματος ειδοποιήσεων δεν μπόρεσαν να καταχωριστούν στο Android. Πρώτο σφάλμα: $error';
String _androidMissing(String value) => value == '1'
    ? 'Δεν ήταν δυνατή η επαλήθευση του προγράμματος ειδοποιήσεων· λείπει 1 εγγραφή από το Android.'
    : 'Δεν ήταν δυνατή η επαλήθευση του προγράμματος ειδοποιήσεων· λείπουν $value εγγραφές από το Android.';
String _dailyExpenses(String value) =>
    value == '1' ? '1 ημερήσιο έξοδο' : '$value ημερήσια έξοδα';
String _expenseRecords(String value) =>
    value == '1' ? '1 εγγραφή εξόδου' : '$value εγγραφές εξόδων';
String _newItems(String value) =>
    value == '1' ? '1 νέα εγγραφή' : '$value νέες εγγραφές';
String _addedItems(String value) => value == '1'
    ? 'Προστέθηκε 1 νέα εγγραφή'
    : 'Προστέθηκαν $value νέες εγγραφές';
String _updatedLinks(String value) => value == '1'
    ? 'ενημερώθηκε 1 συσχέτιση'
    : 'ενημερώθηκαν $value συσχετίσεις';

final List<_GreekPattern> _greekPatterns = <_GreekPattern>[
  _GreekPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Αναφορά MİZAN: ${t(m[1]!)}',
  ),
  _GreekPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => '${m[1]} — οικονομική αναφορά',
  ),
  _GreekPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · Σελίδα ${m[1]}',
  ),
  _GreekPattern(RegExp(r'^(.+) · devam$'), (m, t) => '${t(m[1]!)} · συνέχεια'),
  _GreekPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Περίοδος: ${m[1]}'),
  _GreekPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Εύρος προσώπων: ${t(m[1]!)}',
  ),
  _GreekPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Δημιουργήθηκε: ${m[1]}',
  ),
  _GreekPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) =>
        'Ανοιχτό πρόγραμμα ${m[1]} · Πραγματοποιήθηκαν αυτόν τον μήνα ${m[2]}',
  ),
  _GreekPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Κατάσταση πληρωμών — ${m[1]}',
  ),
  _GreekPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _GreekPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _GreekPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _GreekPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _GreekPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _GreekPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _GreekPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Εμφάνιση περισσότερων ημερών (${_remaining(m[1]!)})',
  ),
  _GreekPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Εμφάνιση περισσότερων ημερών πληρωμής (${_remaining(m[1]!)})',
  ),
  _GreekPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Εμφάνιση περισσότερων ημερών εξόδων (${_remaining(m[1]!)})',
  ),
  _GreekPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) =>
        'Εμφάνιση περισσότερων από αυτήν την ημέρα (${_remaining(m[1]!)})',
  ),
  _GreekPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => m[2] == '1'
        ? 'Απομένει 1 ημέρα έως ${m[1]}'
        : 'Απομένουν ${m[2]} ημέρες έως ${m[1]}',
  ),
  _GreekPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} αναμένεται σήμερα',
  ),
  _GreekPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} έχει καθυστέρηση ${_days(m[2]!)}',
  ),
  _GreekPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Τελευταία είσπραξη: ${m[1]} · Προγραμματισμένη ${m[2]}',
  ),
  _GreekPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'Η προγραμματισμένη περίοδος ${m[1]} καταχωρίστηκε ως εισπραχθείσα στις ${m[2]}. Η σταθερή ημέρα είσπραξης δεν άλλαξε.',
  ),
  _GreekPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Πραγματικό ποσό λογαριασμού — ${m[1]}',
  ),
  _GreekPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Υπόλοιπο ποσό: ${m[1]}',
  ),
  _GreekPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => _remainingInstallments(m[1]!),
  ),
  _GreekPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Να διαγραφεί το έξοδο ${m[1]};',
  ),
  _GreekPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'Θα διαγραφεί η κατηγορία ${m[1]} και μόνο τα έξοδα που συνδέονται με αυτήν.',
  ),
  _GreekPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        'Θα διαγραφεί το πρόσωπο ${m[1]} και όλες οι συνδεδεμένες εγγραφές. Η ενέργεια απαιτεί ρητή επιβεβαίωση.',
  ),
  _GreekPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Δεν ήταν δυνατή η αποθήκευση της αναφοράς PDF: ${m[1]}',
  ),
  _GreekPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Δεν ήταν δυνατή η κοινοποίηση της αναφοράς PDF: ${m[1]}',
  ),
  _GreekPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) => _androidWriteFailure(m[1]!, m[2]!),
  ),
  _GreekPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) => _androidMissing(m[1]!),
  ),
  _GreekPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Υπενθύμιση πληρωμής ${m[1]}',
  ),
  _GreekPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)}· ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _GreekPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) =>
        'Το αναγνωριστικό εγγραφής ${m[1]} δεν είναι έγκυρο ή είναι διπλό.',
  ),
  _GreekPattern(RegExp(r'^(\d+) gün kaldı$'), (m, t) => _remainingDays(m[1]!)),
  _GreekPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'Καθυστέρηση ${_days(m[1]!)}',
  ),
  _GreekPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'Η πληρωμή καθυστέρησε ${_days(m[1]!)}.',
  ),
  _GreekPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Ημερομηνία λήξης: ${m[1]}.',
  ),
  _GreekPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => '${m[1]}η ημέρα του μήνα',
  ),
  _GreekPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'Την ${m[1]}η ημέρα κάθε μήνα',
  ),
  _GreekPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'Κάθε ${_lowerFirst(t(m[1]!))}',
  ),
  _GreekPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Έναρξη: ${m[1]}'),
  _GreekPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Έναρξη ${m[1]}'),
  _GreekPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'Σύνολο: ${t(m[1]!)}'),
  _GreekPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'Υπόλοιπο: ${t(m[1]!)}'),
  _GreekPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} αυτής της περιόδου',
  ),
  _GreekPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Ημερομηνία: ${m[1]}'),
  _GreekPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Σημείωση: ${m[1]}'),
  _GreekPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => 'Το πεδίο «${t(m[1]!)}» δεν μπορεί να είναι κενό.',
  ),
  _GreekPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) =>
        'Το πεδίο «${t(m[1]!)}» μπορεί να περιέχει έως ${m[2]} χαρακτήρες.',
  ),
  _GreekPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) =>
        'Η τιμή του πεδίου «${t(m[1]!)}» πρέπει να είναι μεγαλύτερη από το μηδέν.',
  ),
  _GreekPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) =>
        'Η τιμή του πεδίου «${t(m[1]!)}» πρέπει να είναι μεγαλύτερη από το μηδέν.',
  ),
  _GreekPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => 'Η τιμή του πεδίου «${t(m[1]!)}» δεν μπορεί να είναι αρνητική.',
  ),
  _GreekPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) =>
        'Η τιμή του πεδίου «${t(m[1]!)}» πρέπει να είναι θετικός ακέραιος.',
  ),
  _GreekPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) =>
        'Η τιμή του πεδίου «${t(m[1]!)}» πρέπει να είναι μηδέν ή θετικός ακέραιος.',
  ),
  _GreekPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _GreekPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _GreekPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _GreekPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _GreekPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _GreekPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _GreekPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) =>
        m[1] == '1' ? 'Επιλέχθηκε 1 πρόσωπο' : 'Επιλέχθηκαν ${_people(m[1]!)}',
  ),
  _GreekPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_addedItems(m[1]!)}· τα υπάρχοντα δεδομένα διατηρήθηκαν.',
  ),
  _GreekPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'Η δοκιμή προγραμματίστηκε με ακρίβεια για ${m[1]}.',
  ),
  _GreekPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'Δεν ήταν δυνατή η αποθήκευση του στοιχείου ${t(m[1]!)}: ${m[2]}',
  ),
  _GreekPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'Δεν ήταν δυνατή η δημιουργία του στοιχείου ${t(m[1]!)}: ${m[2]}',
  ),
  _GreekPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) =>
        'Δεν ήταν δυνατή η κοινοποίηση του στοιχείου ${t(m[1]!)}: ${m[2]}',
  ),
  _GreekPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'Δεν ήταν δυνατή η συγχώνευση του στοιχείου ${t(m[1]!)}: ${m[2]}',
  ),
];

const List<(String, String)> _greekPhrases = <(String, String)>[
  ('Kişisel ve kurumsal borçlar', 'Προσωπικά και επαγγελματικά χρέη'),
  ('Kişisel / kurumsal borç', 'Προσωπικό / επαγγελματικό χρέος'),
  ('Kişisel/kurumsal borç', 'Προσωπικό/επαγγελματικό χρέος'),
  ('Ödemelere yapılan gider', 'Δαπάνες πληρωμών'),
  ('Bu ay yapılan', 'Πραγματοποιήθηκαν αυτόν τον μήνα'),
  ('Açık plan', 'Ανοιχτό πρόγραμμα'),
  ('Kalan tutar', 'Υπόλοιπο ποσό'),
  ('Kalan toplam borç', 'Συνολικό ανεξόφλητο χρέος'),
  ('Gecikmiş toplam', 'Συνολικό ποσό σε καθυστέρηση'),
  ('Önümüzdeki 7 gün', 'Επόμενες 7 ημέρες'),
  ('Son ödeme bugün', 'Λήγει σήμερα'),
  ('Banka borçları', 'Τραπεζικά χρέη'),
  ('Kira ve taksitler', 'Ενοίκια και δόσεις'),
  ('Günlük harcamalar', 'Ημερήσια έξοδα'),
  ('Gider ayrıntıları', 'Λεπτομέρειες εξόδων'),
  ('Ödeme ayrıntıları', 'Στοιχεία πληρωμής'),
  ('Gerçekleşen ödeme', 'Πραγματοποιημένη πληρωμή'),
  ('Ödeme kayıtları', 'Εγγραφές πληρωμών'),
  ('Normal giderler', 'Τακτικά έξοδα'),
  ('Toplam gider', 'Συνολικές δαπάνες'),
  ('Kalan ödeme yükü', 'Εκκρεμείς υποχρεώσεις πληρωμής'),
  ('Gecikmiş ödeme yükü', 'Εκπρόθεσμες υποχρεώσεις πληρωμής'),
  ('Yaklaşan ödeme yükü', 'Επερχόμενες υποχρεώσεις πληρωμής'),
  ('Kişi kapsamı', 'Εύρος προσώπων'),
  ('Oluşturulma', 'Δημιουργήθηκε'),
  ('Dönem', 'Περίοδος'),
  ('devam', 'συνέχεια'),
];

class _GreekPattern {
  const _GreekPattern(this.regExp, this.builder);
  final RegExp regExp;
  final String Function(RegExpMatch match, GreekDynamicTranslator translate)
      builder;
}
