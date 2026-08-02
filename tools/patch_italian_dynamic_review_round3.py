#!/usr/bin/env python3
"""Apply reviewed Italian agreement and neutral-validation corrections idempotently."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DYNAMIC = ROOT / "lib/l10n/mizan_it_dynamic.dart"


def replace_block(old: str, new: str) -> None:
    text = DYNAMIC.read_text(encoding="utf-8")
    old_count = text.count(old)
    if old_count == 1:
        DYNAMIC.write_text(text.replace(old, new, 1), encoding="utf-8")
        return
    if old_count == 0 and new in text:
        return
    raise SystemExit(
        f"Expected one Italian dynamic review block, found {old_count}: {old[:100]!r}"
    )


replace_block(
    """  _ItalianPattern(
    RegExp(r'^(\\d+) açık kayıt · (.+)$'),
    (m, t) => '${_items(m[1]!)} aperte · ${m[2]}',
  ),
""",
    """  _ItalianPattern(
    RegExp(r'^(\\d+) açık kayıt · (.+)$'),
    (m, t) => m[1] == '1'
        ? '1 registrazione aperta · ${m[2]}'
        : '${_items(m[1]!)} aperte · ${m[2]}',
  ),
""",
)
replace_block(
    """  _ItalianPattern(
    RegExp(r'^(.+) boş bırakılamaz\\.$'),
    (m, t) => '${t(m[1]!)} non può essere vuoto.',
  ),
""",
    """  _ItalianPattern(
    RegExp(r'^(.+) boş bırakılamaz\\.$'),
    (m, t) => 'Il campo ${t(m[1]!)} non può essere vuoto.',
  ),
""",
)
replace_block(
    """  _ItalianPattern(
    RegExp(r'^(.+) en fazla (\\d+) karakter olabilir\\.$'),
    (m, t) => '${t(m[1]!)} può contenere al massimo ${m[2]} caratteri.',
  ),
""",
    """  _ItalianPattern(
    RegExp(r'^(.+) en fazla (\\d+) karakter olabilir\\.$'),
    (m, t) =>
        'Il campo ${t(m[1]!)} può contenere al massimo ${m[2]} caratteri.',
  ),
""",
)
replace_block(
    """  _ItalianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\\.$'),
    (m, t) => '${t(m[1]!)} deve essere maggiore di zero.',
  ),
""",
    """  _ItalianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalı\\.$'),
    (m, t) =>
        'Il valore di ${t(m[1]!)} deve essere maggiore di zero.',
  ),
""",
)
replace_block(
    """  _ItalianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\\.$'),
    (m, t) => '${t(m[1]!)} deve essere maggiore di zero.',
  ),
""",
    """  _ItalianPattern(
    RegExp(r'^(.+) sıfırdan büyük olmalıdır\\.$'),
    (m, t) =>
        'Il valore di ${t(m[1]!)} deve essere maggiore di zero.',
  ),
""",
)
replace_block(
    """  _ItalianPattern(
    RegExp(r'^(.+) negatif olamaz\\.$'),
    (m, t) => '${t(m[1]!)} non può essere negativo.',
  ),
""",
    """  _ItalianPattern(
    RegExp(r'^(.+) negatif olamaz\\.$'),
    (m, t) => 'Il valore di ${t(m[1]!)} non può essere negativo.',
  ),
""",
)
replace_block(
    """  _ItalianPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\\.$'),
    (m, t) => '${t(m[1]!)} deve essere un numero intero positivo.',
  ),
""",
    """  _ItalianPattern(
    RegExp(r'^(.+) pozitif tam sayı olmalı\\.$'),
    (m, t) =>
        'Il valore di ${t(m[1]!)} deve essere un numero intero positivo.',
  ),
""",
)
replace_block(
    """  _ItalianPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\\.$'),
    (m, t) => '${t(m[1]!)} deve essere zero o un numero intero positivo.',
  ),
""",
    """  _ItalianPattern(
    RegExp(r'^(.+) sıfır veya pozitif tam sayı olmalı\\.$'),
    (m, t) =>
        'Il valore di ${t(m[1]!)} deve essere zero o un numero intero positivo.',
  ),
""",
)
replace_block(
    """  _ItalianPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => '${_people(m[1]!)} selezionate',
  ),
""",
    """  _ItalianPattern(
    RegExp(r'^(.+) kişi seçili$'),
    (m, t) => m[1] == '1'
        ? '1 persona selezionata'
        : '${_people(m[1]!)} selezionate',
  ),
""",
)

print("Italian dynamic agreement review round 3 applied idempotently.")
