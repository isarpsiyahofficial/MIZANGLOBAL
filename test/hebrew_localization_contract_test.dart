import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  test(
    'Hebrew remains locked until the complete 791-key runtime is accepted',
    () {
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
      });
      expect(MizanI18n.isSupported('he'), isFalse);
      expect(MizanI18n.isSupported('he-IL'), isFalse);
      expect(MizanI18n.isSupported('iw-IL'), isFalse);
      expect(MizanI18n.normalizeLanguageTag('he-IL'), 'tr');
      expect(MizanI18n.normalizeLanguageTag('iw_IL'), 'tr');
    },
  );

  test('Hebrew binding contract and terminology foundation are present', () {
    final contract = File(
      'docs/localization/hebrew-quality-contract.md',
    ).readAsStringSync();
    final terminology = File('tools/hebrew_terminology.py').readAsStringSync();
    final validator = File(
      'tools/validate_hebrew_localization_scope.py',
    ).readAsStringSync();

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
    expect(
      validator,
      contains('validate_activation_lock_and_inherited_runtime'),
    );
    expect(validator, contains('EXPECTED_INTEGRATED_LANGUAGES'));
  });
}
