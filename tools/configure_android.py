import re
import shutil
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

# MİZAN GLOBAL does not ship a notification/alarm subsystem. Remove stale
# platform capabilities if they exist in an older Android tree. Monetization
# permissions and metadata are deliberately preserved.
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
# These were required only by the removed notification plugin.
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

# Do not regenerate MainActivity: it contains the device identity and Play
# Integrity MethodChannels used by promo/reward anti-abuse. Accidentally
# replacing it with an empty FlutterActivity silently disables production
# entitlement verification, so treat its absence as a configuration failure.
if not target_main_activity.exists():
    raise SystemExit(
        "Missing monetization-aware MainActivity.kt; refusing to generate a weaker replacement."
    )
main_activity_text = target_main_activity.read_text(encoding="utf-8")
required_native_markers = (
    "device_identity",
    "play_integrity",
    "requestStandardToken",
    "StandardIntegrityManager",
)
missing = [marker for marker in required_native_markers if marker not in main_activity_text]
if missing:
    raise SystemExit(
        "MainActivity.kt is missing monetization security integration: " + ", ".join(missing)
    )
