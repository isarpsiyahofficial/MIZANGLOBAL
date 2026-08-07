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

void main() {
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

  test(
    'all 27 translated static maps have exactly the same 791 stable Turkish source keys',
    () {
      final reference = mizanIndonesian.keys.toSet();
      expect(reference, hasLength(791));
      for (final entry in maps.entries) {
        expect(entry.value, hasLength(791), reason: entry.key);
        expect(
          entry.value.keys.toSet(),
          reference,
          reason: 'key mismatch: ${entry.key}',
        );
        expect(
          entry.value.values.every((v) => v.trim().isNotEmpty),
          isTrue,
          reason: 'empty value: ${entry.key}',
        );
      }
    },
  );

  test(
    'CJK static system copy never crosses Korean Japanese Chinese script boundaries',
    () {
      final ko = mizanKorean.values.join('\n');
      final ja = mizanJapanese.values.join('\n');
      final zh = mizanChinese.values.join('\n');
      expect(RegExp(r'[\u3040-\u30ff]').hasMatch(ko), isFalse);
      expect(RegExp(r'[\uac00-\ud7af]').hasMatch(ja), isFalse);
      expect(RegExp(r'[\uac00-\ud7af\u3040-\u30ff]').hasMatch(zh), isFalse);
      for (final value in const ['首页', '报告', '设置'])
        expect(ko, isNot(contains(value)));
      for (final value in const ['홈', '보고서', '설정']) {
        expect(ja, isNot(contains(value)));
        expect(zh, isNot(contains(value)));
      }
      for (final value in const ['ホーム', 'レポート', '設定']) {
        expect(ko, isNot(contains(value)));
        expect(zh, isNot(contains(value)));
      }
    },
  );

  test(
    'Thai critical static copy is Thai and Vietnamese Swahili stay outside Thai script',
    () {
      final th = mizanThai.values.join('\n');
      final vi = mizanVietnamese.values.join('\n');
      final sw = mizanSwahili.values.join('\n');
      expect(RegExp(r'[\u0e00-\u0e7f]').hasMatch(th), isTrue);
      expect(RegExp(r'[\u0e00-\u0e7f]').hasMatch(vi), isFalse);
      expect(RegExp(r'[\u0e00-\u0e7f]').hasMatch(sw), isFalse);
    },
  );
}
