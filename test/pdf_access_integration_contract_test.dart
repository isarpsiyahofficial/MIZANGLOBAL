import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reports screen drives PDF access from live monetization entitlement', () {
    final source = File('lib/screens/reports_screen.dart').readAsStringSync();

    expect(source, contains('final monetization = MonetizationScope.maybeOf(context);'));
    expect(source, contains('PdfPremiumAccessCard('));
    expect(source, contains('controller: monetization,'));
    expect(source, contains('isPremium: monetization?.isPremium ?? false,'));
    expect(source, contains('onSave: () => _savePdf(report),'));
    expect(source, contains('onShare: () => _sharePdf(report),'));
    expect(
      source,
      isNot(contains('_PdfActions(\n          generating: generatingPdf')),
      reason: 'The legacy always-visible PDF action card must not be rendered.',
    );
  });
}
