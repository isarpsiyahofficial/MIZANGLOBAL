import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  test('final Romanian head exposes the complete eleven-language runtime', () {
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
    });
    expect(MizanI18n.normalizeLanguageTag('it-IT'), 'it');
    expect(MizanI18n.normalizeLanguageTag('it_CH'), 'it');
    expect(MizanI18n.isSupported('it'), isTrue);
    expect(MizanI18n.isSupported('it-IT'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('nl-NL'), 'nl');
    expect(MizanI18n.normalizeLanguageTag('nl_BE'), 'nl');
    expect(MizanI18n.isSupported('nl'), isTrue);
    expect(MizanI18n.isSupported('nl-NL'), isTrue);
  });
}
