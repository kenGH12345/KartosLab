import json
import subprocess
import pathlib

root = pathlib.Path("requirements/req-molecule-polarity/visual-qa")
for name in [
    "11_RealMolecules_hf_initial",
    "13_RealMolecules_dipoles",
    "14_RealMolecules_reset",
]:
    op = root / "ORIGINAL" / f"{name}.png"
    fp = root / "FLUTTER" / f"{name}.png"
    dp = root / "DIFF" / f"{name}.png"
    if not op.exists() or not fp.exists():
        print(name, "MISSING")
        continue
    r = subprocess.run(
        ["python", "tool/diff_visual_qa.py", str(op), str(fp), str(dp)],
        capture_output=True,
        text=True,
    )
    j = json.loads(r.stdout.strip().splitlines()[-1])
    print(
        f"{name}: delta_gt32={j['pct_pixels_delta_gt32']}% mean={j['mean_abs_diff']}"
    )
