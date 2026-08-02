#!/usr/bin/env python3
"""Verify that the first native-safe pt-PT builder layer is locked in source.

The original one-time migration replaced unsafe substring conversion with
word-boundary terminology rules, grammatical repairs and fail-closed language
checks. Those rules now live directly in build_pt_pt_locale.py. This command is
therefore intentionally idempotent: it verifies the committed builder instead
of rewriting it on every CI run.
"""
from pathlib import Path

builder = Path(__file__).with_name("build_pt_pt_locale.py")
source = builder.read_text(encoding="utf-8")

required_markers = (
    "WORD_REPLACEMENTS: tuple[tuple[str, str], ...] = (",
    "PHRASE_REPAIRS: tuple[tuple[str, str], ...] = (",
    "def _replace_complete_word(",
    "def european_value(key: str, value: str) -> str:",
    "strict_forbidden = re.compile(",
    "Non-native or malformed pt-PT copy",
    "Non-native or malformed pt-PT dynamic copy",
    '"Ayarlar": "Definições"',
    '"Kayıtlar": "Registos"',
    '"Kaydet": "Guardar"',
    '"Sil": "Eliminar"',
    '"Ev kredisi": "Crédito à habitação"',
    '"Araç kredisi": "Crédito automóvel"',
)
missing = [marker for marker in required_markers if marker not in source]
if missing:
    raise SystemExit(
        "The committed native-safe pt-PT builder is incomplete: "
        + ", ".join(repr(marker) for marker in missing)
    )

for forbidden in (
    'result = result.replace(source, target)',
    'source = source.replace(old, new)\n    PT_PT_DYNAMIC',
):
    if forbidden in source:
        raise SystemExit(
            f"Unsafe broad pt-PT conversion returned to the builder: {forbidden!r}"
        )

print("First native-safe pt-PT builder layer is locked and verified.")
