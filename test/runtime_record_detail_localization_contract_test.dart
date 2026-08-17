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

  tearDown(
    () => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'),
  );

  test('29 languages localize record details', () {
    expect(MizanI18n.supportedLanguageTags, hasLength(29));

    for (final tag in MizanI18n.supportedLanguageTags) {
      for (final label in labels) {
        final localizedLabel = MizanI18n.text(label, languageTag: tag);
        final actual = MizanI18n.text('$label: VALUE-123', languageTag: tag);
        expect(
          actual,
          startsWith('$localizedLabel: '),
          reason: '$tag / $label => $actual',
        );
        expect(actual, contains('VALUE-123'), reason: '$tag / $label');
        if (tag != 'tr' && localizedLabel != label) {
          expect(
            actual,
            isNot(startsWith('$label: ')),
            reason: 'raw Turkish runtime label leaked: $tag / $label',
          );
        }
      }
    }
  });

  test('nested runtime values are localized too', () {
    for (final tag in MizanI18n.supportedLanguageTags) {
      final day = MizanI18n.text(
        'Ödeme günü: Her ayın 12. günü',
        languageTag: tag,
      );
      final expectedDayLabel = MizanI18n.text('Ödeme günü', languageTag: tag);
      final expectedDayValue = MizanI18n.text(
        'Her ayın 12. günü',
        languageTag: tag,
      );
      expect(day, '$expectedDayLabel: $expectedDayValue', reason: tag);

      final month = MizanI18n.text(
        'Kayıtlı değişken tutarlar: 3 ay',
        languageTag: tag,
      );
      final expectedMonthLabel = MizanI18n.text(
        'Kayıtlı değişken tutarlar',
        languageTag: tag,
      );
      final expectedMonthValue = MizanI18n.text('3 ay', languageTag: tag);
      expect(month, '$expectedMonthLabel: $expectedMonthValue', reason: tag);

      final delay = MizanI18n.text('Gecikme: 4 gün', languageTag: tag);
      final expectedDelayLabel = MizanI18n.text('Gecikme', languageTag: tag);
      final expectedDelayValue = MizanI18n.text('4 gün', languageTag: tag);
      expect(delay, '$expectedDelayLabel: $expectedDelayValue', reason: tag);
    }
  });

  test('user-authored detail values stay intact', () {
    const userValue = 'İbrahim — 東京 — M-Pesa:42';
    for (final tag in MizanI18n.supportedLanguageTags) {
      final actual = MizanI18n.text('Düzenleyen: $userValue', languageTag: tag);
      expect(actual, contains(userValue), reason: tag);
      final label = MizanI18n.text('Düzenleyen', languageTag: tag);
      expect(actual, startsWith('$label: '), reason: tag);
    }
  });
}
