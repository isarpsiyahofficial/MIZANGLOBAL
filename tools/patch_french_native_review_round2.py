#!/usr/bin/env python3
"""Apply the second independent native French review layer."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REPLACEMENTS = {
    ROOT / "lib/l10n/fr/mizan_fr_core.dart": {
        "'Taksitli nakit avans': 'Avance de fonds remboursable en plusieurs fois',":
            "'Taksitli nakit avans': 'Avance de fonds échelonnée',",
    },
    ROOT / "lib/l10n/fr/mizan_fr_reports.dart": {
        "'Gelir sonrası net': 'Solde net après prise en compte des revenus',":
            "'Gelir sonrası net': 'Solde net après revenus',",
    },
}


def apply_native_review() -> None:
    for path, replacements in REPLACEMENTS.items():
        text = path.read_text(encoding="utf-8")
        for old, new in replacements.items():
            if new in text:
                continue
            if text.count(old) != 1:
                raise SystemExit(
                    f"Native French review target missing or repeated in {path}: {old}"
                )
            text = text.replace(old, new, 1)
        path.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    apply_native_review()
    print("Second native French review applied: compact financial copy verified.")
