import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';

const _languages = <String>[
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

const _currencies = <String>['TRY', 'USD', 'EUR', 'JPY', 'AED', 'GBP', 'CNY'];

const _requestedTag = String.fromEnvironment(
  'MIZAN_TEST_LOCALE',
  defaultValue: 'tr',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    '$_requestedTag: 5537 deterministic locale stress scenarios',
    () {
      expect(_languages, hasLength(29));
      expect(_languages, contains(_requestedTag));
      expect(mizanIndonesian.keys, hasLength(791));

      final targetIndex = _languages.indexOf(_requestedTag);
      final foreignTag = _languages[(targetIndex + 1) % _languages.length];
      var scenarioCount = 0;

      for (
        var currencyIndex = 0;
        currencyIndex < _currencies.length;
        currencyIndex++
      ) {
        final currency = _currencies[currencyIndex];
        var keyIndex = 0;
        for (final key in mizanIndonesian.keys) {
          MizanI18n.setProfile(
            languageTag: _requestedTag,
            currencyCode: currency,
          );
          final direct = MizanI18n.text(key);
          final explicit = MizanI18n.text(key, languageTag: _requestedTag);
          expect(
            direct.trim(),
            isNotEmpty,
            reason: '$_requestedTag/$currency/$key: empty target copy',
          );
          expect(
            direct,
            explicit,
            reason: '$_requestedTag/$currency/$key: implicit/explicit lookup diverged',
          );
          expect(
            direct,
            isNot(contains('\u{E000}')),
            reason: '$_requestedTag/$currency/$key: private user marker leaked',
          );

          MizanI18n.setProfile(languageTag: foreignTag, currencyCode: currency);
          expect(
            MizanI18n.text(key).trim(),
            isNotEmpty,
            reason: '$foreignTag/$currency/$key: foreign transition became empty',
          );
          MizanI18n.setProfile(
            languageTag: _requestedTag,
            currencyCode: currency,
          );
          expect(
            MizanI18n.text(key),
            direct,
            reason: '$_requestedTag/$currency/$key: stale locale after round trip',
          );

          final userValue =
              'QA-${scenarioCount + 1}-İbrahim-東京-العربية-${_requestedTag.toUpperCase()}';
          expect(
            MizanI18n.text(MizanI18n.user(userValue)),
            userValue,
            reason: '$_requestedTag/$currency/$key: user value changed',
          );

          final amount = 1000 + currencyIndex * 100 + (keyIndex % 97) + 0.25;
          final rendered = money(amount, currencyCode: currency);
          expect(
            rendered.trim(),
            isNotEmpty,
            reason: '$_requestedTag/$currency/$key: money formatter empty',
          );
          expect(rendered.contains('NaN'), isFalse);
          expect(rendered.contains('Infinity'), isFalse);

          scenarioCount++;
          keyIndex++;
        }
      }

      expect(scenarioCount, 5537);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
