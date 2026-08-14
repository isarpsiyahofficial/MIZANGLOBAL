import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_vi.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_vi_dynamic.dart';

void main() {
  test('Vietnamese owns the complete 791-key static contract', () {
    expect(mizanIndonesian, hasLength(791));
    expect(mizanVietnamese, hasLength(791));
    expect(mizanVietnamese.keys.toSet(), mizanIndonesian.keys.toSet());
    expect(
      mizanVietnamese.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );
  });

  test(
    'Vietnamese critical product surfaces use natural local terminology',
    () {
      expect(mizanVietnamese['Ana sayfa'], 'Trang chủ');
      expect(mizanVietnamese['Kayıtlar'], 'Khoản mục');
      expect(mizanVietnamese['Giderler'], 'Chi tiêu');
      expect(mizanVietnamese['Raporlar'], 'Báo cáo');
      expect(mizanVietnamese['Ayarlar'], 'Cài đặt');
      expect(mizanVietnamese['Tutar'], 'Số tiền');
      expect(mizanVietnamese['Son ödeme tarihi'], contains('đến hạn'));
      expect(mizanVietnamese['Bildirim sistemi'], contains('thông báo'));
      expect(mizanVietnamese['PDF raporu'], 'Báo cáo PDF');
    },
  );

  test('Vietnamese dynamic grammar localizes counts and due status', () {
    expect(
      translateVietnameseReviewedDynamic(
        '3 gün kaldı',
        (value) => mizanVietnamese[value] ?? value,
      ),
      'Còn 3 ngày',
    );
    expect(
      translateVietnameseReviewedDynamic(
        'Ödeme 2 gün gecikti.',
        (value) => mizanVietnamese[value] ?? value,
      ),
      'Khoản thanh toán đã quá hạn 2 ngày.',
    );
    expect(
      translateVietnameseReviewedDynamic(
        'Ödeme hatırlatması 3',
        (value) => mizanVietnamese[value] ?? value,
      ),
      'Lời nhắc thanh toán 3',
    );
  });

  test(
    'Vietnamese copy rejects neighboring-language and CJK leakage in core navigation',
    () {
      final joined = <String>[
        mizanVietnamese['Ana sayfa']!,
        mizanVietnamese['Kayıtlar']!,
        mizanVietnamese['Giderler']!,
        mizanVietnamese['Raporlar']!,
        mizanVietnamese['Ayarlar']!,
        mizanVietnamese['Bildirim sistemi']!,
      ].join(' ').toLowerCase();
      for (final leak in const <String>[
        'pengeluaran',
        'pengaturan',
        'rekod',
        'perbelanjaan',
        'mga tala',
        '홈',
        'ホーム',
        '首页',
      ]) {
        expect(joined, isNot(contains(leak)), reason: leak);
      }
      expect(
        RegExp(r'[\u3040-\u30ff\uac00-\ud7af\u0e00-\u0e7f]').hasMatch(joined),
        isFalse,
      );
    },
  );
}
