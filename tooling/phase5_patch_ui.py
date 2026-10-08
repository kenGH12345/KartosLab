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


# --- bending light ---
patch(
    root / 'lib/bending_light/screens/bending_light_home.dart',
    [
        ("static const String title = 'Bending Light';",
         'static const String title = BlStrings.title;'),
        ("KratosTab(label: 'Intro'", 'KratosTab(label: BlStrings.intro'),
        ("KratosTab(label: 'Prisms'", 'KratosTab(label: BlStrings.prisms'),
        ("KratosTab(label: 'More Tools'", 'KratosTab(label: BlStrings.moreTools'),
    ],
    "import 'package:kratos/bending_light/bl_strings.dart';",
)
patch(
    root / 'lib/bending_light/screens/bending_light_hub.dart',
    [
        ("title: const Text('Bending Light')",
         'title: const Text(BlStrings.title)'),
        ("child: const Text('Intro')", 'child: const Text(BlStrings.intro)'),
        ("child: const Text('Prisms')", 'child: const Text(BlStrings.prisms)'),
        ("child: const Text('More Tools')",
         'child: const Text(BlStrings.moreTools)'),
    ],
    "import 'package:kratos/bending_light/bl_strings.dart';",
)
patch(
    root / 'lib/bending_light/screens/intro_screen.dart',
    [("title: const Text('Bending Light — Intro')",
      'title: const Text(BlStrings.titleIntro)')],
    "import 'package:kratos/bending_light/bl_strings.dart';",
)
patch(
    root / 'lib/bending_light/screens/prisms_screen.dart',
    [("title: const Text('Bending Light — Prisms')",
      'title: const Text(BlStrings.titlePrisms)')],
    "import 'package:kratos/bending_light/bl_strings.dart';",
)
patch(
    root / 'lib/bending_light/screens/more_tools_screen.dart',
    [("title: const Text('Bending Light — More Tools')",
      'title: const Text(BlStrings.titleMoreTools)')],
    "import 'package:kratos/bending_light/bl_strings.dart';",
)
patch(
    root / 'lib/bending_light/components/control_widgets.dart',
    [
        ("value: substance.custom ? 'Custom' : substance.name",
         'value: substance.custom ? BlStrings.custom : substance.name'),
        ("'Custom'", 'BlStrings.custom'),
        ("child: Text('Index of Refraction (n)', style: PhetFont.of(12))",
         'child: Text(BlStrings.indexOfRefraction, style: PhetFont.of(12))'),
        ("child: Text('What is n?', style: PhetFont.of(16))",
         'child: Text(BlStrings.whatIsN, style: PhetFont.of(16))'),
        ("PhetAquaRadio(label: 'Wave'",
         'PhetAquaRadio(label: BlStrings.wave'),
        ("Text('Normal', style: PhetFont.of(12))",
         'Text(BlStrings.normal, style: PhetFont.of(12))'),
        ("Text('Angles', style: PhetFont.of(12))",
         'Text(BlStrings.angles, style: PhetFont.of(12))'),
        ("tooltip: 'Reset All'", 'tooltip: BlStrings.resetAll'),
    ],
    "import 'package:kratos/bending_light/bl_strings.dart';",
)

# Fix Custom string compare after replace may have broken if name == BlStrings.custom
p = root / 'lib/bending_light/components/control_widgets.dart'
t = p.read_text(encoding='utf-8')
t = t.replace("if (name == BlStrings.custom)", "if (name == BlStrings.custom)")
# also fix DropdownMenuItem that used 'Custom' as value
if "if (name == 'Custom')" in t:
    t = t.replace("if (name == 'Custom')", 'if (name == BlStrings.custom)')
p.write_text(t, encoding='utf-8')

# --- wave on a string ---
patch(
    root / 'lib/wave_on_a_string/view/woas_screen.dart',
    [("static const String title = 'Wave on a String';",
      'static const String title = WoasStrings.title;')],
    "import 'package:kratos/wave_on_a_string/woas_strings.dart';",
)

