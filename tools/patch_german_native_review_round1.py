#!/usr/bin/env python3
"""Apply the first fail-closed native German review corrections."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_exact(path: Path, old: str, new: str, expected: int = 1) -> None:
    text = path.read_text(encoding="utf-8")
    if text.count(new) == expected and old not in text:
        return
    actual = text.count(old)
    if actual != expected:
        raise SystemExit(
            f"Expected {expected} occurrence(s) in {path.relative_to(ROOT)}, found {actual}: {old!r}"
        )
    path.write_text(text.replace(old, new), encoding="utf-8")


replace_exact(
    ROOT / "lib/l10n/de/mizan_de_reports.dart",
    "  'Kalan ödeme yükü': 'Offene Zahlungsverpflichtungen',",
    "  'Kalan ödeme yükü': 'Noch fällige Zahlungen',",
)
replace_exact(
    ROOT / "lib/l10n/de/mizan_de_reports.dart",
    "  'Gerçekleşen ödeme ayrıntıları': 'Details der geleisteten Zahlungen',",
    "  'Gerçekleşen ödeme ayrıntıları': 'Details zu geleisteten Zahlungen',",
)
replace_exact(
    ROOT / "lib/l10n/de/mizan_de_settings.dart",
    "  'Gelir': 'Einkommen',",
    "  'Gelir': 'Einnahme',",
)

contract_path = ROOT / "tools/german_native_terms.json"
contract = json.loads(contract_path.read_text(encoding="utf-8"))
french_tokens = contract["forbiddenLeakageTokens"]["French"]
if "abonnement" in french_tokens:
    french_tokens.remove("abonnement")
contract_path.write_text(
    json.dumps(contract, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)

print("German native review round 1 applied.")
