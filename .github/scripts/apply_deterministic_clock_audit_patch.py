from pathlib import Path

ROOT = Path('.')

clock_path = ROOT / 'lib/core/mizan_clock.dart'
if clock_path.exists():
    raise SystemExit('lib/core/mizan_clock.dart unexpectedly already exists')
clock_path.write_text("""class MizanClock {
  MizanClock._();

  static DateTime Function() _provider = DateTime.now;

  static DateTime now() => _provider();

  static void setNowForTesting(DateTime value) {
    _provider = () => value;
  }

  static void resetForTesting() {
    _provider = DateTime.now;
  }
}
""", encoding='utf-8')
print('created deterministic runtime clock')

files = {
    'lib/models/mizan_models.dart': "import '../core/mizan_clock.dart';\n",
    'lib/services/monthly_payment_status_service.dart': "import '../core/mizan_clock.dart';\n",
    'lib/services/report_service.dart': "import '../core/mizan_clock.dart';\n",
    'lib/screens/people_screen.dart': "import '../core/mizan_clock.dart';\n",
    'lib/screens/reports_screen.dart': "import '../core/mizan_clock.dart';\n",
    'lib/screens/expenses_screen.dart': "import '../core/mizan_clock.dart';\n",
    'lib/screens/record_form_dialogs.dart': "import '../core/mizan_clock.dart';\n",
    'lib/screens/dashboard_screen.dart': "import '../core/mizan_clock.dart';\n",
    'lib/screens/settings_screen.dart': "import '../core/mizan_clock.dart';\n",
    'lib/controllers/mizan_controller.dart': "import '../core/mizan_clock.dart';\n",
}
expected_counts = {
    'lib/models/mizan_models.dart': 7,
    'lib/services/monthly_payment_status_service.dart': 1,
    'lib/services/report_service.dart': 1,
    'lib/screens/people_screen.dart': 19,
    'lib/screens/reports_screen.dart': 4,
    'lib/screens/expenses_screen.dart': 3,
    'lib/screens/record_form_dialogs.dart': 15,
    'lib/screens/dashboard_screen.dart': 7,
    'lib/screens/settings_screen.dart': 1,
    'lib/controllers/mizan_controller.dart': 8,
}
for name, import_line in files.items():
    path = ROOT / name
    text = path.read_text(encoding='utf-8')
    count = text.count('DateTime.now()')
    expected = expected_counts[name]
    if count != expected:
        raise SystemExit(f'{name}: expected {expected} DateTime.now() calls, found {count}')
    if 'mizan_clock.dart' in text:
        raise SystemExit(f'{name}: clock import unexpectedly already present')
    text = import_line + text.replace('DateTime.now()', 'MizanClock.now()')
    path.write_text(text, encoding='utf-8')
    print(f'patched clock use: {name} ({count})')

visual = ROOT / 'test/visual_capture_test.dart'
text = visual.read_text(encoding='utf-8')
if "core/mizan_clock.dart" in text:
    raise SystemExit('visual test clock import unexpectedly already present')
text = text.replace(
    "import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';\n",
    "import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';\nimport 'package:lefferion_prime_mizan/core/mizan_clock.dart';\n",
    1,
)
count = text.count('comprehensiveState(reference: DateTime.now())')
if count != 10:
    raise SystemExit(f'visual test: expected 10 moving fixture references, found {count}')
text = text.replace('comprehensiveState(reference: DateTime.now())', 'comprehensiveState(reference: _visualNow)')
marker = "const _screenshotFontFamily = 'MizanScreenshotFont';\n"
if text.count(marker) != 1:
    raise SystemExit('visual test screenshot font marker mismatch')
text = text.replace(marker, marker + "final _visualNow = DateTime(2026, 8, 1, 10);\n", 1)
main_marker = "void main() {\n  setUpAll(_loadScreenshotFonts);\n"
if text.count(main_marker) != 1:
    raise SystemExit('visual test main marker mismatch')
text = text.replace(
    main_marker,
    "void main() {\n  setUpAll(_loadScreenshotFonts);\n  setUp(() => MizanClock.setNowForTesting(_visualNow));\n  tearDown(MizanClock.resetForTesting);\n",
    1,
)
visual.write_text(text, encoding='utf-8')
print('patched visual tests to exact 2026-08-01 clock')

audit = ROOT / 'tools/audit_indonesian_native_copy.py'
text = audit.read_text(encoding='utf-8')
old_dirs = "ID_DIR = ROOT / 'lib' / 'l10n' / 'id'\nBN_DIR = ROOT / 'lib' / 'l10n' / 'bn'\n"
new_dirs = """ID_DIR = ROOT / 'lib' / 'l10n' / 'id'
BN_DIR = ROOT / 'lib' / 'l10n' / 'bn'
PARTS = ('core', 'dashboard', 'records', 'reports', 'settings', 'validation')
ID_FILES = tuple(ID_DIR / f'mizan_id_{part}.dart' for part in PARTS)
BN_FILES = tuple(BN_DIR / f'mizan_bn_{part}.dart' for part in PARTS)
"""
if text.count(old_dirs) != 1:
    raise SystemExit('Indonesian audit directory marker mismatch')
text = text.replace(old_dirs, new_dirs, 1)
old_parse = """def parse_maps(directory: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for path in sorted(directory.glob('mizan_*_*.dart')):
        text = path.read_text(encoding='utf-8')
"""
new_parse = """def parse_maps(paths: tuple[Path, ...]) -> dict[str, str]:
    result: dict[str, str] = {}
    for path in paths:
        text = path.read_text(encoding='utf-8')
"""
if text.count(old_parse) != 1:
    raise SystemExit('Indonesian audit parse_maps marker mismatch')
text = text.replace(old_parse, new_parse, 1)
old_calls = "    source = parse_maps(BN_DIR)\n    target = parse_maps(ID_DIR)\n"
new_calls = "    source = parse_maps(BN_FILES)\n    target = parse_maps(ID_FILES)\n"
if text.count(old_calls) != 1:
    raise SystemExit('Indonesian audit source/target call marker mismatch')
text = text.replace(old_calls, new_calls, 1)
audit.write_text(text, encoding='utf-8')
print('restricted Indonesian audit to six 791-key static localization parts')
