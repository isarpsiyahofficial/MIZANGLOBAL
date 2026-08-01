typedef PortugueseBrDynamicTranslator = String Function(String source);

String translatePortugueseBrReviewedDynamic(
  String source,
  PortugueseBrDynamicTranslator translate,
) {
  for (final pattern in _portugueseBrPatterns) {
    final match = pattern.regExp.firstMatch(source);
    if (match != null) return pattern.builder(match, translate);
  }
  var value = source;
  for (final entry in _portugueseBrPhrases) {
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
String _records(String value) => _count(value, 'registro', 'registros');
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
    value == '1' ? '1 registro novo' : '$value registros novos';
String _addedRecords(String value) => value == '1'
    ? '1 registro novo foi adicionado'
    : '$value registros novos foram adicionados';
String _updatedRelationships(String value) =>
    value == '1' ? '1 vínculo atualizado' : '$value vínculos atualizados';

final List<_PortugueseBrPattern> _portugueseBrPatterns = <_PortugueseBrPattern>[
  _PortugueseBrPattern(
    RegExp(r'^MİZAN (.+) Raporu$'),
    (m, t) => 'Relatório ${_lowerFirst(t(m[1]!))} do MİZAN',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) finans raporu$'),
    (m, t) => 'Relatório financeiro de ${m[1]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^LEFFERION PRIME - MİZAN · Sayfa (\d+)$'),
    (m, t) => 'LEFFERION PRIME - MIZAN · Página ${m[1]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) · devam$'),
    (m, t) => '${t(m[1]!)} · continuação',
  ),
  _PortugueseBrPattern(RegExp(r'^Dönem: (.+)$'), (m, t) => 'Período: ${m[1]}'),
  _PortugueseBrPattern(
    RegExp(r'^Kişi kapsamı: (.+)$'),
    (m, t) => 'Escopo de pessoas: ${t(m[1]!)}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Oluşturulma: (.+)$'),
    (m, t) => 'Gerado em: ${m[1]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Açık plan (.+) · Bu ay yapılan (.+)$'),
    (m, t) => 'Programado em aberto ${m[1]} · Pago neste mês ${m[2]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) Ödeme Durumu$'),
    (m, t) => 'Situação dos pagamentos de ${m[1]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(\d+) açık kayıt · (.+)$'),
    (m, t) => '${_records(m[1]!)} em aberto · ${m[2]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(\d+) günlük harcama · (\d+) ödeme$'),
    (m, t) => '${_dailyExpenses(m[1]!)} · ${_payments(m[2]!)}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(\d+) gün · (\d+) kayıt · (.+)$'),
    (m, t) => '${_days(m[1]!)} · ${_records(m[2]!)} · ${m[3]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(\d+) ödeme · (.+)$'),
    (m, t) => '${_payments(m[1]!)} · ${m[2]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(\d+) gider · (.+)$'),
    (m, t) => '${_expenses(m[1]!)} · ${m[2]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => '${_records(m[1]!)} de despesas',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Daha fazla gün göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostrar mais dias (${_remaining(m[1]!)})',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Daha fazla ödeme günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostrar mais dias de pagamento (${_remaining(m[1]!)})',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Daha fazla gider günü göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostrar mais dias de despesas (${_remaining(m[1]!)})',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Bu günden daha fazla göster \((\d+) kaldı\)$'),
    (m, t) => 'Mostrar mais a partir deste dia (${_remaining(m[1]!)})',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) için (\d+) gün kaldı$'),
    (m, t) => '${_remainingVerb(m[2]!)} ${_days(m[2]!)} para ${m[1]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) bugün bekleniyor$'),
    (m, t) => '${m[1]} é esperado hoje',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) (\d+) gün gecikti$'),
    (m, t) => '${m[1]} está ${_days(m[2]!)} em atraso',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Son alındı: (.+) · Planlanan (.+)$'),
    (m, t) => 'Último recebimento: ${m[1]} · Previsto ${m[2]}',
  ),
  _PortugueseBrPattern(
    RegExp(
      r'^Planlanan (.+) dönemi, (.+) tarihinde alındı olarak kaydedildi\. Sabit yatış günü değişmedi\.$',
    ),
    (m, t) =>
        'O período previsto para ${m[1]} foi registrado como recebido em ${m[2]}. O dia fixo de recebimento não foi alterado.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) gerçek fatura tutarı$'),
    (m, t) => 'Valor real da conta de ${m[1]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Kalan tutar: (.+)$'),
    (m, t) => 'Valor restante: ${m[1]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Kalan taksit: (\d+)$'),
    (m, t) => 'Parcelas restantes: ${m[1]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) gider kaydı silinsin mi\?$'),
    (m, t) => 'Excluir o registro de despesa ${m[1]}?',
  ),
  _PortugueseBrPattern(
    RegExp(
      r'^(.+) kategorisi ve yalnız bu kategoriye bağlı giderler silinecek\.$',
    ),
    (m, t) =>
        'A categoria ${m[1]} e somente as despesas vinculadas a ela serão excluídas.',
  ),
  _PortugueseBrPattern(
    RegExp(
      r'^(.+) ve bu kişiye bağlı bütün kayıtlar silinecek\. Bu işlem yalnız açık onayla yapılır\.$',
    ),
    (m, t) =>
        '${m[1]} e todos os registros vinculados a esta pessoa serão excluídos. Esta ação exige confirmação explícita.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^PDF raporu kaydedilemedi: (.+)$'),
    (m, t) => 'Não foi possível salvar o relatório PDF: ${m[1]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^PDF raporu paylaşılamadı: (.+)$'),
    (m, t) => 'Não foi possível compartilhar o relatório PDF: ${m[1]}',
  ),
  _PortugueseBrPattern(
    RegExp(
      r'^Bildirim planındaki (\d+) kayıt Android sistemine yazılamadı\. İlk hata: (.+)$',
    ),
    (m, t) =>
        'Não foi possível gravar ${_records(m[1]!)} da programação de notificações no Android. Primeiro erro: ${m[2]}',
  ),
  _PortugueseBrPattern(
    RegExp(
      r'^Bildirim planı doğrulanamadı; Android tarafında (\d+) kayıt eksik kaldı\.$',
    ),
    (m, t) =>
        'Não foi possível verificar a programação de notificações; ${_missingVerb(m[1]!)} ${_records(m[1]!)} no Android.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Ödeme hatırlatması (\d+)$'),
    (m, t) => 'Lembrete de pagamento ${m[1]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) yeni, (.+) ilişki güncellendi(.*)\.$'),
    (m, t) => '${_newRecords(m[1]!)}; ${_updatedRelationships(m[2]!)}${m[3]}.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) kayıt kimliği geçersiz veya tekrarlı\.$'),
    (m, t) =>
        'O identificador do registro ${m[1]} é inválido ou está duplicado.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(\d+) gün kaldı$'),
    (m, t) => '${_remainingVerb(m[1]!)} ${_days(m[1]!)}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(\d+) gün gecikmede$'),
    (m, t) => '${_days(m[1]!)} em atraso',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Ödeme (\d+) gün gecikti\.$'),
    (m, t) => 'O pagamento está ${_days(m[1]!)} em atraso.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Son ödeme (.+)\.$'),
    (m, t) => 'Data de vencimento: ${m[1]}.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Ayın (\d+)\. günü$'),
    (m, t) => 'Dia ${m[1]} do mês',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Her ayın (\d+)\. günü$'),
    (m, t) => 'Dia ${m[1]} de cada mês',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Her (.+)$'),
    (m, t) => 'A cada ${_lowerFirst(t(m[1]!))}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Başlangıç: (.+)$'),
    (m, t) => 'Início: ${m[1]}',
  ),
  _PortugueseBrPattern(RegExp(r'^Başlangıç (.+)$'), (m, t) => 'Início ${m[1]}'),
  _PortugueseBrPattern(
    RegExp(r'^Toplam (.+)$'),
    (m, t) => 'Total ${_lowerFirst(t(m[1]!))}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Kalan (.+)$'),
    (m, t) => '${t(m[1]!)} restante',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Bu dönem (.+)$'),
    (m, t) => '${t(m[1]!)} neste período',
  ),
  _PortugueseBrPattern(RegExp(r'^Tarih: (.+)$'), (m, t) => 'Data: ${m[1]}'),
  _PortugueseBrPattern(RegExp(r'^Not: (.*)$'), (m, t) => 'Nota: ${m[1]}'),
  _PortugueseBrPattern(
    RegExp(r'^(.+) boş bırakılamaz\.$'),
    (m, t) => '${t(m[1]!)} é obrigatório.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) en fazla (\d+) karakter olabilir\.$'),
    (m, t) => '${t(m[1]!)} pode ter no máximo ${m[2]} caracteres.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\.$'),
    (m, t) => '${t(m[1]!)} deve ser maior que zero.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\.$'),
    (m, t) => '${t(m[1]!)} deve ser maior que zero.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) negatif olamaz\.$'),
    (m, t) => '${t(m[1]!)} não pode ser negativo.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} deve ser um número inteiro positivo.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\.$'),
    (m, t) => '${t(m[1]!)} deve ser zero ou um número inteiro positivo.',
  ),
  _PortugueseBrPattern(RegExp(r'^(\d+) kayıt$'), (m, t) => _records(m[1]!)),
  _PortugueseBrPattern(RegExp(r'^(\d+) ödeme$'), (m, t) => _payments(m[1]!)),
  _PortugueseBrPattern(RegExp(r'^(\d+) gider$'), (m, t) => _expenses(m[1]!)),
  _PortugueseBrPattern(
    RegExp(r'^(\d+) gider kaydı$'),
    (m, t) => '${_records(m[1]!)} de despesas',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) · (\d+) kayıt$'),
    (m, t) => '${m[1]} · ${_records(m[2]!)}',
  ),
  _PortugueseBrPattern(RegExp(r'^(.+) gün$'), (m, t) => _days(m[1]!)),
  _PortugueseBrPattern(RegExp(r'^(.+) ay$'), (m, t) => _months(m[1]!)),
  _PortugueseBrPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => m[1] == '1'
        ? '${_people(m[1]!)} selecionada'
        : '${_people(m[1]!)} selecionadas',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) yeni kayıt eklendi; mevcut veriler korundu\.$'),
    (m, t) => '${_addedRecords(m[1]!)}; os dados existentes foram preservados.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^Test (.+) için dakik olarak planlandı\.$'),
    (m, t) => 'O teste foi programado exatamente para ${m[1]}.',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) kaydedilemedi: (.+)$'),
    (m, t) => 'Não foi possível salvar ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) oluşturulamadı: (.+)$'),
    (m, t) => 'Não foi possível criar ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) paylaşılamadı: (.+)$'),
    (m, t) => 'Não foi possível compartilhar ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
  _PortugueseBrPattern(
    RegExp(r'^(.+) birleştirilemedi: (.+)$'),
    (m, t) => 'Não foi possível mesclar ${_lowerFirst(t(m[1]!))}: ${m[2]}',
  ),
];

