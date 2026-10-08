from pathlib import Path
import re
p = Path("requirements/localization/GLOBAL_ZH_GOLDEN_MATRIX.md")
t = p.read_text(encoding="utf-8")
t = re.sub(r"\\zh/home/([a-z0-9-]+)_default\.png\\", r"`zh/home/\1_default.png`", t)
t = t.replace("> PHASE 7B · Real PNG captures", "> PHASE 7C · Real PNG captures")
p.write_text(t, encoding="utf-8")
for i, line in enumerate(p.read_text(encoding="utf-8").splitlines(), 1):
    if any(x in line for x in ("acid-base", "beers-law", "circuit |", "PHASE 7", "PENDING", "molarity |", "states-of-matter |")):
        print(i, line)
