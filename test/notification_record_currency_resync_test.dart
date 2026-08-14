import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('changing a record currency reschedules localized reminders', () async {
    final now = DateTime.now();
    final scheduler = SpyScheduler();
    final controller = MizanController(
      MemoryStore(
        comprehensiveState(
          reference: now,
          currencyCode: 'EUR',
        ).copyWith(defaultCurrencyCode: 'EUR'),
      ),
      scheduler: scheduler,
    );
    await controller.load();

    final before = scheduler.rescheduleCount;
    final subscription = controller.state.allSubscriptions.single;
    expect(subscription.currencyCode, 'EUR');

    await controller.updateSubscription(
      personId: 'person-1',
      subscriptionId: subscription.id,
      kind: subscription.kind,
      title: subscription.title,
      providerName: subscription.providerName,
      amount: subscription.amount,
      frequency: subscription.frequency,
      nextDueDate: subscription.nextDueDate,
      currencyCode: 'USD',
    );

    expect(controller.state.allSubscriptions.single.currencyCode, 'USD');
    expect(scheduler.rescheduleCount, before + 1);
    controller.dispose();
  });
}
