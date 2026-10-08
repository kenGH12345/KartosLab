# -*- coding: utf-8 -*-
from pathlib import Path

root = Path(__file__).resolve().parents[1]


def patch(path: Path, reps: list[tuple[str, str]], import_line: str | None = None):
    if not path.exists():
        print('MISSING', path)
        return
    t = path.read_text(encoding='utf-8')
    orig = t
    for a, b in reps:
        t = t.replace(a, b)
    if t != orig and import_line and import_line not in t:
        lines = t.splitlines(True)
        insert_at = 0
        for i, l in enumerate(lines):
            if l.startswith('import '):
                insert_at = i + 1
        lines.insert(insert_at, import_line + '\n')
        t = ''.join(lines)
    if t != orig:
        path.write_text(t, encoding='utf-8')
        print('updated', path.relative_to(root))
    else:
        print('nochange', path.relative_to(root))


# ohms-law
patch(
    root / 'lib/ohms_law/view/ohms_law_screen.dart',
    [
        ('static const String title = "Ohm\'s Law";',
         'static const String title = OhmsLawStrings.title;'),
        ("static const String subtitle = '欧姆定律 · 电压 · 电阻 · 电流';",
         'static const String subtitle = OhmsLawStrings.subtitle;'),
    ],
    "import 'package:kratos/ohms_law/ohms_law_strings.dart';",
)
patch(
    root / 'lib/ohms_law/view/controls/control_panel.dart',
    [
        ("name: 'voltage'", "name: OhmsLawStrings.voltage"),
        ("semanticLabel: 'Voltage'", 'semanticLabel: OhmsLawStrings.voltage'),
        ("name: 'resistance'", "name: OhmsLawStrings.resistance"),
        ("semanticLabel: 'Resistance'", 'semanticLabel: OhmsLawStrings.resistance'),
    ],
    "import 'package:kratos/ohms_law/ohms_law_strings.dart';",
)
patch(
    root / 'lib/ohms_law/view/controls/units_radio.dart',
    [
        ("label: 'Current units'", 'label: OhmsLawStrings.currentUnits'),
        ("label: 'Milliamps (mA)'", 'label: OhmsLawStrings.milliamps'),
        ("label: 'Amps (A)'", 'label: OhmsLawStrings.amps'),
    ],
    "import 'package:kratos/ohms_law/ohms_law_strings.dart';",
)
patch(
    root / 'lib/ohms_law/view/ohms_law_play_area.dart',
    [
        ("label: 'Reset All'", 'label: OhmsLawStrings.resetAll'),
    ],
    "import 'package:kratos/ohms_law/ohms_law_strings.dart';",
)
patch(
    root / 'lib/ohms_law/view/wire_box.dart',
    [
        ("label: 'current equals \$value \$unit'",
         'label: OhmsLawStrings.currentEquals(value, unit)'),
    ],
    "import 'package:kratos/ohms_law/ohms_law_strings.dart';",
)

# Fix wire_box - the string uses interpolation differently
p = root / 'lib/ohms_law/view/wire_box.dart'
t = p.read_text(encoding='utf-8')
if "current equals" in t:
    t = t.replace(
        "label: 'current equals $value $unit',",
        'label: OhmsLawStrings.currentEquals(value, unit),',
    )
    if 'ohms_law_strings' not in t:
        t = t.replace(
            "import 'package:flutter/material.dart';\n",
            "import 'package:flutter/material.dart';\nimport 'package:kratos/ohms_law/ohms_law_strings.dart';\n",
        )
    p.write_text(t, encoding='utf-8')
    print('fixed wire_box')