# --- waves intro ---
patch(
    root / 'lib/waves_intro/screens/waves_intro_home.dart',
    [
        ("static const String title = 'Waves Intro';",
         'static const String title = WavesIntroStrings.title;'),
        ("text: 'Water'", 'text: WavesIntroStrings.water'),
        ("text: 'Sound'", 'text: WavesIntroStrings.sound'),
        ("text: 'Light'", 'text: WavesIntroStrings.light'),
    ],
    "import 'package:kratos/waves_intro/waves_intro_strings.dart';",
)
patch(
    root / 'lib/waves_intro/view/control_column.dart',
    [
        ("Text('Frequency', style: _labelStyle(context))",
         'Text(WavesIntroStrings.frequency, style: _labelStyle(context))'),
        ("Text('Amplitude', style: _labelStyle(context))",
         'Text(WavesIntroStrings.amplitude, style: _labelStyle(context))'),
        ("label: 'Graph'", 'label: WavesIntroStrings.graph'),
        ("label: 'Play Tone'", 'label: WavesIntroStrings.playTone'),
        ("label: 'Screen'", 'label: WavesIntroStrings.screen'),
        ("label: 'Sound Effect'", 'label: WavesIntroStrings.soundEffect'),
        ("(SoundViewType.waves, 'Waves')",
         '(SoundViewType.waves, WavesIntroStrings.waves)'),
        ("(SoundViewType.particles, 'Particles')",
         '(SoundViewType.particles, WavesIntroStrings.particles)'),
        ("(SoundViewType.both, 'Both')",
         '(SoundViewType.both, WavesIntroStrings.both)'),
        ("aLabel: 'Top View'", 'aLabel: WavesIntroStrings.topView'),
        ("bLabel: 'Side View'", 'bLabel: WavesIntroStrings.sideView'),
        ("aLabel: 'Normal'", 'aLabel: WavesIntroStrings.normal'),
        ("bLabel: 'Slow'", 'bLabel: WavesIntroStrings.slow'),
    ],
    "import 'package:kratos/waves_intro/waves_intro_strings.dart';",
)
patch(
    root / 'lib/waves_intro/widgets/waves_intro_controls.dart',
    [
        ("Text('Level', style: Theme.of(context).textTheme.labelSmall)",
         'Text(WavesIntroStrings.level, style: Theme.of(context).textTheme.labelSmall)'),
        ("'Amplitude'", 'WavesIntroStrings.amplitude'),
        ("label: Text('Continuous')",
         'label: Text(WavesIntroStrings.continuous)'),
        ("label: Text('Pulse')", 'label: Text(WavesIntroStrings.pulse)'),
        ("title: const Text('Graph')",
         'title: Text(WavesIntroStrings.graph)'),
        ("'Viewpoint'", 'WavesIntroStrings.viewpoint'),
        ("label: Text('Top')", 'label: Text(WavesIntroStrings.top)'),
        ("label: Text('Side')", 'label: Text(WavesIntroStrings.side)'),
        ("title: const Text('Screen')",
         'title: Text(WavesIntroStrings.screen)'),
        ("'Sound view'", 'WavesIntroStrings.soundView'),
        ("label: Text('Waves')", 'label: Text(WavesIntroStrings.waves)'),
        ("label: Text('Particles')",
         'label: Text(WavesIntroStrings.particles)'),
        ("title: const Text('Play Tone')",
         'title: Text(WavesIntroStrings.playTone)'),
        ("title: const Text('Sound Effect')",
         'title: Text(WavesIntroStrings.soundEffect)'),
        ("'Audio'", 'WavesIntroStrings.audio'),
        ("tooltip: model.audioState.muted ? 'Unmute' : 'Mute'",
         'tooltip: model.audioState.muted ? WavesIntroStrings.unmute : WavesIntroStrings.mute'),
        ("tooltip: model.isRunning ? 'Pause' : 'Play'",
         'tooltip: model.isRunning ? WavesIntroStrings.pause : WavesIntroStrings.play'),
        ("tooltip: 'Step'", 'tooltip: WavesIntroStrings.step'),
        ("tooltip: 'Reset'", 'tooltip: WavesIntroStrings.reset'),
    ],
    "import 'package:kratos/waves_intro/waves_intro_strings.dart';",
)

# --- color vision ---
patch(
    root / 'lib/color_vision/screens/color_vision_home.dart',
    [
        ("static const String title = 'Color Vision / 色觉';",
         'static const String title = ColorVisionStrings.title;'),
        ("label: 'Single Bulb'", 'label: ColorVisionStrings.singleBulb'),
        ("label: 'RGB Bulbs'", 'label: ColorVisionStrings.rgbBulbs'),
    ],
    "import 'package:kratos/color_vision/color_vision_strings.dart';",
)
patch(
    root / 'lib/color_vision/screens/rgb_bulbs_screen.dart',
    [("label: const Text('标签 Labels', style: TextStyle(fontSize: 10))",
      'label: const Text(ColorVisionStrings.labels, style: TextStyle(fontSize: 10))')],
    "import 'package:kratos/color_vision/color_vision_strings.dart';",
)

# --- quantum measurement home ---
patch(
    root / 'lib/quantum_measurement/screens/quantum_measurement_home.dart',
    [
        ("static const String title = 'Quantum Measurement';",
         'static const String title = QmStrings.title;'),
        ("label: 'Coins'", 'label: QmStrings.coins'),
        ("label: 'Photons'", 'label: QmStrings.photons'),
        ("label: 'Spin'", 'label: QmStrings.spin'),
        ("label: 'Bloch Sphere'", 'label: QmStrings.blochSphere'),
    ],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)

