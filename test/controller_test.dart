import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';

import 'test_support.dart';

void main() {
  test('açılışta bildirim izni istenir ve kayıtlar ayrıca yüklenir', () async {
    final store = MemoryStore(comprehensiveState());
    final scheduler = SpyScheduler()..throwOnPermissions = true;
    final controller = MizanController(store, scheduler: scheduler);

    await controller.load();

    expect(scheduler.permissionRequestCount, 1);
    expect(controller.storageReady, isTrue);
    expect(controller.state.people, hasLength(1));
    expect(controller.state.people.single.name, 'İbrahim');
  });

  test('bildirim planlama kendi kendine ödeme kaydı oluşturmaz', () async {
    final initial = comprehensiveState();
    final beforeJson = initial.toJson();
    final beforePayments = paymentCount(initial);
    final store = MemoryStore(initial);
    final scheduler = SpyScheduler();
    final controller = MizanController(store, scheduler: scheduler);

    await controller.load();
    await controller.rescheduleNotifications();
    await controller.refreshNotificationHealth();

    expect(paymentCount(controller.state), beforePayments);
    expect(controller.state.toJson(), beforeJson);
    expect(scheduler.lastScheduledState?.toJson(), beforeJson);
  });

  test(
    'kişisel borç, abonelik ve banka borcu birbirinden bağımsız kaydedilir',
    () async {
      final store = MemoryStore(MizanState.empty());
      final controller = MizanController(store, scheduler: SpyScheduler());
      await controller.load();
      await controller.addPerson('Ali');
      final personId = controller.state.people.single.id;

      await controller.addBankGroup(
        personId: personId,
        userWrittenName: 'Banka grubum',
      );
      final bankId = controller.state.people.single.banks.single.id;
      await controller.addDebtProduct(
        personId: personId,
        bankId: bankId,
        kind: DebtKind.creditCard,
        title: 'Kart borcu',
        totalAmount: 1000,
        monthlyAmount: 250,
        dueDate: DateTime(2026, 8, 1),
      );
      await controller.addPersonalDebt(
        personId: personId,
        creditorType: CreditorType.person,
        title: 'Arkadaşa borç',
        creditorName: 'Mehmet',
        totalAmount: 500,
        debtDate: DateTime(2026, 7, 1),
        dueDate: DateTime(2026, 8, 2),
        frequency: PaymentFrequency.oneTime,
      );
      await controller.addSubscription(
        personId: personId,
        kind: SubscriptionKind.digitalService,
        title: 'Dijital hizmet',
        providerName: 'Sağlayıcı',
        amount: 100,
        frequency: PaymentFrequency.monthly,
        nextDueDate: DateTime(2026, 8, 3),
      );

      final person = controller.state.people.single;
      expect(person.banks.single.products, hasLength(1));
      expect(person.personalDebts, hasLength(1));
      expect(person.subscriptions, hasLength(1));
      expect(store.saveCount, greaterThanOrEqualTo(4));
    },
  );

  test('ödeme yalnız kaynak kayda yazılır ve fazla ödeme reddedilir', () async {
    final store = MemoryStore(comprehensiveState());
    final controller = MizanController(store, scheduler: SpyScheduler());
    await controller.load();
    final person = controller.state.people.single;
    final debt = person.personalDebts.single;

    await controller.addPayment(
      personId: person.id,
      type: RecordType.personalDebt,
      sourceId: debt.id,
      amount: 1000,
      paidAt: DateTime(2026, 7, 19),
    );

    final after = controller.state.people.single;
    expect(after.personalDebts.single.payments, hasLength(1));
    expect(after.bills.single.payments, isEmpty);
    expect(after.subscriptions.single.payments, isEmpty);
    expect(after.rents.single.payments, isEmpty);
    expect(
      after.banks.single.products.single.payments,
      hasLength(1),
      reason:
          'Mevcut banka ödemesi korunmalı ve yeni ödeme buraya yazılmamalı.',
    );

    await expectLater(
      controller.addPayment(
        personId: person.id,
        type: RecordType.bill,
        sourceId: after.bills.single.id,
        amount: 751,
        paidAt: DateTime(2026, 7, 19),
      ),
      throwsArgumentError,
    );
  });

  test('kategori yalnız tam ONAYLIYORUM ile silinir', () async {
    final controller = MizanController(
      MemoryStore(MizanState.empty()),
      scheduler: SpyScheduler(),
    );
    await controller.load();
    await controller.addExpenseCategory('Test');
    final id = controller.state.expenseCategories.single.id;

    await expectLater(
      controller.deleteExpenseCategory(
        categoryId: id,
        confirmation: 'onaylıyorum',
      ),
      throwsArgumentError,
    );
    expect(controller.state.expenseCategories, hasLength(1));

    await controller.deleteExpenseCategory(
      categoryId: id,
      confirmation: 'ONAYLIYORUM',
    );
    expect(controller.state.expenseCategories, isEmpty);
  });

  test('okunamayan cihaz kaydı yeni işlemlerle ezilmez', () async {
    final controller = MizanController(
      MemoryStore(MizanState.empty(), loadError: StateError('bozuk kayıt')),
      scheduler: SpyScheduler(),
    );
    await controller.load();
    expect(controller.storageReady, isFalse);
    await expectLater(controller.addPerson('Yeni kişi'), throwsStateError);
  });

  test(
    'ödeme türü ve bildirim tercihleri güvenli biçimde kaydedilir',
    () async {
      final store = MemoryStore(comprehensiveState());
      final controller = MizanController(store, scheduler: SpyScheduler());
      await controller.load();
      final person = controller.state.people.single;
      final debt = person.banks.single.products.single;

      await controller.addPayment(
        personId: person.id,
        type: RecordType.debt,
        sourceId: debt.id,
        amount: 2000,
        paidAt: DateTime(2026, 7, 21),
        entryType: PaymentEntryType.installment,
      );
      await controller.setPaymentReminderFrequency(
        PaymentReminderFrequency.threeTimesDaily,
      );
      await controller.setNotificationSoundMode(NotificationSoundMode.silent);

      final updated =
          controller.state.people.single.banks.single.products.single;
      expect(updated.payments.first.entryType, PaymentEntryType.installment);
      expect(updated.remainingAmount, 7000);
      expect(
        controller.state.paymentReminderFrequency,
        PaymentReminderFrequency.threeTimesDaily,
      );
      expect(
        controller.state.notificationSoundMode,
        NotificationSoundMode.silent,
      );
      expect(store.saveCount, greaterThanOrEqualTo(3));
    },
  );
}
