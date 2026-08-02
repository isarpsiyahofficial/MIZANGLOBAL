#!/usr/bin/env python3
"""Independent native-language audit for the reviewed French product copy."""
from __future__ import annotations

import re

from build_french_locale import french_pairs
from patch_french_native_review_round2 import apply_native_review

apply_native_review()
pairs = french_pairs()
values = dict(pairs)
failures: list[str] = []

required = {
    "Ana sayfa": "Accueil",
    "Kayıtlar": "Dossiers",
    "Giderler": "Dépenses",
    "Raporlar": "Rapports",
    "Ayarlar": "Paramètres",
    "Son ödeme tarihi": "Date d’échéance",
    "Ödeme planı": "Échéancier",
    "Kalan borç": "Solde de la dette",
    "Kalan tutar": "Montant restant",
    "Kalan ödeme yükü": "Paiements restant dus",
    "Gerçekleşen ödeme ayrıntıları": "Détails des paiements effectués",
    "Ev kredisi": "Crédit immobilier",
    "Araç kredisi": "Crédit automobile",
    "KMH hesabı": "Compte avec découvert autorisé",
    "Senet": "Billet à ordre",
    "Gelir": "Revenu",
    "Gider": "Dépense",
    "Abonelik": "Abonnement",
    "Kaydet": "Enregistrer",
    "Sil": "Supprimer",
    "ONAYLIYORUM": "JE CONFIRME",
}
for key, expected in required.items():
    if values.get(key) != expected:
        failures.append(f"native terminology mismatch: {key!r} -> {values.get(key)!r}")

foreign_patterns = {
    "Turkish": re.compile(
        r"\b(?:ayarlar|kaydet|gider|giderler|borç|ödeme|fatura|kira|"
        r"taksit|gelir|bildirim|hatırlatma|kalan tutar|son ödeme)\b",
        re.IGNORECASE,
    ),
    "English": re.compile(
        r"\b(?:settings|save|delete|expenses|debt|payment|invoice|income|"
        r"subscription|remaining amount|due date|backup)\b",
        re.IGNORECASE,
    ),
    "Spanish": re.compile(
        r"\b(?:ajustes|guardar|eliminar|gastos|deuda|pago|factura|ingresos|"
        r"suscripción|importe pendiente|fecha de vencimiento)\b",
        re.IGNORECASE,
    ),
    "Portuguese": re.compile(
        r"\b(?:definições|guardar|eliminar|despesas|dívida|pagamento|fatura|"
        r"rendimento|subscrição|valor restante|data de vencimento|ficheiro)\b",
        re.IGNORECASE,
    ),
}
for key, value in pairs:
    for language, pattern in foreign_patterns.items():
        if pattern.search(value):
            failures.append(f"{language} leakage in {key!r}: {value!r}")

# France product copy consistently addresses the user with formal « vous ».
informal = re.compile(r"\b(?:tu|toi|ton|ta|tes|tiens|clique)\b", re.IGNORECASE)
for key, value in pairs:
    if informal.search(value):
        failures.append(f"informal register in {key!r}: {value!r}")

# Typographic apostrophes are mandatory inside French words.
straight_apostrophe = re.compile(r"[A-Za-zÀ-ÖØ-öø-ÿ]'[A-Za-zÀ-ÖØ-öø-ÿ]")
for key, value in pairs:
    if straight_apostrophe.search(value):
        failures.append(f"straight apostrophe in {key!r}: {value!r}")
    if "  " in value:
        failures.append(f"double space in {key!r}: {value!r}")

# Short interface controls must remain compact enough for narrow cards and dialogs.
for key, value in pairs:
    is_control = len(key) <= 20 and not any(mark in key for mark in ".?!:…")
    if is_control and len(value) > 42:
        failures.append(
            f"French control copy is too long for narrow layouts: {key!r} -> {value!r}"
        )

# Reject known calques and non-native wording that can look machine-translated.
forbidden_phrases = (
    "faire un paiement",
    "registre de paiement",
    "copie de backup",
    "date finale de paiement",
    "revenu entrant",
    "dette de maison",
    "crédit de voiture",
    "sauver les données",
    "effacer la dette",
    "application langue",
)
for key, value in pairs:
    folded = value.casefold()
    for phrase in forbidden_phrases:
        if phrase in folded:
            failures.append(f"non-native French calque in {key!r}: {phrase!r}")

if failures:
    print("Native French audit failed:")
    for failure in failures:
        print(f"- {failure}")
    raise SystemExit(1)

print(
    "Native French audit passed: terminology, register, typography, leakage and "
    "compact-control copy checked."
)
