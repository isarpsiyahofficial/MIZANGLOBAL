import 'package:shared_preferences/shared_preferences.dart';

import 'legal_documents.dart';

abstract final class LegalAcceptanceStore {
  static const String _generalAcceptanceKey = 'mizan_legal_acceptance_version';
  static const String _purchaseAcceptanceKey = 'mizan_purchase_terms_version';

  static String get currentVersion => MizanLegalDocuments.effectiveDate;

  static Future<bool> hasAcceptedCurrentLegalBundle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_generalAcceptanceKey) == currentVersion;
  }

  static Future<void> acceptCurrentLegalBundle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_generalAcceptanceKey, currentVersion);
    await prefs.setString(_purchaseAcceptanceKey, currentVersion);
  }

  static Future<bool> hasAcceptedCurrentPurchaseTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_purchaseAcceptanceKey) == currentVersion;
  }

  static Future<void> acceptCurrentPurchaseTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_purchaseAcceptanceKey, currentVersion);
  }

  static Future<void> clearForTest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_generalAcceptanceKey);
    await prefs.remove(_purchaseAcceptanceKey);
  }
}
