import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/screens/record_form_dialogs.dart';

import 'test_support.dart';

void main() {
  testWidgets('manuel gecikme değişikliği ayrı onay ister', (tester) async {
    final debt = DebtProduct(
      id: 'debt',
      kind: DebtKind.loan,
      title: 'Kredi',
      totalAmount: 12000,
      monthlyAmount: 1000,
      dueDate: DateTime(2026, 7, 5),
      dueMode: DebtDueMode.monthlyDay,
      dueDayOfMonth: 5,
      manualOverdueDays: 46,
      manualOverdueRecordedAt: DateTime(2026, 7, 21),
      manualOverdueSince: DateTime(2026, 6, 5),
    );
    final person = PersonAccount(
      id: 'person',
      name: 'Kişi',
      banks: [
        BankGroup(id: 'bank', userWrittenName: 'Banka', products: [debt]),
      ],
    );
    final controller = MizanController(
      MemoryStore(
        MizanState(
          people: [person],
          expenseCategories: const [],
          expenses: const [],
          notificationSlots: const [],
        ),
      ),
      scheduler: SpyScheduler(),
    );
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showDebtForm(
                  context: context,
                  controller: controller,
                  person: person,
                  bank: person.banks.single,
                  debt: debt,
                ),
                child: const Text('Düzenle'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Düzenle'));
    await tester.pumpAndSettle();
    expect(find.text('Güncel manuel gecikme günü'), findsOneWidget);
    expect(find.text('Gecikme gününü değiştir'), findsOneWidget);

    await tester.ensureVisible(find.text('Gecikme gününü değiştir'));
    await tester.tap(find.text('Gecikme gününü değiştir'));
    await tester.pumpAndSettle();

    final manualField = find.byKey(const Key('manual-overdue-days-field'));
    expect(manualField, findsOneWidget);
    await tester.enterText(manualField, '46');
    await tester.ensureVisible(find.text('Kaydet'));
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Gecikme hesabını yeniden kur'), findsOneWidget);
    expect(find.text('Değişikliği onayla'), findsOneWidget);
    expect(
      find.textContaining(
        'bildirim, rapor ve ödeme hesaplarını yeniden hesaplayacaktır',
      ),
      findsOneWidget,
    );
  });
}
