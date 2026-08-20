from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
legacy = (ROOT / 'lib/l10n/mizan_i18n_legacy.dart').read_text(encoding='utf-8')
start = legacy.index('static const Map<String, String> _english')
end = legacy.index('\n  };', start) + 5
entry = re.compile(r"'((?:\\.|[^'])*)'\s*:\s*'((?:\\.|[^'])*)'\s*,?", re.S)
keys = {key for key, _ in entry.findall(legacy[start:end])}

paths = [
    *sorted((ROOT / 'lib/screens').glob('*.dart')),
    *sorted((ROOT / 'lib/widgets').glob('*.dart')),
    ROOT / 'lib/services/pdf_report_service.dart',
]
patterns = [
    ('Text', re.compile(r"(?<![A-Za-z])Text\(\s*'([^'\\$]*)'", re.S)),
    ('labelText', re.compile(r"labelText\s*:\s*'([^'\\$]*)'")),
    ('helperText', re.compile(r"helperText\s*:\s*'([^'\\$]*)'")),
    ('hintText', re.compile(r"hintText\s*:\s*'([^'\\$]*)'")),
    ('helpText', re.compile(r"helpText\s*:\s*'([^'\\$]*)'")),
    ('cancelText', re.compile(r"cancelText\s*:\s*'([^'\\$]*)'")),
    ('confirmText', re.compile(r"confirmText\s*:\s*'([^'\\$]*)'")),
    ('saveText', re.compile(r"saveText\s*:\s*'([^'\\$]*)'")),
    ('title/subtitle/message', re.compile(r"(?:title|subtitle|message)\s*:\s*'([^'\\$]*)'")),
]
allowed_exact_literals = {
    ('lib/screens/legal_document_screen.dart', 'Text', 'Türkçe'),
    ('lib/screens/legal_document_screen.dart', 'Text', 'English'),
}

failures = []
for path in paths:
    source = path.read_text(encoding='utf-8')
    relative = str(path.relative_to(ROOT)).replace('\\', '/')
    for kind, pattern in patterns:
        for match in pattern.finditer(source):
            value = match.group(1)
            if (
                not value
                or value in keys
                or value.startswith(('LEFFERION', 'MİZAN'))
                or (relative, kind, value) in allowed_exact_literals
            ):
                continue
            line = source.count('\n', 0, match.start()) + 1
            failures.append(f'{relative}:{line} [{kind}] {value!r}')

surface = '\n'.join(path.read_text(encoding='utf-8') for path in paths)
for marker in ("'Faturalar'", '"Faturalar"', "'Uygula'", '"Uygula"', "suffixText: 'TL'"):
    if marker in surface:
        failures.append(f'known raw locale/currency leak marker returned: {marker}')

if failures:
    print('Visible-copy coverage audit failed:')
    for failure in failures:
        print(f'- {failure}')
    sys.exit(1)

print(f'Visible-copy coverage audit passed: {len(keys)} canonical keys; no unlocalized simple UI literals.')
