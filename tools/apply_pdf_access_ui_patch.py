from pathlib import Path

reports = Path('lib/screens/reports_screen.dart')
source = reports.read_text(encoding='utf-8')
source = source.replace(
    "import '../models/mizan_models.dart';\n",
    "import '../models/mizan_models.dart';\nimport '../monetization/monetization_scope.dart';\n",
    1,
)
source = source.replace(
    "import '../widgets/mizan_cards.dart';\n",
    "import '../widgets/mizan_cards.dart';\nimport '../widgets/pdf_premium_access_card.dart';\n",
    1,
)
source = source.replace(
    "    final report = _reportFor(state, filter);\n    final padding = MediaQuery.sizeOf(context).width < 380 ? 12.0 : 18.0;\n",
    "    final report = _reportFor(state, filter);\n    final monetization = MonetizationScope.maybeOf(context);\n    final padding = MediaQuery.sizeOf(context).width < 380 ? 12.0 : 18.0;\n",
    1,
)
old = """        _PdfActions(\n          generating: generatingPdf,\n          onSave: () => _savePdf(report),\n          onShare: () => _sharePdf(report),\n        ),\n"""
new = """        PdfPremiumAccessCard(\n          controller: monetization,\n          isPremium: monetization?.isPremium ?? false,\n          generating: generatingPdf,\n          onSave: () => _savePdf(report),\n          onShare: () => _sharePdf(report),\n        ),\n"""
if old not in source:
    raise SystemExit('PDF action block not found')
source = source.replace(old, new, 1)
reports.write_text(source, encoding='utf-8')

widget = Path('lib/widgets/pdf_premium_access_card.dart')
source = widget.read_text(encoding='utf-8')
source = source.replace(
    "    required this.controller,\n    required this.generating,\n",
    "    required this.controller,\n    required this.isPremium,\n    required this.generating,\n",
    1,
)
source = source.replace(
    "  final MonetizationController? controller;\n  final bool generating;\n",
    "  final MonetizationController? controller;\n  final bool isPremium;\n  final bool generating;\n",
    1,
)
source = source.replace("\n  bool get isPremium => controller?.isPremium ?? false;\n", "", 1)
widget.write_text(source, encoding='utf-8')

Path('.github/workflows/apply-pdf-access-ui.yml').unlink(missing_ok=True)
Path('tools/apply_pdf_access_ui_patch.py').unlink(missing_ok=True)
