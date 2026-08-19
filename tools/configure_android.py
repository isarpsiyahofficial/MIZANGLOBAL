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
required_manifest_tokens = (
    "android.permission.POST_NOTIFICATIONS",
    "android.permission.RECEIVE_BOOT_COMPLETED",
    "com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver",
    "com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver",
)
for token in required_manifest_tokens:
    if token not in text:
        raise SystemExit(f"Required notification integration is missing: {token}")
for forbidden_permission in (
    "android.permission.SCHEDULE_EXACT_ALARM",
    "android.permission.USE_EXACT_ALARM",
):
    if forbidden_permission in text:
        raise SystemExit(
            f"Exact alarm permission is not allowed for MIZAN reminders: {forbidden_permission}"
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
required_build_tokens = (
    "isCoreLibraryDesugaringEnabled = true",
    'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")',
)
for token in required_build_tokens:
    if token not in text:
        raise SystemExit(f"Required notification build integration is missing: {token}")
build.write_text(text, encoding="utf-8")

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
