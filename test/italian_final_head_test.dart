import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  test('final Hindi head exposes the complete eighteen-language runtime', () {
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
    expect(MizanI18n.normalizeLanguageTag('it-IT'), 'it');
    expect(MizanI18n.normalizeLanguageTag('it_CH'), 'it');
    expect(MizanI18n.isSupported('it'), isTrue);
    expect(MizanI18n.isSupported('it-IT'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('nl-NL'), 'nl');
    expect(MizanI18n.normalizeLanguageTag('nl_BE'), 'nl');
    expect(MizanI18n.isSupported('nl'), isTrue);
    expect(MizanI18n.isSupported('nl-NL'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('el_GR'), 'el');
    expect(MizanI18n.isSupported('ru'), isTrue);
    expect(MizanI18n.isSupported('ru-RU'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('ru_RU'), 'ru');
    expect(MizanI18n.isSupported('el-GR'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('fa-IR'), 'fa');
    expect(MizanI18n.normalizeLanguageTag('fa_AF'), 'fa');
    expect(MizanI18n.isSupported('fa'), isTrue);
    expect(MizanI18n.isSupported('fa-IR'), isTrue);
    expect(MizanI18n.isSupported('he'), isTrue);
    expect(MizanI18n.isSupported('he-IL'), isTrue);
    expect(MizanI18n.isSupported('iw-IL'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('he_IL'), 'he');
    expect(MizanI18n.normalizeLanguageTag('iw_IL'), 'he');
    expect(MizanI18n.isSupported('hi'), isTrue);
    expect(MizanI18n.isSupported('hi-IN'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('hi_IN'), 'hi');
  });
}
