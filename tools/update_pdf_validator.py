from pathlib import Path

path = Path('tools/validate_project.py')
source = path.read_text(encoding='utf-8')

source = source.replace(
    '    premium_screen = read("lib/screens/premium_screen.dart")\n',
    '    premium_screen = read("lib/screens/premium_screen.dart")\n'
    '    pdf_access_card = read("lib/widgets/pdf_premium_access_card.dart")\n'
    '    pdf_access_test = read("test/pdf_premium_access_card_test.dart")\n'
    '    pdf_access_integration_test = read("test/pdf_access_integration_contract_test.dart")\n',
    1,
)

old = '''    require_all(\n        pdf_gate,\n        [\n            "PremiumEntitlementStore",\n            "PremiumPdfRequiredException",\n            "PRO is required",\n            "kReleaseMode",\n            "MIZAN_TEST_LOCALE",\n        ],\n        "PRO PDF entitlement gate incomplete",\n        failures,\n    )\n'''
new = '''    require_all(\n        pdf_gate,\n        [\n            "PremiumEntitlementStore",\n            "PremiumPdfRequiredException",\n            "PRO is required",\n            ".hasPremiumAt(nowUtc)",\n            "throw const PremiumPdfRequiredException()",\n            "renderer.PdfReportService().build(report)",\n        ],\n        "PRO PDF entitlement service gate incomplete",\n        failures,\n    )\n    require_all(\n        reports + pdf_access_card,\n        [\n            "MonetizationScope.maybeOf(context)",\n            "PdfPremiumAccessCard",\n            "isPremium: monetization?.isPremium ?? false",\n            "pdf-pro-locked",\n            "pdf-pro-unlocked",\n            "pdf-preview-button",\n            "pdf-save-enabled",\n            "pdf-share-enabled",\n            "showPdfSamplePreview",\n        ],\n        "PRO PDF live UI lock/preview/unlock gate incomplete",\n        failures,\n    )\n    require_absent(\n        reports,\n        ["class _PdfActions extends StatelessWidget"],\n        "Legacy always-visible PDF export actions remain",\n        failures,\n    )\n    require_all(\n        pdf_access_test + pdf_access_integration_test,\n        [\n            "free user sees PDF lock and sample preview but no export actions",\n            "active PRO removes the lock and enables real PDF actions",\n            "PDF access copy covers exactly every supported MIZAN language",\n            "reports screen drives PDF access from live monetization entitlement",\n            "PDF renderer remains protected behind local PRO entitlement",\n        ],\n        "PRO PDF lock/unlock regression coverage incomplete",\n        failures,\n    )\n'''
if old not in source:
    raise SystemExit('old PDF validator block not found')
source = source.replace(old, new, 1)

old_critical = '        "global_release_integrity_contract_test.dart",\n'
new_critical = (
    '        "global_release_integrity_contract_test.dart",\n'
    '        "pdf_premium_access_card_test.dart",\n'
    '        "pdf_access_integration_contract_test.dart",\n'
)
if old_critical not in source:
    raise SystemExit('critical test anchor not found')
source = source.replace(old_critical, new_critical, 1)

path.write_text(source, encoding='utf-8')
Path('.github/workflows/update-pdf-validator.yml').unlink(missing_ok=True)
Path('tools/update_pdf_validator.py').unlink(missing_ok=True)
