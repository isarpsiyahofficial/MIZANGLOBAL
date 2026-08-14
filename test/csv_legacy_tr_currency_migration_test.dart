import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';

void main() {
  test(
    'legacy Turkish CSV snapshot freezes missing record currencies to persisted TRY exactly once',
    () {
      final legacyJson = <String, dynamic>{
        'schemaVersion': 13,
        'setupCompleted': true,
        'appLanguageTag': 'tr',
        'debtRegionCountryCode': 'TR',
        'defaultCurrencyCode': 'TRY',
        'recentCurrencyCodes': ['TRY'],
        'people': [
          {
            'id': 'legacy-person',
            'name': 'Eski kullanıcı',
            'banks': [
              {
                'id': 'legacy-bank',
                'userWrittenName': 'Eski banka',
                'products': [
                  {
                    'id': 'legacy-debt',
                    'kind': 'loan',
                    'title': 'Eski kredi',
                    'totalAmount': 1000,
                    'monthlyAmount': 100,
                    'dueDate': '2026-09-01T00:00:00.000',
                  },
                ],
              },
            ],
            'personalDebts': [
              {
                'id': 'legacy-personal',
                'creditorType': 'person',
                'title': 'Eski şahıs borcu',
                'creditorName': 'Alacaklı',
                'totalAmount': 500,
                'debtDate': '2026-01-01T00:00:00.000',
                'dueDate': '2026-10-01T00:00:00.000',
                'frequency': 'oneTime',
              },
            ],
            'bills': [
              {
                'id': 'legacy-bill',
                'kind': 'electricity',
                'institutionName': 'Elektrik',
                'amount': 75,
                'dueDate': '2026-08-20T00:00:00.000',
              },
            ],
            'subscriptions': [
              {
                'id': 'legacy-subscription',
                'kind': 'digitalService',
                'title': 'Eski abonelik',
                'providerName': 'Sağlayıcı',
                'amount': 25,
                'frequency': 'monthly',
                'nextDueDate': '2026-08-22T00:00:00.000',
              },
            ],
            'rents': [
              {
                'id': 'legacy-rent',
                'kind': 'homeRent',
                'title': 'Eski kira',
                'amount': 900,
                'paymentDay': 1,
                'receiverName': 'Ev sahibi',
                'dueDate': '2026-09-01T00:00:00.000',
              },
            ],
          },
        ],
        'expenseCategories': [
          {'id': 'legacy-category', 'name': 'Market', 'colorValue': 4278190080},
        ],
        'expenses': [
          {
            'id': 'legacy-expense',
            'categoryId': 'legacy-category',
            'name': 'Eski gider',
            'quantity': 1,
            'unitPrice': 50,
            'spentAt': '2026-08-07T00:00:00.000',
          },
        ],
        'incomes': [
          {
            'id': 'legacy-income',
            'title': 'Eski gelir',
            'amount': 3000,
            'frequency': 'monthly',
            'startDate': '2026-08-01T00:00:00.000',
          },
        ],
        'notificationSlots': const [],
        'paymentNotificationSlots': const [],
      };

      final csv = const ListToCsvConverter().convert([
        const [
          'format',
          'schema_version',
          'entity_type',
          'entity_id',
          'person_id',
          'bank_id',
          'record_type',
          'record_id',
          'name',
          'amount',
          'date',
          'data_json',
        ],
        [
          CsvBackupService.formatName,
          13,
          'snapshot',
          'state',
          '',
          '',
          '',
          '',
          'MİZAN tam yedek',
          '',
          '2026-08-07T12:00:00.000Z',
          jsonEncode(legacyJson),
        ],
      ]);

      const service = CsvBackupService();
      final imported = service.importState(csv);

      expect(imported.defaultCurrencyCode, 'TRY');
      expect(imported.allDebtProducts.single.currencyCode, 'TRY');
      expect(imported.allPersonalDebts.single.currencyCode, 'TRY');
      expect(imported.allBills.single.currencyCode, 'TRY');
      expect(imported.allSubscriptions.single.currencyCode, 'TRY');
      expect(imported.allRents.single.currencyCode, 'TRY');
      expect(imported.expenses.single.currencyCode, 'TRY');
      expect(imported.incomes.single.currencyCode, 'TRY');

      final changedDefault = imported.copyWith(defaultCurrencyCode: 'USD');
      expect(changedDefault.defaultCurrencyCode, 'USD');
      expect(changedDefault.allDebtProducts.single.currencyCode, 'TRY');
      expect(changedDefault.allDebtProducts.single.totalAmount, 1000);
      expect(changedDefault.allPersonalDebts.single.currencyCode, 'TRY');
      expect(changedDefault.allBills.single.currencyCode, 'TRY');
      expect(changedDefault.allSubscriptions.single.currencyCode, 'TRY');
      expect(changedDefault.allRents.single.currencyCode, 'TRY');
      expect(changedDefault.expenses.single.currencyCode, 'TRY');
      expect(changedDefault.expenses.single.unitPrice, 50);
      expect(changedDefault.incomes.single.currencyCode, 'TRY');
      expect(changedDefault.incomes.single.amount, 3000);

      final restoredAgain = service.importState(service.exportState(changedDefault));
      expect(restoredAgain.defaultCurrencyCode, 'USD');
      expect(restoredAgain.allDebtProducts.single.currencyCode, 'TRY');
      expect(restoredAgain.allPersonalDebts.single.currencyCode, 'TRY');
      expect(restoredAgain.allBills.single.currencyCode, 'TRY');
      expect(restoredAgain.allSubscriptions.single.currencyCode, 'TRY');
      expect(restoredAgain.allRents.single.currencyCode, 'TRY');
      expect(restoredAgain.expenses.single.currencyCode, 'TRY');
      expect(restoredAgain.incomes.single.currencyCode, 'TRY');
    },
  );
}
