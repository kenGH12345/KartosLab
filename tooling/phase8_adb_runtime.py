#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""PHASE 8 — real Android (adb) Chinese runtime evidence.

Flutter text is often NOT exposed to uiautomator. This script:
1) launches via explicit MainActivity
2) captures Home
3) lifecycle background/resume
4) taps Home grid by coordinates (Pixel Tablet 2560x1600 landscape)
5) drag / back / screenshots
"""
from __future__ import annotations

import os
import subprocess
import time
from pathlib import Path

DEV = "emulator-5554"
PKG = "com.demo.kratos"
ACTIVITY = "com.demo.kratos/.MainActivity"
OUT = Path("requirements/localization/android_evidence")
OUT.mkdir(parents=True, exist_ok=True)
SDK = Path(os.environ.get("LOCALAPPDATA", "")) / "Android" / "sdk"
ADB = str(SDK / "platform-tools" / "adb.exe")


def adb(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [ADB, "-s", DEV, *args],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )


def cap(name: str) -> None:
    adb("shell", "screencap", "-p", f"/sdcard/{name}.png")
    adb("pull", f"/sdcard/{name}.png", str(OUT / f"{name}.png"))
    p = OUT / f"{name}.png"
    print(f"CAP {name} bytes={p.stat().st_size if p.exists() else 0}")


def launch() -> None:
    adb("shell", "am", "force-stop", PKG)
    time.sleep(0.4)
    adb("shell", "am", "start", "-n", ACTIVITY, "-a", "android.intent.action.MAIN")
    time.sleep(4.0)
    fg = adb("shell", "dumpsys", "activity", "activities")
    ok = PKG in (fg.stdout or "")
    print(f"LAUNCH foreground_has_pkg={ok}")


def back() -> None:
    adb("shell", "input", "keyevent", "4")
    time.sleep(1.2)


def tap(x: int, y: int) -> None:
    print(f"TAP {x},{y}")
    adb("shell", "input", "tap", str(x), str(y))
    time.sleep(2.0)


def swipe(x1: int, y1: int, x2: int, y2: int, ms: int = 350) -> None:
    adb("shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(ms))
    time.sleep(0.8)


def scroll_home(n: int = 1) -> None:
    for _ in range(n):
        swipe(1280, 1200, 1280, 450, 450)
        time.sleep(0.5)


# Pixel Tablet 2560x1600 — Home cards are ~4-col grid under 力学.
# Empirically calibrated from live Home screenshots (content centered ~maxWidth 1200).
# Columns centers approx: 520, 980, 1440, 1900 (adjusted for tablet chrome)
# First card row y ~ 620
GRID = {
    # Mechanics row1
    "forces": (520, 620),
    "collision-lab": (980, 620),
    "vector-addition": (1440, 620),
    "energy-skate-park": (1900, 620),
    # Mechanics row2
    "curve-fitting": (520, 820),
    "gravity-force-lab-basics": (980, 820),
    "gravity-force-lab": (1440, 820),
    "masses-and-springs-basics": (1900, 820),
}

# After scrolling down, approximate high-risk targets (best-effort; verified by screenshot).
SCROLL_TARGETS = [
    # scroll count, then tap
    (2, "density", 520, 700),
    (2, "buoyancy", 980, 700),
    (3, "circuit", 520, 900),
    (3, "cck-ac-virtual-lab", 980, 900),
    (4, "gas-properties", 1440, 800),
    (5, "optics", 520, 700),
    (5, "wave-interference", 980, 700),
    (5, "fourier-making-waves", 1440, 900),
    (6, "quantum-measurement", 520, 800),
    (6, "quantum-wave-interference", 980, 800),
    (7, "molarity", 520, 700),
    (7, "ph-scale", 980, 700),
    (7, "acid-base-solutions", 1440, 700),
    (8, "balancing-chemical-equations", 520, 900),
    (8, "states-of-matter", 980, 900),
    (8, "build-an-atom", 1440, 900),
]


def path_sim(sid: str, x: int, y: int, *, relaunch: bool = True, scrolls: int = 0) -> str:
    if relaunch:
        launch()
    if scrolls:
        scroll_home(scrolls)
    time.sleep(0.5)
    tap(x, y)
    cap(f"10_{sid}_enter")
    swipe(900, 750, 1150, 900, 400)
    cap(f"11_{sid}_drag")
    tap(2420, 1420)
    cap(f"12_{sid}_after_interact")
    back()
    time.sleep(1.0)
    cap(f"13_{sid}_back_home")
    dump = adb("shell", "dumpsys", "window", "windows")
    on_pkg = PKG in (dump.stdout or "")
    return f"{sid}={'OK' if on_pkg else 'BACK_AMBIGUOUS'}"


def main() -> None:
    launch()
    cap("01_home")

    # lifecycle
    adb("shell", "input", "keyevent", "3")  # HOME
    time.sleep(2)
    adb("shell", "am", "start", "-n", ACTIVITY)
    time.sleep(3.5)
    cap("02_home_after_resume")

    results: list[str] = []

    for sid, (x, y) in [
        ("collision-lab", GRID["collision-lab"]),
        ("vector-addition", GRID["vector-addition"]),
        ("forces", GRID["forces"]),
    ]:
        results.append(path_sim(sid, x, y))

    for scrolls, sid, x, y in SCROLL_TARGETS:
        results.append(path_sim(sid, x, y, scrolls=scrolls))

    log = adb("logcat", "-d", "-t", "400", "*:E")
    err = "\n".join(
        ln
        for ln in (log.stdout or "").splitlines()
        if "com.demo.kratos" in ln or "FATAL EXCEPTION" in ln
    )
    (OUT / "logcat_kratos_errors.txt").write_text(err, encoding="utf-8")
    (OUT / "adb_path_results.txt").write_text("\n".join(results) + "\n", encoding="utf-8")
    print("RESULTS:")
    for r in results:
        print(r)
    print("DONE")


if __name__ == "__main__":
    main()
