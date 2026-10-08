# -*- coding: utf-8 -*-
"""Apply PHASE 7 residual Chinese string replacements."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REPLACEMENTS: list[tuple[str, str, str]] = [
    # hookes
    (
        "lib/hookes_law/view/systems/systems_visibility_panel.dart",
        "label: 'Total',",
        "label: '合力',",
    ),
    (
        "lib/hookes_law/view/systems/systems_visibility_panel.dart",
        "label: 'Components',",
        "label: '分量',",
    ),
    # forces
    (
        "lib/forces/screens/motion_screen_v2.dart",
        "label: 'Speed',",
        "label: '速度',",
    ),
    (
        "lib/forces/screens/motion_screen_v2.dart",
        "child: Text(model.stopwatchRunning ? 'Stop' : 'Start'),",
        "child: Text(model.stopwatchRunning ? '停止' : '开始'),",
    ),
    # color vision
    (
        "lib/color_vision/view/rgb_screen_view.dart",
        "label: 'Green',",
        "label: '绿',",
    ),
    (
        "lib/color_vision/view/single_bulb_screen_view.dart",
        "label: 'Bulb Color',",
        "label: '灯泡颜色',",
    ),
    (
        "lib/color_vision/view/single_bulb_screen_view.dart",
        "label: 'Filter Color',",
        "label: '滤光片颜色',",
    ),
    # collision lab
    (
        "lib/collision_lab/widgets/control_panel.dart",
        "const Text('Preset', style: TextStyle(fontWeight: FontWeight.w600)),",
        "const Text('预设', style: TextStyle(fontWeight: FontWeight.w600)),",
    ),
    (
        "lib/collision_lab/widgets/keypad_dialog.dart",
        "child: const Text('Cancel'),",
        "child: const Text('取消'),",
    ),
    (
        "lib/collision_lab/widgets/keypad_dialog.dart",
        "child: const Text('Enter'),",
        "child: const Text('确定'),",
    ),
    (
        "lib/collision_lab/widgets/momenta_diagram_panel.dart",
        "tooltip: 'Zoom out',",
        "tooltip: '缩小',",
    ),
    (
        "lib/collision_lab/widgets/momenta_diagram_panel.dart",
        "tooltip: 'Zoom in',",
        "tooltip: '放大',",
    ),
    # SOM
    (
        "lib/chemistry/states_of_matter/screens/states_of_matter_home.dart",
        "title: 'States of Matter',",
        "title: '物质状态',",
    ),
    # pH scale
    (
        "lib/chemistry/ph_scale/view/graph/ph_scale_graph_node.dart",
        "leftLabel: 'Logarithmic',",
        "leftLabel: '对数',",
    ),
    (
        "lib/chemistry/ph_scale/view/graph/ph_scale_graph_node.dart",
        "rightLabel: 'Linear',",
        "rightLabel: '线性',",
    ),
    (
        "lib/chemistry/ph_scale/view/screens/ph_scale_screen.dart",
        "title: const Text('pH Scale'),",
        "title: const Text(PhsStrings.title),",
    ),
    (
        "lib/chemistry/ph_scale/view/widgets/particle_counts_node.dart",
        "const TextSpan(text: ' Ratio'),",
        "const TextSpan(text: ' 比值'),",
    ),
    (
        "lib/chemistry/ph_scale/view/widgets/particle_counts_node.dart",
        "child: Text('Particle Counts', style: font),",
        "child: Text('粒子计数', style: font),",
    ),
    # isotopes
    (
        "lib/chemistry/isotopes_and_atomic_mass/screens/isotopes_and_atomic_mass_home.dart",
        "label: 'Isotopes',",
        "label: '同位素',",
    ),
    (
        "lib/chemistry/isotopes_and_atomic_mass/screens/isotopes_and_atomic_mass_home.dart",
        "label: 'Mixtures',",
        "label: '混合物',",
    ),
    (
        "lib/chemistry/isotopes_and_atomic_mass/screens/make_isotopes_screen.dart",
        "appBar: AppBar(title: const Text('Isotopes')),",
        "appBar: AppBar(title: const Text('同位素')),",
    ),
    (
        "lib/chemistry/isotopes_and_atomic_mass/screens/mix_isotopes_screen.dart",
        "title: 'Percent Composition',",
        "title: '百分组成',",
    ),
    (
        "lib/chemistry/isotopes_and_atomic_mass/screens/mix_isotopes_screen.dart",
        "appBar: AppBar(title: const Text('Mixtures')),",
        "appBar: AppBar(title: const Text('混合物')),",
    ),
    (
        "lib/chemistry/isotopes_and_atomic_mass/widgets/symbol_abundance_panels.dart",
        "title: 'Abundance in Nature',",
        "title: '自然界丰度',",
    ),
    (
        "lib/chemistry/isotopes_and_atomic_mass/widgets/symbol_abundance_panels.dart",
        "const Text('This Isotope', style: TextStyle(fontSize: 11)),",
        "const Text('该同位素', style: TextStyle(fontSize: 11)),",
    ),
    # BAN
    (
        "lib/chemistry/build_a_nucleus/model/half_life_readout.dart",
        "static const String unknown = 'Unknown';",
        "static const String unknown = '未知';",
    ),
    (
        "lib/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart",
        "label: 'Protons',",
        "label: BanStrings.proton,",
    ),
    (
        "lib/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart",
        "label: 'Neutrons',",
        "label: BanStrings.neutron,",
    ),
    (
        "lib/chemistry/build_a_nucleus/widgets/available_decays_panel.dart",
        "_LegendDot(color: Color(0xFF35B64A), label: 'Positron'),",
        "_LegendDot(color: Color(0xFF35B64A), label: '正电子'),",
    ),
    (
        "lib/chemistry/build_a_nucleus/widgets/half_life_info_dialog.dart",
        "tooltip: 'Close',",
        "tooltip: '关闭',",
    ),
    (
        "lib/chemistry/build_a_nucleus/widgets/half_life_stability_legend.dart",
        "static const String lessStable = 'less stable';",
        "static const String lessStable = '较不稳定';",
    ),
    (
        "lib/chemistry/build_a_nucleus/widgets/half_life_stability_legend.dart",
        "static const String moreStable = 'more stable';",
        "static const String moreStable = '较稳定';",
    ),
    (
        "lib/chemistry/build_a_nucleus/widgets/nuclide_status.dart",
        "label: 'Protons',",
        "label: BanStrings.proton,",
    ),
    (
        "lib/chemistry/build_a_nucleus/widgets/nuclide_status.dart",
        "label: 'Neutrons',",
        "label: BanStrings.neutron,",
    ),
    (
        "lib/chemistry/build_a_nucleus/widgets/show_electron_cloud_checkbox.dart",
        "const Text('Electron Cloud', style: TextStyle(fontSize: 14)),",
        "const Text('电子云', style: TextStyle(fontSize: 14)),",
    ),
    (
        "lib/chemistry/build_a_nucleus/chart_intro/widgets/chart_intro_count_panel.dart",
        "label: 'Protons',",
        "label: BanStrings.proton,",
    ),
    (
        "lib/chemistry/build_a_nucleus/chart_intro/widgets/chart_intro_count_panel.dart",
        "label: 'Neutrons',",
        "label: BanStrings.neutron,",
    ),
    (
        "lib/chemistry/build_a_nucleus/chart_intro/widgets/full_chart_dialog.dart",
        "tooltip: 'Close',",
        "tooltip: '关闭',",
    ),
    # BAA
    (
        "lib/chemistry/build_an_atom/screens/atom_screen.dart",
        "title: 'Periodic Table',",
        "title: '元素周期表',",
    ),
    (
        "lib/chemistry/build_an_atom/screens/atom_screen.dart",
        "title: 'Net Charge',",
        "title: '净电荷',",
    ),
    (
        "lib/chemistry/build_an_atom/screens/atom_screen.dart",
        "child: const Text('Back', style: TextStyle(color: Colors.white)),",
        "child: const Text('返回', style: TextStyle(color: Colors.white)),",
    ),
    (
        "lib/chemistry/build_an_atom/screens/game_screen.dart",
        "child: const Text('Back', style: TextStyle(color: Colors.white)),",
        "child: const Text('返回', style: TextStyle(color: Colors.white)),",
    ),
    (
        "lib/chemistry/build_an_atom/screens/symbol_screen.dart",
        "title: 'Periodic Table',",
        "title: '元素周期表',",
    ),
    (
        "lib/chemistry/build_an_atom/screens/symbol_screen.dart",
        "child: const Text('Back', style: TextStyle(color: Colors.white)),",
        "child: const Text('返回', style: TextStyle(color: Colors.white)),",
    ),
    # ABS
    (
        "lib/chemistry/acid_base_solutions/view/abs_views_panel.dart",
        "label: 'Particles',",
        "label: '粒子',",
    ),
    (
        "lib/chemistry/acid_base_solutions/view/abs_views_panel.dart",
        "label: 'Graph',",
        "label: '图像',",
    ),
    (
        "lib/chemistry/acid_base_solutions/view/abs_views_panel.dart",
        "label: 'Hide Views',",
        "label: '隐藏视图',",
    ),
    # CLB
    (
        "lib/capacitor_lab_basics/common/widgets/clb_time_control_node.dart",
        "label: 'Normal',",
        "label: '正常',",
    ),
    (
        "lib/capacitor_lab_basics/common/widgets/clb_time_control_node.dart",
        "label: 'Slow',",
        "label: '慢速',",
    ),
    # buoyancy
    (
        "lib/buoyancy/shapes/view/buoyancy_shapes_screen.dart",
        "title: const Text('Shapes'),",
        "title: const Text(BuoyancyStrings.shapes),",
    ),
    (
        "lib/buoyancy/shapes/view/buoyancy_shapes_screen.dart",
        "child: const Text('Close'),",
        "child: const Text('关闭'),",
    ),
    (
        "lib/buoyancy/applications/view/buoyancy_applications_screen.dart",
        "const Text('Bottle',",
        "Text(BuoyancyStrings.materialName('bottle'),",
    ),
    (
        "lib/buoyancy/applications/view/buoyancy_applications_screen.dart",
        "const Text('Material Inside', style: TextStyle(fontSize: 11)),",
        "const Text('内部材料', style: TextStyle(fontSize: 11)),",
    ),
    # beers law a11y
    (
        "lib/beers_law_lab/view/beers_law_cuvette_node.dart",
        "label: 'Cuvette width',",
        "label: '比色皿宽度',",
    ),
    (
        "lib/beers_law_lab/view/beers_law_detector_node.dart",
        "label: 'Detector reading $_valueText',",
        "label: '探测器读数 $_valueText',",
    ),
    (
        "lib/beers_law_lab/view/beers_law_detector_node.dart",
        "label: 'Detector probe',",
        "label: '探测器探针',",
    ),
    (
        "lib/beers_law_lab/view/beers_law_light_node.dart",
        "label: 'Light',",
        "label: '光源',",
    ),
    (
        "lib/beers_law_lab/view/beers_law_ruler_node.dart",
        "label: 'Ruler',",
        "label: '直尺',",
    ),
    # BCE
    (
        "lib/balancing_chemical_equations/game/game_feedback_node.dart",
        "label: model.showWhy ? 'Hide Why' : 'Show Why',",
        "label: model.showWhy ? '隐藏原因' : '显示原因',",
    ),
    # astronomy
    (
        "lib/astronomy/my_solar_system/screens/my_solar_system_screen.dart",
        "label: 'Orbital System',",
        "label: '轨道系统',",
    ),
    (
        "lib/astronomy/gravity_and_orbits/model/mode_config.dart",
        "tickLabel: 'Earth',",
        "tickLabel: '地球',",
    ),
    (
        "lib/astronomy/gravity_and_orbits/model/mode_config.dart",
        "tickLabel: 'Our Moon',",
        "tickLabel: '月球',",
    ),
    (
        "lib/astronomy/gravity_and_orbits/model/mode_config.dart",
        "tickLabel: 'Space Station',",
        "tickLabel: '空间站',",
    ),
    # semantics internal — keep but Chinese for consistency
    (
        "lib/bending_light/screens/bending_light_viewport.dart",
        "label: 'BendingLightViewport',",
        "label: '光的折射视口',",
    ),
]

IMPORTS: list[tuple[str, str]] = [
    (
        "lib/chemistry/ph_scale/view/screens/ph_scale_screen.dart",
        "import 'package:kratos/chemistry/ph_scale/phs_strings.dart';\n",
    ),
    (
        "lib/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart",
        "import 'package:kratos/chemistry/build_a_nucleus/ban_strings.dart';\n",
    ),
    (
        "lib/chemistry/build_a_nucleus/widgets/nuclide_status.dart",
        "import 'package:kratos/chemistry/build_a_nucleus/ban_strings.dart';\n",
    ),
    (
        "lib/chemistry/build_a_nucleus/chart_intro/widgets/chart_intro_count_panel.dart",
        "import 'package:kratos/chemistry/build_a_nucleus/ban_strings.dart';\n",
    ),
    (
        "lib/buoyancy/shapes/view/buoyancy_shapes_screen.dart",
        "import 'package:kratos/buoyancy/buoyancy_strings.dart';\n",
    ),
]


def ensure_import(path: Path, import_line: str) -> None:
    text = path.read_text(encoding="utf-8")
    if import_line.strip() in text:
        return
    # insert after last import
    lines = text.splitlines(keepends=True)
    idx = 0
    for i, ln in enumerate(lines):
        if ln.startswith("import "):
            idx = i + 1
    lines.insert(idx, import_line if import_line.endswith("\n") else import_line + "\n")
    path.write_text("".join(lines), encoding="utf-8")


def main() -> None:
    ok = 0
    miss = 0
    for rel, old, new in REPLACEMENTS:
        path = ROOT / rel
        text = path.read_text(encoding="utf-8")
        if old not in text:
            print("MISS", rel, repr(old[:60]))
            miss += 1
            continue
        # replace_all for Earth/Moon which appear multiple times
        count = text.count(old)
        path.write_text(text.replace(old, new), encoding="utf-8")
        ok += count
        print("OK", rel, count)
    for rel, imp in IMPORTS:
        ensure_import(ROOT / rel, imp)
        print("IMPORT", rel)
    print(f"done ok_replacements={ok} miss={miss}")


if __name__ == "__main__":
    main()
