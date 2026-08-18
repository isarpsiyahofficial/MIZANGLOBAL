import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';

void main() {
  test('shipping app has no notification platform/runtime subsystem', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();
    final controller = File(
      'lib/controllers/mizan_controller.dart',
    ).readAsStringSync();
    final settings = File(
      'lib/screens/settings_screen.dart',
    ).readAsStringSync();
    expect(
      File('lib/services/notification_service.dart').existsSync(),
      isFalse,
    );
    final shipping = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.endsWith('reminder_engine.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');
    expect(shipping, isNot(contains('services/reminder_engine.dart')));
    expect(pubspec, isNot(contains('flutter_local_notifications')));
    expect(pubspec, isNot(contains('flutter_timezone')));
    expect(pubspec, isNot(contains('\n  timezone:')));
    expect(main.toLowerCase(), isNot(contains('notification')));
    expect(controller.toLowerCase(), isNot(contains('notification')));
    expect(settings, isNot(contains('Bildirim sistemi')));
    expect(settings, isNot(contains('Ödeme hatırlatmaları')));
    expect(settings, isNot(contains('Günlük gider hatırlatmaları')));
    final androidConfig = File('tools/configure_android.py').readAsStringSync();
    expect(androidConfig, contains('android.permission.POST_NOTIFICATIONS'));
    expect(androidConfig, contains('android.permission.SCHEDULE_EXACT_ALARM'));
    expect(androidConfig, contains('flutterlocalnotifications'));
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
