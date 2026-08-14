import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));
  const keys = [
    'Ana sayfa',
    'Kayıtlar',
    'Giderler',
    'Raporlar',
    'Ayarlar',
    'Bildirim sistemi',
    'Kalan ödeme yükü',
    'PDF raporu',
  ];
  test('ko ja zh system snapshots are all distinct and script isolated', () {
    MizanI18n.setProfile(languageTag: 'ko', currencyCode: 'KRW');
    final ko = keys.map(MizanI18n.text).toList();
    expect(ko.take(5).toList(), ['홈', '기록', '지출', '보고서', '설정']);
    expect(RegExp(r'[\u3040-\u30ff]').hasMatch(ko.join(' ')), isFalse);
    MizanI18n.setProfile(languageTag: 'ja', currencyCode: 'JPY');
    final ja = keys.map(MizanI18n.text).toList();
    expect(ja.take(5).toList(), ['ホーム', '記録', '支出', 'レポート', '設定']);
    expect(RegExp(r'[\uac00-\ud7af]').hasMatch(ja.join(' ')), isFalse);
    MizanI18n.setProfile(languageTag: 'zh', currencyCode: 'CNY');
    final zh = keys.map(MizanI18n.text).toList();
    expect(zh.take(5).toList(), ['首页', '记录', '支出', '报告', '设置']);
    expect(
      RegExp(r'[\uac00-\ud7af\u3040-\u30ff]').hasMatch(zh.join(' ')),
      isFalse,
    );
    expect(ko, isNot(equals(ja)));
    expect(ko, isNot(equals(zh)));
    expect(ja, isNot(equals(zh)));
  });
  test('repeated ko ja zh ko switching never retains prior system copy', () {
    for (final pair in const [
      ('ko', '홈'),
      ('ja', 'ホーム'),
      ('zh', '首页'),
      ('ko', '홈'),
      ('zh', '首页'),
      ('ja', 'ホーム'),
    ]) {
      MizanI18n.setProfile(
        languageTag: pair.$1,
        currencyCode: pair.$1 == 'ko'
            ? 'KRW'
            : pair.$1 == 'ja'
                ? 'JPY'
                : 'CNY',
      );
      expect(MizanI18n.text('Ana sayfa'), pair.$2);
    }
  });
  test('CJK currencies and dates are independent', () {
    MizanI18n.setProfile(languageTag: 'ko', currencyCode: 'KRW');
    expect(money(1234567.5), 'KRW\u00A0₩1,234,568');
    expect(shortDate(DateTime(2026, 8, 7)), '2026년 8월 7일');
    MizanI18n.setProfile(languageTag: 'ja', currencyCode: 'JPY');
    expect(money(1234567.5), 'JPY\u00A0¥1,234,568');
    expect(shortDate(DateTime(2026, 8, 7)), '2026年8月7日');
    MizanI18n.setProfile(languageTag: 'zh', currencyCode: 'CNY');
    expect(money(1234567.5), 'CNY\u00A0¥1,234,567.50');
    expect(shortDate(DateTime(2026, 8, 7)), '2026年8月7日');
  });
  test('CJK catalog names stay language-specific', () async {
    final c = await GlobalCatalogRepository.load();
    expect(c.country('KR').nameFor('ko'), '대한민국');
    expect(c.country('JP').nameFor('ja'), '日本');
    expect(c.country('CN').nameFor('zh'), '中国');
    expect(c.currency('KRW').nameFor('ko'), '대한민국 원');
    expect(c.currency('JPY').nameFor('ja'), '日本円');
    expect(c.currency('CNY').nameFor('zh'), '人民币');
  });
  test('mixed CJK user-authored text is preserved in every CJK runtime', () {
    const raw = '한국어 메모 / 日本語メモ / 中文备注 / Bank 24';
    for (final tag in const ['ko', 'ja', 'zh']) {
      MizanI18n.setProfile(
        languageTag: tag,
        currencyCode: tag == 'ko'
            ? 'KRW'
            : tag == 'ja'
                ? 'JPY'
                : 'CNY',
      );
      expect(MizanI18n.text(MizanI18n.user(raw)), raw, reason: tag);
    }
  });
}
