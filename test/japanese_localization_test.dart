import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ja.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));
  test('Japanese owns exactly the stable 791 product keys', () {
    expect(mizanJapanese, hasLength(791));
    expect(mizanJapanese.keys.toSet(), mizanIndonesian.keys.toSet());
    final values = mizanJapanese.values.join('\n');
    expect(RegExp(r'[\u3040-\u30ff]').hasMatch(values), isTrue);
    expect(RegExp(r'[\uac00-\ud7af]').hasMatch(values), isFalse);
    for (final leak in const [
      '홈',
      '기록',
      '보고서',
      '설정',
      '알림',
      '首页',
      '记录',
      '报告',
      '设置',
      '银行债务',
      '付款',
    ]) expect(values, isNot(contains(leak)), reason: leak);
  });
  test('Japanese locale resolves and uses natural finance labels', () {
    expect(MizanI18n.isSupported('ja'), isTrue);
    expect(MizanI18n.isSupported('ja-JP'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('JA_jp'), 'ja');
    MizanI18n.setProfile(languageTag: 'ja-JP', currencyCode: 'JPY');
    expect(MizanI18n.text('Ana sayfa'), 'ホーム');
    expect(MizanI18n.text('Kayıtlar'), '記録');
    expect(MizanI18n.text('Giderler'), '支出');
    expect(MizanI18n.text('Raporlar'), 'レポート');
    expect(MizanI18n.text('Ayarlar'), '設定');
    expect(MizanI18n.text('Banka borcu'), '銀行の借入');
    expect(MizanI18n.text('Kalan ödeme yükü'), '残りの支払負担');
    expect(MizanI18n.destructiveConfirmation, '確認します');
  });
  test('Japanese dynamic grammar is localized', () {
    MizanI18n.setProfile(languageTag: 'ja', currencyCode: 'JPY');
    expect(MizanI18n.text('3 gün kaldı'), 'あと3日');
    expect(MizanI18n.text('2 ödeme'), '支払い2件');
    expect(MizanI18n.text('Ödeme 5 gün gecikti.'), '支払いが5日延滞しています。');
    expect(
      MizanI18n.text('LEFFERION PRIME - MİZAN · Sayfa 3'),
      'LEFFERION PRIME - MİZAN · 3ページ',
    );
  });
  test('JPY uses zero minor units and Japanese Gregorian dates', () {
    MizanI18n.setProfile(languageTag: 'ja', currencyCode: 'JPY');
    expect(money(1234567.4), 'JPY\u00A0¥1,234,567');
    expect(money(1234567.6), 'JPY\u00A0¥1,234,568');
    expect(decimalText(1234567.5), '1,234,568');
    expect(shortDate(DateTime(2026, 8, 7)), '2026年8月7日');
    expect(monthLabel(DateTime(2026, 8)), '2026年8月');
    expect(parseMoney('¥1,234,567'), 1234567);
    expect(parseMoney('1,234,567円'), 1234567);
    MizanI18n.setProfile(languageTag: 'ja', currencyCode: 'USD');
    expect(money(1234.5), 'USD\u00A01,234.50');
  });
  test('Japanese catalogs are complete and searchable offline', () async {
    MizanI18n.setProfile(languageTag: 'ja', currencyCode: 'JPY');
    final c = await GlobalCatalogRepository.load();
    expect(c.languages, hasLength(29));
    expect(c.countries, hasLength(161));
    expect(c.currencies, hasLength(154));
    expect(c.language('ja').nameFor('ja'), '日本語');
    expect(c.country('JP').nameFor('ja'), '日本');
    expect(c.currency('JPY').nameFor('ja'), '日本円');
    expect(
      c.countries.where((e) => e.matches('日本')).any((e) => e.code == 'JP'),
      isTrue,
    );
    expect(
      c.currencies.where((e) => e.matches('日本円')).any((e) => e.code == 'JPY'),
      isTrue,
    );
  });
  test('Japanese preserves custom Korean Chinese and Latin user text', () {
    MizanI18n.setProfile(languageTag: 'ja', currencyCode: 'JPY');
    final encoded = MizanI18n.user('三井 24 - メモ 한국어 中文 Bank');
    expect(MizanI18n.text(encoded), '三井 24 - メモ 한국어 中文 Bank');
    expect(
      MizanI18n.text('$encoded · Kalan toplam borç'),
      '三井 24 - メモ 한국어 中文 Bank · 残債合計',
    );
  });
}
