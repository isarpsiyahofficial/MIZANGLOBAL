typedef RomanianDynamicTranslator = String Function(String source);

String translateRomanianReviewedDynamic(
  String source,
  RomanianDynamicTranslator translate,
) {
  for (final pattern in _romanianPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _romanianPhrases) {
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

String _days(String value) => _count(value, 'zi', 'zile');
String _items(String value) => _count(value, 'înregistrare', 'înregistrări');
String _openItems(String value) =>
    value == '1' ? '1 înregistrare deschisă' : '$value înregistrări deschise';
String _payments(String value) => _count(value, 'plată', 'plăți');
String _expenses(String value) => _count(value, 'cheltuială', 'cheltuieli');
String _months(String value) => _count(value, 'lună', 'luni');
String _people(String value) => _count(value, 'persoană', 'persoane');
String _remaining(String value) =>
    value == '1' ? 'a mai rămas 1' : 'au mai rămas $value';
String _remainingDays(String value) =>
    value == '1' ? 'A mai rămas 1 zi' : 'Au mai rămas $value zile';
String _dailyExpenses(String value) =>
    value == '1' ? '1 cheltuială zilnică' : '$value cheltuieli zilnice';
String _expenseRecords(String value) => value == '1'
    ? '1 înregistrare de cheltuială'
    : '$value înregistrări de cheltuieli';
String _newItems(String value) =>
    value == '1' ? '1 înregistrare nouă' : '$value înregistrări noi';
String _addedItems(String value) => value == '1'
    ? 'A fost adăugată 1 înregistrare nouă'
    : 'Au fost adăugate $value înregistrări noi';
String _updatedLinks(String value) => value == '1'
    ? 'a fost actualizată 1 asociere'
    : 'au fost actualizate $value asocieri';

final List<_RomanianPattern> _romanianPatterns = <_RomanianPattern>[
  _RomanianPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Raport MİZAN: ${t(m[1]!)}',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => '${m[1]} — raport financiar',
  ),
  _RomanianPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MİZAN · Pagina ${m[1]}',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · continuare',
  ),
  _RomanianPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Perioadă: ${m[1]}'),
  _RomanianPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Persoane incluse: ${t(m[1]!)}',
  ),
  _RomanianPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Generat la: ${m[1]}',
  ),
  _RomanianPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Plan deschis ${m[1]} · Efectuat în această lună ${m[2]}',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Starea plăților — ${m[1]}',
  ),
  _RomanianPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_openItems(m[1]!)} · ${m[2]}',
  ),
  _RomanianPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _RomanianPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_items(m[2]!)} · ${m[3]}',
  ),
  _RomanianPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _RomanianPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _RomanianPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _RomanianPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Afișează mai multe zile (${_remaining(m[1]!)})',
  ),
  _RomanianPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Afișează mai multe zile de plată (${_remaining(m[1]!)})',
  ),
  _RomanianPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Afișează mai multe zile de cheltuieli (${_remaining(m[1]!)})',
  ),
  _RomanianPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Afișează mai multe din această zi (${_remaining(m[1]!)})',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => m[2] == '1'
        ? 'A mai rămas 1 zi până la ${m[1]}'
        : 'Au mai rămas ${m[2]} zile până la ${m[1]}',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} este așteptat astăzi',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} are o întârziere de ${_days(m[2]!)}',
  ),
  _RomanianPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Ultima încasare: ${m[1]} · Planificat ${m[2]}',
  ),
  _RomanianPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'Perioada planificată ${m[1]} a fost marcată ca încasată la data de ${m[2]}. Ziua fixă de încasare nu s-a modificat.',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Valoarea efectivă a facturii — ${m[1]}',
  ),
  _RomanianPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Sumă rămasă: ${m[1]}',
  ),
  _RomanianPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => 'Rate rămase: ${m[1]}',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Ștergeți cheltuiala ${m[1]}?',
  ),
  _RomanianPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'Categoria ${m[1]} și numai cheltuielile asociate acesteia vor fi șterse.',
  ),
  _RomanianPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} și toate înregistrările asociate acestei persoane vor fi șterse. Acțiunea necesită o confirmare explicită.',
  ),
  _RomanianPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Raportul PDF nu a putut fi salvat: ${m[1]}',
  ),
  _RomanianPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Raportul PDF nu a putut fi distribuit: ${m[1]}',
  ),
  _RomanianPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) =>
        '${_items(m[1]!)} din planul de notificări nu au putut fi scrise în sistemul Android. Prima eroare: ${m[2]}',
  ),
  _RomanianPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) =>
        'Planul de notificări nu a putut fi verificat; în sistemul Android lipsesc ${_items(m[1]!)}.',
  ),
  _RomanianPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Memento de plată ${m[1]}',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newItems(m[1]!)}; ${_updatedLinks(m[2]!)}${m[3]}.',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) =>
        'Identificatorul înregistrării ${m[1]} este nevalid sau duplicat.',
  ),
  _RomanianPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => _remainingDays(m[1]!),
  ),
  _RomanianPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => 'Întârziere de ${_days(m[1]!)}',
  ),
  _RomanianPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'Plata are o întârziere de ${_days(m[1]!)}.',
  ),
  _RomanianPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Data scadenței: ${m[1]}.',
  ),
  _RomanianPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'Ziua ${m[1]} a lunii',
  ),
  _RomanianPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'În ziua ${m[1]} a fiecărei luni',
  ),
  _RomanianPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'În fiecare ${_lowerFirst(t(m[1]!))}',
  ),
  _RomanianPattern(RegExp(r'^Başlangıç: (.+)$'), (m, t) => 'Început: ${m[1]}'),
  _RomanianPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Început ${m[1]}'),
  _RomanianPattern(RegExp(r'^Toplam (.+)$'), (m, t) => 'Total: ${t(m[1]!)}'),
  _RomanianPattern(RegExp(r'^Kalan (.+)$'), (m, t) => 'Rămas: ${t(m[1]!)}'),
  _RomanianPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} în această perioadă',
  ),
  _RomanianPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Data: ${m[1]}'),
  _RomanianPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Notă: ${m[1]}'),
  _RomanianPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => 'Câmpul ${_lowerFirst(t(m[1]!))} nu poate fi gol.',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) =>
        'Câmpul ${_lowerFirst(t(m[1]!))} poate conține cel mult ${m[2]} caractere.',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) =>
        'Valoarea pentru ${_lowerFirst(t(m[1]!))} trebuie să fie mai mare decât zero.',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) =>
        'Valoarea pentru ${_lowerFirst(t(m[1]!))} trebuie să fie mai mare decât zero.',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => 'Valoarea pentru ${_lowerFirst(t(m[1]!))} nu poate fi negativă.',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) =>
        'Valoarea pentru ${_lowerFirst(t(m[1]!))} trebuie să fie un număr întreg pozitiv.',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) =>
        'Valoarea pentru ${_lowerFirst(t(m[1]!))} trebuie să fie zero sau un număr întreg pozitiv.',
  ),
  _RomanianPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _items(m[1]!)),
  _RomanianPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _RomanianPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _RomanianPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => _expenseRecords(m[1]!),
  ),
  _RomanianPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_items(m[2]!)}',
  ),
  _RomanianPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _RomanianPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _RomanianPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) =>
        m[1] == '1' ? '1 persoană selectată' : '${_people(m[1]!)} selectate',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_addedItems(m[1]!)}; datele existente au fost păstrate.',
  ),
  _RomanianPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'Testul a fost programat exact pentru ${m[1]}.',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => '${t(m[1]!)} nu a putut fi salvat(ă): ${m[2]}',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} nu a putut fi creat(ă): ${m[2]}',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => '${t(m[1]!)} nu a putut fi distribuit(ă): ${m[2]}',
  ),
  _RomanianPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => '${t(m[1]!)} nu a putut fi combinat(ă): ${m[2]}',
  ),
];

