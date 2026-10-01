"""Inline <style> class rules into SVG attributes for flutter_svg compatibility."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / (
    "assets/simulations/quantum_wave_interference/images"
)


def parse_rules(style: str) -> dict[str, dict[str, str]]:
    rules: dict[str, dict[str, str]] = {}
    for m in re.finditer(r"([^{]+)\{([^}]*)\}", style):
        selectors = m.group(1)
        body = m.group(2)
        props: dict[str, str] = {}
        for pm in re.finditer(r"([\w-]+)\s*:\s*([^;]+);", body):
            props[pm.group(1).strip()] = pm.group(2).strip()
        for cls in re.findall(r"\.([\w-]+)", selectors):
            rules.setdefault(cls, {}).update(props)
    return rules


def inline_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    style_m = re.search(r"<style[^>]*>(.*?)</style>", text, re.S | re.I)
    if not style_m:
        return False
    rules = parse_rules(style_m.group(1))

    def repl(mm: re.Match[str]) -> str:
        tag = mm.group(0)
        cm = re.search(r'class="([^"]+)"', tag)
        if not cm:
            return tag
        attrs: dict[str, str] = {}
        for c in cm.group(1).split():
            attrs.update(rules.get(c, {}))
        tag2 = re.sub(r'\s*class="[^"]+"', "", tag)
        extra = "".join(f' {k}="{v}"' for k, v in attrs.items() if f"{k}=" not in tag2)
        if tag2.endswith("/>"):
            return tag2[:-2] + extra + "/>"
        if tag2.endswith(">"):
            return tag2[:-1] + extra + ">"
        return tag2 + extra

    text2 = re.sub(
        r"<(circle|polygon|path|rect|ellipse|g|line|polyline)[^>]*class=\"[^\"]+\"[^>]*/?>",
        repl,
        text,
    )
    text2 = re.sub(r"<style[^>]*>.*?</style>\s*", "", text2, flags=re.S | re.I)
    path.write_text(text2, encoding="utf-8")
    return True


def main() -> None:
    for p in sorted(ROOT.glob("*.svg")):
        ok = inline_file(p)
        print(("inlined " if ok else "skip ") + p.name)


if __name__ == "__main__":
    main()
