import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  const labels = <String>[
    'Aylık tutar',
    'Ödeme tarihi',
    'Gecikme',
    'Ödenmeyen aylar',
    'Kalan taksit sayısı',
    'Limit',
    'Kullanılan limit',
    'Borç tarihi',
    'Ödeme sıklığı',
    'Düzenli ödeme',
    'Çek no',
    'Düzenleyen',
    'Banka bilgisi',
    'Senet no',
    'Senet',
    'Fatura düzeni',
    'Ödeme günü',
    'İlk fatura ayı',
    'Kayıtlı değişken tutarlar',
    'Abone no',
    'Sözleşme / tesisat no',
    'Tekrar sıklığı',
    'Sözleşme no',
    'Kayıt türü',
    'İlk ödeme ayı',
    'IBAN',
    'Sözleşme başlangıcı',
    'Sözleşme bitişi',
  ];

  test('runtime record labels localize in every language', () {
    expect(MizanI18n.supportedLanguageTags.length, 29);
    for (final tag in MizanI18n.supportedLanguageTags) {
      for (final label in labels) {
        final expected = MizanI18n.text(label, languageTag: tag);
        final actual = MizanI18n.text('$label: VALUE', languageTag: tag);
        expect(actual.startsWith('$expected: '), isTrue);
        expect(actual.contains('VALUE'), isTrue);
      }
    }
  });

  test('runtime record values preserve user content', () {
    const value = 'İbrahim — 東京 — M-Pesa:42';
    for (final tag in MizanI18n.supportedLanguageTags) {
      final actual = MizanI18n.text('Düzenleyen: $value', languageTag: tag);
      expect(actual.contains(value), isTrue);
    }
  });

  test('nested runtime durations localize in every language', () {
    for (final tag in MizanI18n.supportedLanguageTags) {
      final actual = MizanI18n.text('Gecikme: 4 gün', languageTag: tag);
      final label = MizanI18n.text('Gecikme', languageTag: tag);
      final value = MizanI18n.text('4 gün', languageTag: tag);
      expect(actual, '$label: $value');
    }
  });
}
