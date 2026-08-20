import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';

Map<String, dynamic> _stateJson({required bool explicitCurrencies}) =>
    <String, dynamic>{
      'schemaVersion': 13,
      'setupCompleted': true,
      'appLanguageTag': 'en',
      'debtRegionCountryCode': 'US',
      'defaultCurrencyCode': 'USD',
      'recentCurrencyCodes': ['USD', 'EUR', 'JPY'],
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
                  'id': 'debt1',
                  if (explicitCurrencies) 'currencyCode': 'EUR',
                  'kind': 'loan',
                  'title': 'Loan',
                  'totalAmount': 1000,
                  'monthlyAmount': 100,
                  'dueDate': '2026-09-01T00:00:00.000',
                },
              ],
            },
          ],
          'personalDebts': [
            {
              'id': 'personal1',
              if (explicitCurrencies) 'currencyCode': 'GBP',
              'creditorType': 'person',
              'title': 'Personal',
              'creditorName': 'Creditor',
              'totalAmount': 500,
              'debtDate': '2026-01-01T00:00:00.000',
              'dueDate': '2026-10-01T00:00:00.000',
            },
          ],
          'bills': [
            {
              'id': 'bill1',
              if (explicitCurrencies) 'currencyCode': 'CHF',
              'kind': 'electricity',
              'institutionName': 'Utility',
              'amount': 75,
              'dueDate': '2026-08-20T00:00:00.000',
            },
          ],
          'subscriptions': [
            {
              'id': 'sub1',
              if (explicitCurrencies) 'currencyCode': 'JPY',
              'kind': 'digitalService',
              'title': 'Service',
              'providerName': 'Provider',
              'amount': 1200,
              'frequency': 'monthly',
              'nextDueDate': '2026-08-22T00:00:00.000',
            },
          ],
          'rents': [
            {
              'id': 'rent1',
              if (explicitCurrencies) 'currencyCode': 'TRY',
              'kind': 'homeRent',
              'title': 'Rent',
              'amount': 20000,
              'paymentDay': 1,
              'receiverName': 'Landlord',
              'dueDate': '2026-09-01T00:00:00.000',
            },
          ],
        },
      ],
      'expenseCategories': [
        {'id': 'cat1', 'name': 'Food', 'colorValue': 4278190080},
      ],
      'expenses': [
        {
          'id': 'expense1',
          if (explicitCurrencies) 'currencyCode': 'AED',
          'categoryId': 'cat1',
          'name': 'Dinner',
          'quantity': 1,
          'unitPrice': 250,
          'spentAt': '2026-08-07T00:00:00.000',
        },
      ],
      'incomes': [
        {
          'id': 'income1',
          if (explicitCurrencies) 'currencyCode': 'CAD',
          'title': 'Salary',
          'amount': 3000,
          'frequency': 'monthly',
          'startDate': '2026-08-01T00:00:00.000',
        },
      ],
      'notificationSlots': const [],
    };

void main() {
  test(
    'legacy globalization-era records without per-record currency freeze to persisted default once',
    () {
      final state = MizanState.fromJson(_stateJson(explicitCurrencies: false));
      expect(state.defaultCurrencyCode, 'USD');
      expect(state.hasCompleteRecordCurrencies, isTrue);
      expect(state.allDebtProducts.single.currencyCode, 'USD');
      expect(state.allPersonalDebts.single.currencyCode, 'USD');
      expect(state.allBills.single.currencyCode, 'USD');
      expect(state.allSubscriptions.single.currencyCode, 'USD');
      expect(state.allRents.single.currencyCode, 'USD');
      expect(state.expenses.single.currencyCode, 'USD');
      expect(state.incomes.single.currencyCode, 'USD');
    },
  );

  test(
    'modern records preserve independent ISO currencies through JSON round trip',
    () {
      final original = MizanState.fromJson(
        _stateJson(explicitCurrencies: true),
      );
      expect(original.allDebtProducts.single.currencyCode, 'EUR');
      expect(original.allPersonalDebts.single.currencyCode, 'GBP');
      expect(original.allBills.single.currencyCode, 'CHF');
      expect(original.allSubscriptions.single.currencyCode, 'JPY');
      expect(original.allRents.single.currencyCode, 'TRY');
      expect(original.expenses.single.currencyCode, 'AED');
      expect(original.incomes.single.currencyCode, 'CAD');

      final restored = MizanState.fromJson(original.toJson());
      expect(restored.allDebtProducts.single.currencyCode, 'EUR');
      expect(restored.allPersonalDebts.single.currencyCode, 'GBP');
      expect(restored.allBills.single.currencyCode, 'CHF');
      expect(restored.allSubscriptions.single.currencyCode, 'JPY');
      expect(restored.allRents.single.currencyCode, 'TRY');
      expect(restored.expenses.single.currencyCode, 'AED');
      expect(restored.incomes.single.currencyCode, 'CAD');
    },
  );

  test(
    'changing main default currency never rewrites historical record currencies or amounts',
    () {
      final state = MizanState.fromJson(_stateJson(explicitCurrencies: true));
      final before = state.toJson();
      final changed = state.copyWith(defaultCurrencyCode: 'NZD');
      expect(changed.defaultCurrencyCode, 'NZD');
      expect(changed.allDebtProducts.single.currencyCode, 'EUR');
      expect(changed.allDebtProducts.single.totalAmount, 1000);
      expect(changed.allPersonalDebts.single.currencyCode, 'GBP');
      expect(changed.allBills.single.currencyCode, 'CHF');
      expect(changed.allSubscriptions.single.currencyCode, 'JPY');
      expect(changed.allRents.single.currencyCode, 'TRY');
      expect(changed.expenses.single.currencyCode, 'AED');
      expect(changed.expenses.single.unitPrice, 250);
      expect(changed.incomes.single.currencyCode, 'CAD');
      expect(changed.incomes.single.amount, 3000);
      expect(before['people'], changed.toJson()['people']);
      expect(before['expenses'], changed.toJson()['expenses']);
      expect(before['incomes'], changed.toJson()['incomes']);
    },
  );

  test('remaining totals stay in separate currency buckets', () {
    final state = MizanState.fromJson(_stateJson(explicitCurrencies: true));
    final totals = state.recordRemainingTotalsByCurrency();
    expect(
      totals.keys,
      containsAll(<String>['EUR', 'GBP', 'CHF', 'JPY', 'TRY']),
    );
    expect(totals['EUR'], 1000);
    expect(totals['GBP'], 500);
    expect(totals.length, 5);
  });
}
