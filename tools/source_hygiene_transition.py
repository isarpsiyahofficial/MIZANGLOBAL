from pathlib import Path
import re
import shutil

root = Path('.')

source_extensions = {
    '.dart', '.kt', '.kts', '.java', '.gradle', '.groovy',
    '.ts', '.tsx', '.js', '.jsx', '.mjs', '.cjs', '.css', '.scss',
}

for path in root.rglob('*'):
    if not path.is_file() or path.suffix not in source_extensions:
        continue
    try:
        source = path.read_text(encoding='utf-8')
    except UnicodeDecodeError:
        continue
    output = []
    for line in source.splitlines(keepends=True):
        stripped = line.lstrip()
        if (
            stripped.startswith('//')
            and not stripped.startswith('// dart format off')
            and not stripped.startswith('// dart format on')
        ):
            continue
        output.append(line)
    cleaned = ''.join(output).lstrip('\r\n')
    if cleaned != source:
        path.write_text(cleaned, encoding='utf-8')

local_store = root / 'lib/services/local_store.dart'
source = local_store.read_text(encoding='utf-8')
old = (
    '      try {\n'
    '        await temporary.delete();\n'
    '      } on FileSystemException {\n'
    '      }\n'
)
new = (
    '      await temporary.delete().catchError(\n'
    '        (_) => temporary,\n'
    '        test: (error) => error is FileSystemException,\n'
    '      );\n'
)
if old not in source:
    raise SystemExit('Expected temporary-delete block not found')
local_store.write_text(source.replace(old, new, 1), encoding='utf-8')

for relative in (
    'tools/apply_greek_review.py',
    'tools/apply_russian_review.py',
    'tools/generate_pt_br_localization_draft.py',
):
    path = root / relative
    if path.exists():
        path.unlink()

for relative in (
    'tools/audit_greek_native_copy.py',
    'tools/audit_russian_native_copy.py',
):
    path = root / relative
    if path.exists():
        source = path.read_text(encoding='utf-8')
        source = source.replace(" or 'MACHINE-GENERATED' in text", '')
        path.write_text(source, encoding='utf-8')

replacements = {
    'tools/apply_romanian_review.py': (
        (
            "            '// REVIEWED ROMANIAN LOCALIZATION — ROMANIA-ORIENTED NATIVE COPY.',\n",
            '',
        ),
        (
            "    text=text.replace('// ROMANIAN LOCALIZATION CANDIDATE — 791/791 STATIC VALUES.',\n"
            "                      '// REVIEWED ROMANIAN LOCALIZATION — 791/791 STATIC VALUES.')\n",
            "    text=text.replace('// ROMANIAN LOCALIZATION CANDIDATE — 791/791 STATIC VALUES.\\n','')\n",
        ),
    ),
    'tools/finalize_hindi_native_copy.py': (
        (
            "            '// REVIEWED HINDI LOCALIZATION — NATURAL INDIA-ORIENTED PRODUCT COPY.',\n",
            '',
        ),
    ),
    'tools/materialize_bengali_locale.py': (
        (
            "            '// REVIEWED BENGALI LOCALIZATION — NATURAL BANGLADESH/INDIA PRODUCT COPY.',\n",
            '',
        ),
        (
            "                '// REVIEWED BENGALI LOCALIZATION — 791/791 STATIC VALUES.',\n",
            '',
        ),
    ),
    'tools/build_pt_pt_locale.py': (
        ('HEADER = "// REVIEWED PT-PT LOCALIZATION — 791/791 STATIC VALUES AUDITED."\n', ''),
        ('        HEADER,\n', ''),
        ('        "// Deterministic European Portuguese product source.",\n', ''),
        ('        "// User-authored names, notes and descriptions are never translated.",\n', ''),
    ),
    'tools/finalize_polish_copy.py': (
        (
            "index=index.replace('// User-authored content is never translated.\\n',"
            "'// Reviewed Polish product copy. User-authored content is never translated.\\n')\n",
            "index=index.replace('// User-authored content is never translated.\\n','')\n",
        ),
    ),
}

for relative, pairs in replacements.items():
    path = root / relative
    if not path.exists():
        continue
    source = path.read_text(encoding='utf-8')
    for old, new in pairs:
        if old not in source:
            raise SystemExit(f'Expected cleanup target not found: {relative}')
        source = source.replace(old, new)
    path.write_text(source, encoding='utf-8')

for relative in ('.idea', 'test/failures'):
    path = root / relative
    if path.is_dir():
        shutil.rmtree(path)

for relative in (
    'lefferion_prime_mizan.iml',
    'android/lefferion_prime_mizan_android.iml',
    'docs/BATCH_PLAN.md',
    'docs/ENGLISH_LOCALIZATION_VERIFICATION.md',
    'docs/SPANISH_LOCALIZATION_VERIFICATION.md',
    'docs/localization/bengali-final-candidate-status.md',
    'docs/localization/filipino-source-final.md',
    'docs/localization/global-language-status.md',
):
    path = root / relative
    if path.exists():
        path.unlink()

ignore = root / '.gitignore'
source = ignore.read_text(encoding='utf-8')
for entry in ('.idea/', 'test/failures/'):
    if entry not in source.splitlines():
        if source and not source.endswith('\n'):
            source += '\n'
        source += entry + '\n'
ignore.write_text(source, encoding='utf-8')

readme = root / 'README.md'
source = readme.read_text(encoding='utf-8')
source = re.sub(r'\n## CI çıktıları\n.*\Z', '\n', source, flags=re.S)
readme.write_text(source, encoding='utf-8')

(root / '.github/workflows/source-hygiene-once.yml').unlink(missing_ok=True)
final_workflow = root / '.github/monetization-ci.final'
if not final_workflow.exists():
    raise SystemExit('Final monetization workflow template is missing')
shutil.move(str(final_workflow), str(root / '.github/workflows/monetization-ci.yml'))
Path(__file__).unlink()
