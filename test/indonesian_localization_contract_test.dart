import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_bn.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id_dynamic.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));

  test('Indonesian static catalog is exactly complete', () {
    expect(mizanBengali.length, 791);
    expect(mizanIndonesian.length, 791);
    expect(mizanIndonesian.keys.toSet(), mizanBengali.keys.toSet());
    expect(
      mizanIndonesian.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );
  });

  test(
    'Indonesian copy contains no foreign-script or Turkish fallback leakage',
    () {
      final foreignScript = RegExp(
        r'[\u0400-\u052f\u0590-\u08ff\u0900-\u0dff\u0e00-\u109f\u1100-\u11ff\u2e80-\u9fff\uac00-\ud7af]',
        unicode: true,
      );
      final turkishFallback = RegExp(
        r'\b(ödeme|gider|borç|kayıt|fatura|kira|taksit|gelir|bildirim|ayarlar|kaydet|düzenle|gecikmiş|yaklaşan|tutar|kişi|abonelik)\b',
        caseSensitive: false,
        unicode: true,
      );
      for (final entry in mizanIndonesian.entries) {
        expect(foreignScript.hasMatch(entry.value), isFalse, reason: entry.key);
        expect(
          turkishFallback.hasMatch(entry.value),
          isFalse,
          reason: entry.key,
        );
      }
    },
  );

  test(
    'id and legacy in tags normalize to Indonesian without affecting other languages',
    () {
      expect(MizanI18n.normalizeLanguageTag('id-ID'), 'id');
      expect(MizanI18n.normalizeLanguageTag('id_ID'), 'id');
      expect(MizanI18n.normalizeLanguageTag('in-ID'), 'id');
      expect(MizanI18n.normalizeLanguageTag('tr-TR'), 'tr');
      expect(MizanI18n.normalizeLanguageTag('ar-SA'), 'ar');
      expect(MizanI18n.isSupported('id-ID'), isTrue);
    },
  );

  test('Indonesian money and date formats use IDR conventions', () {
    MizanI18n.setProfile(languageTag: 'id-ID', currencyCode: 'IDR');
    expect(money(1234567.89), 'Rp1.234.567,89');
    expect(decimalText(1234567.89), '1.234.567,89');
    expect(parseMoney('Rp1.234.567,89'), 1234567.89);
    expect(shortDate(DateTime(2026, 8, 6)), '6 Agu 2026');
    expect(monthLabel(DateTime(2026, 8)), 'Agustus 2026');
    expect(MizanI18n.destructiveConfirmation, 'SAYA SETUJU');
  });

  test(
    'dynamic Indonesian grammar remains natural and preserves user data',
    () {
      String translate(String source) => mizanIndonesian[source] ?? source;
      expect(
        translateIndonesianReviewedDynamic('3 gün kaldı', translate),
        '3 hari lagi',
      );
      expect(
        translateIndonesianReviewedDynamic('Ödeme 5 gün gecikti.', translate),
        'Pembayaran terlambat 5 hari.',
      );
      expect(
        translateIndonesianReviewedDynamic('Kalan taksit: 2', translate),
        '2 cicilan tersisa',
      );
      MizanI18n.setLanguageTag('id');
      expect(MizanI18n.text('Raporlar'), 'Laporan');
      expect(MizanI18n.text('Ayarlar'), 'Pengaturan');
      expect(
        MizanI18n.text('Not: ${MizanI18n.user('Budi 中文 العربية')}'),
        'Catatan: Budi 中文 العربية',
      );
    },
  );
}
