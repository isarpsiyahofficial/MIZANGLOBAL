#!/usr/bin/env python3
"""Update legacy localization validators and tests after pt-PT integration."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
I18N = ROOT / 'lib/l10n/mizan_i18n.dart'
validator_paths = [
    ROOT / 'tools/validate_english_localization.py',
    ROOT / 'tools/validate_spanish_localization.py',
    ROOT / 'tools/validate_portuguese_br_localization.py',
]
test_paths = [
    ROOT / 'test/english_localization_test.dart',
    ROOT / 'test/spanish_localization_test.dart',
    ROOT / 'test/portuguese_br_localization_test.dart',
]
old_runtime = "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR'};"
new_runtime = "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl'};"

# Existing accepted-language validators deliberately compare the exact set. Keep
# this one compact declaration outside formatter rewriting so all independent
# validators inspect the same canonical product gate.
i18n_source = I18N.read_text(encoding='utf-8')
canonical_block = f"  // dart format off\n  {new_runtime}\n  // dart format on"
if canonical_block not in i18n_source:
    if new_runtime not in i18n_source:
        raise SystemExit('Could not locate integrated pt-PT supported-language gate')
    i18n_source = i18n_source.replace(
        f"  {new_runtime}",
        canonical_block,
        1,
    )
    I18N.write_text(i18n_source, encoding='utf-8')

for path in validator_paths:
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
        + '        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_fr.dart",
        "lib/l10n/mizan_fr_dynamic.dart",
        "lib/l10n/fr/mizan_fr_core.dart",
        "lib/l10n/fr/mizan_fr_validation.dart",
        "lib/l10n/fr/mizan_fr_dashboard.dart",
        "lib/l10n/fr/mizan_fr_records.dart",
        "lib/l10n/fr/mizan_fr_reports.dart",
        "lib/l10n/fr/mizan_fr_settings.dart",
        "lib/l10n/mizan_de.dart",
        "lib/l10n/mizan_de_dynamic.dart",
        "lib/l10n/de/mizan_de_core.dart",
        "lib/l10n/de/mizan_de_validation.dart",
        "lib/l10n/de/mizan_de_dashboard.dart",
        "lib/l10n/de/mizan_de_records.dart",
        "lib/l10n/de/mizan_de_reports.dart",
        "lib/l10n/de/mizan_de_settings.dart",\n'
    )
    if '"lib/l10n/mizan_pt_pt.dart"' not in source and anchor in source:
        source = source.replace(anchor, addition, 1)
    path.write_text(source, encoding='utf-8')

for path in test_paths:
    source = path.read_text(encoding='utf-8')
    source = source.replace(
        "expect(MizanI18n.isSupported('pt-PT'), isFalse);",
        "expect(MizanI18n.isSupported('pt-PT'), isTrue);",
    )
    if "expect(MizanI18n.normalizeLanguageTag('pt_PT'), 'pt-PT');" not in source:
        anchor = "expect(MizanI18n.isSupported('pt-PT'), isTrue);"
        if anchor in source:
            source = source.replace(
                anchor,
                anchor + "\n    expect(MizanI18n.normalizeLanguageTag('pt_PT'), 'pt-PT');",
                1,
            )
    path.write_text(source, encoding='utf-8')

print('Legacy validators and locale tests now recognise pt-PT.')
