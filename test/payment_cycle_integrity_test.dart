import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';

import 'test_support.dart';

MizanState _stateWith(PersonAccount person) => MizanState(
  people: [person],
  expenseCategories: const [],
  expenses: const [],
);

void main() {
  test('aylık fatura ve kira ödemeleri her dönemde ayrı doğrulanır', () async {
    final person = PersonAccount(
      id: 'person',
      name: 'Kişi',
      bills: [
        BillEntry(
          id: 'bill',
          currencyCode: 'TRY',
          kind: BillKind.electricity,
          institutionName: 'Kurum',
          amount: 100,
          dueDate: DateTime(2026, 1, 5),
          scheduleMode: BillScheduleMode.monthly,
          paymentDay: 5,
        ),
      ],
      rents: [
        RentEntry(
          id: 'rent',
          currencyCode: 'TRY',
          kind: RentEntryKind.homeRent,
          title: 'Ev',
          amount: 1000,
          paymentDay: 5,
          receiverName: 'Ev sahibi',
          dueDate: DateTime(2026, 1, 5),
          recurringMonthly: true,
        ),
      ],
    );
    final controller = MizanController(
      MemoryStore(_stateWith(person)),
      scheduler: SpyScheduler(),
    );
    await controller.load();

    await controller.addPayment(
      personId: 'person',
      type: RecordType.bill,
      sourceId: 'bill',
      amount: 100,
      paidAt: DateTime(2026, 1, 5),
    );
    await controller.addPayment(
      personId: 'person',
      type: RecordType.bill,
      sourceId: 'bill',
      amount: 100,
      paidAt: DateTime(2026, 2, 5),
    );
    await controller.addPayment(
      personId: 'person',
      type: RecordType.rent,
      sourceId: 'rent',
      amount: 1000,
      paidAt: DateTime(2026, 1, 5),
    );
    await controller.addPayment(
      personId: 'person',
      type: RecordType.rent,
      sourceId: 'rent',
      amount: 1000,
      paidAt: DateTime(2026, 2, 5),
    );

    final updated = controller.state.people.single;
    expect(updated.bills.single.payments, hasLength(2));
    expect(updated.rents.single.payments, hasLength(2));
    expect(
      updated.bills.single.payments.map((item) => item.appliesToDueDate),
      containsAll([DateTime(2026, 1, 5), DateTime(2026, 2, 5)]),
    );
    expect(
      updated.rents.single.payments.map((item) => item.appliesToDueDate),
      containsAll([DateTime(2026, 1, 5), DateTime(2026, 2, 5)]),
    );
  });

  test('abonelik ödeme düzenleme ve silme dönem tarihini uzlaştırır', () async {
    final person = PersonAccount(
      id: 'person',
      name: 'Kişi',
      subscriptions: [
        SubscriptionEntry(
          id: 'subscription',
          currencyCode: 'TRY',
          kind: SubscriptionKind.digitalService,
          title: 'Hizmet',
          providerName: 'Sağlayıcı',
          amount: 100,
          frequency: PaymentFrequency.monthly,
          nextDueDate: DateTime(2026, 1, 10),
        ),
      ],
    );
    final controller = MizanController(
      MemoryStore(_stateWith(person)),
      scheduler: SpyScheduler(),
    );
    await controller.load();
    await controller.addPayment(
      personId: 'person',
      type: RecordType.subscription,
      sourceId: 'subscription',
      amount: 100,
      paidAt: DateTime(2026, 1, 10),
    );

    var subscription = controller.state.people.single.subscriptions.single;
    final paymentId = subscription.payments.single.id;
    expect(subscription.nextDueDate, DateTime(2026, 2, 10));

    await controller.updatePayment(
      personId: 'person',
      type: RecordType.subscription,
      sourceId: 'subscription',
      paymentId: paymentId,
      amount: 50,
      paidAt: DateTime(2026, 1, 10),
    );
    subscription = controller.state.people.single.subscriptions.single;
    expect(subscription.nextDueDate, DateTime(2026, 1, 10));

    await controller.updatePayment(
      personId: 'person',
      type: RecordType.subscription,
      sourceId: 'subscription',
      paymentId: paymentId,
      amount: 100,
      paidAt: DateTime(2026, 1, 10),
    );
    subscription = controller.state.people.single.subscriptions.single;
    expect(subscription.nextDueDate, DateTime(2026, 2, 10));

    await controller.deletePayment(
      personId: 'person',
      type: RecordType.subscription,
      sourceId: 'subscription',
      paymentId: paymentId,
    );
    subscription = controller.state.people.single.subscriptions.single;
    expect(subscription.nextDueDate, DateTime(2026, 1, 10));
  });
}