# riaw
patch(
    root / 'lib/resistance_in_a_wire/view/riaw_play_area.dart',
    [("label: 'Reset All'", 'label: RiawStrings.resetAll')],
    "import 'package:kratos/resistance_in_a_wire/riaw_strings.dart';",
)
patch(
    root / 'lib/resistance_in_a_wire/view/wire_node.dart',
    [("label: 'The Wire'", 'label: RiawStrings.theWire')],
    "import 'package:kratos/resistance_in_a_wire/riaw_strings.dart';",
)
patch(
    root / 'lib/resistance_in_a_wire/view/controls/control_panel.dart',
    [
        ("final readout = 'resistance = \$formatted ohms';",
         'final readout = RiawStrings.resistanceReadout(formatted);'),
        ("name: 'resistivity'", 'name: RiawStrings.resistivity'),
        ("semanticLabel: 'rho, Resistivity'",
         'semanticLabel: RiawStrings.semanticResistivity'),
        ("name: 'length'", 'name: RiawStrings.length'),
        ("semanticLabel: 'L, Length'", 'semanticLabel: RiawStrings.semanticLength'),
        ("name: 'area'", 'name: RiawStrings.area'),
        ("semanticLabel: 'A, Area'", 'semanticLabel: RiawStrings.semanticArea'),
    ],
    "import 'package:kratos/resistance_in_a_wire/riaw_strings.dart';",
)
p = root / 'lib/resistance_in_a_wire/view/controls/control_panel.dart'
t = p.read_text(encoding='utf-8')
t = t.replace(
    "final readout = 'resistance = $formatted ohms';",
    'final readout = RiawStrings.resistanceReadout(formatted);',
)
if 'riaw_strings' not in t:
    t = t.replace(
        "import 'package:flutter/material.dart';\n",
        "import 'package:flutter/material.dart';\nimport 'package:kratos/resistance_in_a_wire/riaw_strings.dart';\n",
    )
p.write_text(t, encoding='utf-8')
print('fixed riaw control panel readout')

p = root / 'lib/resistance_in_a_wire/view/formula_equation.dart'
t = p.read_text(encoding='utf-8')
if 'Resistance Equation' in t:
    # replace long a11y string
    import re
    t2 = re.sub(
        r"label:\s*'Resistance Equation\.[^']*'",
        'label: RiawStrings.equationA11y()',
        t,
        count=1,
    )
    if 'riaw_strings' not in t2:
        t2 = t2.replace(
            "import 'package:flutter/material.dart';\n",
            "import 'package:flutter/material.dart';\nimport 'package:kratos/resistance_in_a_wire/riaw_strings.dart';\n",
        )
    p.write_text(t2, encoding='utf-8')
    print('fixed formula_equation')

# faradays
patch(
    root / 'lib/faradays_law/view/faradays_law_screen.dart',
    [
        ('static const String title = "Faraday\'s Law";',
         'static const String title = FaradaysLawStrings.title;'),
        ("static const String subtitle = '磁铁 · 线圈 · 感应电动势';",
         'static const String subtitle = FaradaysLawStrings.subtitle;'),
    ],
    "import 'package:kratos/faradays_law/faradays_law_strings.dart';",
)
patch(
    root / 'lib/faradays_law/view/controls/control_panel.dart',
    [
        ("label: 'Voltmeter'", 'label: FaradaysLawStrings.voltmeter'),
        ("label: 'Field Lines'", 'label: FaradaysLawStrings.fieldLines'),
    ],
    "import 'package:kratos/faradays_law/faradays_law_strings.dart';",
)
patch(
    root / 'lib/faradays_law/view/controls/flip_magnet_button.dart',
    [("label: 'Flip Magnet'", 'label: FaradaysLawStrings.flipMagnet')],
    "import 'package:kratos/faradays_law/faradays_law_strings.dart';",
)
patch(
    root / 'lib/faradays_law/view/controls/coil_radio_group.dart',
    [("label: 'Circuit Mode'", 'label: FaradaysLawStrings.circuitMode')],
    "import 'package:kratos/faradays_law/faradays_law_strings.dart';",
)

# john travoltage
patch(
    root / 'lib/john_travoltage/view/john_travoltage_screen.dart',
    [
        ("static const String title = 'John Travoltage';",
         'static const String title = JtStrings.title;'),
        ("static const String subtitle = '静电 · 摩擦起电 · 放电';",
         'static const String subtitle = JtStrings.subtitle;'),
    ],
    "import 'package:kratos/john_travoltage/jt_strings.dart';",
)

