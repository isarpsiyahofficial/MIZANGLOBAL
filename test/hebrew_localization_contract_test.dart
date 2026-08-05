import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  test('Hebrew remains enabled in the complete eighteen-language runtime', () {
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
    expect(MizanI18n.isSupported('he'), isTrue);
    expect(MizanI18n.isSupported('he-IL'), isTrue);
    expect(MizanI18n.isSupported('iw-IL'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('HE_il'), 'he');
    expect(MizanI18n.normalizeLanguageTag('iw_IL'), 'he');
  });

  test('Hebrew binding contract and final runtime validators are present', () {
    final contract = File(
      'docs/localization/hebrew-quality-contract.md',
    ).readAsStringSync();
    final terminology = File('tools/hebrew_terminology.py').readAsStringSync();
    final validator = File(
      'tools/validate_hebrew_localization_scope.py',
    ).readAsStringSync();
    final audit = File('tools/audit_hebrew_native_copy.py').readAsStringSync();

    for (final marker in const [
      '791/791',
      'TextDirection.rtl',
      'one`, `two`, `other',
      '29 dil, 161 ülke ve 154 para birimi',
      'exactAllowWhileIdle',
      'inexactAllowWhileIdle',
      'İbrani takvimine',
    ]) {
      expect(contract, contains(marker), reason: marker);
    }
    for (final marker in const [
      'חוב',
      'תשלום',
      'הוצאה',
      'הכנסה',
      'מועד פירעון',
      'הרשאת התראות',
      'מיזוג גיבויים',
    ]) {
      expect(terminology, contains(marker), reason: marker);
    }
    expect(validator, contains('validate_runtime'));
    expect(validator, contains('EXPECTED_INTEGRATED_LANGUAGES'));
    expect(audit, contains('Hebrew native-copy audit passed'));
  });
}
