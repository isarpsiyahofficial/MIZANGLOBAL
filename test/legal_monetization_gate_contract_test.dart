import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production bootstrap passes persisted legal acceptance to monetization', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(
      source,
      contains('LegalAcceptanceStore.hasAcceptedCurrentLegalBundle()'),
    );
    expect(
      source,
      contains('monetization.initialize(legalAccessGranted: legalAccepted)'),
    );
    expect(source, contains('activateAfterLegalAcceptance()'));
    expect(source, contains('if (_legalAccepted == false)'));
    expect(source, contains('LegalConsentScreen('));
  });

  test('monetization controller fail-closes purchase ads rewards and promo', () {
    final source = File(
      'lib/monetization/monetization_controller.dart',
    ).readAsStringSync();
    expect(source, contains('if (!_legalAccessGranted) return;'));
    expect(source, contains('if (!_legalAccessGranted) return false;'));
    expect(source, contains('if (!_legalAccessGranted ||'));
    expect(source, contains('legal_not_accepted'));
    expect(source, contains('if (_networkGate.isOnline && _legalAccessGranted)'));
    expect(source, contains('await _ensurePurchaseInitialized();'));
  });

  test('advertising is UMP gated, non-personalized and restricted', () {
    final source = File('lib/monetization/ad_service.dart').readAsStringSync();
    expect(source, contains('requestConsentInfoUpdate('));
    expect(source, contains('loadAndShowConsentFormIfRequired('));
    expect(source, contains('canRequestAds()'));
    expect(source, contains('getPrivacyOptionsRequirementStatus()'));
    expect(source, contains('showPrivacyOptionsForm('));
    expect(source, contains('nonPersonalizedAds: true'));
    expect(source, contains("extras: {'rdp': '1'}"));
    expect(source, contains('request: _privacyPreservingRequest'));
  });
}