# balloons
patch(
    root / 'lib/balloons_and_static_electricity/view/balloons_static_electricity_screen.dart',
    [
        ("static const String title = 'Balloons and Static Electricity';",
         'static const String title = BaseStrings.title;'),
        ("static const String subtitle = '摩擦起电 · 诱导电荷 · 静电吸引';",
         'static const String subtitle = BaseStrings.subtitle;'),
    ],
    "import 'package:kratos/balloons_and_static_electricity/base_strings.dart';",
)
patch(
    root / 'lib/balloons_and_static_electricity/view/balloons_static_electricity_view.dart',
    [
        ("semanticLabel: 'Yellow Balloon'",
         'semanticLabel: BaseStrings.yellowBalloon'),
        ("semanticLabel: 'Green Balloon'",
         'semanticLabel: BaseStrings.greenBalloon'),
    ],
    "import 'package:kratos/balloons_and_static_electricity/base_strings.dart';",
)
patch(
    root / 'lib/balloons_and_static_electricity/view/balloon_node.dart',
    [("label: widget.semanticLabel ?? 'Balloon'",
      'label: widget.semanticLabel ?? BaseStrings.balloon')],
    "import 'package:kratos/balloons_and_static_electricity/base_strings.dart';",
)
patch(
    root / 'lib/balloons_and_static_electricity/view/sweater_node.dart',
    [("label: 'Sweater'", 'label: BaseStrings.sweater')],
    "import 'package:kratos/balloons_and_static_electricity/base_strings.dart';",
)
patch(
    root / 'lib/balloons_and_static_electricity/view/wall_node.dart',
    [("label: 'Wall'", 'label: BaseStrings.wall')],
    "import 'package:kratos/balloons_and_static_electricity/base_strings.dart';",
)
patch(
    root / 'lib/balloons_and_static_electricity/view/control_panel.dart',
    [
        ("label: two ? 'Reset Balloons' : 'Reset Balloon'",
         'label: two ? BaseStrings.resetBalloons : BaseStrings.resetBalloon'),
        ("label: wallVisible ? 'Remove Wall' : 'Add Wall'",
         'label: wallVisible ? BaseStrings.removeWall : BaseStrings.addWall'),
        ("(ShowCharges.allCharges, 'Show all charges')",
         '(ShowCharges.allCharges, BaseStrings.showAllCharges)'),
        ("(ShowCharges.noCharges, 'Show no charges')",
         '(ShowCharges.noCharges, BaseStrings.showNoCharges)'),
        ("(ShowCharges.chargeDifferences, 'Show charge differences')",
         '(ShowCharges.chargeDifferences, BaseStrings.showChargeDifferences)'),
    ],
    "import 'package:kratos/balloons_and_static_electricity/base_strings.dart';",
)

# Fix balloons control panel - const list can't use non-const from other class if not const
# BaseStrings fields ARE static const so OK, but `const [` with BaseStrings might need removing const
p = root / 'lib/balloons_and_static_electricity/view/control_panel.dart'
t = p.read_text(encoding='utf-8')
t = t.replace(
    'for (final entry in const [',
    'for (final entry in [',
)
p.write_text(t, encoding='utf-8')
print('fixed balloons const list')

# magnet
patch(
    root / 'lib/magnetism/magnet_and_compass/widgets/control_panel.dart',
    [
        ("const Text('Bar Magnet'", 'Text(MacStrings.barMagnet'),
        ("const Text('Strength:'", 'Text(\'${MacStrings.strength}:\''),
        ("_check('See Inside'", '_check(MacStrings.seeInside'),
        ("_check('Earth'", '_check(MacStrings.earth'),
        ("child: const Text('Flip Polarity'",
         'child: Text(MacStrings.flipPolarity'),
        ("const Expanded(child: Text('Compass'",
         'Expanded(child: Text(MacStrings.compass'),
        ("const Expanded(child: Text('Field Meter'",
         'Expanded(child: Text(MacStrings.fieldMeter'),
    ],
    "import 'package:kratos/magnetism/magnet_and_compass/mac_strings.dart';",
)

print('DONE')
