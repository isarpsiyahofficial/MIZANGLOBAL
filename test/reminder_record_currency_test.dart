import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';

void main() {
  test('payment reminder formats amount with record currency, not main default', () {
    final now = DateTime(2026, 8, 7, 8);
    final state = MizanState(
      setupCompleted: true,
      appLanguageTag: 'en',
      debtRegionCountryCode: 'US',
      defaultCurrencyCode: 'USD',
      notificationsEnabled: true,
      expenseCategories: const [],
      expenses: const [],
      notificationSlots: const [],
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'payment-1',
          label: 'Ödeme hatırlatması 1',
          hour: 9,
          minute: 0,
          message: 'Yaklaşan ve gecikmiş ödemelerini kontrol et.',
        ),
      ],
      people: [
        PersonAccount(
          id: 'person-1',
          name: 'Owner',
          banks: [
            BankGroup(
              id: 'bank-1',
              userWrittenName: 'Bank',
              products: [
                DebtProduct(
                  id: 'debt-1',
                  currencyCode: 'JPY',
                  kind: DebtKind.loan,
                  title: 'Loan',
                  totalAmount: 12000,
                  monthlyAmount: 1000,
                  dueDate: DateTime(2026, 8, 8),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final plan = const ReminderPlanBuilder().build(state: state, now: now);
    final reminder = plan.firstWhere((item) => item.sourceId == 'debt-1');
    final expectedDueAmount = money(1000, currencyCode: 'JPY');
    final wrongDefaultCurrency = money(1000, currencyCode: 'USD');

    expect(reminder.message, contains(expectedDueAmount));
    expect(reminder.message, isNot(contains(wrongDefaultCurrency)));
  });
}
