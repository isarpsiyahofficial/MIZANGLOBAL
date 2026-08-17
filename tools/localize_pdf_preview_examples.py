from pathlib import Path

path = Path('lib/widgets/pdf_premium_access_card.dart')
source = path.read_text(encoding='utf-8')
replacements = {
    "const _SampleBar(label: '#1', value: '6.250 TRY', factor: .82)": "_SampleBar(label: _ui('Borçlar'), value: '6.250 TRY', factor: .82)",
    "const _SampleBar(label: '#2', value: '3.480 TRY', factor: .56)": "_SampleBar(label: _ui('Faturalar'), value: '3.480 TRY', factor: .56)",
    "const _SampleBar(label: '#3', value: '2.120 TRY', factor: .38)": "_SampleBar(label: _ui('Kira / Taksit'), value: '2.120 TRY', factor: .38)",
    "const _SampleLine(title: '#1', value: '4.500 TRY')": "_SampleLine(title: _ui('Borçlar'), value: '4.500 TRY')",
    "const _SampleLine(title: '#2', value: '1.350 TRY')": "_SampleLine(title: _ui('Faturalar'), value: '1.350 TRY')",
    "const _SampleLine(title: '#3', value: '6.000 TRY')": "_SampleLine(title: _ui('Kira / Taksit'), value: '6.000 TRY')",
}
for old, new in replacements.items():
    if old not in source:
        raise SystemExit(f'missing preview label: {old}')
    source = source.replace(old, new, 1)
path.write_text(source, encoding='utf-8')

Path('.github/workflows/localize-pdf-preview-examples.yml').unlink(missing_ok=True)
Path('tools/localize_pdf_preview_examples.py').unlink(missing_ok=True)
