import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const authoritativeLanguages = <String>[
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

  test('all 29 languages cover all 154 currencies and 161 countries offline', () async {
    final catalog = await GlobalCatalogRepository.load();
    expect(authoritativeLanguages, hasLength(29));
    expect(catalog.currencies, hasLength(154));
    expect(catalog.countries, hasLength(161));

    for (final language in authoritativeLanguages) {
      for (final currency in catalog.currencies) {
        expect(
          currency.nameFor(language).trim(),
          isNotEmpty,
          reason: '$language/${currency.code} currency name must be offline',
        );
        expect(
          currency.matches(currency.code),
          isTrue,
          reason: '$language/${currency.code} must be searchable by ISO code',
        );
        expect(
          catalog.currencyMatches(currency, currency.code),
          isTrue,
          reason: '$language/${currency.code} exact ISO lookup must resolve itself',
        );
      }

      for (final country in catalog.countries) {
        expect(
          country.nameFor(language).trim(),
          isNotEmpty,
          reason: '$language/${country.code} country name must be offline',
        );
        expect(
          country.matches(country.code),
          isTrue,
          reason: '$language/${country.code} must be searchable by country code',
        );
      }
    }
  });

  test('29 x 154 money formatting is finite, nonempty, and round-trips', () async {
    final catalog = await GlobalCatalogRepository.load();
    const value = 123456.78;

    for (final language in authoritativeLanguages) {
      for (final currency in catalog.currencies) {
        MizanI18n.setProfile(
          languageTag: language,
          currencyCode: currency.code,
        );
        final rendered = money(value, currencyCode: currency.code);
        expect(
          rendered.trim(),
          isNotEmpty,
          reason: '$language/${currency.code} rendered empty',
        );
        expect(rendered.contains('NaN'), isFalse);
        expect(rendered.contains('Infinity'), isFalse);

        final parsed = parseMoney(rendered);
        final roundsNativeZeroDecimal =
            (language == 'ja' && currency.code == 'JPY') ||
            (language == 'ko' && currency.code == 'KRW') ||
            (language == 'vi' && currency.code == 'VND');
        final expected = roundsNativeZeroDecimal ? value.roundToDouble() : value;
        expect(
          parsed,
          closeTo(expected, 0.0001),
          reason: '$language/${currency.code}: $rendered -> $parsed',
        );
      }
    }
  });
}
