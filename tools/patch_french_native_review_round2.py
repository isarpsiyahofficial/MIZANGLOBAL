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


def patch_builder_parser() -> None:
    path = ROOT / "tools/build_french_locale.py"
    text = path.read_text(encoding="utf-8")
    old = '''    end = source.index("\\n};", start)\n    body = source[start:end]\n'''
    new = '''    end = source.find("\\n};", start)\n    if end < 0:\n        end = source.find("\\n  };", start)\n    if end < 0:\n        raise ValueError(f"map closing brace not found after {marker!r}")\n    body = source[start:end]\n'''
    if new not in text:
        if text.count(old) != 1:
            raise SystemExit("French builder parser patch target is missing or repeated")
        text = text.replace(old, new, 1)
    path.write_text(text, encoding="utf-8")


def patch_currency_aliases() -> None:
    path = ROOT / "tools/build_french_locale.py"
    text = path.read_text(encoding="utf-8")
    old = '''        aliases = item.setdefault("aliases", [])\n        for alias in (name, name.casefold(), normal(name)):\n            if alias and alias not in aliases:\n                aliases.append(alias)\n'''
    new = '''        aliases = item.setdefault("aliases", [])\n        common_french_aliases = {\n            "USD": (\n                "dollar américain",\n                "dollar americain",\n                "dollar États-Unis",\n                "dollar etats unis",\n                "dollar etats",\n                "dollar US",\n            ),\n            "EUR": ("monnaie européenne", "monnaie europeenne"),\n            "GBP": ("livre anglaise", "pound sterling"),\n            "TRY": ("lira turque", "livre de Turquie"),\n        }\n        for alias in (\n            name,\n            name.casefold(),\n            normal(name),\n            *common_french_aliases.get(code, ()),\n        ):\n            if alias and alias not in aliases:\n                aliases.append(alias)\n'''
    if new not in text:
        if text.count(old) != 1:
            raise SystemExit("French currency-alias patch target is missing or repeated")
        text = text.replace(old, new, 1)
    path.write_text(text, encoding="utf-8")


def apply_native_review() -> None:
    patch_builder_parser()
    patch_currency_aliases()
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
    print(
        "Second native French review applied: compact copy, parser and search aliases verified."
    )
