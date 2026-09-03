import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/local_store.dart';

void main() {
  test('10 bin gider ve 10 bin ödeme yerel kayıtta kaybolmaz', () async {
    final directory = await Directory.systemTemp.createTemp('mizan-scale-test');
    addTearDown(() => directory.delete(recursive: true));

    final payments = List<PaymentRecord>.generate(
      10000,
      (index) => PaymentRecord(
        id: 'payment-$index',
        amount: 1,
        paidAt: DateTime(2020, 1, 1).add(Duration(days: index % 2000)),
      ),
    );
    final expenses = List<ExpenseItem>.generate(
      10000,
      (index) => ExpenseItem(
        id: 'expense-$index',
        categoryId: 'category',
        name: 'Gider $index',
        quantity: 1,
        unitPrice: (index % 100 + 1).toDouble(),
        spentAt: DateTime(2020, 1, 1).add(Duration(days: index % 2000)),
      ),
    );
    final state = MizanState(
      people: [
        PersonAccount(
          id: 'person',
          name: 'Ölçek Testi',
          banks: [
            BankGroup(
              id: 'bank',
              userWrittenName: 'Kurum',
              products: [
                DebtProduct(
                  id: 'debt',
                  kind: DebtKind.creditCard,
                  title: 'Yük testi',
                  totalAmount: 20000,
                  monthlyAmount: 100,
                  dueDate: DateTime(2026, 8, 5),
                  payments: payments,
                ),
              ],
            ),
          ],
        ),
      ],
      expenseCategories: const [ExpenseCategory(id: 'category', name: 'Genel')],
      expenses: expenses,
    );
    final store = LocalStore(directory: directory);
    final stopwatch = Stopwatch()..start();
    await store.save(state);
    final loaded = await store.load();
    stopwatch.stop();

    expect(loaded.state.expenses, hasLength(10000));
    expect(
      loaded.state.people.single.banks.single.products.single.payments,
      hasLength(10000),
    );
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 40)));
  });
}
