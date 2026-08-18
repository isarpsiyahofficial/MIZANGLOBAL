import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('current shipping version has no notification platform integration', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final androidGradle = File(
      'android/app/build.gradle.kts',
    ).readAsStringSync();

    for (final token in const [
      'flutter_local_notifications',
      'flutter_timezone',
      'android_intent_plus',
    ]) {
      expect(pubspec, isNot(contains(token)), reason: token);
    }
    for (final token in const [
      'POST_NOTIFICATIONS',
      'SCHEDULE_EXACT_ALARM',
      'RECEIVE_BOOT_COMPLETED',
      'flutterlocalnotifications',
    ]) {
      expect(manifest + androidGradle, isNot(contains(token)), reason: token);
    }
    expect(
      File('lib/services/notification_service.dart').existsSync(),
      isFalse,
    );
  });

  test(
    'current shipping UI does not expose notification controls or PRO claims',
    () {
      final settings = File(
        'lib/screens/settings_screen.dart',
      ).readAsStringSync();
      final premium = File(
        'lib/screens/premium_screen.dart',
      ).readAsStringSync();
      final monetizationStrings = File(
        'lib/monetization/monetization_strings.dart',
      ).readAsStringSync();
      final main = File('lib/main.dart').readAsStringSync();

      for (final token in const [
        'Bildirim sistemi',
        'POST_NOTIFICATIONS',
        'benefitNotification',
        'notification_service.dart',
        'reminder_engine.dart',
      ]) {
        expect(
          settings + premium + monetizationStrings + main,
          isNot(contains(token)),
          reason: token,
        );
      }
    },
  );
}
