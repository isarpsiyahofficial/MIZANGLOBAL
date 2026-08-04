import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dakik alarm izni yokken arka plan yaklaşık planlaması korunur', () {
    final service = File(
      'lib/services/notification_service.dart',
    ).readAsStringSync();
    final controller = File(
      'lib/controllers/mizan_controller.dart',
    ).readAsStringSync();
    final settings = File(
      'lib/screens/settings_screen.dart',
    ).readAsStringSync();

    expect(service, contains('AndroidScheduleMode.exactAllowWhileIdle'));
    expect(service, contains('AndroidScheduleMode.inexactAllowWhileIdle'));
    expect(
      service,
      isNot(
        contains(
          'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.',
        ),
      ),
    );
    expect(
      controller,
      contains('state.notificationsEnabled && !health.permissionGranted'),
    );
    expect(
      controller,
      isNot(
        contains(
          '(!health.permissionGranted || !health.preciseTimingGranted)',
        ),
      ),
    );
    expect(
      settings,
      isNot(contains('MİZAN yaklaşık zamanlama kullanmaz')),
    );
  });
}
