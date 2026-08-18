import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';

import 'test_support.dart';

void main() {
  test('CSV dışa ve içe aktarma tam state ilişkisini korur', () {
    const service = CsvBackupService();
    final state = comprehensiveState();
    final csv = service.exportState(state);
    final restored = service.importState(csv);

    expect(restored.toJson(), state.toJson());
    expect(csv, contains('bank_debt'));
    expect(csv, contains('personal_corporate_debt'));
    expect(csv, contains('subscription'));
    expect(csv, contains('rent_installment'));
    expect(csv, contains('expense'));
  });

  test('CSV birleştirme mevcut kayıtları silmez ve ortak veriyi çoğaltmaz', () {
    const service = CsvBackupService();
    final current = comprehensiveState(reference: DateTime(2026, 7, 19));
    final person = current.people.single;
    final imported = current.copyWith(
      people: [
        person.copyWith(
          bills: [
            ...person.bills,
            BillEntry(
              id: 'bill-new',
              kind: BillKind.water,
              institutionName: 'Su kurumu',
              amount: 320,
              dueDate: DateTime(2026, 8, 5),
            ),
          ],
        ),
        const PersonAccount(id: 'person-new', name: 'Yeni kişi'),
      ],
      incomes: [
        IncomeEntry(
          id: 'income-new',
          title: 'Ek gelir',
          amount: 2500,
          frequency: IncomeFrequency.oneTime,
          startDate: DateTime(2026, 7, 20),
        ),
      ],
      notificationSoundMode: NotificationSoundMode.silent,
    );

    final result = service.mergeStates(current, imported);
    final merged = result.state;

    expect(merged.people, hasLength(2));
    expect(
      merged.people.firstWhere((item) => item.id == person.id).bills,
      hasLength(2),
    );
    expect(
      merged.people
          .firstWhere((item) => item.id == person.id)
          .banks
          .single
          .products
          .single
          .payments,
      hasLength(1),
      reason: 'Ortak ödeme ikinci kez yazılmamalı.',
    );
    expect(merged.incomes.single.id, 'income-new');
    expect(
      merged.notificationSoundMode,
      current.notificationSoundMode,
      reason: 'Mevcut cihaz bildirim tercihi yedek tarafından ezilmemeli.',
    );
    expect(result.addedCount, greaterThanOrEqualTo(3));
    expect(result.duplicateCount, greaterThan(0));
  });

  test(
    'boş uygulamaya yedek yüklenirken varsayılan ayarlar ortak kullanıcı kaydı sayılmaz',
    () {
      const service = CsvBackupService();
      final imported = MizanState.empty().copyWith(
        people: [
          PersonAccount(
            id: 'backup-person',
            name: 'Yedek kişi',
            banks: [
              BankGroup(
                id: 'backup-bank',
                userWrittenName: 'Kullanıcı bankası',
                products: [
                  DebtProduct(
                    id: 'backup-debt',
                    kind: DebtKind.loan,
                    title: 'Yedek kredi',
                    totalAmount: 12000,
                    monthlyAmount: 1000,
                    dueDate: DateTime(2026, 7, 5),
                    dueMode: DebtDueMode.monthlyDay,
                    dueDayOfMonth: 5,
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final restored = service.importState(service.exportState(imported));
      final result = service.mergeStates(MizanState.empty(), restored);

      expect(result.state.people, hasLength(1));
      expect(result.state.people.single.banks.single.products, hasLength(1));
      expect(
        result.duplicateCount,
        0,
        reason:
            'Varsayılan kategori ve bildirim saatleri ortak kullanıcı kaydı değildir.',
      );
    },
  );

  test('aynı isimli farklı kimlikler birbirine karıştırılmaz', () {
    const service = CsvBackupService();
    final current = MizanState.empty().copyWith(
      people: const [PersonAccount(id: 'current-person', name: 'İbrahim')],
    );
    final imported = MizanState.empty().copyWith(
      people: [
        PersonAccount(
          id: 'backup-person',
          name: '  İBRAHİM ',
          bills: [
            BillEntry(
              id: 'backup-bill',
              kind: BillKind.internet,
              institutionName: 'İnternet',
              amount: 500,
              dueDate: DateTime(2026, 8, 10),
            ),
          ],
        ),
      ],
    );

    final merged = service.mergeStates(current, imported).state;
    expect(merged.people, hasLength(2));
    expect(
      merged.people.firstWhere((item) => item.id == 'current-person').bills,
      isEmpty,
    );
    expect(
      merged.people
          .firstWhere((item) => item.id == 'backup-person')
          .bills
          .single
          .id,
      'backup-bill',
    );
  });

  test('boş kategori listesine yeni kategori ve gider eklenebilir', () {
    const service = CsvBackupService();
    final current = MizanState.empty().copyWith(
      expenseCategories: const [],
      expenses: const [],
    );
    final imported = MizanState.empty().copyWith(
      expenseCategories: const [
        ExpenseCategory(id: 'backup-yeni', name: 'Yeni kategori'),
      ],
      expenses: [
        ExpenseItem(
          id: 'backup-yeni-gider',
          categoryId: 'backup-yeni',
          name: 'Yeni gider',
          quantity: 1,
          unitPrice: 250,
          spentAt: DateTime(2026, 7, 22),
        ),
      ],
    );

    final exported = service.exportState(imported);
    final restored = service.importState(exported);
    final result = service.mergeStates(current, restored);

    expect(result.state.expenseCategories, hasLength(1));
    expect(result.state.expenses, hasLength(1));
    expect(result.state.expenses.single.categoryId, 'backup-yeni');
    expect(result.addedCount, greaterThanOrEqualTo(2));
  });

  test(
    'gider kategorisi isimle eşleşir ve yeni gider doğru kategoriye bağlanır',
    () {
      const service = CsvBackupService();
      final current = MizanState.empty().copyWith(
        expenseCategories: const [
          ExpenseCategory(id: 'current-market', name: 'Market'),
        ],
      );
      final imported = MizanState.empty().copyWith(
        expenseCategories: const [
          ExpenseCategory(id: 'backup-market', name: ' market '),
        ],
        expenses: [
          ExpenseItem(
            id: 'backup-expense',
            categoryId: 'backup-market',
            name: 'Alışveriş',
            quantity: 1,
            unitPrice: 100,
            spentAt: DateTime(2026, 7, 22),
          ),
        ],
      );

      final merged = service.mergeStates(current, imported).state;
      expect(merged.expenseCategories, hasLength(1));
      expect(merged.expenses.single.categoryId, 'current-market');
    },
  );

  test('geçersiz CSV mevcut state olarak kabul edilmez', () {
    const service = CsvBackupService();
    expect(() => service.importState('a,b,c\n1,2,3'), throwsFormatException);
  });

  test('kalıcı Google Play satın alma parmak izi yedekte ayrı korunur', () {
    const service = CsvBackupService();
    final state = comprehensiveState();
    const fingerprint =
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
    final csv = service.exportState(
      state,
      permanentPurchaseFingerprint: fingerprint,
    );
    final backup = service.importBackup(csv);

    expect(backup.state.toJson(), state.toJson());
    expect(backup.permanentPurchaseFingerprint, fingerprint);
    expect(backup.hasPermanentPurchaseProof, isTrue);
    expect(csv, contains('entitlement_proof'));
    expect(csv, contains('google_play_non_consumable'));
    expect(csv, contains('premium_lifetime'));
    expect(csv, isNot(contains('temporaryUntilUtc')));
    expect(csv, isNot(contains('rewardedViewsToday')));
  });

  test('eski CSV yedekleri satın alma izi olmadan geriye uyumlu kalır', () {
    const service = CsvBackupService();
    final state = comprehensiveState();
    final csv = service.exportState(state);
    final backup = service.importBackup(csv);

    expect(backup.state.toJson(), state.toJson());
    expect(backup.permanentPurchaseFingerprint, isNull);
    expect(backup.hasPermanentPurchaseProof, isFalse);
    expect(csv, isNot(contains('entitlement_proof')));
  });

  test('geçersiz satın alma parmak izi yedeğe yazılmaz', () {
    const service = CsvBackupService();
    final csv = service.exportState(
      comprehensiveState(),
      permanentPurchaseFingerprint: 'not-a-valid-proof',
    );
    final backup = service.importBackup(csv);

    expect(backup.permanentPurchaseFingerprint, isNull);
    expect(csv, isNot(contains('entitlement_proof')));
  });

}
