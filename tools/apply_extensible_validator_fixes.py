#!/usr/bin/env python3
"""Remove obsolete exact supported-language-set assumptions from old validators."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPANISH = ROOT / "tools/validate_spanish_localization.py"

OLD = """if (
    \"static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar'};\"
    not in i18n_text
):
    failures.append(\"supported locales must include tr/en/es/pt-BR/pt-PT/pt-PT/pt-PT/pt-PT\")
"""
NEW = """supported_match = re.search(
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


def main() -> None:
    text = SPANISH.read_text(encoding="utf-8")
    if NEW in text:
        print("Spanish validator already uses an extensible supported-language check.")
        return
    if text.count(OLD) != 1:
        raise SystemExit("Expected one obsolete Spanish supported-language check")
    SPANISH.write_text(text.replace(OLD, NEW, 1), encoding="utf-8")
    print("Spanish supported-language validator made extensible.")


if __name__ == "__main__":
    main()
