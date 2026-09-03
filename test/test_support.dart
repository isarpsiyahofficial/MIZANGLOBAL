import 'package:lefferion_prime_mizan/legal/legal_acceptance_store.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryStore implements MizanStore {
  MemoryStore(this.current, {this.loadError, this.acceptLegal = true});

  MizanState current;
  final Object? loadError;
  final bool acceptLegal;
  int saveCount = 0;

  @override
  Future<StoreLoadResult> load() async {
    if (loadError != null) {
      throw loadError!;
    }
    if (acceptLegal) {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      await LegalAcceptanceStore.acceptCurrentLegalBundle();
    }
    final normalized = MizanState.fromJson(current.toJson());
    current = normalized;
    return StoreLoadResult(state: normalized, source: StoreLoadSource.primary);
  }

  @override
  Future<void> reset(MizanState state) async {
    current = state;
    saveCount++;
  }

  @override
  Future<void> save(MizanState state) async {
    current = state;
    saveCount++;
  }
}

class SpyScheduler {}

MizanState comprehensiveState({
  DateTime? reference,
  String currencyCode = 'TRY',
}) {
  final now = reference ?? DateTime(2026, 7, 19, 10);
  return MizanState(
    people: [
      PersonAccount(
        id: 'person-1',
        name: 'İbrahim',
        banks: [
          BankGroup(
            id: 'bank-1',
            userWrittenName: 'Kullanıcının bankası',
            products: [
              DebtProduct(
                id: 'bank-debt-1',
                currencyCode: currencyCode,
                kind: DebtKind.creditCard,
                title: 'Kart borcu',
                totalAmount: 12000,
                monthlyAmount: 2000,
                dueDate: now.add(const Duration(days: 2)),
                payments: [
                  PaymentRecord(
                    id: 'payment-bank-1',
                    amount: 3000,
                    paidAt: now.subtract(const Duration(days: 5)),
                  ),
                ],
              ),
            ],
          ),
        ],
        personalDebts: [
          PersonalDebtEntry(
            id: 'personal-debt-1',
            currencyCode: currencyCode,
            creditorType: CreditorType.promissoryNote,
            title: 'Senet ödemesi',
            creditorName: 'Örnek alacaklı',
            totalAmount: 6000,
            debtDate: now.subtract(const Duration(days: 30)),
            dueDate: now.add(const Duration(days: 3)),
            frequency: PaymentFrequency.monthly,
            isInstallment: true,
            installmentCount: 3,
            currentInstallment: 1,
            monthlyAmount: 2000,
            promissoryNoteNumber: 'SNT-001',
            documentCount: 3,
            currentDocument: 1,
            schedule: [
              DueScheduleItem(
                id: 'schedule-1',
                label: '1. senet',
                amount: 2000,
                dueDate: now.add(const Duration(days: 3)),
              ),
              DueScheduleItem(
                id: 'schedule-2',
                label: '2. senet',
                amount: 2000,
                dueDate: now.add(const Duration(days: 33)),
              ),
              DueScheduleItem(
                id: 'schedule-3',
                label: '3. senet',
                amount: 2000,
                dueDate: now.add(const Duration(days: 63)),
              ),
            ],
          ),
        ],
        bills: [
          BillEntry(
            id: 'bill-1',
            currencyCode: currencyCode,
            kind: BillKind.electricity,
            institutionName: 'Elektrik kurumu',
            amount: 750,
            dueDate: now.add(const Duration(days: 1)),
          ),
        ],
        subscriptions: [
          SubscriptionEntry(
            id: 'subscription-1',
            currencyCode: currencyCode,
            kind: SubscriptionKind.digitalService,
            title: 'Dijital hizmet',
            providerName: 'Sağlayıcı',
            amount: 249.90,
            frequency: PaymentFrequency.monthly,
            nextDueDate: now.add(const Duration(days: 4)),
          ),
        ],
        rents: [
          RentEntry(
            id: 'rent-1',
            currencyCode: currencyCode,
            kind: RentEntryKind.homeRent,
            recurringMonthly: true,
            title: 'Ev kirası',
            amount: 15000,
            paymentDay: 5,
            receiverName: 'Ev sahibi',
            dueDate: now.add(const Duration(days: 5)),
          ),
        ],
      ),
    ],
    expenseCategories: const [
      ExpenseCategory(id: 'category-1', name: 'Market'),
    ],
    expenses: [
      ExpenseItem(
        id: 'expense-1',
        currencyCode: currencyCode,
        categoryId: 'category-1',
        name: 'Alışveriş',
        quantity: 1,
        unitPrice: 450,
        spentAt: now,
      ),
    ],
  );
}

int paymentCount(MizanState state) => state.people.fold<int>(0, (sum, person) {
  final bankPayments = person.banks.fold<int>(
    0,
    (bankSum, bank) =>
        bankSum +
        bank.products.fold<int>(
          0,
          (debtSum, debt) => debtSum + debt.payments.length,
        ),
  );
  return sum +
      bankPayments +
      person.personalDebts.fold<int>(
        0,
        (value, item) => value + item.payments.length,
      ) +
      person.bills.fold<int>(0, (value, item) => value + item.payments.length) +
      person.subscriptions.fold<int>(
        0,
        (value, item) => value + item.payments.length,
      ) +
      person.rents.fold<int>(0, (value, item) => value + item.payments.length);
});
