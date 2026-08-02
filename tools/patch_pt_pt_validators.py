#!/usr/bin/env python3
"""Update legacy localization validators after pt-PT runtime integration."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
paths = [
    ROOT / 'tools/validate_english_localization.py',
    ROOT / 'tools/validate_spanish_localization.py',
    ROOT / 'tools/validate_portuguese_br_localization.py',
]
old_runtime = "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR'};"
new_runtime = "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT'};"
for path in paths:
    source = path.read_text(encoding='utf-8')
    if old_runtime in source:
        source = source.replace(old_runtime, new_runtime)
    source = source.replace(
        'Turkish, English, Spanish and Brazilian Portuguese must be enabled',
        'Turkish, English, Spanish, Brazilian Portuguese and European Portuguese must be enabled',
    )
    source = source.replace(
        'supported locales must include tr/en/es/pt-BR',
        'supported locales must include tr/en/es/pt-BR/pt-PT',
    )
    anchor = '        "lib/l10n/mizan_pt_br_dynamic.dart",\n'
    addition = (
        anchor
        + '        "lib/l10n/mizan_pt_pt.dart",\n'
        + '        "lib/l10n/mizan_pt_pt_dynamic.dart",\n'
    )
    if '"lib/l10n/mizan_pt_pt.dart"' not in source and anchor in source:
        source = source.replace(anchor, addition, 1)
    path.write_text(source, encoding='utf-8')
print('Legacy localization validators now recognise pt-PT.')
