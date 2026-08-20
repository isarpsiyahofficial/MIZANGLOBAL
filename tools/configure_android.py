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
for permission_name in (
    "android.permission.POST_NOTIFICATIONS",
    "android.permission.RECEIVE_BOOT_COMPLETED",
    "android.permission.SCHEDULE_EXACT_ALARM",
    "android.permission.USE_EXACT_ALARM",
    "android.permission.VIBRATE",
    "android.permission.USE_FULL_SCREEN_INTENT",
):
    text = re.sub(
        rf"\s*<uses-permission[^>]*android:name=\"{re.escape(permission_name)}\"[^>]*/>\s*",
        "\n",
        text,
    )
text = re.sub(
    r"\s*<receiver\b[^>]*com\.dexterous\.flutterlocalnotifications\.[^>]*>.*?</receiver>\s*",
    "\n",
    text,
    flags=re.S,
)
text = re.sub(
    r"\s*<receiver\b[^>]*/com\.dexterous\.flutterlocalnotifications[^>]*/>\s*",
    "\n",
    text,
    flags=re.S,
)
text = re.sub(
    r"\s*<receiver\b[^>]*com\.dexterous\.flutterlocalnotifications\.[^>]*/>\s*",
    "\n",
    text,
    flags=re.S,
)
text = text.replace('            android:showWhenLocked="true"\n', '')
text = text.replace('            android:turnScreenOn="true"\n', '')
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
text = re.sub(
    r"^\s*isCoreLibraryDesugaringEnabled\s*=\s*true\s*\n?",
    "",
    text,
    flags=re.M,
)
text = re.sub(
    r"\n\s*dependencies\s*\{\s*coreLibraryDesugaring\([^\n]+\)\s*\}\s*\Z",
    "\n",
    text,
    flags=re.S,
)
build.write_text(text, encoding="utf-8")

registrant = Path("android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java")
if registrant.exists():
    generated = registrant.read_text(encoding="utf-8")
    generated = re.sub(
        r"\s*try \{\s*flutterEngine\.getPlugins\(\)\.add\(new [^;]*(?:flutterlocalnotifications|FlutterLocalNotifications)[^;]*;\s*\} catch \(Exception e\) \{.*?\}\s*",
        "\n",
        generated,
        flags=re.S | re.I,
    )
    generated = re.sub(
        r"\s*try \{\s*flutterEngine\.getPlugins\(\)\.add\(new [^;]*(?:flutter_timezone|FlutterTimezone)[^;]*;\s*\} catch \(Exception e\) \{.*?\}\s*",
        "\n",
        generated,
        flags=re.S | re.I,
    )
    registrant.write_text(generated, encoding="utf-8")

main_activity_root = Path("android/app/src/main/kotlin")
target_main_activity = (
    main_activity_root / Path(*ANDROID_PACKAGE.split(".")) / "MainActivity.kt"
)
target_main_activity.parent.mkdir(parents=True, exist_ok=True)
for candidate in main_activity_root.rglob("MainActivity.kt"):
    if candidate != target_main_activity:
        candidate.unlink()

expected_main_activity = (
    f"package {ANDROID_PACKAGE}\n\n"
    "import io.flutter.embedding.android.FlutterActivity\n\n"
    "class MainActivity : FlutterActivity()\n"
)
if not target_main_activity.exists():
    target_main_activity.write_text(expected_main_activity, encoding="utf-8")

main_activity_text = target_main_activity.read_text(encoding="utf-8")
for forbidden in (
    "play_integrity",
    "device_identity",
    "StandardIntegrityManager",
    "IntegrityManagerFactory",
    "requestStandardToken",
):
    if forbidden in main_activity_text:
        raise SystemExit(f"Forbidden server verification integration remains: {forbidden}")
