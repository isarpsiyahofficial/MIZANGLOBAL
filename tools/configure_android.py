import re
from pathlib import Path

ANDROID_PACKAGE = "com.lefferionprime.mizanglobal"
ANDROID_LABEL = "LEFFERION PRIME - MIZAN GLOBAL"

manifest = Path("android/app/src/main/AndroidManifest.xml")
text = manifest.read_text(encoding="utf-8")
text = re.sub(
    r'android:label="[^"]+"',
    f'android:label="{ANDROID_LABEL}"',
    text,
    count=1,
)
text = text.replace(
    '    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />\n',
    '',
)
text = text.replace('            android:showWhenLocked="true"\n', '')
text = text.replace('            android:turnScreenOn="true"\n', '')
manifest_tag = '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
for permission_name in (
    "android.permission.POST_NOTIFICATIONS",
    "android.permission.RECEIVE_BOOT_COMPLETED",
    "android.permission.SCHEDULE_EXACT_ALARM",
    "android.permission.VIBRATE",
):
    if permission_name not in text:
        permission_line = (
            f'    <uses-permission android:name="{permission_name}" />\n'
        )
        text = text.replace(manifest_tag, manifest_tag + "\n" + permission_line, 1)
receivers = """
        <receiver android:exported=\"false\" android:name=\"com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver\" />
        <receiver android:exported=\"false\" android:name=\"com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver\">
            <intent-filter>
                <action android:name=\"android.intent.action.BOOT_COMPLETED\" />
                <action android:name=\"android.intent.action.MY_PACKAGE_REPLACED\" />
                <action android:name=\"android.intent.action.QUICKBOOT_POWERON\" />
                <action android:name=\"com.htc.intent.action.QUICKBOOT_POWERON\" />
            </intent-filter>
        </receiver>
"""
if "ScheduledNotificationReceiver" not in text:
    text = text.replace("    </application>", receivers + "    </application>")
exact_permission_receiver = """
        <receiver android:exported=\"false\" android:name=\"com.dexterous.flutterlocalnotifications.ExactAlarmPermissionReceiver\">
            <intent-filter>
                <action android:name=\"android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED\" />
            </intent-filter>
        </receiver>
"""
if "ExactAlarmPermissionReceiver" not in text:
    text = text.replace(
        "    </application>",
        exact_permission_receiver + "    </application>",
    )
manifest.write_text(text, encoding="utf-8")

build = Path("android/app/build.gradle.kts")
text = build.read_text(encoding="utf-8")
text = re.sub(
    r'namespace\s*=\s*"[^"]+"',
    f'namespace = "{ANDROID_PACKAGE}"',
    text,
    count=1,
)
text = re.sub(
    r'applicationId\s*=\s*"[^"]+"',
    f'applicationId = "{ANDROID_PACKAGE}"',
    text,
    count=1,
)
if "isCoreLibraryDesugaringEnabled" not in text:
    text = text.replace(
        "    compileOptions {",
        "    compileOptions {\n        isCoreLibraryDesugaringEnabled = true",
    )
if "coreLibraryDesugaring(" not in text:
    text += """

dependencies {
    coreLibraryDesugaring(\"com.android.tools:desugar_jdk_libs:2.1.5\")
}
"""
build.write_text(text, encoding="utf-8")

main_activity_root = Path("android/app/src/main/kotlin")
target_main_activity = (
    main_activity_root / Path(*ANDROID_PACKAGE.split(".")) / "MainActivity.kt"
)
target_main_activity.parent.mkdir(parents=True, exist_ok=True)
for candidate in main_activity_root.rglob("MainActivity.kt"):
    if candidate != target_main_activity:
        candidate.unlink()
target_main_activity.write_text(
    f"""package {ANDROID_PACKAGE}

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
""",
    encoding="utf-8",
)

receiver = Path(
    "android/app/src/main/java/com/dexterous/flutterlocalnotifications/ExactAlarmPermissionReceiver.java"
)
receiver.parent.mkdir(parents=True, exist_ok=True)
receiver.write_text(
    """package com.dexterous.flutterlocalnotifications;

import android.app.AlarmManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import androidx.annotation.Keep;

@Keep
public final class ExactAlarmPermissionReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || intent == null) return;
        if (!AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED.equals(intent.getAction())) return;
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (alarmManager != null && alarmManager.canScheduleExactAlarms()) {
            FlutterLocalNotificationsPlugin.rescheduleNotifications(context);
        }
    }
}
""",
    encoding="utf-8",
)
