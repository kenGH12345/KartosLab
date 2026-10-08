#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""PHASE 8 live paths while `flutter run` keeps the process attached."""
from __future__ import annotations

import os
import subprocess
import time
from pathlib import Path

DEV = "emulator-5554"
PKG = "com.demo.kratos"
OUT = Path("requirements/localization/android_evidence")
OUT.mkdir(parents=True, exist_ok=True)
ADB = str(Path(os.environ["LOCALAPPDATA"]) / "Android/sdk/platform-tools/adb.exe")


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


def tap(x: int, y: int) -> None:
    print(f"TAP {x},{y}")
    adb("shell", "input", "tap", str(x), str(y))
    time.sleep(2.2)


def swipe(x1, y1, x2, y2, ms=400) -> None:
    adb("shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(ms))
    time.sleep(0.9)


def back() -> None:
    adb("shell", "input", "keyevent", "4")
    time.sleep(1.4)


def ensure_app() -> bool:
    dump = adb("shell", "dumpsys", "activity", "activities").stdout or ""
    return "com.demo.kratos/.MainActivity" in dump and "topResumedActivity" in dump


def scroll(n: int) -> None:
    for _ in range(n):
        swipe(1280, 1250, 1280, 420, 450)


def path(sid: str, x: int, y: int, scrolls: int = 0) -> str:
    # Return to top of Home via repeated back then relaunch is avoided — use back until home.
    for _ in range(3):
        back()
    # Bring app front if needed
    adb("shell", "am", "start", "-n", "com.demo.kratos/.MainActivity")
    time.sleep(2.0)
    if scrolls:
        scroll(scrolls)
    tap(x, y)
    time.sleep(1.5)
    cap(f"10_{sid}_enter")
    swipe(950, 780, 1200, 950, 400)
    cap(f"11_{sid}_drag")
    # Reset button often bottom-right
    tap(2450, 1450)
    time.sleep(1.0)
    cap(f"12_{sid}_after_interact")
    back()
    time.sleep(1.2)
    cap(f"13_{sid}_back_home")
    ok = ensure_app()
    return f"{sid}={'OK' if ok else 'FAIL'}"


def main() -> None:
    if not ensure_app():
        print("APP_NOT_FOREGROUND")
        return
    cap("01_home_live")

    # lifecycle
    adb("shell", "input", "keyevent", "3")
    time.sleep(2)
    adb("shell", "am", "start", "-n", "com.demo.kratos/.MainActivity")
    time.sleep(3)
    cap("02_home_after_resume")
    print(f"resume_ok={ensure_app()}")

    results = []
    # Mechanics visible
    results.append(path("collision-lab", 980, 620))
    results.append(path("vector-addition", 1440, 620))
    results.append(path("forces", 520, 620))

    # High-risk scrolled (best-effort coords)
    targets = [
        (2, "buoyancy", 980, 720),
        (2, "density", 520, 720),
        (3, "circuit", 520, 900),
        (3, "cck-ac-virtual-lab", 980, 900),
        (4, "gas-properties", 1440, 820),
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
    for scrolls, sid, x, y in targets:
        results.append(path(sid, x, y, scrolls=scrolls))

    (OUT / "adb_path_results.txt").write_text("\n".join(results) + "\n", encoding="utf-8")
    print("RESULTS:")
    for r in results:
        print(r)
    print("DONE")


if __name__ == "__main__":
    main()
