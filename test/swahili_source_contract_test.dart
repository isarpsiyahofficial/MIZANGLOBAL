import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_sw.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_sw_dynamic.dart';

void main() {
  test('Swahili owns the complete 791-key static contract', () {
    expect(mizanIndonesian, hasLength(791));
    expect(mizanSwahili, hasLength(791));
    expect(mizanSwahili.keys.toSet(), mizanIndonesian.keys.toSet());
    expect(
      mizanSwahili.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );
  });

  test('Swahili critical product surfaces use reviewed terminology', () {
    expect(mizanSwahili['Ana sayfa'], 'Nyumbani');
    expect(mizanSwahili['Kayıtlar'], 'Rekodi');
    expect(mizanSwahili['Giderler'], 'Matumizi');
    expect(mizanSwahili['Raporlar'], 'Ripoti');
    expect(mizanSwahili['Ayarlar'], 'Mipangilio');
    expect(mizanSwahili['Bildirim sistemi'], contains('arifa'));
    expect(mizanSwahili['PDF raporu'], 'Ripoti ya PDF');
  });

  test('Swahili dynamic grammar localizes counts and due status', () {
    expect(
      translateSwahiliReviewedDynamic(
        '3 gün kaldı',
        (value) => mizanSwahili[value] ?? value,
      ),
      'Siku 3 zimebaki',
    );
    expect(
      translateSwahiliReviewedDynamic(
        'Ödeme 2 gün gecikti.',
        (value) => mizanSwahili[value] ?? value,
      ),
      'Malipo yamechelewa 2 siku.',
    );
    expect(
      translateSwahiliReviewedDynamic(
        'Ödeme hatırlatması 3',
        (value) => mizanSwahili[value] ?? value,
      ),
      'Kikumbusho cha malipo 3',
    );
  });

  test('Swahili navigation rejects neighboring language fallback', () {
    final joined = const [
      'Ana sayfa',
      'Kayıtlar',
      'Giderler',
      'Raporlar',
      'Ayarlar',
      'Bildirim sistemi',
    ].map((key) => mizanSwahili[key]!.toLowerCase()).join(' ');
    for (final leak in const [
      'pengeluaran',
      'pengaturan',
      'perbelanjaan',
      'mga tala',
      'trang chủ',
      'báo cáo',
    ]) {
      expect(joined, isNot(contains(leak)), reason: leak);
    }
  });
}
