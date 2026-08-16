import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';

const _languageTags = <String>[
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
  'bn',
  'ur',
  'id',
  'ms',
  'fil',
  'vi',
  'th',
  'sw',
  'zh',
  'ja',
  'ko',
];

void main() {
  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test(
    '29x28 language switching keeps all 791 system keys isolated',
    () {
      expect(MizanI18n.supportedLanguageTags, _languageTags.toSet());

      final keys = mizanIndonesian.keys.toList(growable: false);
      expect(keys, hasLength(791));

      final snapshots = <String, Map<String, String>>{};
      for (final tag in _languageTags) {
        final snapshot = <String, String>{};
        for (final key in keys) {
          final value = MizanI18n.text(key, languageTag: tag);
          if (value.trim().isEmpty) {
            fail('$tag: empty key "$key"');
          }
          snapshot[key] = value;
        }
        expect(snapshot, hasLength(791), reason: '$tag static key snapshot');
        snapshots[tag] = snapshot;
      }

      var directionalChecks = 0;
      var keyChecks = 0;
      for (final from in _languageTags) {
        for (final to in _languageTags) {
          if (from == to) continue;

          MizanI18n.setProfile(languageTag: from, currencyCode: 'USD');
          for (final key in keys) {
            // Exercise the complete source-language catalog before switching.
            MizanI18n.text(key);
          }

          MizanI18n.setProfile(languageTag: to, currencyCode: 'USD');
          var distinguishableKeys = 0;
          for (final key in keys) {
            final expectedTarget = snapshots[to]![key]!;
            final previousLanguage = snapshots[from]![key]!;
            final actual = MizanI18n.text(key);

            if (actual != expectedTarget) {
              fail(
                '$from -> $to retained or resolved the wrong key "$key": '
                'expected "$expectedTarget", got "$actual"',
              );
            }
            if (previousLanguage != expectedTarget) {
              distinguishableKeys++;
              if (actual == previousLanguage) {
                fail(
                  '$from -> $to leaked previous-language copy for "$key": '
                  '"$actual"',
                );
              }
            }
            keyChecks++;
          }

          expect(
            distinguishableKeys,
            greaterThan(0),
            reason: '$from -> $to has no distinguishable static system copy',
          );
          directionalChecks++;
        }
      }

      expect(directionalChecks, 29 * 28);
      expect(keyChecks, 29 * 28 * 791);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
