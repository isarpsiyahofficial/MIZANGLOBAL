import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_th.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_th_dynamic.dart';

void main() {
  test('Thai owns the complete 791-key static contract', () {
    expect(mizanIndonesian, hasLength(791));
    expect(mizanThai, hasLength(791));
    expect(mizanThai.keys.toSet(), mizanIndonesian.keys.toSet());
    expect(mizanThai.values.every((value) => value.trim().isNotEmpty), isTrue);
  });

  test('Thai critical product surfaces use Thai script and reviewed terminology', () {
    for (final key in const ['Ana sayfa','Kayıtlar','Giderler','Raporlar','Ayarlar','Bildirim sistemi','PDF raporu','Kalan ödeme yükü']) {
      final value = mizanThai[key]!;
      expect(RegExp(r'[\u0E00-\u0E7F]').hasMatch(value), isTrue, reason: '$key => $value');
      expect(RegExp(r'[\u3040-\u30ff\uac00-\ud7af]').hasMatch(value), isFalse, reason: key);
    }
  });

  test('Thai dynamic grammar localizes counts and due status', () {
    expect(translateThaiReviewedDynamic('3 gün kaldı', (value) => mizanThai[value] ?? value), 'เหลือ 3 วัน');
    expect(translateThaiReviewedDynamic('Ödeme 2 gün gecikti.', (value) => mizanThai[value] ?? value), 'การชำระเงินค้าง 2 วัน.');
    expect(translateThaiReviewedDynamic('Ödeme hatırlatması 3', (value) => mizanThai[value] ?? value), 'การเตือนชำระเงิน 3');
  });

  test('Thai navigation rejects neighboring-language and CJK leakage', () {
    final joined = const ['Ana sayfa','Kayıtlar','Giderler','Raporlar','Ayarlar','Bildirim sistemi']
        .map((key) => mizanThai[key]!.toLowerCase()).join(' ');
    for (final leak in const ['pengeluaran','pengaturan','rekod','perbelanjaan','mga tala','trang chủ','báo cáo']) {
      expect(joined, isNot(contains(leak)), reason: leak);
    }
    expect(RegExp(r'[\u3040-\u30ff\uac00-\ud7af]').hasMatch(joined), isFalse);
  });
}