# QM hardcodes — key files
patch(
    root / 'lib/quantum_measurement/coins/components/coin_bias_controls.dart',
    [
        ("'Initial Orientation'", 'QmStrings.initialOrientation'),
        ("'State to Prepare'", 'QmStrings.stateToPrepare'),
        ("'Basis State'", 'QmStrings.basisState'),
        ("Text('Probability P(', style: style)",
         'Text(QmStrings.probabilityP, style: style)'),
    ],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)
patch(
    root / 'lib/quantum_measurement/coins/components/coins_scene_primitives.dart',
    [("child: Text('New Coin', style: TextStyle(fontSize: 14))",
      'child: Text(QmStrings.newCoin, style: TextStyle(fontSize: 14))')],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)
patch(
    root / 'lib/quantum_measurement/coins/components/coin_count_selector.dart',
    [("'Identical Coins'", 'QmStrings.identicalCoins')],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)
patch(
    root / 'lib/quantum_measurement/photons/components/photon_source.dart',
    [("const Text('Photon Source', style: TextStyle(fontSize: 12))",
      'Text(QmStrings.photonSource, style: const TextStyle(fontSize: 12))')],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)
patch(
    root / 'lib/quantum_measurement/photons/components/photon_controls.dart',
    [
        ("const Text('Behavior', style: QmTypography.boldTitle)",
         'Text(QmStrings.behavior, style: QmTypography.boldTitle)'),
        ("label: 'Classical'", 'label: QmStrings.classical'),
    ],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)
patch(
    root / 'lib/quantum_measurement/bloch_sphere/components/measurement_controls.dart',
    [
        ("return 'Reprepare';", 'return QmStrings.reprepare;'),
        ("if (model.magneticFieldEnabled) return 'Start';",
         'if (model.magneticFieldEnabled) return QmStrings.start;'),
        ("return 'Observe';", 'return QmStrings.observe;'),
        ("const Text('Number of Atoms', style: _controlFont)",
         'Text(QmStrings.numberOfAtoms, style: _controlFont)'),
        ("const Text('Spin Measurement Axis', style: _controlFont)",
         'Text(QmStrings.spinMeasurementAxis, style: _controlFont)'),
        ("'Measurement Delay'", 'QmStrings.measurementDelay'),
    ],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)
patch(
    root / 'lib/quantum_measurement/bloch_sphere/view/bloch_scene.dart',
    [("label: 'Magnetic Field'", 'label: QmStrings.magneticField')],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)
patch(
    root / 'lib/quantum_measurement/bloch_sphere/components/magnetic_field_control.dart',
    [("label: 'Magnetic Field'", 'label: QmStrings.magneticField')],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)
patch(
    root / 'lib/quantum_measurement/bloch_sphere/components/state_preset_controls.dart',
    [
        ("(BlochStateDirection.custom, 'Custom')",
         '(BlochStateDirection.custom, QmStrings.custom)'),
        ("Text('Polar angle (θ)', style: _controlFont)",
         'Text(QmStrings.polarAngle, style: _controlFont)'),
        ("Text('Azimuthal angle (φ)', style: _controlFont)",
         'Text(QmStrings.azimuthalAngle, style: _controlFont)'),
    ],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)
patch(
    root / 'lib/quantum_measurement/bloch_sphere/components/bloch_state_equation.dart',
    [
        ("'Spin State to Prepare'", 'QmStrings.spinStateToPrepare'),
        ("const Text('Basis:', style: TextStyle(fontSize: 14))",
         'Text(QmStrings.basis, style: const TextStyle(fontSize: 14))'),
        ("isSingle ? 'Atom' : 'Atoms'",
         'isSingle ? QmStrings.atom : QmStrings.atoms'),
    ],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)
patch(
    root / 'lib/quantum_measurement/spin/components/spin_controls.dart',
    [("'Spin State to Prepare'", 'QmStrings.spinStateToPrepare')],
    "import 'package:kratos/quantum_measurement/qm_strings.dart';",
)

