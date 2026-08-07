import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ko.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));
  test('Korean owns exactly the stable 791 product keys', () {
    expect(mizanKorean, hasLength(791));
    expect(mizanKorean.keys.toSet(), mizanIndonesian.keys.toSet());
    final values = mizanKorean.values.join('\n');
    expect(RegExp(r'[\uac00-\ud7af]').hasMatch(values), isTrue);
    expect(RegExp(r'[\u3040-\u30ff]').hasMatch(values), isFalse);
    for (final leak in const [
      '首页',
      '记录',
      '报告',
      '设置',
      '通知',
      '付款',
      'ホーム',
      'レポート',
      '設定',
      '支払い',
    ])
      expect(values, isNot(contains(leak)), reason: leak);
  });
  test('Korean locale resolves and uses South Korean product terms', () {
    expect(MizanI18n.isSupported('ko'), isTrue);
    expect(MizanI18n.isSupported('ko-KR'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('KO_kr'), 'ko');
    MizanI18n.setProfile(languageTag: 'ko-KR', currencyCode: 'KRW');
    expect(MizanI18n.text('Ana sayfa'), '홈');
    expect(MizanI18n.text('Kayıtlar'), '기록');
    expect(MizanI18n.text('Giderler'), '지출');
    expect(MizanI18n.text('Raporlar'), '보고서');
    expect(MizanI18n.text('Ayarlar'), '설정');
    expect(MizanI18n.text('Banka borcu'), '은행 부채');
    expect(MizanI18n.text('Kalan ödeme yükü'), '남은 납부 부담');
    expect(MizanI18n.destructiveConfirmation, '확인합니다');
  });
  test('Korean dynamic grammar is compact and natural', () {
    MizanI18n.setProfile(languageTag: 'ko', currencyCode: 'KRW');
    expect(MizanI18n.text('3 gün kaldı'), '3일 남음');
    expect(MizanI18n.text('2 ödeme'), '납부 2건');
    expect(MizanI18n.text('Ödeme 5 gün gecikti.'), '납부가 5일 연체되었습니다.');
    expect(
      MizanI18n.text('LEFFERION PRIME - MİZAN · Sayfa 3'),
      'LEFFERION PRIME - MİZAN · 3페이지',
    );
  });
  test('KRW uses zero minor units and Korean Gregorian dates', () {
    MizanI18n.setProfile(languageTag: 'ko', currencyCode: 'KRW');
    expect(money(1234567.4), 'KRW\u00A0₩1,234,567');
    expect(money(1234567.6), 'KRW\u00A0₩1,234,568');
    expect(decimalText(1234567.5), '1,234,568');
    expect(shortDate(DateTime(2026, 8, 7)), '2026년 8월 7일');
    expect(monthLabel(DateTime(2026, 8)), '2026년 8월');
    expect(parseMoney('₩1,234,567'), 1234567);
    MizanI18n.setProfile(languageTag: 'ko', currencyCode: 'USD');
    expect(money(1234.5), 'USD\u00A01,234.50');
  });
  test('Korean catalogs are complete and searchable offline', () async {
    MizanI18n.setProfile(languageTag: 'ko', currencyCode: 'KRW');
    final c = await GlobalCatalogRepository.load();
    expect(c.languages, hasLength(29));
    expect(c.countries, hasLength(161));
    expect(c.currencies, hasLength(154));
    expect(c.language('ko').nameFor('ko'), '한국어');
    expect(c.country('KR').nameFor('ko'), '대한민국');
    expect(c.currency('KRW').nameFor('ko'), '대한민국 원');
    expect(
      c.countries.where((e) => e.matches('대한')).any((e) => e.code == 'KR'),
      isTrue,
    );
    expect(
      c.currencies.where((e) => e.matches('원')).any((e) => e.code == 'KRW'),
      isTrue,
    );
  });
  test(
    'Korean preserves custom Japanese Chinese and Latin user text without treating it as system copy',
    () {
      MizanI18n.setProfile(languageTag: 'ko', currencyCode: 'KRW');
      final encoded = MizanI18n.user('KB 24 - 고객 메모 日本語 中文 Bank');
      expect(MizanI18n.text(encoded), 'KB 24 - 고객 메모 日本語 中文 Bank');
      expect(
        MizanI18n.text('$encoded · Kalan toplam borç'),
        'KB 24 - 고객 메모 日本語 中文 Bank · 총 잔여 부채',
      );
    },
  );
}
