#!/usr/bin/env python3
"""Apply reviewed Italian agreement and gender-neutral validation corrections."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DYNAMIC = ROOT / "lib/l10n/mizan_it_dynamic.dart"


def replace_once(old: str, new: str, marker: str) -> None:
    text = DYNAMIC.read_text(encoding="utf-8")
    if marker in text:
        return
    if text.count(old) != 1:
        raise SystemExit(f"Expected one Italian dynamic review target, found {text.count(old)}")
    DYNAMIC.write_text(text.replace(old, new, 1), encoding="utf-8")


replace_once(
    """    (m, t) => '${_items(m[1]!)} aperte · ${m[2]}',""",
    """    (m, t) => m[1] == '1'
        ? '1 registrazione aperta · ${m[2]}'
        : '${_items(m[1]!)} aperte · ${m[2]}',""",
    "1 registrazione aperta",
)
replace_once(
    """    (m, t) => '${t(m[1]!)} non può essere vuoto.',""",
    """    (m, t) => 'Il campo ${t(m[1]!)} non può essere vuoto.',""",
    "Il campo ${t(m[1]!)} non può essere vuoto",
)
replace_once(
    """    (m, t) => '${t(m[1]!)} può contenere al massimo ${m[2]} caratteri.',""",
    """    (m, t) =>
        'Il campo ${t(m[1]!)} può contenere al massimo ${m[2]} caratteri.',""",
    "Il campo ${t(m[1]!)} può contenere",
)
replace_once(
    """    (m, t) => '${t(m[1]!)} deve essere maggiore di zero.',""",
    """    (m, t) => 'Il valore di ${t(m[1]!)} deve essere maggiore di zero.',""",
    "Il valore di ${t(m[1]!)} deve essere maggiore di zero",
)
# The same source sentence exists twice with two Turkish variants.
text = DYNAMIC.read_text(encoding="utf-8")
old_second = """    (m, t) => '${t(m[1]!)} deve essere maggiore di zero.',"""
new_second = """    (m, t) => 'Il valore di ${t(m[1]!)} deve essere maggiore di zero.',"""
if text.count(new_second) < 2:
    if text.count(old_second) != 1:
        raise SystemExit(
            f"Expected one remaining positive-value target, found {text.count(old_second)}"
        )
    DYNAMIC.write_text(text.replace(old_second, new_second, 1), encoding="utf-8")
replace_once(
    """    (m, t) => '${t(m[1]!)} non può essere negativo.',""",
    """    (m, t) => 'Il valore di ${t(m[1]!)} non può essere negativo.',""",
    "Il valore di ${t(m[1]!)} non può essere negativo",
)
replace_once(
    """    (m, t) => '${t(m[1]!)} deve essere un numero intero positivo.',""",
    """    (m, t) =>
        'Il valore di ${t(m[1]!)} deve essere un numero intero positivo.',""",
    "Il valore di ${t(m[1]!)} deve essere un numero intero positivo",
)
replace_once(
    """    (m, t) => '${t(m[1]!)} deve essere zero o un numero intero positivo.',""",
    """    (m, t) =>
        'Il valore di ${t(m[1]!)} deve essere zero o un numero intero positivo.',""",
    "Il valore di ${t(m[1]!)} deve essere zero o un numero intero positivo",
)
replace_once(
    """    (m, t) => '${_people(m[1]!)} selezionate',""",
    """    (m, t) => m[1] == '1'
        ? '1 persona selezionata'
        : '${_people(m[1]!)} selezionate',""",
    "1 persona selezionata",
)

print("Italian dynamic agreement review round 3 applied.")
