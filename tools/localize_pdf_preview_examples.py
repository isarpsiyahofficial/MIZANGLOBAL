from pathlib import Path

path = Path('lib/widgets/pdf_premium_access_card.dart')
source = path.read_text(encoding='utf-8')

source = source.replace(
    "  String _ui(String turkish) => MizanI18n.text(turkish);\n",
    "  String _ui(String turkish) => MizanI18n.text(turkish);\n\n"
    "  String _pdf(String key) =>\n"
    "      PdfAccessStrings.text(MizanI18n.languageTag, key);\n",
    1,
)

replacements = {
    "const _SampleBar(label: '#1', value: '6.250 TRY', factor: .82)": "_SampleBar(label: '${_pdf('sampleEntry')} 1', value: '6.250 TRY', factor: .82)",
    "const _SampleBar(label: '#2', value: '3.480 TRY', factor: .56)": "_SampleBar(label: '${_pdf('sampleEntry')} 2', value: '3.480 TRY', factor: .56)",
    "const _SampleBar(label: '#3', value: '2.120 TRY', factor: .38)": "_SampleBar(label: '${_pdf('sampleEntry')} 3', value: '2.120 TRY', factor: .38)",
    "const _SampleLine(title: '#1', value: '4.500 TRY')": "_SampleLine(title: '${_pdf('sampleEntry')} 1', value: '4.500 TRY')",
    "const _SampleLine(title: '#2', value: '1.350 TRY')": "_SampleLine(title: '${_pdf('sampleEntry')} 2', value: '1.350 TRY')",
    "const _SampleLine(title: '#3', value: '6.000 TRY')": "_SampleLine(title: '${_pdf('sampleEntry')} 3', value: '6.000 TRY')",
}
for old, new in replacements.items():
    if old not in source:
        raise SystemExit(f'missing preview label: {old}')
    source = source.replace(old, new, 1)

anchor = "  static String text(String languageTag, String key) {\n"
labels = """  static const _sampleEntryLabels = <String, String>{
    'tr': 'Örnek kayıt',
    'en': 'Sample entry',
    'es': 'Registro de ejemplo',
    'pt-BR': 'Registro de exemplo',
    'pt-PT': 'Registo de exemplo',
    'fr': 'Enregistrement exemple',
    'de': 'Beispieleintrag',
    'it': 'Voce di esempio',
    'nl': 'Voorbeelditem',
    'pl': 'Przykładowy wpis',
    'ro': 'Înregistrare exemplu',
    'el': 'Δείγμα εγγραφής',
    'ru': 'Пример записи',
    'uk': 'Приклад запису',
    'ar': 'سجل تجريبي',
    'fa': 'رکورد نمونه',
    'he': 'רשומה לדוגמה',
    'hi': 'नमूना प्रविष्टि',
    'bn': 'নমুনা এন্ট্রি',
    'ur': 'نمونہ اندراج',
    'id': 'Entri contoh',
    'ms': 'Entri contoh',
    'fil': 'Halimbawang entry',
    'ko': '예시 항목',
    'ja': 'サンプル項目',
    'zh': '示例记录',
    'vi': 'Mục mẫu',
    'th': 'รายการตัวอย่าง',
    'sw': 'Ingizo la mfano',
  };

"""
if anchor not in source:
    raise SystemExit('PdfAccessStrings text anchor missing')
source = source.replace(anchor, labels + anchor, 1)
source = source.replace(
    "    final tag = MizanI18n.normalizeLanguageTag(languageTag);\n"
    "    return _values[tag]?[key] ?? _values['en']![key] ?? key;\n",
    "    final tag = MizanI18n.normalizeLanguageTag(languageTag);\n"
    "    if (key == 'sampleEntry') {\n"
    "      return _sampleEntryLabels[tag] ?? _sampleEntryLabels['en']!;\n"
    "    }\n"
    "    return _values[tag]?[key] ?? _values['en']![key] ?? key;\n",
    1,
)

path.write_text(source, encoding='utf-8')

# Keep the regression contract aware of the new preview-only localized label.
test_path = Path('test/pdf_premium_access_card_test.dart')
test_source = test_path.read_text(encoding='utf-8')
test_source = test_source.replace(
    "      'preparing',\n",
    "      'preparing',\n      'sampleEntry',\n",
    1,
)
test_path.write_text(test_source, encoding='utf-8')

Path('.github/workflows/localize-pdf-preview-examples.yml').unlink(missing_ok=True)
Path('tools/localize_pdf_preview_examples.py').unlink(missing_ok=True)
