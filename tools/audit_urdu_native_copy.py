#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAP_FILES = [
    ROOT / 'lib/l10n/ur/mizan_ur_core.dart',
    ROOT / 'lib/l10n/ur/mizan_ur_dashboard.dart',
    ROOT / 'lib/l10n/ur/mizan_ur_records.dart',
    ROOT / 'lib/l10n/ur/mizan_ur_reports.dart',
    ROOT / 'lib/l10n/ur/mizan_ur_settings.dart',
    ROOT / 'lib/l10n/ur/mizan_ur_validation.dart',
]
ENTRY = re.compile(r"'((?:\\.|[^'])*)'\s*:\s*'((?:\\.|[^'])*)'\s*,?", re.S)
FORBIDDEN_COPY = re.compile(r'[\u0400-\u052f\u0590-\u05ff\u0900-\u0d7f]')
FORBIDDEN_CONTROLS = tuple(chr(code) for code in (
    0x200B, 0x200C, 0x200D, 0x200E, 0x200F,
    0x202A, 0x202B, 0x202C, 0x202D, 0x202E,
    0x2066, 0x2067, 0x2068, 0x2069,
))
EXPECTED_CATALOGS = {
    'languages_v1.json': 29,
    'countries_v1.json': 161,
    'currencies_v1.json': 154,
}


def entries(path: Path) -> list[tuple[str, str]]:
    return ENTRY.findall(path.read_text(encoding='utf-8'))


def catalog_count(source: str, name: str) -> int:
    match = re.search(
        rf"const {name} = <String, String>\{{(.*?)\n\}};",
        source,
        re.DOTALL,
    )
    assert match, f'missing catalog: {name}'
    return len(ENTRY.findall(match.group(1)))


def main() -> None:
    pairs = [pair for path in MAP_FILES for pair in entries(path)]
    keys = [key for key, _ in pairs]
    values = [value for _, value in pairs]
    assert len(keys) == 791, len(keys)
    assert len(set(keys)) == 791, 'duplicate Urdu keys'
    assert all(value.strip() for value in values), 'empty Urdu value'
    combined = '\n'.join(values)
    assert re.search(r'[\u0600-\u06ff]', combined), 'Urdu script missing'
    assert not FORBIDDEN_COPY.search(combined), 'foreign-script copy leaked'
    assert not any(control in combined for control in FORBIDDEN_CONTROLS), 'bidi control embedded in static copy'

    catalog = (ROOT / 'lib/l10n/ur/mizan_ur_catalog.dart').read_text(encoding='utf-8')
    assert catalog_count(catalog, 'urduLanguageNames') == EXPECTED_CATALOGS['languages_v1.json']
    assert catalog_count(catalog, 'urduCountryNames') == EXPECTED_CATALOGS['countries_v1.json']
    assert catalog_count(catalog, 'urduCurrencyNames') == EXPECTED_CATALOGS['currencies_v1.json']

    runtime = (ROOT / 'lib/l10n/mizan_i18n.dart').read_text(encoding='utf-8')
    formatters = (ROOT / 'lib/core/formatters.dart').read_text(encoding='utf-8')
    main_dart = (ROOT / 'lib/main.dart').read_text(encoding='utf-8')
    for marker in ("'ur'", 'mizanUrdu', 'translateUrduReviewedDynamic', '\\u2068', '\\u2069'):
        assert marker in runtime, marker
    for code in ('PKR', 'INR'):
        assert re.search(rf"\bcode\s*==\s*'{code}'", formatters), f'{code} formatter branch'
    for marker in ('_groupIndian', '_urduMonths'):
        assert marker in formatters, marker
    assert re.search(r"Locale\(\s*'ur'\s*,\s*'PK'\s*\)", main_dart), 'ur-PK locale'

    print('Urdu native-copy audit passed: 791 static values, 29/161/154 catalogs, runtime and formatting markers.')


if __name__ == '__main__':
    main()
