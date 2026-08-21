#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET
from pathlib import Path

PACKAGE = "com.lefferionprime.mizanglobal"
ACTIVITY = f"{PACKAGE}/.MainActivity"
APK = Path("build/app/outputs/flutter-apk/app-release.apk")
OUT = Path("android-smoke-artifacts")
OUT.mkdir(exist_ok=True)


def run(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(args, text=True, capture_output=True)
    if check and result.returncode != 0:
        raise RuntimeError(
            f"command failed ({result.returncode}): {' '.join(args)}\n"
            f"stdout:\n{result.stdout}\nstderr:\n{result.stderr}"
        )
    return result


def adb(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    return run("adb", *args, check=check)


def dump_ui() -> ET.Element:
    adb("shell", "uiautomator", "dump", "/sdcard/mizan-ui.xml", check=False)
    adb("pull", "/sdcard/mizan-ui.xml", str(OUT / "ui.xml"))
    return ET.parse(OUT / "ui.xml").getroot()


def node_text(node: ET.Element) -> str:
    return " ".join(
        part.strip()
        for part in (node.attrib.get("text", ""), node.attrib.get("content-desc", ""))
        if part.strip()
    )


def bounds_center(bounds: str) -> tuple[int, int]:
    match = re.fullmatch(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", bounds)
    if not match:
        raise RuntimeError(f"invalid bounds: {bounds}")
    x1, y1, x2, y2 = map(int, match.groups())
    return (x1 + x2) // 2, (y1 + y2) // 2


def matching_nodes(root: ET.Element, needle: str, *, exact: bool = False):
    needle_fold = needle.casefold()
    for node in root.iter("node"):
        text = node_text(node)
        folded = text.casefold()
        if (exact and folded == needle_fold) or (not exact and needle_fold in folded):
            yield node


def wait_for_text(needle: str, timeout: float = 20.0, *, exact: bool = False) -> ET.Element:
    deadline = time.time() + timeout
    last = ""
    while time.time() < deadline:
        root = dump_ui()
        nodes = list(matching_nodes(root, needle, exact=exact))
        if nodes:
            return nodes[0]
        last = " | ".join(filter(None, (node_text(n) for n in root.iter("node"))))
        time.sleep(0.6)
    raise RuntimeError(f"UI text not found: {needle!r}; last UI={last[:3000]}")


def tap_node(node: ET.Element) -> None:
    x, y = bounds_center(node.attrib["bounds"])
    adb("shell", "input", "tap", str(x), str(y))
    time.sleep(0.5)


def tap_text(needle: str, *, exact: bool = False, timeout: float = 20.0) -> None:
    tap_node(wait_for_text(needle, timeout=timeout, exact=exact))


def tap_first_edit_text() -> None:
    root = dump_ui()
    for node in root.iter("node"):
        if node.attrib.get("class") == "android.widget.EditText":
            tap_node(node)
            return
    for node in root.iter("node"):
        if node.attrib.get("focusable") == "true" and node.attrib.get("enabled") == "true":
            text = node_text(node).casefold()
            if "search" in text or "ara" in text:
                tap_node(node)
                return
    raise RuntimeError("search text field not found")


def type_search(value: str) -> None:
    tap_first_edit_text()
    adb("shell", "input", "keyevent", "KEYCODE_MOVE_END", check=False)
    adb("shell", "input", "text", value)
    time.sleep(0.8)


def screenshot(name: str) -> None:
    remote = f"/sdcard/{name}.png"
    adb("shell", "screencap", "-p", remote)
    adb("pull", remote, str(OUT / f"{name}.png"))


def swipe_to_end(max_swipes: int = 18) -> None:
    size = adb("shell", "wm", "size").stdout
    match = re.search(r"(\d+)x(\d+)", size)
    width, height = (1080, 1920) if not match else tuple(map(int, match.groups()))
    x = width // 2
    for _ in range(max_swipes):
        adb(
            "shell",
            "input",
            "swipe",
            str(x),
            str(int(height * 0.82)),
            str(x),
            str(int(height * 0.20)),
            "250",
        )
        time.sleep(0.18)


def assert_process_and_foreground(stage: str) -> None:
    pid = adb("shell", "pidof", PACKAGE).stdout.strip()
    if not pid:
        raise RuntimeError(f"{stage}: app process is not alive")
    activities = adb("shell", "dumpsys", "activity", "activities").stdout
    (OUT / f"activities-{stage}.txt").write_text(activities)
    if PACKAGE not in activities:
        raise RuntimeError(f"{stage}: package not present in activity state")


def open_and_complete_legal(label: str) -> None:
    tap_text(label)
    swipe_to_end()
    tap_text("Read", exact=True, timeout=12)


def main() -> int:
    if not APK.is_file() or APK.stat().st_size == 0:
        raise RuntimeError(f"release APK missing: {APK}")

    adb("wait-for-device")
    adb("install", "-r", str(APK))
    adb("shell", "pm", "clear", PACKAGE)
    adb("logcat", "-c")
    start = adb("shell", "am", "start", "-W", "-n", ACTIVITY)
    (OUT / "am-start.txt").write_text(start.stdout + start.stderr)

    wait_for_text("MİZAN GLOBAL", timeout=30)
    wait_for_text("Dil seç", timeout=15)
    assert_process_and_foreground("cold-start")
    screenshot("01-cold-start-setup")

    tap_text("Dil seç")
    wait_for_text("Dil ara")
    type_search("en")
    tap_text("EN", exact=True)

    tap_text("Select country")
    wait_for_text("Search by country name or code")
    type_search("TR")
    tap_text("TR", exact=True)

    tap_text("TRY", exact=False)
    wait_for_text("Search by name, ISO code, or symbol")
    type_search("AED")
    tap_text("AED", exact=False)

    wait_for_text("Complete setup")
    screenshot("02-independent-setup-en-tr-aed")
    tap_text("Complete setup")

    wait_for_text("Before You Continue", timeout=20)
    wait_for_text("Read Privacy Policy")
    wait_for_text("Read Terms of Use")
    screenshot("03-legal-consent-first-install")

    open_and_complete_legal("Read Privacy Policy")
    wait_for_text("Before You Continue")
    open_and_complete_legal("Read Terms of Use")
    wait_for_text("Before You Continue")
    tap_text("I Have Read, Understood and Accept")

    deadline = time.time() + 20
    while time.time() < deadline:
        root = dump_ui()
        if not list(matching_nodes(root, "Before You Continue", exact=True)):
            break
        time.sleep(0.6)
    else:
        raise RuntimeError("legal acceptance did not persist / consent screen remained active")

    assert_process_and_foreground("post-legal")
    screenshot("04-post-legal-main-app")

    logcat = adb("logcat", "-d").stdout
    (OUT / "logcat.txt").write_text(logcat)
    fatal = re.findall(
        rf"(?is)(FATAL EXCEPTION.*?(?:\n\s*at .*?){{0,8}}|Process:\s*{re.escape(PACKAGE)}.*?FATAL)",
        logcat,
    )
    if fatal:
        raise RuntimeError("fatal Android/Flutter crash detected in release cold-start logcat")

    print("Android release smoke passed: install, cold-start, EN+TR+AED setup, legal read/accept chain, foreground process and screenshots.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        try:
            screenshot("99-failure")
            (OUT / "failure.txt").write_text(str(exc))
            (OUT / "logcat-failure.txt").write_text(adb("logcat", "-d", check=False).stdout)
        except Exception:
            pass
        print(f"Android release smoke FAILED: {exc}", file=sys.stderr)
        raise
