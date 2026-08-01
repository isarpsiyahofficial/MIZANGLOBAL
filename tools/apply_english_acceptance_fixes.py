from __future__ import annotations

import re
from pathlib import Path


def update_l10n() -> None:
    path = Path('lib/l10n/mizan_i18n.dart')
    text = path.read_text(encoding='utf-8')
    exact_entry = "    'MİZAN Aylık Raporu': 'MİZAN Monthly Report',\n"
    if exact_entry not in text:
        anchor = "  static const Map<String, String> _english = <String, String>{\n"
        if text.count(anchor) != 1:
            raise SystemExit('English translation map anchor is missing or duplicated.')
        text = text.replace(anchor, anchor + exact_entry, 1)
        path.write_text(text, encoding='utf-8')


def update_report_model_user_data() -> None:
    path = Path('lib/services/report_service.dart')
    text = path.read_text(encoding='utf-8')
    pattern = re.compile(r'MizanI18n\.user\(([A-Za-z_][A-Za-z0-9_.]*)\)')
    matches = pattern.findall(text)
    if matches:
        text = pattern.sub(r'\1', text)
        path.write_text(text, encoding='utf-8')
    if 'MizanI18n.user(' in path.read_text(encoding='utf-8'):
        raise SystemExit('A user-protection marker still leaks into report model data.')


if __name__ == '__main__':
    update_l10n()
    update_report_model_user_data()
