import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const globalPackage = 'com.lefferionprime.mizanglobal';
  const legacyPackage = 'com.lefferionprime.lefferion_prime_mizan';

  test('MIZAN GLOBAL uses an Android package distinct from legacy MIZAN', () {
    final buildFile = File('android/app/build.gradle.kts');
    expect(buildFile.existsSync(), isTrue);
    final build = buildFile.readAsStringSync();

    expect(build, contains('namespace = "$globalPackage"'));
    expect(build, contains('applicationId = "$globalPackage"'));
    expect(build, isNot(contains('applicationId = "$legacyPackage"')));

    final globalActivity = File(
      'android/app/src/main/kotlin/com/lefferionprime/mizanglobal/MainActivity.kt',
    );
    final legacyActivity = File(
      'android/app/src/main/kotlin/com/lefferionprime/lefferion_prime_mizan/MainActivity.kt',
    );
    expect(globalActivity.existsSync(), isTrue);
    expect(globalActivity.readAsStringSync(), contains('package $globalPackage'));
    expect(legacyActivity.existsSync(), isFalse);

    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:label="LEFFERION PRIME - MIZAN GLOBAL"'));
  });

  test('Android regeneration reapplies the GLOBAL package identity', () {
    final configurator = File('tools/configure_android.py').readAsStringSync();

    expect(configurator, contains('ANDROID_PACKAGE = "$globalPackage"'));
    expect(configurator, contains('ANDROID_LABEL = "LEFFERION PRIME - MIZAN GLOBAL"'));
    expect(configurator, contains('applicationId'));
    expect(configurator, contains('namespace'));
    expect(configurator, contains('MainActivity.kt'));
  });
}