# --- QWI ---
patch(
    root / 'lib/physics/quantum_wave_interference/screens/quantum_wave_interference_home.dart',
    [
        ("static const String experimentTabLabel = 'Experiment';",
         'static const String experimentTabLabel = QwiStrings.experiment;'),
        ("static const String highIntensityTabLabel = 'High Intensity';",
         'static const String highIntensityTabLabel = QwiStrings.highIntensity;'),
        ("static const String singleParticlesTabLabel = 'Single Particles';",
         'static const String singleParticlesTabLabel = QwiStrings.singleParticles;'),
    ],
    "import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';",
)
patch(
    root / 'lib/physics/quantum_wave_interference/view/experiment/experiment_snapshots.dart',
    [
        ("tooltip: 'Take Snapshot'", 'tooltip: QwiStrings.takeSnapshot'),
        ("tooltip: 'View Snapshots'", 'tooltip: QwiStrings.viewSnapshots'),
        ("const Text('Snapshots', style: TextStyle(fontWeight: FontWeight.bold))",
         'Text(QwiStrings.snapshots, style: const TextStyle(fontWeight: FontWeight.bold))'),
        ("child: const Text('Close')", 'child: Text(QwiStrings.close)'),
        ("title: Text('Snapshot ${s.snapshotNumber}')",
         'title: Text(QwiStrings.snapshotN(s.snapshotNumber))'),
        ("child: const Text('Delete', style: TextStyle(fontSize: 11))",
         'child: Text(QwiStrings.delete, style: const TextStyle(fontSize: 11))'),
    ],
    "import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';",
)
patch(
    root / 'lib/physics/quantum_wave_interference/view/experiment/experiment_ruler.dart',
    [("const Text('Ruler', style: TextStyle(fontSize: 12))",
      'Text(QwiStrings.ruler, style: const TextStyle(fontSize: 12))')],
    "import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';",
)
patch(
    root / 'lib/physics/quantum_wave_interference/view/common/qwi_probe_node.dart',
    [
        ("probe.state == ProbeState.ready ? 'Detect' : 'Reset Detector'",
         'probe.state == ProbeState.ready ? QwiStrings.detect : QwiStrings.resetDetector'),
        ("label: 'Detector probe'", 'label: QwiStrings.detectorProbe'),
        ("Text('Detector Size', style: QwiTypography.label(11))",
         'Text(QwiStrings.detectorSize, style: QwiTypography.label(11))'),
    ],
    "import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';",
)
patch(
    root / 'lib/physics/quantum_wave_interference/view/high_intensity/high_intensity_controls.dart',
    [
        ("title: 'Speed'", 'title: QwiStrings.speed'),
        ("SlitConfiguration.bothOpen: 'Both Slits Open'",
         'SlitConfiguration.bothOpen: QwiStrings.bothSlitsOpen'),
        ("SlitConfiguration.leftCovered: 'Top Covered'",
         'SlitConfiguration.leftCovered: QwiStrings.topCovered'),
        ("SlitConfiguration.rightCovered: 'Bottom Covered'",
         'SlitConfiguration.rightCovered: QwiStrings.bottomCovered'),
        ("SlitConfiguration.leftDetector: 'Detector on Top'",
         'SlitConfiguration.leftDetector: QwiStrings.detectorOnTop'),
        ("SlitConfiguration.rightDetector: 'Detector on Bottom'",
         'SlitConfiguration.rightDetector: QwiStrings.detectorOnBottom'),
        ("SlitConfiguration.bothDetectors: 'Detectors Both'",
         'SlitConfiguration.bothDetectors: QwiStrings.detectorsBoth'),
        ("SlitConfiguration.noBarrier: 'No Barrier'",
         'SlitConfiguration.noBarrier: QwiStrings.noBarrier'),
        ("const Text('Configuration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11))",
         'Text(QwiStrings.configuration, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11))'),
        ("title: 'Slit Separation'", 'title: QwiStrings.slitSeparation'),
        ("WaveDisplayMode.electricField: 'Electric Field'",
         'WaveDisplayMode.electricField: QwiStrings.electricField'),
        ("WaveDisplayMode.amplitude: 'Amplitude'",
         'WaveDisplayMode.amplitude: QwiStrings.amplitude'),
        ("WaveDisplayMode.realPart: 'Real Part'",
         'WaveDisplayMode.realPart: QwiStrings.realPart'),
        ("leftLabel: 'Screen'", 'leftLabel: QwiStrings.screen'),
        ("rightLabel: 'Graph'", 'rightLabel: QwiStrings.graph'),
        ("DetectorMode.intensity: 'Intensity'",
         'DetectorMode.intensity: QwiStrings.intensity'),
        ("DetectorMode.hits: 'Hits'", 'DetectorMode.hits: QwiStrings.hits'),
    ],
    "import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';",
)
patch(
    root / 'lib/physics/quantum_wave_interference/view/layout/high_intensity_layout_composer.dart',
    [
        ("'Wave Display'", 'QwiStrings.waveDisplay'),
        ("label: 'Snap'", 'label: QwiStrings.snap'),
        ("label: 'View'", 'label: QwiStrings.view'),
        ("const Text('Snapshots', style: TextStyle(fontWeight: FontWeight.bold))",
         'Text(QwiStrings.snapshots, style: const TextStyle(fontWeight: FontWeight.bold))'),
        ("child: const Text('Close')", 'child: Text(QwiStrings.close)'),
    ],
    "import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';",
)

print('DONE')
