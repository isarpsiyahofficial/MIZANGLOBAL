import 'dart:typed_data';

import '../monetization/premium_entitlement_store.dart';
import 'pdf_report_renderer.dart' as renderer;
import 'report_service.dart';

class PremiumPdfRequiredException implements Exception {
  const PremiumPdfRequiredException();

  @override
  String toString() => 'PRO is required to export PDF reports.';
}

typedef PremiumAccessResolver = Future<bool> Function(DateTime nowUtc);

class PdfReportService {
  const PdfReportService({this.entitlementStore, this.premiumAccessResolver});

  final PremiumEntitlementStore? entitlementStore;
  final PremiumAccessResolver? premiumAccessResolver;

  Future<Uint8List> build(MizanReport report) async {
    final nowUtc = DateTime.now().toUtc();
    final resolver = premiumAccessResolver;
    final hasPremium =
        resolver != null
            ? await resolver(nowUtc)
            : (await (entitlementStore ?? PremiumEntitlementStore()).load())
                .hasPremiumAt(nowUtc);
    if (!hasPremium) {
      throw const PremiumPdfRequiredException();
    }
    return const renderer.PdfReportService().build(report);
  }
}
