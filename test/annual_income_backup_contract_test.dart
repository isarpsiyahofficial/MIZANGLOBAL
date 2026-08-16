import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

void main() {
  test(
    'annual income survives CSV round-trip and is counted only once per year',
    () {
      const backup = CsvBackupService();
      final source = MizanState(
        people: const [],
        expenseCategories: const [],
        expenses: const [],
        notificationSlots: const [],
        incomes: [
          IncomeEntry(
            id: 'annual-income',
            currencyCode: 'EUR',
            title: 'Annual bonus',
            amount: 12000,
            frequency: IncomeFrequency.yearly,
            startDate: DateTime(2026, 7, 31),
            note: 'user text stays user text',
          ),
        ],
        setupCompleted: true,
        appLanguageTag: 'en',
        debtRegionCountryCode: 'DE',
        defaultCurrencyCode: 'EUR',
        recentCurrencyCodes: const ['EUR', 'USD'],
      );

      final restored = backup.importState(backup.exportState(source));
      final income = restored.incomes.single;

      expect(income.frequency, IncomeFrequency.yearly);
      expect(income.currencyCode, 'EUR');
      expect(income.amount, 12000);
      expect(income.title, 'Annual bonus');
      expect(income.note, 'user text stays user text');
      expect(
        income.occurrenceCount(DateTime(2026, 1, 1), DateTime(2028, 12, 31)),
        3,
      );
      expect(
        income.totalForRange(DateTime(2027, 7, 1), DateTime(2027, 7, 31)),
        12000,
      );
      expect(
        income.totalForRange(DateTime(2027, 8, 1), DateTime(2027, 8, 31)),
        0,
      );

      final july = const MizanReportService().build(
        state: restored,
        filter: ReportFilter(
          period: ReportPeriod.monthly,
          anchorDate: DateTime(2027, 7, 1),
        ),
        now: DateTime(2027, 7, 31),
      );
      final august = const MizanReportService().build(
        state: restored,
        filter: ReportFilter(
          period: ReportPeriod.monthly,
          anchorDate: DateTime(2027, 8, 1),
        ),
        now: DateTime(2027, 8, 31),
      );
      expect(july.totalIncomeByCurrency, {'EUR': 12000});
      expect(august.totalIncomeByCurrency, isEmpty);

      final available = restored
          .availableReportMonths(DateTime(2028, 12, 31))
          .map((date) => '${date.year}-${date.month}')
          .toSet();
      expect(available, {'2026-7', '2027-7', '2028-7'});
    },
  );
}
