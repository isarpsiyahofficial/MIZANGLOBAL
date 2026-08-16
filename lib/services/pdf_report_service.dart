import 'package:flutter/foundation.dart';

import '../monetization/premium_entitlement_store.dart';
import 'pdf_report_renderer.dart' as renderer;
import 'report_service.dart';

class PremiumPdfRequiredException implements Exception {
  const PremiumPdfRequiredException();

  @override
  String toString() => 'PRO is required to export PDF reports.';
}

class PdfReportService {
  const PdfReportService({this.entitlementStore});

  final PremiumEntitlementStore? entitlementStore;

  static const String _deepLocaleTest = String.fromEnvironment(
    'MIZAN_TEST_LOCALE',
    defaultValue: '',
  );

  Future<Uint8List> build(MizanReport report) async {
    // The 29-language deep matrix validates PDF rendering itself and runs only
    // under flutter test. Release mode can never use this hook, even if an
    // accidental define is supplied. Normal app calls always enforce PRO.
    final deepLocaleRendererTest = !kReleaseMode && _deepLocaleTest.isNotEmpty;
    if (!deepLocaleRendererTest) {
      final store = entitlementStore ?? PremiumEntitlementStore();
      final snapshot = await store.load();
      if (!snapshot.hasPremiumAt(DateTime.now().toUtc())) {
        throw const PremiumPdfRequiredException();
      }
    }
    return const renderer.PdfReportService().build(report);
  }
}
