import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PRO notification Android integration is present without exact alarms', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final configure = File('tools/configure_android.py').readAsStringSync();

    expect(pubspec, contains('flutter_local_notifications: ^22.3.0'));
    expect(pubspec, contains('flutter_timezone: ^5.1.0'));
    expect(pubspec, contains('timezone: ^0.11.1'));
    expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
    expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
    expect(manifest, contains('ScheduledNotificationReceiver'));
    expect(manifest, contains('ScheduledNotificationBootReceiver'));
    expect(manifest, isNot(contains('SCHEDULE_EXACT_ALARM')));
    expect(manifest, isNot(contains('USE_EXACT_ALARM')));
    expect(gradle, contains('isCoreLibraryDesugaringEnabled = true'));
    expect(
      gradle,
      contains(
        'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")',
      ),
    );
    expect(configure, contains('Required notification integration is missing'));
    expect(configure, isNot(contains('GeneratedPluginRegistrant.java')));
  });

  test('production notification scheduling is legal and PRO gated', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final coordinator = File(
      'lib/services/premium_notification_coordinator.dart',
    ).readAsStringSync();
    final notificationService = File(
      'lib/services/notification_service.dart',
    ).readAsStringSync();

    expect(mainSource, contains('PremiumNotificationCoordinator'));
    expect(coordinator, contains('monetization.legalAccessGranted'));
    expect(coordinator, contains('monetization.isPremium'));
    expect(coordinator, contains('state.notificationsEnabled'));
    expect(coordinator, contains('_notificationService.cancelAll()'));
    expect(coordinator, contains('_notificationService.requestPermission()'));
    expect(notificationService, contains('AndroidScheduleMode.inexactAllowWhileIdle'));
    expect(notificationService, contains('DateTimeComponents.time'));
    expect(notificationService, isNot(contains('exactAllowWhileIdle')));
  });
}
