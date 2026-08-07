import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));
  const tags = [
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
    'bn',
    'ur',
    'id',
    'ms',
    'fil',
    'vi',
    'th',
    'sw',
    'zh',
    'ja',
    'ko',
  ];

  test(
    'all 29 product language options and regional aliases are recognized',
    () {
      for (final tag in tags) {
        expect(MizanI18n.isSupported(tag), isTrue, reason: tag);
      }
      for (final alias in const [
        'vi-VN',
        'th-TH',
        'sw-TZ',
        'sw-KE',
        'zh-CN',
        'ja-JP',
        'ko-KR',
      ]) {
        expect(MizanI18n.isSupported(alias), isTrue, reason: alias);
      }
      expect(MizanI18n.normalizeLanguageTag('vi-VN'), 'vi');
      expect(MizanI18n.normalizeLanguageTag('th-TH'), 'th');
      expect(MizanI18n.normalizeLanguageTag('sw-KE'), 'sw');
      expect(MizanI18n.supportedLanguageTags.toSet(), tags.toSet());
      expect(MizanI18n.supportedLanguageTags, hasLength(29));
    },
  );

  test(
    'every language has localized navigation report notification and remaining-payment system copy',
    () {
      final seen = <String, String>{};
      for (final tag in tags) {
        MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
        final value = [
          'Ana sayfa',
          'Kayıtlar',
          'Giderler',
          'Raporlar',
          'Ayarlar',
          'Bildirim sistemi',
          'PDF raporu',
          'Kalan ödeme yükü',
          'Gecikmiş ödeme yükü',
        ].map(MizanI18n.text).join(' | ');
        expect(value.trim(), isNotEmpty, reason: tag);
        if (tag != 'tr') {
          expect(
            value,
            isNot(
              contains('Ana sayfa | Kayıtlar | Giderler | Raporlar | Ayarlar'),
            ),
            reason: tag,
          );
        }
        seen[tag] = value;
      }
      for (var i = 0; i < tags.length; i++) {
        for (var j = i + 1; j < tags.length; j++) {
          expect(
            seen[tags[i]],
            isNot(equals(seen[tags[j]])),
            reason: '${tags[i]} == ${tags[j]}',
          );
        }
      }
    },
  );

  test(
    'language switching torture does not retain previous product language',
    () {
      const sequence = [
        'ko',
        'ja',
        'zh',
        'vi',
        'th',
        'sw',
        'ar',
        'he',
        'en',
        'fil',
        'ms',
        'id',
        'ur',
        'tr',
        'vi',
        'sw',
        'th',
        'ko',
        'zh',
        'ja',
      ];
      String? prior;
      for (final tag in sequence) {
        MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
        final current = MizanI18n.text('Ana sayfa');
        if (prior != null)
          expect(current, isNot(prior), reason: 'switch to $tag');
        prior = current;
      }
    },
  );

  test(
    'user-authored multilingual data remains byte-visible in every language',
    () {
      const raw =
          'Bank 24 | Türkçe | العربية | اردو | 한국어 | 日本語 | 中文 | Tiếng Việt | ไทย | Kiswahili';
      for (final tag in tags) {
        MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
        final visible = MizanI18n.text(MizanI18n.user(raw));
        for (final marker in const [
          'Bank 24',
          '한국어',
          '日本語',
          '中文',
          'Tiếng Việt',
          'ไทย',
          'Kiswahili',
        ]) {
          expect(visible, contains(marker), reason: '$tag/$marker');
        }
      }
    },
  );
}
