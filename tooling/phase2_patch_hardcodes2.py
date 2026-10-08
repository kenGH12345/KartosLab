#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def sub(rel: str, pairs: list[tuple[str, str]], imports: list[str] | None = None):
    p = ROOT / rel
    t = p.read_text(encoding="utf-8")
    if imports:
        for imp in imports:
            if imp not in t:
                t = imp + "\n" + t
    for a, b in pairs:
        if a not in t:
            print("MISS", rel, a[:60])
        t = t.replace(a, b)
    p.write_text(t, encoding="utf-8")
    print("OK", rel)


sub(
    "lib/masses_and_springs_basics/widgets/spring_constant_control.dart",
    [("'Spring Constant'", "MasbStrings.title.contains('') and '劲度系数' or '劲度系数'")],
)
# fix botched - rewrite properly
p = ROOT / "lib/masses_and_springs_basics/widgets/spring_constant_control.dart"
t = p.read_text(encoding="utf-8")
t = t.replace(
    "MasbStrings.title.contains('') and '劲度系数' or '劲度系数'",
    "劲度系数",
)
# if still English:
t = t.replace("'Spring Constant'", "'劲度系数'")
if "masb_strings" not in t:
    t = "import '../masb_strings.dart';\n" + t
p.write_text(t, encoding="utf-8")
print("spring constant title fixed")

sub(
    "lib/forces/screens/forces_home.dart",
    [
        ("title: 'Forces and Motion: Basics'", "title: ForcesStrings.forcesHomeTitle"),
        ("label: 'Net Force'", "label: ForcesStrings.netForceCard"),
    ],
    ["import 'package:kratos/forces/config/forces_strings.dart';"],
)

sub(
    "lib/forces/screens/motion_screen_v2.dart",
    [
        ("'Sum of Forces = 0'", "'合力 = 0'"),
        ("'Sum of Forces'", "'合力'"),
        ("Text('None',", "Text(ForcesStrings.frictionLabel.trim().isEmpty ? '无' : '无',"),
        ("Text('Lots',", "Text('很多',"),
        ("'Applied Force'", "'外力'"),
        ("model.showValues ? '${sum.round()} N' : 'Sum of Forces'",
         "model.showValues ? '${sum.round()} N' : '合力'"),
    ],
)

# Fix botched None line - simplify
p = ROOT / "lib/forces/screens/motion_screen_v2.dart"
t = p.read_text(encoding="utf-8")
t = t.replace(
    "Text(ForcesStrings.frictionLabel.trim().isEmpty ? '无' : '无',",
    "Text('无',",
)
p.write_text(t, encoding="utf-8")

sub(
    "lib/forces/screens/net_force_screen.dart",
    [
        ("? (blueRed ? 'Blue Wins!' : 'Purple Wins!')",
         "? (blueRed ? '蓝队获胜!' : '紫队获胜!')"),
        (": (blueRed ? 'Red Wins!' : 'Orange Wins!')",
         ": (blueRed ? '红队获胜!' : '橙队获胜!')"),
        ("'Sum of Forces = 0'", "'合力 = 0'"),
        ("'Sum of Forces'", "'合力'"),
    ],
)

sub(
    "lib/projectile_motion/widgets/pm_panels.dart",
    [
        ("Text('Diameter: ${_trim(model.projectileDiameter)} m'",
         "Text('${PmStrings.diameter}: ${_trim(model.projectileDiameter)} m'"),
        ("Text('Height: ${model.cannonHeight.toStringAsFixed(2)} m'",
         "Text('${PmStrings.height}: ${model.cannonHeight.toStringAsFixed(2)} m'"),
        ("Text('Cannon Angle: ${model.cannonAngle.toStringAsFixed(0)}°'",
         "Text('${PmStrings.cannonAngle}: ${model.cannonAngle.toStringAsFixed(0)}°'"),
        ("Text('Speed: ${model.initialSpeed.toStringAsFixed(0)} m/s'",
         "Text('${PmStrings.speed}: ${model.initialSpeed.toStringAsFixed(0)} m/s'"),
        ("'Drag Coefficient: ${model.projectileDragCoefficient.toStringAsFixed(2)}'",
         "'${PmStrings.dragCoefficient}: ${model.projectileDragCoefficient.toStringAsFixed(2)}'"),
    ],
)

sub(
    "lib/balancing_act/view/ba_game_screen.dart",
    [
        ("Text('Timer', style: PhetFont.of(14))",
         "Text('计时器', style: PhetFont.of(14))"),
        ("Text('Time: ${m.elapsedTime.toStringAsFixed(0)} s'",
         "Text('时间: ${m.elapsedTime.toStringAsFixed(0)} s'"),
    ],
)

sub(
    "lib/gravity_force_lab/widgets/gfl_keyboard_help.dart",
    [
        ("_Row('Grab or release ruler', 'Enter / Space')",
         "_Row('抓取或释放尺子', 'Enter / Space')"),
        ("child: const Text('Close')", "child: const Text('关闭')"),
    ],
)

sub(
    "lib/gravity_force_lab/widgets/ruler_widget.dart",
    [
        ("? 'Use arrow keys or WASD to move. Press Enter to release.'",
         "? '使用方向键或 WASD 移动。按 Enter 释放。'"),
        (": 'Press Enter or Space to grab.'",
         ": '按 Enter 或空格键抓取。'"),
    ],
)

sub(
    "lib/gravity_force_lab/model/force_notation.dart",
    [
        ("'Force on $thisObject by $otherObject = $value N'",
         "'$otherObject 对 $thisObject 的力 = $value N'"),
        ("'Force on $thisObject by $otherObject'",
         "'$otherObject 对 $thisObject 的力'"),
    ],
)

# Hooke's visibility panels
sub(
    "lib/hookes_law/view/energy/energy_visibility_panel.dart",
    [
        ("'Bar Graph'", "'柱状图'"),
        ("'Energy Plot'", "'能量图像'"),
        ("'Force Plot'", "'力的图像'"),
        ("label: 'Applied Force'", "label: '外力'"),
        ("label: 'Equilibrium Position'", "label: '平衡位置'"),
    ],
)
sub(
    "lib/hookes_law/view/systems/systems_visibility_panel.dart",
    [
        ("'Applied Force'", "'外力'"),
        ("'Spring Force'", "'弹簧力'"),
        ("'Equilibrium Position'", "'平衡位置'"),
    ],
)
sub(
    "lib/hookes_law/view/intro/intro_visibility_panel.dart",
    [
        ("label: 'Applied Force'", "label: '外力'"),
        ("label: 'Spring Force'", "label: '弹簧力'"),
    ],
)
sub(
    "lib/hookes_law/view/energy/energy_graph_painter.dart",
    [
        ("'Potential Energy'", "'势能'"),
        ("'Displacement'", "'位移'"),
        ("'Applied Force'", "'外力'"),
    ],
)

print("done")
