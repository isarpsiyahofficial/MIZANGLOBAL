import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'reports screen drives PDF access from live monetization entitlement',
    () {
      // This contract intentionally verifies the production ReportsScreen wiring,
      // not only the isolated PDF access card widget.
      final source = File('lib/screens/reports_screen.dart').readAsStringSync();

      expect(
        source,
        contains('final monetization = MonetizationScope.maybeOf(context);'),
      );
      expect(source, contains('PdfPremiumAccessCard('));
      expect(source, contains('controller: monetization,'));
      expect(source, contains('isPremium: monetization?.isPremium ?? false,'));
      expect(source, contains('onSave: () => _savePdf(report),'));
      expect(source, contains('onShare: () => _sharePdf(report),'));
      expect(
        source,
        isNot(contains('class _PdfActions extends StatelessWidget')),
        reason: 'The legacy always-visible PDF action card must stay removed.',
      );
    },
  );

  test('PDF renderer remains protected behind local PRO entitlement', () {
    // Do not add a locale, debug, or network bypass here: production PDF access
    // is intentionally decided by the locally cached PRO entitlement.
    final source = File(
      'lib/services/pdf_report_service.dart',
    ).readAsStringSync();

    expect(source, contains('PremiumEntitlementStore'));
    expect(source, contains('.hasPremiumAt(nowUtc)'));
    expect(source, contains('throw const PremiumPdfRequiredException()'));
    expect(source, contains('renderer.PdfReportService().build(report)'));
  });
}
