import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  test('Hindi is enabled only as the complete eighteenth runtime', () {
    expect(MizanI18n.supportedLanguageTags, {
      'tr',
      'en',
      'es',
      'pt-BR',
      'pt-PT',
      'fr',
      'de',
      'it',
      'nl',
      'pl',
      'ro',
      'el',
      'ru',
      'uk',
      'ar',
      'fa',
      'he',
      'hi',
    });
    expect(MizanI18n.isSupported('hi'), isTrue);
    expect(MizanI18n.isSupported('hi-IN'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('HI_in'), 'hi');
    expect(MizanI18n.isSupported('he-IL'), isTrue);
    expect(MizanI18n.isSupported('iw-IL'), isTrue);
  });

  test('Hindi contract and final validators are present', () {
    final contract = File(
      'docs/localization/hindi-quality-contract.md',
    ).readAsStringSync();
    final terminology = File('tools/hindi_terminology.py').readAsStringSync();
    final validator = File(
      'tools/validate_hindi_localization_scope.py',
    ).readAsStringSync();
    final audit = File('tools/audit_hindi_native_copy.py').readAsStringSync();

    for (final marker in const [
      '791/791',
      'TextDirection.ltr',
      'one` ve `other',
      '29 dil, 161 ülke ve 154 para birimi',
      'exactAllowWhileIdle',
      'inexactAllowWhileIdle',
      '₹1,23,456.78',
      'Gregoryen',
    ]) {
      expect(contract, contains(marker), reason: marker);
    }
    for (final marker in const [
      'कर्ज़',
      'भुगतान',
      'खर्च',
      'आय',
      'अंतिम भुगतान तिथि',
      'सूचना की अनुमति',
      'बैकअप मिलाएँ',
    ]) {
      expect(terminology, contains(marker), reason: marker);
    }
    expect(validator, contains('validate_runtime'));
    expect(validator, contains('EXPECTED_INTEGRATED_LANGUAGES'));
    expect(audit, contains('Hindi native-copy audit passed'));
  });
}
