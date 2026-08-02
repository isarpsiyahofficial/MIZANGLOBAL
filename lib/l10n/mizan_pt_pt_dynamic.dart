typedef PortuguesePtDynamicTranslator = String Function(String source);

String translatePortuguesePtReviewedDynamic(
  String source,
  PortuguesePtDynamicTranslator translate,
) {
  for (final pattern in _portuguesePtPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _portuguesePtPhrases) {
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

String _days(String value) => _count(value, 'dia', 'dias');
String _records(String value) => _count(value, 'registo', 'registos');
String _payments(String value) => _count(value, 'pagamento', 'pagamentos');
String _expenses(String value) => _count(value, 'despesa', 'despesas');
String _months(String value) => _count(value, 'mês', 'meses');
String _people(String value) => _count(value, 'pessoa', 'pessoas');
String _remaining(String value) => _count(value, 'restante', 'restantes');
String _dailyExpenses(String value) =>
    value == '1' ? '$value despesa diária' : '$value despesas diárias';
String _remainingVerb(String value) => value == '1' ? 'Falta' : 'Faltam';
String _missingVerb(String value) => value == '1' ? 'falta' : 'faltam';
String _newRecords(String value) =>
    value == '1' ? '1 registo novo' : '$value registos novos';
String _addedRecords(String value) => value == '1'
    ? '1 registo novo foi adicionado'
    : '$value registos novos foram adicionados';
String _updatedRelationships(String value) =>
    value == '1' ? '1 ligação atualizada' : '$value ligações atualizadas';

final List<_PortuguesePtPattern> _portuguesePtPatterns = <_PortuguesePtPattern>[
  _PortuguesePtPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Relatório ${_lowerFirst(t(m[1]!))} do MİZAN',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => 'Relatório financeiro de ${m[1]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MIZAN · Página ${m[1]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · continuação',
  ),
  _PortuguesePtPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Período: ${m[1]}'),
  _PortuguesePtPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Âmbito de pessoas: ${t(m[1]!)}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Gerado em: ${m[1]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Programado em aberto ${m[1]} · Pago neste mês ${m[2]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Situação dos pagamentos de ${m[1]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_records(m[1]!)} em aberto · ${m[2]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_records(m[2]!)} · ${m[3]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => '${_records(m[1]!)} de despesas',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostrar mais dias (${_remaining(m[1]!)})',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostrar mais dias de pagamento (${_remaining(m[1]!)})',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostrar mais dias de despesas (${_remaining(m[1]!)})',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostrar mais a partir deste dia (${_remaining(m[1]!)})',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => '${_remainingVerb(m[2]!)} ${_days(m[2]!)} para ${m[1]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} está previsto para hoje',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} está ${_days(m[2]!)} em atraso',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Último recebimento: ${m[1]} · Previsto ${m[2]}',
  ),
  _PortuguesePtPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'O período previsto para ${m[1]} foi registado como recebido em ${m[2]}. O dia fixo de recebimento não foi alterado.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Valor real da fatura de ${m[1]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Valor restante: ${m[1]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => 'Prestações restantes: ${m[1]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Eliminar o registo de despesa ${m[1]}?',
  ),
  _PortuguesePtPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'A categoria ${m[1]} e apenas as despesas associadas a ela serão eliminadas.',
  ),
  _PortuguesePtPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} e todos os registos associados a esta pessoa serão eliminados. Esta ação exige confirmação explícita.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Não foi possível guardar o relatório PDF: ${m[1]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Não foi possível partilhar o relatório PDF: ${m[1]}',
  ),
  _PortuguesePtPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) =>
        'Não foi possível gravar ${_records(m[1]!)} da programação de notificações no Android. Primeiro erro: ${m[2]}',
  ),
  _PortuguesePtPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) =>
        'Não foi possível verificar a programação de notificações; ${_missingVerb(m[1]!)} ${_records(m[1]!)} no Android.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Lembrete de pagamento ${m[1]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newRecords(m[1]!)}; ${_updatedRelationships(m[2]!)}${m[3]}.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) =>
        'O identificador do registo ${m[1]} é inválido ou está duplicado.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => '${_remainingVerb(m[1]!)} ${_days(m[1]!)}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => '${_days(m[1]!)} em atraso',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'O pagamento está ${_days(m[1]!)} em atraso.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Data de vencimento: ${m[1]}.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'Dia ${m[1]} do mês',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'Dia ${m[1]} de cada mês',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'A cada ${_lowerFirst(t(m[1]!))}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Başlangıç: (.+)$'),
    (m, t) => 'Início: ${m[1]}',
  ),
  _PortuguesePtPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Início ${m[1]}'),
  _PortuguesePtPattern(
    RegExp(r'^Toplam (.+)$'),
    (m, t) => 'Total ${_lowerFirst(t(m[1]!))}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Kalan (.+)$'),
    (m, t) => '${t(m[1]!)} restante',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} neste período',
  ),
  _PortuguesePtPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Data: ${m[1]}'),
  _PortuguesePtPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Nota: ${m[1]}'),
  _PortuguesePtPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} é obrigatório.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => '${t(m[1]!)} pode ter no máximo ${m[2]} caracteres.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} deve ser maior que zero.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} deve ser maior que zero.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} não pode ser negativo.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} deve ser um número inteiro positivo.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} deve ser zero ou um número inteiro positivo.',
  ),
  _PortuguesePtPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _records(m[1]!)),
  _PortuguesePtPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _PortuguesePtPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _PortuguesePtPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => '${_records(m[1]!)} de despesas',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_records(m[2]!)}',
  ),
  _PortuguesePtPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _PortuguesePtPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _PortuguesePtPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => m[1] == '1'
        ? '${_people(m[1]!)} selecionada'
        : '${_people(m[1]!)} selecionadas',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_addedRecords(m[1]!)}; os dados existentes foram preservados.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'O teste foi programado exatamente para ${m[1]}.',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'Não foi possível guardar ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'Não foi possível criar ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'Não foi possível partilhar ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _PortuguesePtPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'Não foi possível combinar ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
];

