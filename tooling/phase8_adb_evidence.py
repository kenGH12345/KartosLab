#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""PHASE 8 cold-start evidence (Impeller disabled). Sequential, no concurrency."""
from __future__ import annotations

import os
import subprocess
import time
from pathlib import Path

DEV = "emulator-5554"
ACT = "com.demo.kratos/.MainActivity"
OUT = Path("requirements/localization/android_evidence")
OUT.mkdir(parents=True, exist_ok=True)
ADB = str(Path(os.environ["LOCALAPPDATA"]) / "Android/sdk/platform-tools/adb.exe")


def adb(*args: str) -> str:
    r = subprocess.run([ADB, "-s", DEV, *args], capture_output=True, text=True, encoding="utf-8", errors="replace")
    return (r.stdout or "") + (r.stderr or "")


def cap(name: str) -> int:
    adb("shell", "screencap", "-p", f"/sdcard/{name}.png")
    adb("pull", f"/sdcard/{name}.png", str(OUT / f"{name}.png"))
    n = (OUT / f"{name}.png").stat().st_size
    print(f"CAP {name}={n}")
    return n


def launch(cold: bool = True) -> None:
    if cold:
        adb("shell", "am", "force-stop", "com.demo.kratos")
        time.sleep(0.5)
    out = adb("shell", "am", "start", "-W", "-n", ACT)
    print(out.strip().splitlines()[:6])
    time.sleep(3.0)


def back() -> None:
    adb("shell", "input", "keyevent", "4")
    time.sleep(1.5)


def tap(x: int, y: int) -> None:
    adb("shell", "input", "tap", str(x), str(y))
    time.sleep(2.5)


def swipe(x1, y1, x2, y2, ms=400) -> None:
    adb("shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(ms))
    time.sleep(1.0)


def path(sid: str, x: int, y: int, scrolls: int = 0) -> str:
    launch(True)
    for _ in range(scrolls):
        swipe(1280, 1250, 1280, 400, 450)
    tap(x, y)
    enter = cap(f"10_{sid}_enter")
    swipe(950, 780, 1200, 940, 400)
    drag = cap(f"11_{sid}_drag")
    tap(2450, 1450)
    reset = cap(f"12_{sid}_reset")
    back()
    home = cap(f"13_{sid}_back")
    # Heuristic: sim enter should be substantially different size from tiny splash (~35k)
    ok = enter > 80000
    return f"{sid}={'PASS' if ok else 'FAIL_ENTER'} enter={enter} drag={drag} reset={reset} back={home}"


def main() -> None:
    launch(True)
    h = cap("01_home")
    assert h > 80000, "home screenshot too small"

    adb("shell", "input", "keyevent", "3")
    time.sleep(2)
    launch(False)
    r = cap("02_home_after_resume")
    assert r > 80000, "resume screenshot too small"

    results = [
        path("collision-lab", 980, 620),
        path("vector-addition", 1440, 620),
        path("forces", 520, 620),
        path("buoyancy", 980, 720, scrolls=2),
        path("density", 520, 720, scrolls=2),
        path("circuit", 520, 900, scrolls=3),
        path("cck-ac", 980, 900, scrolls=3),
        path("gas-properties", 1440, 820, scrolls=4),
        path("optics", 520, 700, scrolls=5),
        path("wave-interference", 980, 700, scrolls=5),
        path("fourier", 1440, 900, scrolls=5),
        path("quantum-measurement", 520, 800, scrolls=6),
        path("quantum-wave", 980, 800, scrolls=6),
        path("molarity", 520, 700, scrolls=7),
        path("ph-scale", 980, 700, scrolls=7),
        path("acid-base", 1440, 700, scrolls=7),
        path("bce", 520, 900, scrolls=8),
        path("states-of-matter", 980, 900, scrolls=8),
        path("build-an-atom", 1440, 900, scrolls=8),
    ]
    (OUT / "adb_path_results.txt").write_text("\n".join(results) + "\n", encoding="utf-8")
    print("RESULTS")
    for line in results:
        print(line)
    print("DONE")


if __name__ == "__main__":
    main()
