import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ar.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_bn.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_de.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_el.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_es.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_fa.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_fil.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_fr.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_he.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_hi.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_it.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ja.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ko.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ms.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_nl.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_pl.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_pt_br.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_pt_pt.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ro.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ru.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_sw.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_th.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_uk.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ur.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_vi.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_zh.dart';

// Final language contract: this file intentionally remains part of the exact-HEAD release gate.
void main() {
  const tags = <String>[
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
  final maps = <String, Map<String, String>>{
    'es': mizanSpanish,
    'pt-BR': mizanPortugueseBr,
    'pt-PT': mizanPortuguesePt,
    'fr': mizanFrench,
    'de': mizanGerman,
    'it': mizanItalian,
    'nl': mizanDutch,
    'pl': mizanPolish,
    'ro': mizanRomanian,
    'el': mizanGreek,
    'ru': mizanRussian,
    'uk': mizanUkrainian,
    'ar': mizanArabic,
    'fa': mizanPersian,
    'he': mizanHebrew,
    'hi': mizanHindi,
    'bn': mizanBengali,
    'ur': mizanUrdu,
    'id': mizanIndonesian,
    'ms': mizanMalay,
    'fil': mizanFilipino,
    'vi': mizanVietnamese,
    'th': mizanThai,
    'sw': mizanSwahili,
    'zh': mizanChinese,
    'ja': mizanJapanese,
    'ko': mizanKorean,
  };

  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));

  test('authoritative runtime exposes exactly 29 language options', () {
    expect(tags, hasLength(29));
    expect(MizanI18n.supportedLanguageTags, hasLength(29));
    expect(MizanI18n.supportedLanguageTags.toSet(), tags.toSet());
    for (final tag in tags) {
      expect(MizanI18n.isSupported(tag), isTrue, reason: tag);
    }
    for (final alias in const [
      'id-ID',
      'in-ID',
      'fil-PH',
      'tl-PH',
      'ko-KR',
      'ja-JP',
      'zh-CN',
      'zh-Hans',
      'vi-VN',
      'th-TH',
      'sw-TZ',
      'sw-KE',
    ]) {
      expect(MizanI18n.isSupported(alias), isTrue, reason: alias);
    }
  });

  test(
    'all 27 explicit translated static maps own the exact 791-key contract',
    () {
      final reference = mizanIndonesian.keys.toSet();
      expect(reference, hasLength(791));
      for (final entry in maps.entries) {
        expect(entry.value, hasLength(791), reason: entry.key);
        expect(
          entry.value.keys.toSet(),
          reference,
          reason: 'keys: ${entry.key}',
        );
        expect(
          entry.value.values.every((value) => value.trim().isNotEmpty),
          isTrue,
          reason: 'empty: ${entry.key}',
        );
        expect(
          entry.value.entries
              .where((item) => item.value.trim() == item.key.trim())
              .length,
          lessThan(120),
          reason: 'excessive source fallback: ${entry.key}',
        );
      }
    },
  );

  test('English runtime covers every stable Turkish source key', () {
    final keys = mizanIndonesian.keys.toList(growable: false);
    var translated = 0;
    for (final source in keys) {
      final value = MizanI18n.text(source, languageTag: 'en');
      expect(value.trim(), isNotEmpty, reason: source);
      if (value != source) translated++;
    }
    expect(translated, greaterThan(760));
  });

  test(
    'critical product surfaces survive repeated 29-language switching without previous-language retention',
    () {
      const source = [
        'Ana sayfa',
        'Kayıtlar',
        'Giderler',
        'Raporlar',
        'Ayarlar',
        'Bildirim sistemi',
        'PDF raporu',
        'Kalan ödeme yükü',
      ];
      final signatures = <String, String>{};
      for (final tag in [...tags, ...tags.reversed]) {
        MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
        final current = source.map(MizanI18n.text).join(' | ');
        expect(current.trim(), isNotEmpty, reason: tag);
        if (tag != 'tr') {
          expect(
            current,
            isNot(source.join(' | ')),
            reason: 'raw Turkish fallback: $tag',
          );
        }
        signatures[tag] = current;
      }
      for (final tag in const [
        'ko',
        'ja',
        'zh',
        'vi',
        'th',
        'sw',
        'id',
        'ms',
        'fil',
        'ur',
        'ar',
        'he',
      ]) {
        expect(signatures[tag], isNot(equals(signatures['tr'])), reason: tag);
      }
    },
  );

  test('CJK and Thai system-script boundaries are mutually isolated', () {
    final ko = mizanKorean.values.join('\n');
    final ja = mizanJapanese.values.join('\n');
    final zh = mizanChinese.values.join('\n');
    final th = mizanThai.values.join('\n');
    expect(RegExp(r'[\u3040-\u30ff]').hasMatch(ko), isFalse);
    expect(RegExp(r'[\uac00-\ud7af]').hasMatch(ja), isFalse);
    expect(RegExp(r'[\uac00-\ud7af\u3040-\u30ff]').hasMatch(zh), isFalse);
    expect(RegExp(r'[\u0e00-\u0e7f]').hasMatch(th), isTrue);
    expect(RegExp(r'[\u3040-\u30ff\uac00-\ud7af]').hasMatch(th), isFalse);
    expect(
      RegExp(r'[\u0e00-\u0e7f]').hasMatch(mizanVietnamese.values.join('\n')),
      isFalse,
    );
    expect(
      RegExp(r'[\u0e00-\u0e7f]').hasMatch(mizanSwahili.values.join('\n')),
      isFalse,
    );
  });

  test(
    'closely related new Latin languages reject high-signal neighboring fallbacks',
    () {
      final samples = <String, String>{
        'id': const [
          'Ana sayfa',
          'Kayıtlar',
          'Giderler',
          'Ayarlar',
          'Bildirim sistemi',
        ].map((k) => mizanIndonesian[k]!).join(' ').toLowerCase(),
        'ms': const [
          'Ana sayfa',
          'Kayıtlar',
          'Giderler',
          'Ayarlar',
          'Bildirim sistemi',
        ].map((k) => mizanMalay[k]!).join(' ').toLowerCase(),
        'fil': const [
          'Ana sayfa',
          'Kayıtlar',
          'Giderler',
          'Ayarlar',
          'Bildirim sistemi',
        ].map((k) => mizanFilipino[k]!).join(' ').toLowerCase(),
        'vi': const [
          'Ana sayfa',
          'Kayıtlar',
          'Giderler',
          'Ayarlar',
          'Bildirim sistemi',
        ].map((k) => mizanVietnamese[k]!).join(' ').toLowerCase(),
        'sw': const [
          'Ana sayfa',
          'Kayıtlar',
          'Giderler',
          'Ayarlar',
          'Bildirim sistemi',
        ].map((k) => mizanSwahili[k]!).join(' ').toLowerCase(),
      };
      expect(samples['ms'], isNot(contains('pengeluaran')));
      expect(samples['ms'], isNot(contains('pengaturan')));
      expect(samples['fil'], isNot(contains('pengeluaran')));
      expect(samples['vi'], isNot(contains('pengeluaran')));
      expect(samples['vi'], isNot(contains('perbelanjaan')));
      expect(samples['sw'], isNot(contains('pengeluaran')));
      expect(samples['sw'], isNot(contains('trang chủ')));
    },
  );

  test(
    'user-authored mixed-script content remains visible under every language',
    () {
      const raw =
          'Banka A.Ş. | قرض | اردو | हिन्दी | বাংলা | 한국어 | 日本語 | 中文 | ภาษาไทย | Việt Nam | M-Pesa';
      for (final tag in tags) {
        MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
        final visible = MizanI18n.text(MizanI18n.user(raw));
        for (final marker in const [
          'Banka A.Ş.',
          '한국어',
          '日本語',
          '中文',
          'ภาษาไทย',
          'Việt Nam',
          'M-Pesa',
        ]) {
          expect(visible, contains(marker), reason: '$tag/$marker');
        }
      }
    },
  );
}
