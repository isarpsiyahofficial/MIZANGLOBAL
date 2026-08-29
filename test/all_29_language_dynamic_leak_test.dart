import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

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

  const dynamicSystemCopy = <String>[
    'MİZAN 08/2026 Raporu',
    '08/2026 finans raporu',
    'LEFFERION PRIME - MİZAN · Sayfa 3',
    'Gider ayrıntıları · devam',
    'Dönem: 08/2026',
    'Kişi kapsamı: Tüm kişiler',
    'Oluşturulma: 29/08/2026 · 12:30',
    'Açık plan TRY 120 · Bu ay yapılan TRY 80',
    '08/2026 Ödeme Durumu',
    '3 açık kayıt · TRY 120',
    '4 günlük harcama · 3 ödeme',
    '3 gün · 9 kayıt · TRY 200',
    '7 ödeme · TRY 200',
    '3 gider · TRY 200',
    '3 gider kaydı',
    'Daha fazla gün göster (4 kaldı)',
    'Daha fazla ödeme günü göster (4 kaldı)',
    'Daha fazla gider günü göster (4 kaldı)',
    'Bu günden daha fazla göster (4 kaldı)',
    'Rent için 2 gün kaldı',
    'Salary bugün bekleniyor',
    'Rent 3 gün gecikti',
    'Son alındı: 20/08/2026 · Planlanan 18/08/2026',
    'Planlanan 08/2026 dönemi, 20/08/2026 tarihinde alındı olarak kaydedildi. Sabit yatış günü değişmedi.',
    '08/2026 gerçek fatura tutarı',
    'Kalan tutar: TRY 200',
    'Kalan taksit: 4',
    'Sample gider kaydı silinsin mi?',
    'PDF raporu kaydedilemedi: disk full',
    'PDF raporu paylaşılamadı: share failed',
    '2 yeni, 1 ilişki güncellendi.',
    '2 kayıt kimliği geçersiz veya tekrarlı.',
    '3 gün kaldı',
    '3 gün gecikmede',
    'Ödeme 5 gün gecikti.',
    'Son ödeme 30/08/2026.',
    'Ayın 3. günü',
    'Her ayın 3. günü',
    'Başlangıç: 29/08/2026',
    'Toplam TRY 200',
    'Bu dönem TRY 200',
    'Tarih: 29/08/2026',
    'Not: customer note',
    'Kişi adı boş bırakılamaz.',
    'Kişi adı en fazla 80 karakter olabilir.',
    'Tutar sıfırdan büyük olmalı.',
    'Birim fiyat negatif olamaz.',
    '4 kayıt',
    '4 ödeme',
    '4 gider',
    '29/08/2026 · 4 kayıt',
    '4 ay',
    '4 kişi seçili',
    '2 yeni kayıt eklendi; mevcut veriler korundu.',
  ];

  final targetScripts = <String, RegExp>{
    'el': RegExp(r'[\u0370-\u03FF\u1F00-\u1FFF]'),
    'ru': RegExp(r'[\u0400-\u052F]'),
    'uk': RegExp(r'[\u0400-\u052F]'),
    'ar': RegExp(r'[\u0600-\u06FF\u0750-\u077F]'),
    'fa': RegExp(r'[\u0600-\u06FF\u0750-\u077F]'),
    'he': RegExp(r'[\u0590-\u05FF]'),
    'hi': RegExp(r'[\u0900-\u097F]'),
    'bn': RegExp(r'[\u0980-\u09FF]'),
    'ur': RegExp(r'[\u0600-\u06FF\u0750-\u077F]'),
    'th': RegExp(r'[\u0E00-\u0E7F]'),
    'zh': RegExp(r'[\u3400-\u4DBF\u4E00-\u9FFF]'),
    'ja': RegExp(r'[\u3040-\u30FF\u3400-\u4DBF\u4E00-\u9FFF]'),
    'ko': RegExp(r'[\u1100-\u11FF\uAC00-\uD7AF]'),
  };

  final turkishSystemFragments = <RegExp>[
    RegExp(r'(?<![\p{L}\p{M}])gün(?![\p{L}\p{M}])', unicode: true),
    RegExp(r'(?<![\p{L}\p{M}])kayıt(?![\p{L}\p{M}])', unicode: true),
    RegExp(r'(?<![\p{L}\p{M}])ödeme(?![\p{L}\p{M}])', unicode: true),
    RegExp(r'(?<![\p{L}\p{M}])gider(?![\p{L}\p{M}])', unicode: true),
    RegExp(r'(?<![\p{L}\p{M}])kaldı(?![\p{L}\p{M}])', unicode: true),
    RegExp(r'Daha fazla', caseSensitive: false),
    RegExp(r'kişi seçili', caseSensitive: false),
    RegExp(r'mevcut veriler', caseSensitive: false),
    RegExp(r'finans raporu', caseSensitive: false),
    RegExp(r'(?<![\p{L}\p{M}])Sayfa(?![\p{L}\p{M}])', unicode: true),
    RegExp(r'(?<![\p{L}\p{M}])devam(?![\p{L}\p{M}])', unicode: true),
    RegExp(r'(?<![\p{L}\p{M}])Dönem(?![\p{L}\p{M}])', unicode: true),
    RegExp(r'Kişi kapsamı', caseSensitive: false),
    RegExp(r'(?<![\p{L}\p{M}])Oluşturulma(?![\p{L}\p{M}])', unicode: true),
    RegExp(r'Açık plan', caseSensitive: false),
    RegExp(r'Bu ay yapılan', caseSensitive: false),
    RegExp(r'Ödeme Durumu', caseSensitive: false),
    RegExp(r'(?<![\p{L}\p{M}])Başlangıç(?![\p{L}\p{M}])', unicode: true),
    RegExp(r'boş bırakılamaz', caseSensitive: false),
    RegExp(r'en fazla', caseSensitive: false),
    RegExp(r'sıfırdan', caseSensitive: false),
    RegExp(r'negatif olamaz', caseSensitive: false),
  ];

  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));

  test('all 29 languages isolate the complete dynamic system-copy corpus', () {
    expect(tags, hasLength(29));
    expect(dynamicSystemCopy.length, greaterThanOrEqualTo(50));

    for (final tag in tags) {
      for (final source in dynamicSystemCopy) {
        final rendered = MizanI18n.text(source, languageTag: tag);
        expect(rendered.trim(), isNotEmpty, reason: '$tag/$source');
        if (tag == 'tr') {
          expect(rendered, source, reason: '$tag/$source');
          continue;
        }
        expect(
          rendered,
          isNot(source),
          reason: '$tag source fallback: $source',
        );
        for (final fragment in turkishSystemFragments) {
          expect(
            fragment.hasMatch(rendered),
            isFalse,
            reason: '$tag retained ${fragment.pattern}: $source => $rendered',
          );
        }
        final targetScript = targetScripts[tag];
        if (targetScript != null) {
          expect(
            targetScript.hasMatch(rendered),
            isTrue,
            reason: '$tag target script missing: $source => $rendered',
          );
        }
      }
    }
  });

  test('reviewed long Malay dynamic copy is not Indonesian copy', () {
    const samples = <String>[
      '08/2026 finans raporu',
      'Dönem: 08/2026',
      'Kişi kapsamı: Tüm kişiler',
      'Açık plan MYR 120 · Bu ay yapılan MYR 80',
      '4 günlük harcama · 3 ödeme',
      '3 gün · 9 kayıt · MYR 200',
      'Daha fazla gider günü göster (4 kaldı)',
      'Son alındı: 20/08/2026 · Planlanan 18/08/2026',
      '2 yeni kayıt eklendi; mevcut veriler korundu.',
    ];
    for (final source in samples) {
      final indonesian = MizanI18n.text(source, languageTag: 'id');
      final malay = MizanI18n.text(source, languageTag: 'ms');
      expect(malay, isNot(indonesian), reason: source);
    }
  });
}
