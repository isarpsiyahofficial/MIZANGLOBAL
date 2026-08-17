from pathlib import Path

path = Path('lib/screens/reports_screen.dart')
source = path.read_text(encoding='utf-8')
start = source.find('class _PdfActions extends StatelessWidget {')
end = source.find('class _CurrentExpenseOverview extends StatelessWidget {')
if start < 0 or end < 0 or end <= start:
    raise SystemExit('legacy PDF action block boundaries not found')
source = source[:start] + source[end:]
path.write_text(source, encoding='utf-8')

Path('.github/workflows/remove-legacy-pdf-actions.yml').unlink(missing_ok=True)
Path('tools/remove_legacy_pdf_actions.py').unlink(missing_ok=True)
