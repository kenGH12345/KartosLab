# -*- coding: utf-8 -*-
"""Patch under_pressure / gases / diffusion / membrane hard-coded English."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]

def patch_file(path: Path, replacements: list[tuple[str, str]], import_line: str | None = None):
    if not path.exists():
        print('MISSING', path)
        return
    t = path.read_text(encoding='utf-8')
    orig = t
    for a, b in replacements:
        t = t.replace(a, b)
    if t != orig and import_line and import_line not in t:
        # insert after last consecutive import
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


# --- under_pressure ---
up = root / 'lib' / 'under_pressure'
patch_file(
    up / 'screens' / 'under_pressure_home.dart',
    [
        ("static const String title = 'Under Pressure';",
         "static const String title = UnderPressureStrings.title;"),
    ],
    "import 'package:kratos/under_pressure/under_pressure_strings.dart';",
)

patch_file(
    up / 'view' / 'controls' / 'up_tools_control_panel.dart',
    [
        ("'Ruler'", 'UnderPressureStrings.ruler'),
        ("'Grid'", 'UnderPressureStrings.grid'),
        ("'Atmosphere'", 'UnderPressureStrings.atmosphere'),
        ("'On'", 'UnderPressureStrings.on'),
        ("'Off'", 'UnderPressureStrings.off'),
        ("const Text(\n            UnderPressureStrings.atmosphere,",
         "Text(\n            UnderPressureStrings.atmosphere,"),  # may not match
    ],
    "import 'package:kratos/under_pressure/under_pressure_strings.dart';",
)

# Fix atmosphere Text - re-read and do carefully
p = up / 'view' / 'controls' / 'up_tools_control_panel.dart'
t = p.read_text(encoding='utf-8')
t2 = t.replace(
    """          const Text(
            UnderPressureStrings.atmosphere,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          )""",
    """          Text(
            UnderPressureStrings.atmosphere,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          )""",
)
# if first replace of Atmosphere left const Text with non-const string
t2 = t2.replace(
    """          const Text(
            'Atmosphere',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          )""",
    """          Text(
            UnderPressureStrings.atmosphere,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          )""",
)
if 'UnderPressureStrings.atmosphere' in t2 and "const Text(\n            UnderPressureStrings.atmosphere" in t2:
    t2 = t2.replace(
        'const Text(\n            UnderPressureStrings.atmosphere,',
        'Text(\n            UnderPressureStrings.atmosphere,',
    ).replace(
        'style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),',
        'style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),',
        1,
    )
if t2 != t:
    p.write_text(t2, encoding='utf-8')
    print('fixed tools panel const')

patch_file(
    up / 'view' / 'controls' / 'up_units_control_panel.dart',
    [
        ("'Units'", 'UnderPressureStrings.units'),
        ("'Metric'", 'UnderPressureStrings.metric'),
        ("'Atmospheres'", 'UnderPressureStrings.atmospheres'),
        ("'English'", 'UnderPressureStrings.english'),
    ],
    "import 'package:kratos/under_pressure/under_pressure_strings.dart';",
)

p = up / 'view' / 'controls' / 'up_units_control_panel.dart'
t = p.read_text(encoding='utf-8')
t2 = t.replace(
    """          const Text(
            UnderPressureStrings.units,""",
    """          Text(
            UnderPressureStrings.units,""",
)
if "const Text(\n            'Units'," in t:
    t2 = t.replace(
        """          const Text(
            'Units',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          )""",
        """          Text(
            UnderPressureStrings.units,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          )""",
    )
if 'const Text(\n            UnderPressureStrings.units' in t2:
    t2 = t2.replace(
        'const Text(\n            UnderPressureStrings.units,',
        'Text(\n            UnderPressureStrings.units,',
    )
    t2 = t2.replace(
        'style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),',
        'style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),',
        1,
    )
if t2 != p.read_text(encoding='utf-8'):
    p.write_text(t2, encoding='utf-8')
    print('fixed units panel')

patch_file(
    up / 'view' / 'under_pressure_screen.dart',
    [
        ("title: 'Fluid Density'", 'title: UnderPressureStrings.fluidDensity'),
        ("title: 'Gravity'", 'title: UnderPressureStrings.gravity'),
        ("(title: 'Earth'", '(title: UnderPressureStrings.earth'),
    ],
    "import 'package:kratos/under_pressure/under_pressure_strings.dart';",
)

patch_file(
    up / 'view' / 'controls' / 'up_mystery_controls.dart',
    [
        ("label: 'Mystery Fluid'", 'label: UnderPressureStrings.mysteryFluid'),
        ("label: 'Mystery Planet'", 'label: UnderPressureStrings.mysteryPlanet'),
        ("items: const ['Fluid A', 'Fluid B', 'Fluid C']",
         "items: const [UnderPressureStrings.fluidA, UnderPressureStrings.fluidB, UnderPressureStrings.fluidC]"),
        ("items: const ['Planet A', 'Planet B', 'Planet C']",
         "items: const [UnderPressureStrings.planetA, UnderPressureStrings.planetB, UnderPressureStrings.planetC]"),
    ],
    "import 'package:kratos/under_pressure/under_pressure_strings.dart';",
)

# --- gases_intro ---
gi = root / 'lib' / 'gases_intro'
patch_file(
    gi / 'screens' / 'gases_intro_home.dart',
    [
        ("static const String title = 'Gases Intro';",
         "static const String title = GasesIntroStrings.title;"),
        ("Tab(text: 'Intro')", 'Tab(text: GasesIntroStrings.intro)'),
        ("Tab(text: 'Laws')", 'Tab(text: GasesIntroStrings.laws)'),
    ],
    "import 'package:kratos/gases_intro/gases_intro_strings.dart';",
)

patch_file(
    gi / 'widgets' / 'gases_intro_shell.dart',
    [
        ("const Text('Return Lid')", 'Text(GasesIntroStrings.returnLid)'),
        ("tooltip: 'Reset All'", 'tooltip: GasesIntroStrings.resetAll'),
        ("'Hold Constant'", 'GasesIntroStrings.holdConstant'),
        ("label: 'Width'", 'label: GasesIntroStrings.width'),
        ("label: 'Stopwatch'", 'label: GasesIntroStrings.stopwatch'),
        ("label: 'Collision Counter'", 'label: GasesIntroStrings.collisionCounter'),
        ("return 'Nothing';", 'return GasesIntroStrings.nothing;'),
        ("return 'Volume (V)';", 'return GasesIntroStrings.volumeV;'),
        ("return 'Temperature (T)';", 'return GasesIntroStrings.temperatureT;'),
        ("return 'Pressure ↕ V';", 'return GasesIntroStrings.pressureV;'),
        ("return 'Pressure ↕ T';", 'return GasesIntroStrings.pressureT;'),
        ("'Particles'", 'GasesIntroStrings.particles'),
        ("label: 'Heavy'", 'label: GasesIntroStrings.heavy'),
        ("label: 'Light'", 'label: GasesIntroStrings.light'),
    ],
    "import 'package:kratos/gases_intro/gases_intro_strings.dart';",
)

# fix const Text Hold Constant
p = gi / 'widgets' / 'gases_intro_shell.dart'
t = p.read_text(encoding='utf-8')
t = t.replace(
    """              const Text(
                GasesIntroStrings.holdConstant,""",
    """              Text(
                GasesIntroStrings.holdConstant,""",
)
t = t.replace(
    """              const Text(
                'Hold Constant',""",
    """              Text(
                GasesIntroStrings.holdConstant,""",
)
# Particles header
t = t.replace(
    """                      child: Text(
                        GasesIntroStrings.particles,""",
    """                      child: Text(
                        GasesIntroStrings.particles,""",
)
t = t.replace(
    """                      child: Text(
                        'Particles',""",
    """                      child: Text(
                        GasesIntroStrings.particles,""",
)
p.write_text(t, encoding='utf-8')
print('gases shell cleanup')

patch_file(
    gi / 'widgets' / 'tool_nodes.dart',
    [
        ("'Wall Collisions'", 'GasesIntroStrings.wallCollisions'),
        ("'Sample Period'", 'GasesIntroStrings.samplePeriod'),
    ],
    "import 'package:kratos/gases_intro/gases_intro_strings.dart';",
)
p = gi / 'widgets' / 'tool_nodes.dart'
t = p.read_text(encoding='utf-8')
for old, new in [
    ("const Text(\n                GasesIntroStrings.wallCollisions,", "Text(\n                GasesIntroStrings.wallCollisions,"),
    ("const Text(\n                GasesIntroStrings.samplePeriod,", "Text(\n                GasesIntroStrings.samplePeriod,"),
]:
    t = t.replace(old, new)
p.write_text(t, encoding='utf-8')

patch_file(
    gi / 'widgets' / 'instruments.dart',
    [
        ("const Text('Heat', style: labelStyle)", "Text(GasesIntroStrings.heat, style: labelStyle)"),
        ("const Text('Cool', style: labelStyle)", "Text(GasesIntroStrings.cool, style: labelStyle)"),
        ("const Text('OK')", "Text(GasesIntroStrings.ok)"),
    ],
    "import 'package:kratos/gases_intro/gases_intro_strings.dart';",
)

# --- gas_properties ---
gp = root / 'lib' / 'gas_properties'
patch_file(
    gp / 'screens' / 'gas_properties_home.dart',
    [
        ("static const String title = 'Gas Properties';",
         "static const String title = GasPropertiesStrings.title;"),
        ("Tab(text: 'Ideal')", 'Tab(text: GasPropertiesStrings.ideal)'),
        ("Tab(text: 'Explore')", 'Tab(text: GasPropertiesStrings.explore)'),
        ("Tab(text: 'Energy')", 'Tab(text: GasPropertiesStrings.energy)'),
        ("Tab(text: 'Diffusion')", 'Tab(text: GasPropertiesStrings.diffusion)'),
    ],
    "import 'package:kratos/gas_properties/gas_properties_strings.dart';",
)

patch_file(
    gp / 'widgets' / 'ideal_phet_controls.dart',
    [
        ("title: 'Particles'", 'title: GasPropertiesStrings.particles'),
        ("label: 'Heavy'", 'label: GasPropertiesStrings.heavy'),
        ("label: 'Light'", 'label: GasPropertiesStrings.light'),
        ("label: 'Collisions'", 'label: GasPropertiesStrings.collisions'),
        ("title: 'Hold Constant'", 'title: GasPropertiesStrings.holdConstant'),
        ("HoldConstant.nothing => 'Nothing'",
         'HoldConstant.nothing => GasPropertiesStrings.nothing'),
        ("HoldConstant.volume => 'Volume (V)'",
         'HoldConstant.volume => GasPropertiesStrings.volumeV'),
        ("HoldConstant.temperature => 'Temperature (T)'",
         'HoldConstant.temperature => GasPropertiesStrings.temperatureT'),
        ("HoldConstant.pressureV => 'Pressure ↕V'",
         'HoldConstant.pressureV => GasPropertiesStrings.pressureV'),
        ("HoldConstant.pressureT => 'Pressure ↕T'",
         'HoldConstant.pressureT => GasPropertiesStrings.pressureT'),
        ("label: 'Width'", 'label: GasPropertiesStrings.width'),
        ("label: 'Wall Velocity'", 'label: GasPropertiesStrings.wallVelocity'),
        ("label: 'Stopwatch'", 'label: GasPropertiesStrings.stopwatch'),
        ("label: 'Collision Counter'", 'label: GasPropertiesStrings.collisionCounter'),
    ],
    "import 'package:kratos/gas_properties/gas_properties_strings.dart';",
)

patch_file(
    gp / 'widgets' / 'gas_ideal_family_shell.dart',
    [
        ("label: 'Heat Cool'", 'label: GasPropertiesStrings.heatCool'),
        ("const Text('Return Lid')", 'Text(GasPropertiesStrings.returnLid)'),
        ("tooltip: 'Reset All'", 'tooltip: GasPropertiesStrings.resetAll'),
        ("const Text('Stopwatch'", 'Text(GasPropertiesStrings.stopwatch'),
        ("const Text('Collisions'", 'Text(GasPropertiesStrings.collisions'),
        ("title: 'Injection Temperature'",
         'title: GasPropertiesStrings.injectionTemperature'),
        ("label: 'Set to'", 'label: GasPropertiesStrings.setTo'),
        ("'Match Container'", 'GasPropertiesStrings.matchContainer'),
        ("title: 'Speed'", 'title: GasPropertiesStrings.speed'),
        ("title: 'Kinetic Energy'", 'title: GasPropertiesStrings.kineticEnergy'),
        ("HoldConstantOops.emptyTemperature =>\n          'Temperature cannot be held constant when the container is empty.'",
         "HoldConstantOops.emptyTemperature =>\n          GasPropertiesStrings.tempEmpty"),
        ("HoldConstantOops.openTemperature =>\n          'Temperature cannot be held constant when the container is open.'",
         "HoldConstantOops.openTemperature =>\n          GasPropertiesStrings.tempOpen"),
        ("HoldConstantOops.emptyPressure =>\n          'Pressure cannot be held constant when the container is empty.'",
         "HoldConstantOops.emptyPressure =>\n          GasPropertiesStrings.pressureEmpty"),
        ("HoldConstantOops.pressureVolumeTooLarge =>\n          'Pressure cannot be held constant. Volume would be too large.'",
         "HoldConstantOops.pressureVolumeTooLarge =>\n          GasPropertiesStrings.pressureVolumeLarge"),
        ("HoldConstantOops.pressureVolumeTooSmall =>\n          'Pressure cannot be held constant. Volume would be too small.'",
         "HoldConstantOops.pressureVolumeTooSmall =>\n          GasPropertiesStrings.pressureVolumeSmall"),
        ("HoldConstantOops.maximumTemperature => 'Maximum temperature reached.'",
         'HoldConstantOops.maximumTemperature => GasPropertiesStrings.maxTemperature'),
        ("'Oops!\\n\\n$_message'",
         "'${GasPropertiesStrings.oops}\\n\\n$_message'"),
        ("child: const Text('OK')", 'child: Text(GasPropertiesStrings.ok)'),
    ],
    "import 'package:kratos/gas_properties/gas_properties_strings.dart';",
)

# Fix Stopwatch/Collisions const Text breakage
p = gp / 'widgets' / 'gas_ideal_family_shell.dart'
t = p.read_text(encoding='utf-8')
# if broken "Text(GasPropertiesStrings.stopwatch," without closing - check
p.write_text(t, encoding='utf-8')

patch_file(
    gp / 'widgets' / 'gas_diffusion_shell.dart',
    [
        ("_side('Left'", "_side(GasPropertiesStrings.left"),
        ("_side('Right'", "_side(GasPropertiesStrings.right"),
        ("m.container.hasDivider ? 'Remove Divider' : 'Reset Divider'",
         "m.container.hasDivider ? GasPropertiesStrings.removeDivider : GasPropertiesStrings.resetDivider"),
        ("title: const Text('Center of Mass'",
         "title: Text(GasPropertiesStrings.centerOfMass"),
        ("title: const Text('Particle Flow Rate'",
         "title: Text(GasPropertiesStrings.particleFlowRate"),
        ("label: const Text('Normal')",
         "label: Text(GasPropertiesStrings.normal)"),
        ("label: const Text('Slow')",
         "label: Text(GasPropertiesStrings.slow)"),
        ("_row('Mass'", "_row(GasPropertiesStrings.mass"),
        ("_row('Radius'", "_row(GasPropertiesStrings.radius"),
    ],
    "import 'package:kratos/gas_properties/gas_properties_strings.dart';",
)

patch_file(
    gp / 'painters' / 'histogram_painter.dart',
    [
        ("'Average Speed'", 'GasPropertiesStrings.averageSpeed'),
        ("'Heavy: ", "'${GasPropertiesStrings.heavy}: "),
        ("'Light: ", "'${GasPropertiesStrings.light}: "),
    ],
    "import 'package:kratos/gas_properties/gas_properties_strings.dart';",
)

# Fix histogram - Heavy/Light string interpolation may break
p = gp / 'painters' / 'histogram_painter.dart'
t = p.read_text(encoding='utf-8')
# Fix if we created broken quotes like '${GasPropertiesStrings.heavy}: ${fmt...}'
# Original was: 'Heavy: ${fmt(energy?.heavyAverageSpeed)}'
# After naive replace of 'Heavy:  -> '${GasPropertiesStrings.heavy}: 
# might become '${GasPropertiesStrings.heavy}: ${fmt(...)}' which is good if we close properly
# Check: "'${GasPropertiesStrings.heavy}: ${fmt(energy?.heavyAverageSpeed)}',"
print('histogram snippet:')
for line in t.splitlines():
    if 'heavy' in line.lower() or 'average' in line.lower() or 'light' in line.lower():
        if 'GasProperties' in line or 'Average' in line or 'Heavy' in line or 'Light' in line:
            print(repr(line))

# --- diffusion ---
df = root / 'lib' / 'diffusion'
patch_file(
    df / 'screens' / 'diffusion_home.dart',
    [
        ("static const String title = 'Diffusion';",
         "static const String title = DiffusionStrings.title;"),
    ],
    "import 'package:kratos/diffusion/diffusion_strings.dart';",
)

patch_file(
    df / 'widgets' / 'diffusion_shell.dart',
    [
        ("'Data'", 'DiffusionStrings.data'),
        ("item(DiffusionTimeSpeed.normal, 'Normal')",
         "item(DiffusionTimeSpeed.normal, DiffusionStrings.normal)"),
        ("item(DiffusionTimeSpeed.slow, 'Slow')",
         "item(DiffusionTimeSpeed.slow, DiffusionStrings.slow)"),
        ("label: 'Number of Particles'",
         'label: DiffusionStrings.numberOfParticles'),
        ("label: 'Mass (AMU)'", 'label: DiffusionStrings.massAmu'),
        ("label: 'Radius (pm)'", 'label: DiffusionStrings.radiusPm'),
        ("label: 'Initial Temperature (K)'",
         'label: DiffusionStrings.initialTemperatureK'),
        ("model.container.hasDivider ? 'Remove Divider' : 'Reset Divider'",
         "model.container.hasDivider ? DiffusionStrings.removeDivider : DiffusionStrings.resetDivider"),
        ("title: const Text('Center of Mass'",
         "title: Text(DiffusionStrings.centerOfMass"),
        ("title: const Text('Particle Flow Rate'",
         "title: Text(DiffusionStrings.particleFlowRate"),
        ("title: const Text('Scale'",
         "title: Text(DiffusionStrings.scale"),
        ("title: const Text('Stopwatch'",
         "title: Text(DiffusionStrings.stopwatch"),
    ],
    "import 'package:kratos/diffusion/diffusion_strings.dart';",
)

p = df / 'widgets' / 'diffusion_shell.dart'
t = p.read_text(encoding='utf-8')
t = t.replace(
    """          title: const Text(
            DiffusionStrings.data,""",
    """          title: Text(
            DiffusionStrings.data,""",
)
t = t.replace(
    """          title: const Text(
            'Data',""",
    """          title: Text(
            DiffusionStrings.data,""",
)
p.write_text(t, encoding='utf-8')

# --- membrane ---
mt = root / 'lib' / 'membrane_transport'
patch_file(
    mt / 'screens' / 'membrane_transport_home.dart',
    [
        ("static const String title = 'Membrane Transport';",
         "static const String title = MembraneTransportStrings.title;"),
    ],
    "import 'package:kratos/membrane_transport/membrane_transport_strings.dart';",
)

patch_file(
    mt / 'view' / 'transport_protein_panel.dart',
    [
        ("title: 'Leakage Channels'",
         'title: MembraneTransportStrings.leakageChannels'),
        ("title: 'Voltage-Gated Channels'",
         'title: MembraneTransportStrings.voltageGatedChannels'),
        ("title: 'Ligand-Gated Channels'",
         'title: MembraneTransportStrings.ligandGatedChannels'),
        ("title: 'Active Transporters'",
         'title: MembraneTransportStrings.activeTransporters'),
        ("labels: const ['Sodium Ion', 'Potassium Ion']",
         "labels: const [MembraneTransportStrings.sodiumIon, MembraneTransportStrings.potassiumIon]"),
        ("labels: const ['Na⁺/K⁺ Pump', 'Na⁺/Glucose']",
         "labels: const [MembraneTransportStrings.naKPump, MembraneTransportStrings.naGlucose]"),
        ("'Membrane Potential (mV)'",
         'MembraneTransportStrings.membranePotential'),
        ("'Charges'", 'MembraneTransportStrings.charges'),
        ("added ? 'Remove Ligands' : 'Add Ligands'",
         "added ? MembraneTransportStrings.removeLigands : MembraneTransportStrings.addLigands"),
    ],
    "import 'package:kratos/membrane_transport/membrane_transport_strings.dart';",
)

patch_file(
    mt / 'screens' / 'simple_diffusion_screen.dart',
    [
        ("'Solutes'", 'MembraneTransportStrings.solutes'),
        ("'Solute Concentrations'",
         'MembraneTransportStrings.soluteConcentrations'),
        ("side == MembraneSide.outside ? 'Outside' : 'Inside'",
         "side == MembraneSide.outside ? MembraneTransportStrings.outside : MembraneTransportStrings.inside"),
        ("label: 'Normal'", 'label: MembraneTransportStrings.normal'),
        ("label: 'Slow'", 'label: MembraneTransportStrings.slow'),
        ("label: 'Crossing Highlights'",
         'label: MembraneTransportStrings.crossingHighlights'),
        ("label: 'Crossing Sounds'",
         'label: MembraneTransportStrings.crossingSounds'),
        ("'Outside'", 'MembraneTransportStrings.outside'),
        ("'Inside'", 'MembraneTransportStrings.inside'),
    ],
    "import 'package:kratos/membrane_transport/membrane_transport_strings.dart';",
)

print('DONE')
