import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/vi/mizan_vi_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/th/mizan_th_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/sw/mizan_sw_catalog.dart';

void main() {
  test('Vietnamese offline selector catalog is complete', () {
    expect(vietnameseLanguageNames, hasLength(29));
    expect(vietnameseCountryNames, hasLength(161));
    expect(vietnameseCurrencyNames, hasLength(154));
    expect(vietnameseLanguageNames.values.every((v) => v.trim().isNotEmpty), isTrue);
    expect(vietnameseCountryNames.values.every((v) => v.trim().isNotEmpty), isTrue);
    expect(vietnameseCurrencyNames.values.every((v) => v.trim().isNotEmpty), isTrue);
    expect(vietnameseCountryNames['VN'], isNot(equals('VN')));
    expect(vietnameseCurrencyNames['VND'], isNot(equals('VND')));
  });

  test('Thai offline selector catalog is complete', () {
    expect(thaiLanguageNames, hasLength(29));
    expect(thaiCountryNames, hasLength(161));
    expect(thaiCurrencyNames, hasLength(154));
    expect(thaiLanguageNames.values.every((v) => v.trim().isNotEmpty), isTrue);
    expect(thaiCountryNames.values.every((v) => v.trim().isNotEmpty), isTrue);
    expect(thaiCurrencyNames.values.every((v) => v.trim().isNotEmpty), isTrue);
    expect(thaiCountryNames['TH'], contains('ไทย'));
    expect(thaiCurrencyNames['THB'], isNot(equals('THB')));
  });

  test('Swahili offline selector catalog is complete', () {
    expect(swahiliLanguageNames, hasLength(29));
    expect(swahiliCountryNames, hasLength(161));
    expect(swahiliCurrencyNames, hasLength(154));
    expect(swahiliLanguageNames.values.every((v) => v.trim().isNotEmpty), isTrue);
    expect(swahiliCountryNames.values.every((v) => v.trim().isNotEmpty), isTrue);
    expect(swahiliCurrencyNames.values.every((v) => v.trim().isNotEmpty), isTrue);
    expect(swahiliLanguageNames['sw'], 'Kiswahili');
    expect(swahiliCurrencyNames['TZS'], isNot(equals('TZS')));
  });

  test('the three new catalogs stay lexically distinct on critical selectors', () {
    for (final code in const ['tr','en','vi','th','sw','zh','ja','ko']) {
      expect(vietnameseLanguageNames[code], isNot(equals(thaiLanguageNames[code])), reason: code);
      expect(vietnameseLanguageNames[code], isNot(equals(swahiliLanguageNames[code])), reason: code);
      expect(thaiLanguageNames[code], isNot(equals(swahiliLanguageNames[code])), reason: code);
    }
  });
}
