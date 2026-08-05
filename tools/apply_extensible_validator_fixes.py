#!/usr/bin/env python3
"""Remove obsolete exact supported-language-set assumptions from old validators."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPANISH = ROOT / "tools/validate_spanish_localization.py"
PT_BR = ROOT / "tools/validate_portuguese_br_localization.py"

SPANISH_OLD = """if (
    \"static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar'};\"
    not in i18n_text
):
    failures.append(\"supported locales must include tr/en/es/pt-BR/pt-PT/pt-PT/pt-PT/pt-PT\")
"""
SPANISH_NEW = """supported_match = re.search(
    r\"static const supportedLanguageTags = <String>\\{([^}]*)\\};\",
    i18n_text,
)
if supported_match is None:
    failures.append(\"supported language set could not be parsed\")
else:
    supported = set(re.findall(r\"'([^']+)'\", supported_match.group(1)))
    required_supported = {\"tr\", \"en\", \"es\", \"pt-BR\", \"pt-PT\"}
    missing_supported = sorted(required_supported - supported)
    if missing_supported:
        failures.append(f\"required baseline languages are not enabled: {missing_supported}\")
"""

PT_BR_OLD = """runtime_requirements = (
    \"static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar'};\",
"""
PT_BR_NEW = """supported_match = re.search(
    r\"static const supportedLanguageTags = <String>\\{([^}]*)\\};\",
    i18n_text,
)
if supported_match is None:
    failures.append(\"supported language set could not be parsed\")
else:
    supported = set(re.findall(r\"'([^']+)'\", supported_match.group(1)))
    if \"pt-BR\" not in supported:
        failures.append(\"pt-BR is not enabled in the supported language set\")

runtime_requirements = (
"""


def patch(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        print(f"{label} validator already uses an extensible supported-language check.")
        return
    if text.count(old) != 1:
        raise SystemExit(f"Expected one obsolete {label} supported-language check")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")
    print(f"{label} supported-language validator made extensible.")


def main() -> None:
    patch(SPANISH, SPANISH_OLD, SPANISH_NEW, "Spanish")
    patch(PT_BR, PT_BR_OLD, PT_BR_NEW, "Brazilian Portuguese")


if __name__ == "__main__":
    main()
