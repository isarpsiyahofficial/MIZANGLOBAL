import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/monthly_payment_status_service.dart';

void main() {
  test('Android kapalı uygulama ve izin dönüşü yapılandırması eksiksizdir', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final receiver = File(
      'android/app/src/main/java/com/dexterous/flutterlocalnotifications/ExactAlarmPermissionReceiver.java',
    ).readAsStringSync();
    final service = File(
      'lib/services/notification_service.dart',
    ).readAsStringSync();

    expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
    expect(manifest, contains('android.permission.SCHEDULE_EXACT_ALARM'));
    expect(manifest, contains('ScheduledNotificationReceiver'));
    expect(manifest, contains('ScheduledNotificationBootReceiver'));
    expect(manifest, contains('ExactAlarmPermissionReceiver'));
    expect(
      manifest,
      contains(
        'android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED',
      ),
    );
    expect(
      manifest,
      isNot(contains('android.permission.USE_FULL_SCREEN_INTENT')),
    );
    expect(manifest, isNot(contains('android:showWhenLocked="true"')));
    expect(manifest, isNot(contains('android:turnScreenOn="true"')));
    expect(receiver, contains('canScheduleExactAlarms()'));
    expect(receiver, contains('rescheduleNotifications(context)'));
    expect(service, contains('pendingNotificationRequests()'));
    expect(service, contains('desiredIds.difference(actualIds)'));
    expect(service, isNot(contains('_scheduledSignatures')));
    expect(service, isNot(contains('_scheduleCachePrimed')));
  });

  test('yedi banka Temmuz planı ödeme ve açık tutarı kayıpsız uzlaştırır', () {
    const amounts = <double>[5200, 4800, 6100, 3900, 7000, 4500, 5600];
    final banks = <BankGroup>[];
    for (var index = 0; index < amounts.length; index++) {
      final payments = <PaymentRecord>[];
      if (index == 0) {
        payments.add(
          PaymentRecord(
            id: 'payment-full',
            amount: amounts[index],
            paidAt: DateTime(2026, 7, 3),
          ),
        );
      } else if (index == 1) {
        payments.add(
          PaymentRecord(
            id: 'payment-partial',
            amount: 1800,
            paidAt: DateTime(2026, 7, 4),
          ),
        );
      }
      banks.add(
        BankGroup(
          id: 'bank-$index',
          userWrittenName: 'Banka ${index + 1}',
          products: [
            DebtProduct(
              id: 'debt-$index',
              kind: DebtKind.creditCard,
              title: 'Temmuz kaydı ${index + 1}',
              totalAmount: amounts[index],
              monthlyAmount: amounts[index],
              dueDate: DateTime(2026, 7, 10 + index),
              payments: payments,
            ),
          ],
        ),
      );
    }
    final state = MizanState.empty().copyWith(
      people: [PersonAccount(id: 'person-1', name: 'Kişi', banks: banks)],
    );

    final status = const MonthlyPaymentStatusService().build(
      state: state,
      month: DateTime(2026, 7),
    );
    expect(status.paidTotal, closeTo(7000, 0.001));
    expect(status.openTotal, closeTo(30100, 0.001));
    expect(status.plannedAndPaidTotal, closeTo(37100, 0.001));
    expect(status.plannedAndPaidTotal, greaterThan(36000));

    final represented = <String>{
      ...status.openRecords.map((item) => item.sourceId),
      ...status.paymentDetails.map((item) => item.recordId),
    };
    expect(represented, hasLength(7));
  });
}
