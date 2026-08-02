#!/usr/bin/env python3
"""Apply the final sentence-level European Portuguese review layer.

This pass covers agreement in backup messages, European wording in payment and
report copy, and contract/rent terminology. It updates the deterministic builder
rather than patching generated output, then installs fail-closed gates so the
same issues cannot reappear.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

# Direct final-head verification trigger; product text is unchanged.
path = Path(__file__).with_name("build_pt_pt_locale.py")
source = path.read_text(encoding="utf-8")
changed = False

reviewed_overrides = {
    "Gelir kaydı opsiyoneldir. Borç ödemeleri ve giderler gelirden ayrı tutulur; net sonuç raporda hesaplanır.": "O registo de rendimento é opcional. Os pagamentos de dívidas e as despesas mantêm-se separados dos rendimentos; o resultado líquido é calculado no relatório.",
    "Bu kayda henüz ödeme eklenmedi.": "Ainda não foi registado nenhum pagamento neste registo.",
    "Son ödeme tarihi takvimden sabitlenmez. Girilen ödeme günü ve ilk ödeme ayı esas alınır; sonraki aylar gerçek takvime göre otomatik hesaplanır.": "A data de vencimento não fica fixada numa única data do calendário. O dia de pagamento e o primeiro mês introduzidos servem de referência; os meses seguintes são calculados automaticamente de acordo com o calendário real.",
    "Açıksa taksit sayısı ve düzenli ödeme tutarı saklanır.": "Quando ativado, são guardados o número de prestações e o valor do pagamento recorrente.",
    "Kalan borcu aşmayacak ödeme tutarını kendin girebilirsin.": "Pode introduzir um valor de pagamento que não ultrapasse o saldo restante.",
    "Otomatik tutar ödeme türüne göre hesaplandı. Kısmi ödeme seçilirse elle değiştirilebilir.": "O valor foi calculado automaticamente de acordo com o tipo de pagamento. Pode ser alterado manualmente ao selecionar Pagamento parcial.",
    "Ödemeleri, giderleri ve kalan yükü aynı filtreyle doğru ve ayrıntılı gösterir.": "Apresenta pagamentos, despesas e obrigações restantes com precisão e detalhe, utilizando o mesmo filtro.",
    "Serbest girilen gelir türleri ve seçili döneme düşen tutarları gösterilir.": "São apresentados os tipos de rendimento introduzidos pelo utilizador e os valores correspondentes ao período selecionado.",
    "Elektrik, su, doğalgaz ve benzeri faturaların tutarı her ay ayrı kaydedilir. Geçmiş ayların tutarı değiştirilmeden raporlarda gerçek ödeme kayıtları kullanılır.": "Os valores de eletricidade, água, gás natural e faturas semelhantes são registados separadamente em cada mês. Os relatórios utilizam os pagamentos reais sem alterar os valores dos meses anteriores.",
    "Sözleşme bitişi": "Fim do contrato",
    "Sözleşme bitişi (opsiyonel)": "Fim do contrato (opcional)",
    "Sözleşme bitişi başlangıçtan önce olamaz.": "A data de fim do contrato não pode ser anterior à data de início.",
    "Kira artış tarihi (opsiyonel)": "Data de atualização da renda (opcional)",
    "CSV yedeği oluşturuldu.": "A cópia de segurança CSV foi criada.",
    "CSV yedeği doğrulandı ve geri yüklendi.": "A cópia de segurança CSV foi validada e restaurada.",
    "CSV yedeği mevcut kayıtlarla birleştirildi: ": "A cópia de segurança CSV foi combinada com os registos existentes: ",
    "CSV yedeği boş veya eksik.": "A cópia de segurança CSV está vazia ou incompleta.",
    "CSV tam yedek verisi geçersiz.": "Os dados da cópia de segurança CSV completa são inválidos.",
    "CSV içinde tam MİZAN yedeği bulunamadı.": "Não foi encontrada nenhuma cópia de segurança completa do MİZAN no ficheiro CSV.",
}

override_end = source.index("\n}\n\nWORD_REPLACEMENTS:")
for key, value in reviewed_overrides.items():
    encoded_key = json.dumps(key, ensure_ascii=False)
    replacement_line = f"    {encoded_key}: {json.dumps(value, ensure_ascii=False)},"
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

# Fail closed on every sentence pattern found during the third independent read.
gate_marker = "    # Native review round 3 gate.\n"
if gate_marker not in source:
    anchor = '    i18n = I18N.read_text(encoding="utf-8")\n'
    if source.count(anchor) != 1:
        raise SystemExit("Could not locate pt-PT round-3 verification insertion point")
    gate = r'''    # Native review round 3 gate.
    round3_forbidden = re.compile(
        r"^pode informar|\bEle poderá\b|\bExibe\b|\bexibe\b|"
        r"\bem uma única\b|\binformados são usados\b|\barmazenad[oa]s?\b|"
        r"\breajuste da renda\b|\bTérmino do contrato\b|"
        r"cópia de segurança CSV foi (?:criado|verificado|restaurado|combinado)|"
        r"cópia de segurança CSV está (?:vazio|incompleto)|"
        r"cópia de segurança CSV completo|"
        r"Nenhuma cópia de segurança completo|"
        r"cópia de segurança completa do MİZAN foi encontrado",
        re.IGNORECASE,
    )
    round3_leaks = [
        (key, value) for key, value in pairs if round3_forbidden.search(value)
    ]
    if round3_leaks:
        raise SystemExit(f"Third native pt-PT review failed: {round3_leaks[:20]}")
    dynamic_round3 = PT_PT_DYNAMIC.read_text(encoding="utf-8")
    dynamic_match = round3_forbidden.search(dynamic_round3)
    if dynamic_match:
        raise SystemExit(
            f"Third native pt-PT dynamic review failed: {dynamic_match.group(0)!r}"
        )
'''
    source = source.replace(anchor, gate + anchor, 1)
    changed = True

if changed:
    path.write_text(source, encoding="utf-8")
    print("Applied final sentence-level pt-PT review and fail-closed gates.")
else:
    print("Final sentence-level pt-PT review is already current.")
