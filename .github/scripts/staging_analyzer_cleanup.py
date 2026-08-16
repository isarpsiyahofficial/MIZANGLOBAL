from pathlib import Path
import re

settings = Path('lib/screens/settings_screen.dart')
s = settings.read_text()
s = s.replace("import '../core/formatters.dart';\n", '')
s = s.replace("import '../models/mizan_models.dart';\n", '')
s, count = re.subn(
    r"\n  static String\? _requiredValidator\(String\? value\) =>\n      value == null \|\| value\.trim\(\)\.isEmpty \? 'Bu alan boş bırakılamaz\.' : null;\n",
    "\n",
    s,
    count=1,
)
if count != 1:
    raise SystemExit('settings required validator cleanup did not match exactly once')
# Keep color customization real instead of leaving an unused optional parameter.
needle = """                const _InfoPanel(\n                  icon: Icons.shield_outlined,\n                  title: 'Profil kayıtları korunur',\n"""
replacement = """                const _InfoPanel(\n                  icon: Icons.shield_outlined,\n                  color: MizanTheme.green,\n                  title: 'Profil kayıtları korunur',\n"""
if needle not in s:
    raise SystemExit('settings info panel insertion point missing')
s = s.replace(needle, replacement, 1)
settings.write_text(s)

controller = Path('test/controller_test.dart')
s = controller.read_text()
s, count = re.subn(
    r"\n      await controller\.setPaymentReminderFrequency\(\n        PaymentReminderFrequency\.threeTimesDaily,\n      \);\n      await controller\.setNotificationSoundMode\(NotificationSoundMode\.silent\);",
    "",
    s,
    count=1,
)
if count != 1:
    raise SystemExit('controller stale notification setters did not match exactly once')
s, count1 = re.subn(
    r"\n      expect\(\n        controller\.state\.paymentReminderFrequency,\n        PaymentReminderFrequency\.threeTimesDaily,\n      \);",
    "",
    s,
    count=1,
)
s, count2 = re.subn(
    r"\n      expect\(\n        controller\.state\.notificationSoundMode,\n        NotificationSoundMode\.silent,\n      \);",
    "",
    s,
    count=1,
)
if (count1, count2) != (1, 1):
    raise SystemExit('controller stale notification expectations did not match')
s = s.replace('expect(store.saveCount, greaterThanOrEqualTo(3));', 'expect(store.saveCount, greaterThanOrEqualTo(1));', 1)
s = s.replace(
    "'ödeme türü ve bildirim tercihleri güvenli biçimde kaydedilir'",
    "'ödeme türü bildirim motoru olmadan güvenli biçimde kaydedilir'",
    1,
)
controller.write_text(s)

perf = Path('test/notification_performance_report_final_test.dart')
s = perf.read_text()
pattern = re.compile(
    r"\n  test\('500 kayıtlı bildirim planı kararlı ve sınırlıdır', \(\) \{.*?\n  \}\);\n\}",
    re.S,
)
replacement = """
  test('500 borç kaydı bildirim planı üretmeden raporlanabilir', () {
    final now = DateTime(2026, 7, 20, 8);
    final state = MizanState.empty().copyWith(
      people: [
        PersonAccount(
          id: 'p',
          name: 'Kişi',
          banks: [
            BankGroup(
              id: 'b',
              userWrittenName: 'Banka',
              products: [
                for (var index = 0; index < 500; index++)
                  DebtProduct(
                    id: 'd-$index',
                    kind: DebtKind.creditCard,
                    title: 'Kart $index',
                    totalAmount: 1000,
                    monthlyAmount: 100,
                    dueDate: DateTime(2026, 7, 25),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
    final stopwatch = Stopwatch()..start();
    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );
    stopwatch.stop();

    expect(report.remainingDetails.length, 500);
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
  });
}
"""
s, count = pattern.subn(replacement, s, count=1)
if count != 1:
    raise SystemExit('notification performance stale planner test did not match exactly once')
perf.write_text(s)

# Upgrade the deep UI leakage guard from Turkish-only to every other supported
# language. A value that is legitimately identical in two languages is skipped;
# otherwise an exact foreign system label must never be visible in the active UI.
deep = Path('test/all_29_language_deep_surface_test.dart')
s = deep.read_text()
start = s.find('void _expectNoForeignSystemLeak(WidgetTester tester, _LocaleCase locale) {')
end = s.find('\nFuture<void> _visitEveryPrimaryScreen', start)
if start < 0 or end < 0:
    raise SystemExit('deep-surface foreign-language helper boundaries not found')
replacement = r"""const _foreignLeakSources = <String>[
  'Ana sayfa',
  'Kayıtlar',
  'Giderler',
  'Raporlar',
  'Ayarlar',
  'Faturalar',
  'Uygula',
  'Kaydet',
  'Vazgeç',
  'Toplam borç',
  'Aylık tutar',
  'Son ödeme tarihi',
  'Varsayılan para birimi',
  'Gider adı',
  'Birim fiyat',
  'Kişi ekle',
  'Kişi adı',
  'Banka grubu ekle',
  'Banka adı',
  'Borç ürünü ekle',
  'Borç türü',
  'Kişisel / kurumsal borç ekle',
  'Fatura ekle',
  'Abonelik ekle',
  'Kira / taksit ekle',
  'Ödeme ekle',
  'PDF raporu',
  'Para birimi',
];

void _expectNoForeignSystemLeak(WidgetTester tester, _LocaleCase locale) {
  final visible = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
      .where((value) => value.trim().isNotEmpty)
      .toSet();

  for (final foreign in _localeCases) {
    if (foreign.tag == locale.tag) continue;
    for (final source in _foreignLeakSources) {
      final activeCopy = MizanI18n.text(source, languageTag: locale.tag);
      final foreignCopy = MizanI18n.text(source, languageTag: foreign.tag);
      if (foreignCopy.trim().isEmpty || foreignCopy == activeCopy) continue;
      expect(
        visible,
        isNot(contains(foreignCopy)),
        reason:
            '${locale.tag}: foreign ${foreign.tag} system copy leaked for "$source": "$foreignCopy"',
      );
    }
  }

  expect(
    find.text(MizanI18n.text('Bildirim sistemi')),
    findsNothing,
    reason: '${locale.tag}: removed notification UI returned',
  );
}
"""
s = s[:start] + replacement + s[end:]
deep.write_text(s)

