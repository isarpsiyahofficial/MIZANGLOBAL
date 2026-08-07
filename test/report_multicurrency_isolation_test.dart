import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

void main() {
  test('report preserves independent currency buckets without conversion', () {
    final now = DateTime(2026, 8, 7);
    final state = MizanState.fromJson({
      'schemaVersion': 14,
      'setupCompleted': true,
      'appLanguageTag': 'en',
      'debtRegionCountryCode': 'US',
      'defaultCurrencyCode': 'USD',
      'people': [
        {
          'id': 'p1',
          'name': 'Owner',
          'banks': [
            {
              'id': 'b1',
              'userWrittenName': 'Bank',
              'products': [
                {
                  'id': 'd1',
                  'currencyCode': 'EUR',
                  'kind': 'loan',
                  'title': 'Euro loan',
                  'totalAmount': 1000,
                  'monthlyAmount': 100,
                  'dueDate': '2026-08-20T00:00:00.000',
                  'payments': [
                    {
                      'id': 'pay1',
                      'amount': 40,
                      'paidAt': '2026-08-07T00:00:00.000',
                    },
                  ],
                },
              ],
            },
          ],
          'personalDebts': [],
          'bills': [],
          'subscriptions': [],
          'rents': [
            {
              'id': 'r1',
              'currencyCode': 'TRY',
              'kind': 'homeRent',
              'title': 'Rent',
              'amount': 20000,
              'paymentDay': 20,
              'receiverName': 'Owner',
              'dueDate': '2026-08-20T00:00:00.000',
            },
          ],
        },
      ],
      'expenseCategories': [
        {'id': 'c1', 'name': 'Food', 'colorValue': 4278190080},
      ],
      'expenses': [
        {
          'id': 'e1',
          'currencyCode': 'AED',
          'categoryId': 'c1',
          'name': 'Meal',
          'quantity': 1,
          'unitPrice': 50,
          'spentAt': '2026-08-07T00:00:00.000',
        },
      ],
      'incomes': [
        {
          'id': 'i1',
          'currencyCode': 'CAD',
          'title': 'Salary',
          'amount': 3000,
          'frequency': 'monthly',
          'startDate': '2026-08-01T00:00:00.000',
        },
      ],
      'notificationSlots': [],
      'paymentNotificationSlots': [],
    });

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.totalIncomeByCurrency['CAD'], 3000);
    expect(report.totalExpensesByCurrency['AED'], 50);
    expect(report.totalPaymentsByCurrency['EUR'], 40);
    expect(report.remainingLoadByCurrency.keys, containsAll(<String>['EUR', 'TRY']));
    expect(report.paymentDetails.single.currencyCode, 'EUR');
    expect(
      report.remainingDetails.every((record) => record.currencyCode.isNotEmpty),
      isTrue,
    );
    expect(report.realizedGrandTotalsByCurrency['AED'], 50);
    expect(report.realizedGrandTotalsByCurrency['EUR'], 40);
    expect(report.realizedGrandTotalsByCurrency.containsKey('USD'), isFalse);
  });
}
