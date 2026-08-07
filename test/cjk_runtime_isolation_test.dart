import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));
  test('Korean and Japanese runtime snapshots are mutually isolated', () {
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
    MizanI18n.setProfile(languageTag: 'ko', currencyCode: 'KRW');
    final ko = keys.map(MizanI18n.text).toList();
    expect(ko.take(5).toList(), ['홈', '기록', '지출', '보고서', '설정']);
    expect(RegExp(r'[\u3040-\u30ff]').hasMatch(ko.join(' ')), isFalse);
    MizanI18n.setProfile(languageTag: 'ja', currencyCode: 'JPY');
    final ja = keys.map(MizanI18n.text).toList();
    expect(ja.take(5).toList(), ['ホーム', '記録', '支出', 'レポート', '設定']);
    expect(RegExp(r'[\uac00-\ud7af]').hasMatch(ja.join(' ')), isFalse);
    expect(ja, isNot(equals(ko)));
    MizanI18n.setProfile(languageTag: 'ko', currencyCode: 'KRW');
    expect(keys.map(MizanI18n.text).toList(), ko);
  });
  test(
    'mixed CJK user content is preserved through Korean Japanese switching',
    () {
      const raw = '한국어 메모 / 日本語メモ / 中文备注 / Bank 24';
      for (final tag in const ['ko', 'ja']) {
        MizanI18n.setProfile(
          languageTag: tag,
          currencyCode: tag == 'ko' ? 'KRW' : 'JPY',
        );
        expect(MizanI18n.text(MizanI18n.user(raw)), raw, reason: tag);
      }
    },
  );
}
