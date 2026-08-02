typedef FrenchDynamicTranslator = String Function(String source);

String translateFrenchReviewedDynamic(
  String source,
  FrenchDynamicTranslator translate,
) {
  for (final pattern in _frenchPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _frenchPhrases) {
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

String _days(String value) => _count(value, 'jour', 'jours');
String _items(String value) => _count(value, 'élément', 'éléments');
String _payments(String value) => _count(value, 'paiement', 'paiements');
String _expenses(String value) => _count(value, 'dépense', 'dépenses');
String _months(String value) => '$value mois';
String _people(String value) => _count(value, 'personne', 'personnes');
String _remaining(String value) =>
    value == '1' ? '$value restant' : '$value restants';
String _dailyExpenses(String value) =>
    value == '1' ? '$value dépense quotidienne' : '$value dépenses quotidiennes';
String _expenseRecords(String value) =>
    value == '1' ? '$value dépense enregistrée' : '$value dépenses enregistrées';
String _newItems(String value) =>
    value == '1' ? '1 nouvel élément' : '$value nouveaux éléments';
String _addedItems(String value) => value == '1'
    ? '1 nouvel élément a été ajouté'
    : '$value nouveaux éléments ont été ajoutés';
String _updatedLinks(String value) =>
    value == '1' ? '1 lien mis à jour' : '$value liens mis à jour';
String _ordinalDay(String value) => value == '1' ? '1er' : value;

final List<_FrenchPattern> _frenchPatterns = <_FrenchPattern>[
  _FrenchPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Rapport ${_lowerFirst(t(m[1]!))} MİZAN',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => 'Rapport financier — ${m[1]}',
  ),
  _FrenchPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MIZAN · Page ${m[1]}',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · suite',
  ),
  _FrenchPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Période : ${m[1]}'),
  _FrenchPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Périmètre des personnes : ${t(m[1]!)}',
  ),
  _FrenchPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Généré le : ${m[1]}',
  ),
  _FrenchPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Prévu et restant ${m[1]} · Payé ce mois-ci ${m[2]}',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'État des paiements — ${m[1]}',
  ),
  _FrenchPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_items(m[1]!)} ouverts · ${m[2]}',
  ),
  _FrenchPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _FrenchPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _FrenchPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _FrenchPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _FrenchPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _FrenchPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Afficher plus de jours (${_remaining(m[1]!)})',
  ),
  _FrenchPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Afficher plus de jours de paiement (${_remaining(m[1]!)})',
  ),
  _FrenchPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Afficher plus de jours de dépenses (${_remaining(m[1]!)})',
  ),
  _FrenchPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Afficher davantage à partir de ce jour (${_remaining(m[1]!)})',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => 'Il reste ${_days(m[2]!)} avant ${m[1]}',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} est prévu aujourd’hui',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} a ${_days(m[2]!)} de retard',
  ),
  _FrenchPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Dernière réception : ${m[1]} · Prévu ${m[2]}',
  ),
  _FrenchPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'La période prévue pour ${m[1]} a été enregistrée comme reçue le ${m[2]}. Le jour de versement fixe n’a pas été modifié.',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Montant réel de la facture — ${m[1]}',
  ),
  _FrenchPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Montant restant : ${m[1]}',
  ),
  _FrenchPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => 'Mensualités restantes : ${m[1]}',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Supprimer la dépense ${m[1]} ?',
  ),
  _FrenchPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'La catégorie ${m[1]} et uniquement les dépenses qui lui sont associées seront supprimées.',
  ),
  _FrenchPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} et tous les éléments associés à cette personne seront supprimés. Cette action nécessite une confirmation explicite.',
  ),
  _FrenchPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Impossible d’enregistrer le rapport PDF : ${m[1]}',
  ),
  _FrenchPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Impossible de partager le rapport PDF : ${m[1]}',
  ),
  _FrenchPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) =>
        'Impossible d’écrire ${_items(m[1]!)} de la programmation des notifications dans Android. Première erreur : ${m[2]}',
  ),
  _FrenchPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) =>
        'La programmation des notifications n’a pas pu être vérifiée ; il manque ${_items(m[1]!)} dans Android.',
  ),
  _FrenchPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Rappel de paiement ${m[1]}',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)} ; ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) =>
        'L’identifiant de l’élément ${m[1]} n’est pas valide ou est dupliqué.',
  ),
  _FrenchPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => 'Il reste ${_days(m[1]!)}',
  ),
  _FrenchPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => '${_days(m[1]!)} de retard',
  ),
  _FrenchPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'Le paiement a ${_days(m[1]!)} de retard.',
  ),
  _FrenchPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Échéance : ${m[1]}.',
  ),
  _FrenchPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'Le ${_ordinalDay(m[1]!)} du mois',
  ),
  _FrenchPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'Le ${_ordinalDay(m[1]!)} de chaque mois',
  ),
  _FrenchPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'Chaque ${_lowerFirst(t(m[1]!))}',
  ),
  _FrenchPattern(
    RegExp(r'^Başlangıç: (.+)$'),
    (m, t) => 'Début : ${m[1]}',
  ),
  _FrenchPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Début ${m[1]}'),
  _FrenchPattern(
    RegExp(r'^Toplam (.+)$'),
    (m, t) => 'Total ${_lowerFirst(t(m[1]!))}',
  ),
  _FrenchPattern(
    RegExp(r'^Kalan (.+)$'),
    (m, t) => 'Reste : ${t(m[1]!)}',
  ),
  _FrenchPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} pour cette période',
  ),
  _FrenchPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Date : ${m[1]}'),
  _FrenchPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Note : ${m[1]}'),
  _FrenchPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} est obligatoire.',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => '${t(m[1]!)} peut contenir au maximum ${m[2]} caractères.',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} doit être supérieur à zéro.',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} doit être supérieur à zéro.',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} ne peut pas être négatif.',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} doit être un nombre entier positif.',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} doit être égal à zéro ou être un nombre entier positif.',
  ),
  _FrenchPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _FrenchPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _FrenchPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _FrenchPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _FrenchPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _FrenchPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _FrenchPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _FrenchPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => m[1] == '1'
        ? '${_people(m[1]!)} sélectionnée'
        : '${_people(m[1]!)} sélectionnées',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_addedItems(m[1]!)} ; les données existantes ont été conservées.',
  ),
  _FrenchPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'Le test a été programmé exactement pour ${m[1]}.',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'Impossible d’enregistrer ${_lowerFirst(t(m[1]!))} : ${m[2]}',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'Impossible de créer ${_lowerFirst(t(m[1]!))} : ${m[2]}',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'Impossible de partager ${_lowerFirst(t(m[1]!))} : ${m[2]}',
  ),
  _FrenchPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'Impossible de fusionner ${_lowerFirst(t(m[1]!))} : ${m[2]}',
  ),
];