const List<(String, String)> _portugueseBrPhrases = <(String, String)>[
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
  ('Kira ve taksitler', 'Aluguéis e parcelas'),
  ('Günlük harcamalar', 'Despesas diárias'),
  ('Gider ayrıntıları', 'Detalhes das despesas'),
  ('Ödeme ayrıntıları', 'Detalhes dos pagamentos'),
  ('Gerçekleşen ödeme', 'Pagamento realizado'),
  ('Ödeme kayıtları', 'Registros de pagamento'),
  ('Normal giderler', 'Despesas comuns'),
  ('Toplam gider', 'Total de gastos'),
  ('Kalan ödeme yükü', 'Obrigações de pagamento restantes'),
  ('Gecikmiş ödeme yükü', 'Obrigações de pagamento em atraso'),
  ('Yaklaşan ödeme yükü', 'Próximas obrigações de pagamento'),
  ('Kişi kapsamı', 'Escopo de pessoas'),
  ('Oluşturulma', 'Gerado em'),
  ('Dönem', 'Período'),
  ('devam', 'continuação'),
];

class _PortugueseBrPattern {
  const _PortugueseBrPattern(this.regExp, this.builder);

  final RegExp regExp;
  final String Function(
    RegExpMatch match,
    PortugueseBrDynamicTranslator translate,
  )
  builder;
}
