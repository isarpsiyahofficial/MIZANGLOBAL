import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';

MizanState _state(String suffix, String currency) => MizanState.fromJson({
      'schemaVersion': currentSchemaVersion,
      'setupCompleted': true,
      'appLanguageTag': 'en',
      'debtRegionCountryCode': 'US',
      'defaultCurrencyCode': 'USD',
      'recentCurrencyCodes': ['USD', 'EUR'],
      'people': [
        {
          'id': 'person-common',
          'name': 'Same Owner',
          'banks': [
            {
              'id': 'bank-common',
              'userWrittenName': 'Same Bank',
              'products': [
                {
                  'id': 'debt-$suffix',
                  'currencyCode': currency,
                  'kind': 'loan',
                  'title': 'Same Loan',
                  'totalAmount': 1000,
                  'monthlyAmount': 100,
                  'dueDate': '2026-09-01T00:00:00.000',
                },
              ],
            },
          ],
          'personalDebts': [
            {
              'id': 'personal-$suffix',
              'currencyCode': currency,
              'creditorType': 'person',
              'title': 'Same Personal Debt',
              'creditorName': 'Same Creditor',
              'totalAmount': 500,
              'debtDate': '2026-01-01T00:00:00.000',
              'dueDate': '2026-10-01T00:00:00.000',
              'frequency': 'oneTime',
            },
          ],
          'bills': [
            {
              'id': 'bill-$suffix',
              'currencyCode': currency,
              'kind': 'electricity',
              'institutionName': 'Same Utility',
              'amount': 75,
              'dueDate': '2026-08-20T00:00:00.000',
            },
          ],
          'subscriptions': [
            {
              'id': 'subscription-$suffix',
              'currencyCode': currency,
              'kind': 'digitalService',
              'title': 'Same Service',
              'providerName': 'Same Provider',
              'amount': 25,
              'frequency': 'monthly',
              'nextDueDate': '2026-08-22T00:00:00.000',
            },
          ],
          'rents': [
            {
              'id': 'rent-$suffix',
              'currencyCode': currency,
              'kind': 'homeRent',
              'title': 'Same Rent',
              'amount': 900,
              'paymentDay': 1,
              'receiverName': 'Same Landlord',
              'dueDate': '2026-09-01T00:00:00.000',
            },
          ],
        },
      ],
      'expenseCategories': [
        {
          'id': 'category-common',
          'name': 'Same Category',
          'colorValue': 4278190080
        },
      ],
      'expenses': [
        {
          'id': 'expense-$suffix',
          'currencyCode': currency,
          'categoryId': 'category-common',
          'name': 'Same Expense',
          'quantity': 1,
          'unitPrice': 10,
          'spentAt': '2026-08-07T00:00:00.000',
          'note': 'same',
        },
      ],
      'incomes': [
        {
          'id': 'income-$suffix',
          'currencyCode': currency,
          'title': 'Same Income',
          'amount': 3000,
          'frequency': 'monthly',
          'startDate': '2026-08-01T00:00:00.000',
          'note': 'same',
        },
      ],
      'notificationSlots': const [],
      'paymentNotificationSlots': const [],
    });

void main() {
  test(
      'CSV merge never deduplicates otherwise identical records across currencies',
      () {
    const service = CsvBackupService();
    final current = _state('usd', 'USD');
    final imported = _state('eur', 'EUR');

    final merged = service.mergeStates(current, imported).state;

    // The same persisted owner/bank identity intentionally merges its containers,
    // while money records remain separate because their own ISO currencies differ.
    expect(merged.people, hasLength(1));
    expect(merged.people.single.banks, hasLength(1));
    expect(merged.allDebtProducts, hasLength(2));
    expect(merged.allPersonalDebts, hasLength(2));
    expect(merged.allBills, hasLength(2));
    expect(merged.allSubscriptions, hasLength(2));
    expect(merged.allRents, hasLength(2));
    expect(merged.expenses, hasLength(2));
    expect(merged.incomes, hasLength(2));

    for (final codes in <Iterable<String>>[
      merged.allDebtProducts.map((item) => item.currencyCode),
      merged.allPersonalDebts.map((item) => item.currencyCode),
      merged.allBills.map((item) => item.currencyCode),
      merged.allSubscriptions.map((item) => item.currencyCode),
      merged.allRents.map((item) => item.currencyCode),
      merged.expenses.map((item) => item.currencyCode),
      merged.incomes.map((item) => item.currencyCode),
    ]) {
      expect(codes.toSet(), {'USD', 'EUR'});
    }
  });
}
