#!/usr/bin/env python3
"""Apply a second native-level review layer to the pt-PT builder.

The first hardening pass removes unsafe substring morphology. This pass records
sentence-level European Portuguese decisions found by independent source review
and adds gates for agreement, archive/file ambiguity and Brazilian constructions.
It runs after patch_pt_pt_builder.py and before build_pt_pt_locale.py.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

path = Path(__file__).with_name("build_pt_pt_locale.py")
source = path.read_text(encoding="utf-8")
changed = False

reviewed_overrides = {
    "Gelir bilgisi belirtilmemiş": "Nenhum rendimento indicado",
    "Tek seferlik, günlük, haftalık veya aylık gelir ekleyebilirsin.": "Pode adicionar rendimentos pontuais, diários, semanais ou mensais.",
    "Arşivden çıkar": "Retirar do arquivo",
    "Gelir türü / adı": "Tipo / Nome do rendimento",
    "Maaş, ek iş, kira geliri…": "Salário, trabalho extra, rendimento de rendas…",
    "Gelir tutarı sıfırdan büyük olmalıdır.": "O valor do rendimento deve ser superior a zero.",
    "Gelir sıklığı": "Frequência do rendimento",
    "Gelir başlangıç tarihini seçin": "Selecionar a data de início do rendimento",
    "Gelir notu (opsiyonel)": "Nota do rendimento (opcional)",
    "Gelirin gerçekten alındığı tarihi seçin": "Selecionar a data em que o rendimento foi efetivamente recebido",
    "Haftalık gelir için geçerli bir gün seçilmelidir.": "Selecione um dia da semana válido para o rendimento semanal.",
    "Aylık gelir günü 1 ile 31 arasında olmalıdır.": "O dia do rendimento mensal deve estar entre 1 e 31.",
    "Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.": "O acompanhamento do dia de recebimento só pode ser utilizado em rendimentos semanais e mensais.",
    "Bu gelir için yatış günü takibi açık değil.": "O acompanhamento do dia de recebimento não está ativado para este rendimento.",
    "Kişisel / kurumsal borç ekle": "Adicionar dívida pessoal / empresarial",
    "Kişisel / kurumsal borcu düzenle": "Editar dívida pessoal / empresarial",
    "Bu banka grubunda görüntülenecek borç bulunmuyor.": "Não há dívidas para apresentar neste grupo bancário.",
    "Varsayılan aylık tutar": "Valor mensal predefinido",
    "Cihazın varsayılan bildirim sesi": "Som de notificação predefinido do dispositivo",
    "PDF hazırlanıyor.": "A preparar o PDF.",
    "PDF hazırlanıyor": "A preparar o PDF",
    "Normal giderler ve ödemeler ayrı başlıklar altında kalır; yalnız toplam hesaplamada birleşir.": "As despesas comuns e os pagamentos mantêm-se em secções separadas; apenas são combinados no cálculo do total.",
    "İlk kayıttan bugüne kadar bütün ödeme, gider ve gelir hareketleri kapsanır.": "Abrange todos os movimentos de pagamentos, despesas e rendimentos desde o primeiro registo até hoje.",
    "Gider kayıtlarında kişi alanı bulunmadığı için giderler seçili dönem kapsamında ve kişi filtresinden bağımsız hesaplanır.": "Como os registos de despesas não têm um campo de pessoa, as despesas são calculadas no período selecionado, independentemente do filtro de pessoas.",
    "Bu kişide aynı banka adı zaten var.": "Esta pessoa já tem um banco com o mesmo nome.",
    "Gecikme hesabını yeniden kur": "Recalcular atraso",
    "Değer değiştirilirse referans tarihi bugün esas alınarak gecikme, bildirim ve rapor hesapları yeniden kurulur.": "Se o valor for alterado, os cálculos de atraso, notificações e relatórios serão refeitos tendo a data de hoje como referência.",
    "Bu işlem referans tarihini bugün esas alarak vade, gecikme, bildirim, rapor ve ödeme hesaplarını yeniden hesaplayacaktır.": "Esta ação recalculará vencimentos, atrasos, notificações, relatórios e pagamentos tendo a data de hoje como referência.",
    "29, 30 veya 31 seçildiğinde kısa aylarda ayın son geçerli günü kullanılır.": "Nos meses mais curtos, ao selecionar 29, 30 ou 31, é utilizado o último dia válido do mês.",
    "Girilen tutarın ait olduğu ay": "Mês a que pertence o valor introduzido",
    "Belirtilmemiş": "Não indicado",
    "Her ayın kaçıncı günü?": "Em que dia de cada mês?",
    "Haftanın hangi günü yatıyor?": "Em que dia da semana é recebido?",
    "Her ayın kaçında yatıyor?": "Em que dia do mês é recebido?",
    "Her ayın kaçında ödenecek? (1-31)": "Em que dia do mês será paga? (1–31)",
}

# Update or add OVERRIDES entries. The builder uses JSON-compatible quoted keys.
override_end = source.index("\n}\n\nWORD_REPLACEMENTS:")
for key, value in reviewed_overrides.items():
    encoded_key = json.dumps(key, ensure_ascii=False)
    replacement_line = (
        f"    {encoded_key}: {json.dumps(value, ensure_ascii=False)},"
    )
    pattern = rf"^    {re.escape(encoded_key)}: .*,$"
    updated, count = re.subn(
        pattern,
        replacement_line,
        source,
        count=1,
        flags=re.MULTILINE,
    )
    if count:
        if updated != source:
            source = updated
            changed = True
        continue
    insertion = replacement_line + "\n"
    source = source[:override_end] + insertion + source[override_end:]
    override_end += len(insertion)
    changed = True

# Shared static/dynamic phrase-level European Portuguese corrections.
phrase_repairs = {
    "associadas a ela": "que lhe estão associadas",
    "maior que zero": "superior a zero",
    "Em qual dia": "Em que dia",
    "Preparando o PDF.": "A preparar o PDF.",
    "Preparando PDF": "A preparar o PDF",
    "movimentações": "movimentos",
    "possuem": "têm",
    "exibir": "apresentar",
    "padrão": "predefinido",
}
phrase_end = source.index("\n)\n\n\ndef _replace_complete_word", source.index("PHRASE_REPAIRS:"))
for old, new in phrase_repairs.items():
    line = (
        f"    ({json.dumps(old, ensure_ascii=False)}, "
        f"{json.dumps(new, ensure_ascii=False)}),\n"
    )
    if line in source:
        continue
    source = source[:phrase_end] + "\n" + line.rstrip("\n") + source[phrase_end:]
    phrase_end += len(line)
    changed = True

# `arquivo` is the correct word for an archive in Portugal, while `ficheiro` is
# required for a computer/data file. Remove the old broad ban and replace it
# with an exact, context-aware allowance for the unarchive action.
old_forbidden = 'r"\\b(?:aplicativo|arquivo|salvar|excluir|usuário|tela|celular|"'
new_forbidden = 'r"\\b(?:aplicativo|salvar|excluir|usuário|tela|celular|"'
if old_forbidden in source:
    source = source.replace(old_forbidden, new_forbidden, 1)
    changed = True
old_strict = 'r"\\b(?:aplicativo|arquivo|salvar|salvamento|excluir|usuário|tela|celular|"'
new_strict = 'r"\\b(?:aplicativo|salvar|salvamento|excluir|usuário|tela|celular|"'
if old_strict in source:
    source = source.replace(old_strict, new_strict, 1)
    changed = True

archive_gate_marker = "    # Archive/file context gate.\n"
if archive_gate_marker not in source:
    anchor = "    strict_forbidden = re.compile(\n"
    if source.count(anchor) != 1:
        raise SystemExit("Could not locate pt-PT archive/file verification point")
    archive_gate = r'''    # Archive/file context gate.
    archive_usages = [
        (key, value)
        for key, value in pairs
        if re.search(r"\barquivos?\b", value, re.IGNORECASE)
        and not (key == "Arşivden çıkar" and value == "Retirar do arquivo")
    ]
    if archive_usages:
        raise SystemExit(
            f"pt-PT must use ficheiro for computer/data files: {archive_usages[:12]}"
        )
'''
    source = source.replace(anchor, archive_gate + anchor, 1)
    changed = True

# Add a second fail-closed review gate immediately before runtime marker checks.
gate_marker = "    # Native review round 2 gate.\n"
if gate_marker not in source:
    anchor = '    i18n = I18N.read_text(encoding="utf-8")\n'
    if source.count(anchor) != 1:
        raise SystemExit("Could not locate pt-PT round-2 verification insertion point")
    gate = r'''    # Native review round 2 gate.
    round2_forbidden = re.compile(
        r"rendimento informada|rendimentos únicas|\bda rendimento\b|"
        r"\buma rendimento\b|\ba rendimento\b|renda de renda|"
        r"Restaurar do ficheiro|\bexibir\b|\bPreparando\b|"
        r"\bmovimentações\b|\bpossuem\b|\bpadrão\b|\bEm qual\b|"
        r"associadas a ela|maior que zero",
        re.IGNORECASE,
    )
    round2_leaks = [
        (key, value) for key, value in pairs if round2_forbidden.search(value)
    ]
    uppercase_business = [
        (key, value) for key, value in pairs if "/ Empresarial" in value
    ]
    if round2_leaks or uppercase_business:
        raise SystemExit(
            f"Second native pt-PT review failed: "
            f"{(round2_leaks + uppercase_business)[:20]}"
        )
    dynamic_round2 = PT_PT_DYNAMIC.read_text(encoding="utf-8")
    dynamic_match = round2_forbidden.search(dynamic_round2)
    if dynamic_match or "/ Empresarial" in dynamic_round2:
        offending = dynamic_match.group(0) if dynamic_match else "/ Empresarial"
        raise SystemExit(
            f"Second native pt-PT dynamic review failed: {offending!r}"
        )
'''
    source = source.replace(anchor, gate + anchor, 1)
    changed = True

if changed:
    path.write_text(source, encoding="utf-8")
    print("Applied second native-level pt-PT review layer and fail-closed gates.")
else:
    print("Second native-level pt-PT review layer is already current.")
