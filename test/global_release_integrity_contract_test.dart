import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';

void main() {
  test('shipping notifications remain PRO gated without exact-alarm privileges', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();
    final coordinator = File(
      'lib/services/premium_notification_coordinator.dart',
    ).readAsStringSync();
    final notificationService = File(
      'lib/services/notification_service.dart',
    ).readAsStringSync();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(File('lib/services/notification_service.dart').existsSync(), isTrue);
    expect(
      File('lib/services/premium_notification_coordinator.dart').existsSync(),
      isTrue,
    );
    expect(pubspec, contains('flutter_local_notifications'));
    expect(pubspec, contains('flutter_timezone'));
    expect(main, contains('PremiumNotificationCoordinator'));
    expect(coordinator, contains('monetization.legalAccessGranted'));
    expect(coordinator, contains('monetization.isPremium'));
    expect(coordinator, contains('state.notificationsEnabled'));
    expect(coordinator, contains('_notificationService.cancelAll()'));
    expect(
      notificationService,
      contains('AndroidScheduleMode.inexactAllowWhileIdle'),
    );
    expect(
      notificationService,
      isNot(contains('AndroidScheduleMode.exactAllowWhileIdle')),
    );
    expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
    expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
    expect(manifest, isNot(contains('SCHEDULE_EXACT_ALARM')));
    expect(manifest, isNot(contains('USE_EXACT_ALARM')));
  });

  test('shipping Android monetization remains serverless', () {
    final androidConfig = File('tools/configure_android.py').readAsStringSync();
    final mainActivity = File(
      'android/app/src/main/kotlin/com/lefferionprime/mizanglobal/MainActivity.kt',
    ).readAsStringSync();
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(
      androidConfig,
      contains('Forbidden server verification integration'),
    );
    expect(mainActivity, contains('class MainActivity : FlutterActivity()'));
    expect(mainActivity, isNot(contains('play_integrity')));
    expect(mainActivity, isNot(contains('device_identity')));
    expect(gradle, isNot(contains('com.google.android.play:integrity')));
    expect(gradle, isNot(contains('MIZAN_MONETIZATION_API')));
    expect(Directory('backend/monetization-worker').existsSync(), isFalse);
  });

  test('all record money inputs follow the selected record currency', () {
    final forms = File(
      'lib/screens/record_form_dialogs.dart',
    ).readAsStringSync();
    final expenses = File(
      'lib/screens/expenses_screen.dart',
    ).readAsStringSync();
    final dashboard = File(
      'lib/screens/dashboard_screen.dart',
    ).readAsStringSync();

    expect(forms, isNot(contains("suffixText: 'TL'")));
    expect(forms, contains('suffixText: currencyCode'));
    expect(forms, contains('required this.currencyCode'));
    expect(expenses, contains('suffixText: currencyCode'));
    expect(dashboard, contains('suffixText: currencyCode'));
  });

  test('record group labels are localized in every supported language', () {
    for (final tag in MizanI18n.supportedLanguageTags) {
      MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
      for (final type in RecordType.values) {
        final label = type.groupLabelFor(languageTag: tag);
        expect(label.trim(), isNotEmpty, reason: '$tag/${type.name}');
        if (tag != 'tr') {
          expect(label, isNot('Faturalar'), reason: '$tag/${type.name}');
        }
      }
    }
  });

  test('known raw Turkish leak markers are absent from product surfaces', () {
    final paths = <String>[
      'lib/screens/dashboard_screen.dart',
      'lib/screens/expenses_screen.dart',
      'lib/screens/people_screen.dart',
      'lib/screens/reports_screen.dart',
      'lib/services/pdf_report_service.dart',
    ];
    final source = paths
        .map((path) => File(path).readAsStringSync())
        .join('\n');
    expect(source, isNot(contains("'Faturalar'")));
    expect(source, isNot(contains('"Faturalar"')));
    expect(source, isNot(contains("'Uygula'")));
    expect(source, isNot(contains('"Uygula"')));
    expect(source, isNot(contains("suffixText: 'TL'")));
  });

  test('GLOBAL Android identity remains isolated from original MIZAN', () {
    final androidConfig = File('tools/configure_android.py').readAsStringSync();
    expect(androidConfig, contains('com.lefferionprime.mizanglobal'));
    expect(androidConfig, contains('LEFFERION PRIME - MIZAN GLOBAL'));
  });
}
