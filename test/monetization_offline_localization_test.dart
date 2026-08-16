import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/monetization/offline_gate_strings.dart';

void main() {
  test('free offline gate has native text for every supported locale', () {
    expect(
      OfflineGateStrings.supportedLanguageTags,
      MizanI18n.supportedLanguageTags,
    );
    final english = <String>{
      OfflineGateStrings.title('en'),
      OfflineGateStrings.body('en'),
      OfflineGateStrings.retry('en'),
    };
    for (final tag in MizanI18n.supportedLanguageTags) {
      final values = <String>[
        OfflineGateStrings.title(tag),
        OfflineGateStrings.body(tag),
        OfflineGateStrings.retry(tag),
      ];
      for (final value in values) {
        expect(value.trim(), isNotEmpty, reason: '$tag must not be empty');
      }
      if (tag != 'en') {
        expect(
          values.any(english.contains),
          isFalse,
          reason: '$tag must not silently fall back to English',
        );
      }
    }
  });
}