const List<(String, String)> _frenchPhrases = <(String, String)>[
  ('Kişisel ve kurumsal borçlar', 'Dettes personnelles et professionnelles'),
  ('Kişisel / kurumsal borç', 'Dette personnelle / professionnelle'),
  ('Kişisel/kurumsal borç', 'Dette personnelle/professionnelle'),
  ('Ödemelere yapılan gider', 'Dépenses liées aux paiements'),
  ('Bu ay yapılan', 'Payé ce mois-ci'),
  ('Açık plan', 'Prévu et restant'),
  ('Kalan tutar', 'Montant restant'),
  ('Kalan toplam borç', 'Dette totale restante'),
  ('Gecikmiş toplam', 'Total en retard'),
  ('Önümüzdeki 7 gün', '7 prochains jours'),
  ('Son ödeme bugün', 'Échéance aujourd’hui'),
  ('Banka borçları', 'Dettes bancaires'),
  ('Kira ve taksitler', 'Loyers et mensualités'),
  ('Günlük harcamalar', 'Dépenses quotidiennes'),
  ('Gider ayrıntıları', 'Détails des dépenses'),
  ('Ödeme ayrıntıları', 'Détails des paiements'),
  ('Gerçekleşen ödeme', 'Paiement effectué'),
  ('Ödeme kayıtları', 'Paiements enregistrés'),
  ('Normal giderler', 'Dépenses courantes'),
  ('Toplam gider', 'Dépenses totales'),
  ('Kalan ödeme yükü', 'Paiements restant dus'),
  ('Gecikmiş ödeme yükü', 'Paiements en retard restant dus'),
  ('Yaklaşan ödeme yükü', 'Paiements à venir'),
  ('Kişi kapsamı', 'Périmètre des personnes'),
  ('Oluşturulma', 'Généré le'),
  ('Dönem', 'Période'),
  ('devam', 'suite'),
];

class _FrenchPattern {
  const _FrenchPattern(this.regExp, this.builder);

  final RegExp regExp;
  final String Function(RegExpMatch match, FrenchDynamicTranslator translate)
  builder;
}
