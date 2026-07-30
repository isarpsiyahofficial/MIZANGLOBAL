import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';

void main() {
  test('aylık gelir sabit günü üzerinden kalan ve geciken günü hesaplar', () {
    final income = IncomeEntry(
      id: 'salary',
      title: 'Maaş',
      amount: 30000,
      frequency: IncomeFrequency.monthly,
      startDate: DateTime(2026, 7, 1),
      scheduleTrackingEnabled: true,
      scheduledDayOfMonth: 5,
      trackingStartedAt: DateTime(2026, 7, 1),
    );

    expect(
      income.trackedOccurrenceAt(DateTime(2026, 7, 2)),
      DateTime(2026, 7, 5),
    );
    expect(income.daysUntilTrackedOccurrence(DateTime(2026, 7, 2)), 3);
    expect(income.daysUntilTrackedOccurrence(DateTime(2026, 7, 8)), -3);
  });

  test(
    'geç alınan maaş gerçek tarihi kaydeder ancak sabit günü değiştirmez',
    () {
      final income = IncomeEntry(
        id: 'salary',
        title: 'Maaş',
        amount: 30000,
        frequency: IncomeFrequency.monthly,
        startDate: DateTime(2026, 7, 1),
        scheduleTrackingEnabled: true,
        scheduledDayOfMonth: 5,
        trackingStartedAt: DateTime(2026, 7, 1),
        receipts: [
          IncomeReceipt(
            id: 'receipt-july',
            scheduledDate: DateTime(2026, 7, 5),
            receivedDate: DateTime(2026, 7, 9),
          ),
        ],
      );

      expect(income.effectiveScheduledDayOfMonth, 5);
      expect(income.latestReceipt?.receivedDate, DateTime(2026, 7, 9));
      expect(income.latestReceipt?.scheduledDate, DateTime(2026, 7, 5));
      expect(
        income.trackedOccurrenceAt(DateTime(2026, 7, 9)),
        DateTime(2026, 8, 5),
      );
    },
  );

  test('haftalık gelir seçilen hafta gününü korur', () {
    final income = IncomeEntry(
      id: 'weekly',
      title: 'Haftalık gelir',
      amount: 2000,
      frequency: IncomeFrequency.weekly,
      startDate: DateTime(2026, 7, 1),
      scheduleTrackingEnabled: true,
      scheduledWeekday: DateTime.friday,
      trackingStartedAt: DateTime(2026, 7, 1),
      receipts: [
        IncomeReceipt(
          id: 'first',
          scheduledDate: DateTime(2026, 7, 3),
          receivedDate: DateTime(2026, 7, 6),
        ),
      ],
    );

    expect(income.effectiveScheduledWeekday, DateTime.friday);
    expect(
      income.trackedOccurrenceAt(DateTime(2026, 7, 6)),
      DateTime(2026, 7, 10),
    );
  });

  test('ayın 31i kısa aylarda son geçerli güne düşer, seçim değişmez', () {
    final income = IncomeEntry(
      id: 'month-end',
      title: 'Ay sonu gelir',
      amount: 1000,
      frequency: IncomeFrequency.monthly,
      startDate: DateTime(2027, 2, 1),
      scheduleTrackingEnabled: true,
      scheduledDayOfMonth: 31,
      trackingStartedAt: DateTime(2027, 2, 1),
    );

    expect(
      income.trackedOccurrenceAt(DateTime(2027, 2, 1)),
      DateTime(2027, 2, 28),
    );
    expect(income.effectiveScheduledDayOfMonth, 31);
  });

  test('CSV birleştirme gelir alınma geçmişini çoğaltmadan korur', () {
    const service = CsvBackupService();
    final currentIncome = IncomeEntry(
      id: 'salary',
      title: 'Maaş',
      amount: 30000,
      frequency: IncomeFrequency.monthly,
      startDate: DateTime(2026, 7, 1),
      scheduleTrackingEnabled: true,
      scheduledDayOfMonth: 5,
      trackingStartedAt: DateTime(2026, 7, 1),
      receipts: [
        IncomeReceipt(
          id: 'july',
          scheduledDate: DateTime(2026, 7, 5),
          receivedDate: DateTime(2026, 7, 9),
        ),
      ],
    );
    final importedIncome = currentIncome.copyWith(
      receipts: [
        ...currentIncome.receipts,
        IncomeReceipt(
          id: 'august',
          scheduledDate: DateTime(2026, 8, 5),
          receivedDate: DateTime(2026, 8, 6),
        ),
      ],
    );
    final current = MizanState.empty().copyWith(incomes: [currentIncome]);
    final imported = MizanState.empty().copyWith(incomes: [importedIncome]);

    final merged = service.mergeStates(current, imported).state;
    expect(merged.incomes.single.receipts, hasLength(2));
    expect(merged.incomes.single.effectiveScheduledDayOfMonth, 5);
  });
}