const List<(String, String)> _romanianPhrases = <(String, String)>[
  ('Kişisel ve kurumsal borçlar', 'Datorii personale și comerciale'),
  ('Kişisel / kurumsal borç', 'Datorie personală / comercială'),
  ('Kişisel/kurumsal borç', 'Datorie personală/comercială'),
  ('Ödemelere yapılan gider', 'Cheltuieli aferente plăților'),
  ('Bu ay yapılan', 'Efectuat în această lună'),
  ('Açık plan', 'Plan deschis'),
  ('Kalan tutar', 'Sumă rămasă'),
  ('Kalan toplam borç', 'Datorie totală rămasă'),
  ('Gecikmiş toplam', 'Total restant'),
  ('Önümüzdeki 7 gün', 'Următoarele 7 zile'),
  ('Son ödeme bugün', 'Scadență astăzi'),
  ('Banka borçları', 'Datorii bancare'),
  ('Kira ve taksitler', 'Chirii și rate'),
  ('Günlük harcamalar', 'Cheltuieli zilnice'),
  ('Gider ayrıntıları', 'Detalii despre cheltuieli'),
  ('Ödeme ayrıntıları', 'Detalii despre plăți'),
  ('Gerçekleşen ödeme', 'Plată efectuată'),
  ('Ödeme kayıtları', 'Înregistrări de plată'),
  ('Normal giderler', 'Alte cheltuieli'),
  ('Toplam gider', 'Cheltuieli totale'),
  ('Kalan ödeme yükü', 'Obligații de plată rămase'),
  ('Gecikmiş ödeme yükü', 'Obligații de plată restante'),
  ('Yaklaşan ödeme yükü', 'Obligații de plată viitoare'),
  ('Kişi kapsamı', 'Persoane incluse'),
  ('Oluşturulma', 'Generat la'),
  ('Dönem', 'Perioadă'),
  ('devam', 'continuare'),
];

class _RomanianPattern {
  const _RomanianPattern(this.regExp, this.builder);

  final RegExp regExp;
  final String Function(RegExpMatch match, RomanianDynamicTranslator translate)
  builder;
}
