#!/usr/bin/env python3
"""Shorten one reviewed Italian notification label for narrow layouts."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "lib/l10n/it/mizan_it_core.dart"
OLD = """  'Bildirim planı bilgisi':
      'Informazioni sulla pianificazione delle notifiche',
"""
NEW = """  'Bildirim planı bilgisi': 'Dettagli piano notifiche',
"""

text = CORE.read_text(encoding="utf-8")
if NEW in text and OLD not in text:
    print("Italian compact notification label is already current.")
else:
    if text.count(OLD) != 1:
        raise SystemExit(
            f"Expected one Italian compact-copy target, found {text.count(OLD)}"
        )
    CORE.write_text(text.replace(OLD, NEW, 1), encoding="utf-8")
    print("Italian compact notification label corrected.")
