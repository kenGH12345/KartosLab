"""Make screen-icon SVGs flutter_svg friendly: inline styles, expand xlink, simplify radials."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "assets/simulations/quantum_wave_interference/images"
FILES = [
    "experimentScreenIcon.svg",
    "highIntensityScreenIcon.svg",
    "singleParticlesScreenIcon.svg",
]


def collect_stops(text: str) -> dict[str, str]:
    stops: dict[str, str] = {}
    for kind in ("linearGradient", "radialGradient"):
        for m in re.finditer(rf"<{kind}\b([^>]*)>(.*?)</{kind}>", text, re.S):
            attrs, body = m.group(1), m.group(2)
            gid = re.search(r'\bid="([^"]+)"', attrs)
            if gid:
                stops[gid.group(1)] = "".join(re.findall(r"<stop[^/]*/>", body))
    return stops


def expand_self_closing_xlink(text: str) -> str:
    stop_map = collect_stops(text)

    def repl(m: re.Match[str]) -> str:
        kind, attrs = m.group(1), m.group(2)
        gid = re.search(r'\bid="([^"]+)"', attrs)
        href = re.search(r'xlink:href="#([^"]+)"', attrs)
        if not gid or not href or href.group(1) not in stop_map:
            return m.group(0)
        body = stop_map[href.group(1)]
        # keep non-xlink attrs that matter for linear gradients
        clean = re.sub(r'\s*xlink:href="#[^"]+"', "", attrs)
        clean = re.sub(r"\s+", " ", clean).strip()
        return f"<{kind} {clean}>{body}</{kind}>"

    return re.sub(r"<(linearGradient|radialGradient)\b([^>]*)\s*/>", repl, text)


def simplify_radials(text: str) -> str:
    def repl(m: re.Match[str]) -> str:
        attrs, body = m.group(1), m.group(2)
        gid = re.search(r'\bid="([^"]+)"', attrs)
        stops = "".join(re.findall(r"<stop[^/]*/>", body))
        if not gid or not stops:
            return m.group(0)
        # Keep simple objectBoundingBox; strip broken absolute transforms
        if "gradientTransform" in attrs or 'gradientUnits="userSpaceOnUse"' in attrs:
            return (
                f'<radialGradient id="{gid.group(1)}" gradientUnits="objectBoundingBox" '
                f'cx="0.35" cy="0.32" r="0.75">{stops}</radialGradient>'
            )
        return m.group(0)

    return re.sub(r"<radialGradient\b([^>]*)>(.*?)</radialGradient>", repl, text, flags=re.S)


def fill_bare_paths(text: str) -> str:
    # Experiment trap body path without fill → medium grey (not pure black silhouette)
    text = re.sub(
        r'(<path d="M223\.35,82\.94[^"]+")(\s*/>)',
        r'\1 fill="#6a6a6a"\2',
        text,
    )
    return text


def main() -> None:
    for name in FILES:
        path = ROOT / name
        text = path.read_text(encoding="utf-8")
        text = expand_self_closing_xlink(text)
        text = simplify_radials(text)
        text = fill_bare_paths(text)
        path.write_text(text, encoding="utf-8")
        print(
            name,
            "xlink:",
            text.count("xlink:href"),
            "userSpace radial:",
            len(re.findall(r'radialGradient[^>]*userSpaceOnUse', text)),
        )


if __name__ == "__main__":
    main()
