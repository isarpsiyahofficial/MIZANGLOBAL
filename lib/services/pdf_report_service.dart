import 'dart:typed_data';

import '../models/mizan_models.dart';
import '../monetization/premium_entitlement_store.dart';
import 'pdf_report_renderer.dart' as renderer;

class PremiumPdfRequiredException implements Exception {
  const PremiumPdfRequiredException();

  @override
  String toString() => 'Premium is required to export PDF reports.';
}

class PdfReportService {
  const PdfReportService({PremiumEntitlementStore? entitlementStore})
    : _entitlementStore = entitlementStore;

  final PremiumEntitlementStore? _entitlementStore;

  Future<Uint8List> build(MizanReport report) async {
    final store = _entitlementStore ?? PremiumEntitlementStore();
    final snapshot = await store.load();
    if (!snapshot.hasPremiumAt(DateTime.now().toUtc())) {
      throw const PremiumPdfRequiredException();
    }
    return const renderer.PdfReportService().build(report);
  }
}