const List<(String, String)> _portuguesePtPhrases = <(String, String)>[
  ('Kişisel ve kurumsal borçlar', 'Dívidas pessoais e empresariais'),
  ('Kişisel / kurumsal borç', 'Dívida pessoal / empresarial'),
  ('Kişisel/kurumsal borç', 'Dívida pessoal/empresarial'),
  ('Ödemelere yapılan gider', 'Valores destinados a pagamentos'),
  ('Bu ay yapılan', 'Pago neste mês'),
  ('Açık plan', 'Programado em aberto'),
  ('Kalan tutar', 'Valor restante'),
  ('Kalan toplam borç', 'Dívida total restante'),
  ('Gecikmiş toplam', 'Total em atraso'),
  ('Önümüzdeki 7 gün', 'Próximos 7 dias'),
  ('Son ödeme bugün', 'Vence hoje'),
  ('Banka borçları', 'Dívidas bancárias'),
  ('Kira ve taksitler', 'Rendas e prestações'),
  ('Günlük harcamalar', 'Despesas diárias'),
  ('Gider ayrıntıları', 'Detalhes das despesas'),
  ('Ödeme ayrıntıları', 'Detalhes dos pagamentos'),
  ('Gerçekleşen ödeme', 'Pagamento realizado'),
  ('Ödeme kayıtları', 'Registos de pagamento'),
  ('Normal giderler', 'Despesas comuns'),
  ('Toplam gider', 'Total de gastos'),
  ('Kalan ödeme yükü', 'Obrigações de pagamento restantes'),
  ('Gecikmiş ödeme yükü', 'Obrigações de pagamento em atraso'),
  ('Yaklaşan ödeme yükü', 'Próximas obrigações de pagamento'),
  ('Kişi kapsamı', 'Âmbito de pessoas'),
  ('Oluşturulma', 'Gerado em'),
  ('Dönem', 'Período'),
  ('devam', 'continuação'),
];

class _PortuguesePtPattern {
  const _PortuguesePtPattern(this.regExp, this.builder);

  final RegExp regExp;
  final String Function(
    RegExpMatch match,
    PortuguesePtDynamicTranslator translate,
  )
  builder;
}
