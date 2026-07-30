import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/main.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';

import 'test_support.dart';

void main() {
  testWidgets('uygulama ilk kurulumda örneksiz ve boş açılır', (tester) async {
    final controller = MizanController(
      MemoryStore(MizanState.empty()),
      scheduler: SpyScheduler(),
    );
    await controller.load();
    await tester.pumpWidget(MizanApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('LEFFERION PRIME - MİZAN'), findsOneWidget);
    final emptyMessage = find.text('Uygulama boş ve kullanıma hazır');
    await tester.scrollUntilVisible(
      emptyMessage,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(emptyMessage, findsOneWidget);
    expect(find.text('Örnek kişi'), findsNothing);
    expect(find.text('Kredi kartı borcu'), findsNothing);
    expect(controller.state.people, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
