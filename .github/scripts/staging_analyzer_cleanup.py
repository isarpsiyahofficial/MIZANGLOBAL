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

    expect(report.items.length, 500);
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
  });
}
"""
s, count = pattern.subn(replacement, s, count=1)
if count != 1:
    raise SystemExit('notification performance stale planner test did not match exactly once')
perf.write_text(s)