# Add an independent 29 x 28 runtime isolation contract over every one of the
# 791 stable system keys. This catches stale previous-language state and broad
# catalog shadowing between any pair, not merely Turkish fallback.
pairwise = Path('test/all_29_pairwise_language_isolation_test.dart')
pairwise.write_text(r"""import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_es.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

const _tags = <String>[
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

Map<String, String> _explicitSnapshot(String tag) => <String, String>{
  for (final source in mizanSpanish.keys)
    source: MizanI18n.text(source, languageTag: tag),
};

Map<String, String> _activeSnapshot() => <String, String>{
  for (final source in mizanSpanish.keys) source: MizanI18n.text(source),
};

void main() {
  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('29 language catalogs expose all 791 stable system keys independently', () {
    expect(_tags.length, 29);
    expect(MizanI18n.supportedLanguageTags.length, 29);
    expect(MizanI18n.supportedLanguageTags, containsAll(_tags));
    expect(mizanSpanish.length, 791);

    final snapshots = <String, Map<String, String>>{};
    for (final tag in _tags) {
      final snapshot = _explicitSnapshot(tag);
      expect(snapshot.length, 791, reason: tag);
      expect(
        snapshot.values.every((value) => value.trim().isNotEmpty),
        isTrue,
        reason: '$tag has an empty static system value',
      );
      snapshots[tag] = snapshot;
    }

    var directions = 0;
    for (final active in _tags) {
      for (final foreign in _tags) {
        if (active == foreign) continue;
        directions++;
        final activeSnapshot = snapshots[active]!;
        final foreignSnapshot = snapshots[foreign]!;
        final differingKeys = mizanSpanish.keys
            .where((source) => activeSnapshot[source] != foreignSnapshot[source])
            .length;
        expect(
          differingKeys,
          greaterThanOrEqualTo(25),
          reason:
              '$active is suspiciously shadowed by $foreign: only $differingKeys / 791 system keys differ',
        );
      }
    }
    expect(directions, 29 * 28);
  });

  test('29 x 28 ordered language switches never retain any foreign snapshot', () {
    final snapshots = <String, Map<String, String>>{
      for (final tag in _tags) tag: _explicitSnapshot(tag),
    };

    var directions = 0;
    for (final active in _tags) {
      for (final foreign in _tags) {
        if (active == foreign) continue;
        directions++;

        MizanI18n.setProfile(languageTag: foreign, currencyCode: 'USD');
        // Materialize the entire foreign catalog first so a stale cache/state bug
        // cannot hide behind a single probe string.
        final foreignActive = _activeSnapshot();
        expect(foreignActive, equals(snapshots[foreign]), reason: foreign);

        MizanI18n.setProfile(languageTag: active, currencyCode: 'USD');
        final restoredActive = _activeSnapshot();
        expect(
          restoredActive,
          equals(snapshots[active]),
          reason: '$foreign -> $active retained foreign system copy',
        );
        expect(
          restoredActive,
          isNot(equals(snapshots[foreign])),
          reason: '$foreign -> $active collapsed to the foreign snapshot',
        );
      }
    }
    expect(directions, 29 * 28);
  });

  test('script-exclusive language families never contaminate other catalogs', () {
    final rules = <({String name, RegExp script, Set<String> allowed})>[
      (
        name: 'Greek',
        script: RegExp(r'[\u0370-\u03ff]'),
        allowed: const {'el'},
      ),
      (
        name: 'Cyrillic',
        script: RegExp(r'[\u0400-\u04ff]'),
        allowed: const {'ru', 'uk'},
      ),
      (
        name: 'Arabic-derived',
        script: RegExp(r'[\u0600-\u06ff]'),
        allowed: const {'ar', 'fa', 'ur'},
      ),
      (
        name: 'Hebrew',
        script: RegExp(r'[\u0590-\u05ff]'),
        allowed: const {'he'},
      ),
      (
        name: 'Devanagari',
        script: RegExp(r'[\u0900-\u097f]'),
        allowed: const {'hi'},
      ),
      (
        name: 'Bengali',
        script: RegExp(r'[\u0980-\u09ff]'),
        allowed: const {'bn'},
      ),
      (
        name: 'Thai',
        script: RegExp(r'[\u0e00-\u0e7f]'),
        allowed: const {'th'},
      ),
      (
        name: 'Hangul',
        script: RegExp(r'[\uac00-\ud7af]'),
        allowed: const {'ko'},
      ),
      (
        name: 'Japanese kana',
        script: RegExp(r'[\u3040-\u30ff]'),
        allowed: const {'ja'},
      ),
    ];

    for (final tag in _tags) {
      final joined = _explicitSnapshot(tag).values.join('\n');
      for (final rule in rules) {
        if (rule.allowed.contains(tag)) {
          expect(
            rule.script.hasMatch(joined),
            isTrue,
            reason: '$tag is missing its ${rule.name} script signature',
          );
        } else {
          expect(
            rule.script.hasMatch(joined),
            isFalse,
            reason: '$tag contains foreign ${rule.name} system copy',
          );
        }
      }
    }
  });
}
""")
