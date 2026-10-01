"""Inline CSS from <style> into SVG presentation attributes for flutter_svg."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(
    r"D:\OneDrive\Desktop\KartosLab\KartosLab\assets\simulations\membrane_transport\images"
)

PROP_MAP = {
    "fill": "fill",
    "stroke": "stroke",
    "stroke-width": "stroke-width",
    "stroke-miterlimit": "stroke-miterlimit",
    "stroke-linecap": "stroke-linecap",
    "stroke-linejoin": "stroke-linejoin",
    "stroke-dasharray": "stroke-dasharray",
    "stroke-dashoffset": "stroke-dashoffset",
    "opacity": "opacity",
    "fill-opacity": "fill-opacity",
    "stroke-opacity": "stroke-opacity",
    "fill-rule": "fill-rule",
    "clip-rule": "clip-rule",
    "font-size": "font-size",
    "font-family": "font-family",
    "font-weight": "font-weight",
    "text-anchor": "text-anchor",
    "display": "display",
    "visibility": "visibility",
}


def parse_style_block(css: str) -> dict[str, dict[str, str]]:
    rules: dict[str, dict[str, str]] = {}
    css = re.sub(r"/\*.*?\*/", "", css, flags=re.S)
    for m in re.finditer(r"([^{}]+)\{([^{}]+)\}", css):
        selectors = m.group(1)
        body = m.group(2)
        props: dict[str, str] = {}
        for part in body.split(";"):
            part = part.strip()
            if not part or ":" not in part:
                continue
            k, v = part.split(":", 1)
            k, v = k.strip().lower(), v.strip()
            if k in PROP_MAP:
                props[PROP_MAP[k]] = v
        for sel in selectors.split(","):
            sel = sel.strip()
            cm = re.fullmatch(r"\.([A-Za-z_][\w-]*)", sel)
            if not cm:
                continue
            name = cm.group(1)
            rules.setdefault(name, {}).update(props)
    return rules


def apply_classes(tag: str, rules: dict[str, dict[str, str]]) -> str:
    cm = re.search(r'\bclass="([^"]*)"', tag)
    if not cm:
        return tag
    classes = cm.group(1).split()
    merged: dict[str, str] = {}
    for c in classes:
        if c in rules:
            merged.update(rules[c])
    if not merged:
        return tag
    tag2 = re.sub(r'\s*class="[^"]*"', "", tag)
    for attr, val in merged.items():
        if re.search(rf'\b{re.escape(attr)}="', tag2):
            continue
        if tag2.endswith("/>"):
            tag2 = tag2[:-2] + f' {attr}="{val}" />'
        elif tag2.endswith(">"):
            tag2 = tag2[:-1] + f' {attr}="{val}">'
        else:
            tag2 = tag2 + f' {attr}="{val}"'
    return tag2


def process_svg(text: str) -> str:
    styles = re.findall(r"<style[^>]*>(.*?)</style>", text, flags=re.S | re.I)
    if not styles:
        return text
    rules: dict[str, dict[str, str]] = {}
    for s in styles:
        chunk = s.replace("&gt;", ">").replace("&lt;", "<").replace("&amp;", "&")
        parsed = parse_style_block(chunk)
        for k, v in parsed.items():
            rules.setdefault(k, {}).update(v)

    text2 = re.sub(r"<style[^>]*>.*?</style>", "", text, flags=re.S | re.I)

    def repl(m: re.Match[str]) -> str:
        return apply_classes(m.group(0), rules)

    text2 = re.sub(r"<[^>]*\bclass=\"[^\"]*\"[^>]*>", repl, text2)
    text2 = re.sub(r"\n{3,}", "\n\n", text2)
    return text2


def main() -> None:
    n = 0
    for path in sorted(ROOT.glob("*.svg")):
        raw = path.read_text(encoding="utf-8")
        if "<style" not in raw.lower():
            continue
        path.write_text(process_svg(raw), encoding="utf-8")
        n += 1
        print(f"OK {path.name}")
    print(f"DONE {n} files")
    o = (ROOT / "oxygen.svg").read_text(encoding="utf-8")
    print("oxygen has_style", "<style" in o.lower())
    m = re.search(r"<circle[^>]+>", o)
    print(m.group(0)[:220] if m else "no circle")


if __name__ == "__main__":
    main()
