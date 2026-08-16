import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));

  test(
    'Vietnamese formatter uses VND and local separators without changing value',
    () {
      MizanI18n.setProfile(languageTag: 'vi-VN', currencyCode: 'VND');
      expect(money(1234567), '1.234.567\u00A0₫');
      expect(decimalText(1234567), '1.234.567');
      expect(parseMoney('1.234.567 ₫'), 1234567);
      expect(shortDate(DateTime(2026, 8, 7)), '7/08/2026');
      expect(monthLabel(DateTime(2026, 8, 7)), 'tháng 8 2026');
    },
  );

  test('Thai formatter uses THB and Thai month labels', () {
    MizanI18n.setProfile(languageTag: 'th-TH', currencyCode: 'THB');
    expect(money(1234.5), '฿1,234.50');
    expect(decimalText(1234.5), '1,234.50');
    expect(parseMoney('฿1,234.50'), 1234.5);
    expect(shortDate(DateTime(2026, 8, 7)), '7 สิงหาคม 2026');
    expect(monthLabel(DateTime(2026, 8, 7)), 'สิงหาคม 2026');
  });

  test('Swahili formatter uses TZS and Swahili month labels', () {
    MizanI18n.setProfile(languageTag: 'sw-KE', currencyCode: 'TZS');
    expect(money(1234.5), 'TSh\u00A01,234.50');
    expect(decimalText(1234.5), '1,234.50');
    expect(parseMoney('TSh 1,234.50'), 1234.5);
    expect(shortDate(DateTime(2026, 8, 7)), '7 Agosti 2026');
    expect(monthLabel(DateTime(2026, 8, 7)), 'Agosti 2026');
  });

  test('changing interface language never changes the numeric amount', () {
    const input = 987654.32;
    for (final setup in const [('vi', 'USD'), ('th', 'USD'), ('sw', 'USD')]) {
      MizanI18n.setProfile(languageTag: setup.$1, currencyCode: setup.$2);
      expect(parseMoney(money(input)), input, reason: setup.$1);
    }
  });
}
