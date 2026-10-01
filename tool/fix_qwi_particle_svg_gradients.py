"""Rewrite particle SVG radialGradients to objectBoundingBox for flutter_svg."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "assets/simulations/quantum_wave_interference/images"
FILES = ["photon.svg", "electron.svg", "neutron.svg", "heliumAtom.svg"]


def collect_stops(text: str) -> dict[str, str]:
    stops: dict[str, str] = {}
    for m in re.finditer(
        r'<radialGradient\b([^>]*)>(.*?)</radialGradient>',
        text,
        re.S,
    ):
        attrs, body = m.group(1), m.group(2)
        gid = re.search(r'\bid="([^"]+)"', attrs)
        if gid:
            stops[gid.group(1)] = "".join(re.findall(r"<stop[^/]*/>", body))
    return stops


def rewrite(text: str) -> str:
    stop_map = collect_stops(text)

    # Resolve self-closing xlink gradients into full gradients first.
    def expand_self_closing(m: re.Match[str]) -> str:
        attrs = m.group(1)
        gid = re.search(r'\bid="([^"]+)"', attrs)
        href = re.search(r'xlink:href="#([^"]+)"', attrs)
        if not gid or not href or href.group(1) not in stop_map:
            return m.group(0)
        body = stop_map[href.group(1)]
        stop_map[gid.group(1)] = body
        return (
            f'<radialGradient id="{gid.group(1)}" gradientUnits="objectBoundingBox" '
            f'cx="0.35" cy="0.32" r="0.75">{body}</radialGradient>'
        )

    text = re.sub(
        r"<radialGradient\b([^>]*)\s*/>",
        expand_self_closing,
        text,
    )

    # Refresh stops after expansions
    stop_map = collect_stops(text)

    def simplify(m: re.Match[str]) -> str:
        attrs, body = m.group(1), m.group(2)
        gid = re.search(r'\bid="([^"]+)"', attrs)
        if not gid:
            return m.group(0)
        stops = "".join(re.findall(r"<stop[^/]*/>", body)) or stop_map.get(gid.group(1), "")
        if not stops:
            return m.group(0)
        return (
            f'<radialGradient id="{gid.group(1)}" gradientUnits="objectBoundingBox" '
            f'cx="0.35" cy="0.32" r="0.75">{stops}</radialGradient>'
        )

    text = re.sub(
        r"<radialGradient\b([^>]*)>(.*?)</radialGradient>",
        simplify,
        text,
        flags=re.S,
    )
    return text


def main() -> None:
    for name in FILES:
        path = ROOT / name
        original = path.read_text(encoding="utf-8")
        fixed = rewrite(original)
        path.write_text(fixed, encoding="utf-8")
        print(name, "userSpaceOnUse left:", fixed.count("userSpaceOnUse"), "xlink left:", fixed.count("xlink:href"))


if __name__ == "__main__":
    main()
