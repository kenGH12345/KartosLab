import json
import subprocess
import pathlib

root = pathlib.Path("requirements/req-molecule-polarity/visual-qa")
names = [
    "01_TwoAtoms_initial",
    "05_TwoAtoms_rotated",
    "12_TwoAtoms_en_modified",
    "13_TwoAtoms_hints_hidden_after_rotate",
]
for name in names:
    o = root / "ORIGINAL" / f"{name}.png"
    f = root / "FLUTTER" / f"{name}.png"
    d = root / "DIFF" / f"{name}.png"
    if not o.exists() or not f.exists():
        print(name, "MISSING", "orig", o.exists(), "flut", f.exists())
        continue
    r = subprocess.run(
        ["python", "tool/diff_visual_qa.py", str(o), str(f), str(d)],
        capture_output=True,
        text=True,
    )
    j = json.loads(r.stdout.strip().splitlines()[-1])
    print(
        f"{name}: delta_gt32={j['pct_pixels_delta_gt32']}% mean={j['mean_abs_diff']}"
    )
