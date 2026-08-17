from pathlib import Path

widget = Path('lib/widgets/pdf_premium_access_card.dart')
source = widget.read_text(encoding='utf-8')
source = source.replace("import 'mizan_cards.dart';\n", "")
source = source.replace(
    "const _SampleBar(label: 'Kredi kartı', value: '6.250 TRY', factor: .82)",
    "const _SampleBar(label: '#1', value: '6.250 TRY', factor: .82)",
)
source = source.replace(
    "const _SampleBar(label: 'Market', value: '3.480 TRY', factor: .56)",
    "const _SampleBar(label: '#2', value: '3.480 TRY', factor: .56)",
)
source = source.replace(
    "const _SampleBar(label: 'Fatura', value: '2.120 TRY', factor: .38)",
    "const _SampleBar(label: '#3', value: '2.120 TRY', factor: .38)",
)
source = source.replace(
    "const _SampleLine(title: 'Banka · Kredi kartı', value: '4.500 TRY')",
    "const _SampleLine(title: '#1', value: '4.500 TRY')",
)
source = source.replace(
    "const _SampleLine(title: 'Fatura · Elektrik', value: '1.350 TRY')",
    "const _SampleLine(title: '#2', value: '1.350 TRY')",
)
source = source.replace(
    "const _SampleLine(title: 'Kira', value: '6.000 TRY')",
    "const _SampleLine(title: '#3', value: '6.000 TRY')",
)
widget.write_text(source, encoding='utf-8')

Path('.github/workflows/finalize-pdf-access-ui.yml').unlink(missing_ok=True)
Path('tools/finalize_pdf_access_ui.py').unlink(missing_ok=True)
