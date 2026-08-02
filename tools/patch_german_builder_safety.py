#!/usr/bin/env python3
"""Make the German builder idempotent without rewriting other locale builders."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GERMAN_BUILDER = ROOT / "tools/build_german_locale.py"
FRENCH_BUILDER = ROOT / "tools/build_french_locale.py"


def replace_or_verify(path: Path, old: str, new: str, marker: str) -> None:
    text = path.read_text(encoding="utf-8")
    if marker in text and old not in text:
        return
    if text.count(old) != 1:
        raise SystemExit(
            f"Expected one safety target in {path.relative_to(ROOT)}, found {text.count(old)}"
        )
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


unsafe_injection = '''            if path.suffix == ".py" and "lib/l10n/mizan_de.dart" not in text:
                anchor = '\"lib/l10n/fr/mizan_fr_settings.dart\",'
                if anchor in text:
                    additions = "\\n".join(
                        [
                            anchor,
                            '        "lib/l10n/mizan_de.dart",',
                            '        "lib/l10n/mizan_de_dynamic.dart",',
                            '        "lib/l10n/de/mizan_de_core.dart",',
                            '        "lib/l10n/de/mizan_de_validation.dart",',
                            '        "lib/l10n/de/mizan_de_dashboard.dart",',
                            '        "lib/l10n/de/mizan_de_records.dart",',
                            '        "lib/l10n/de/mizan_de_reports.dart",',
                            '        "lib/l10n/de/mizan_de_settings.dart",',
                        ]
                    )
                    text = text.replace(anchor, additions)
'''
safe_comment = '''            # Locale-builder file lists are maintained explicitly. Generic text
            # injection is forbidden because quoted examples can resemble real entries.
'''
replace_or_verify(
    GERMAN_BUILDER,
    unsafe_injection,
    safe_comment,
    "Generic text\n            # injection is forbidden",
)

corrupted_french_entry = '''                            '        "lib/l10n/fr/mizan_fr_settings.dart",
        "lib/l10n/mizan_de.dart",
        "lib/l10n/mizan_de_dynamic.dart",
        "lib/l10n/de/mizan_de_core.dart",
        "lib/l10n/de/mizan_de_validation.dart",
        "lib/l10n/de/mizan_de_dashboard.dart",
        "lib/l10n/de/mizan_de_records.dart",
        "lib/l10n/de/mizan_de_reports.dart",
        "lib/l10n/de/mizan_de_settings.dart",',
'''
restored_french_entry = '''                            '        "lib/l10n/fr/mizan_fr_settings.dart",',
'''
replace_or_verify(
    FRENCH_BUILDER,
    corrupted_french_entry,
    restored_french_entry,
    "'        \"lib/l10n/fr/mizan_fr_settings.dart\",',",
)

print("German builder safety and French builder syntax verified.")
