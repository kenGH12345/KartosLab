# -*- coding: utf-8 -*-
"""PHASE 5 pass-2: remaining English UI → *Strings constants."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def ensure_import(text: str, import_line: str) -> str:
    if import_line in text:
        return text
    lines = text.splitlines(keepends=True)
    # after last import
    idx = 0
    for i, line in enumerate(lines):
        if line.startswith("import ") or line.startswith("export "):
            idx = i + 1
    lines.insert(idx, import_line + ("\n" if not import_line.endswith("\n") else ""))
    return "".join(lines)


def patch_file(rel: str, replacements: list[tuple[str, str]], import_line: str | None = None) -> None:
    path = ROOT / rel
    text = path.read_text(encoding="utf-8")
    orig = text
    if import_line:
        text = ensure_import(text, import_line)
    for a, b in replacements:
        if a not in text:
            print(f"MISS {rel}: {a[:70]!r}")
            continue
        text = text.replace(a, b)
    if text != orig:
        path.write_text(text, encoding="utf-8")
        print(f"updated {rel}")
    else:
        print(f"unchanged {rel}")


def main() -> None:
    bl = "import 'package:kratos/bending_light/bl_strings.dart';"
    woas = "import 'package:kratos/wave_on_a_string/woas_strings.dart';"
    wi = "import 'package:kratos/waves_intro/waves_intro_strings.dart';"
    cv = "import 'package:kratos/color_vision/color_vision_strings.dart';"
    qm = "import 'package:kratos/quantum_measurement/qm_strings.dart';"
    qwi = "import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';"

    # --- substance names (display) ---
    patch_file(
        "lib/bending_light/model/substance.dart",
        [
            ("name: 'Air',", "name: BlStrings.air,"),
            ("name: 'Water',", "name: BlStrings.water,"),
            ("name: 'Glass',", "name: BlStrings.glass,"),
            ("name: 'Diamond',", "name: BlStrings.diamond,"),
            ("name: 'Mystery A',", "name: BlStrings.mysteryA,"),
            ("name: 'Mystery B',", "name: BlStrings.mysteryB,"),
            ("name: 'Custom',", "name: BlStrings.custom,"),
        ],
        bl,
    )

    patch_file(
        "lib/bending_light/components/scenery_controls.dart",
        [
            ("PhetSliderTick(Substance.air.indexForRed, 'Air'),", "PhetSliderTick(Substance.air.indexForRed, BlStrings.air),"),
            ("PhetSliderTick(Substance.water.indexForRed, 'Water'),", "PhetSliderTick(Substance.water.indexForRed, BlStrings.water),"),
            ("PhetSliderTick(Substance.glass.indexForRed, 'Glass'),", "PhetSliderTick(Substance.glass.indexForRed, BlStrings.glass),"),
        ],
        bl,
    )

    patch_file(
        "lib/bending_light/components/source_nodes.dart",
        [
            ("label: 'Normal',", "label: BlStrings.normalSpeed,"),
            ("label: 'Slow',", "label: BlStrings.slow,"),
            ("semanticsLabel: isPlaying ? 'Pause' : 'Play',", "semanticsLabel: isPlaying ? BlStrings.pause : BlStrings.play,"),
            ("semanticsLabel: 'Step',", "semanticsLabel: BlStrings.step,"),
        ],
        bl,
    )

    patch_file(
        "lib/bending_light/components/toolbox_icons.dart",
        [
            ("text: TextSpan(text: 'Intensity', style: PhetFont.of(24, color: Colors.white))", "text: TextSpan(text: BlStrings.intensity, style: PhetFont.of(24, color: Colors.white))"),
            ("text: TextSpan(text: 'Speed', style: PhetFont.of(10))", "text: TextSpan(text: BlStrings.speed, style: PhetFont.of(10))"),
        ],
        bl,
    )

    patch_file(
        "lib/bending_light/components/velocity_sensor_widget.dart",
        [
            ("text: TextSpan(text: 'Speed', style: PhetFont.of(10, color: Colors.black))", "text: TextSpan(text: BlStrings.speed, style: PhetFont.of(10, color: Colors.black))"),
        ],
        bl,
    )

    patch_file(
        "lib/bending_light/view/intro_play_area.dart",
        [("semanticsLabel: 'Intensity',", "semanticsLabel: BlStrings.intensity,")],
        bl,
    )
    patch_file(
        "lib/bending_light/view/more_tools_play_area.dart",
        [("semanticsLabel: 'Intensity',", "semanticsLabel: BlStrings.intensity,")],
        bl,
    )
    patch_file(
        "lib/bending_light/view/prisms_play_area.dart",
        [("row('Normal', normals, onNormals),", "row(BlStrings.normal, normals, onNormals),")],
        bl,
    )

    # --- WOAS ---
    patch_file(
        "lib/wave_on_a_string/view/woas_play_area.dart",
        [
            ("labels: const ['Manual', 'Oscillate', 'Pulse'],", "labels: const [WoasStrings.manual, WoasStrings.oscillate, WoasStrings.pulse],"),
        ],
        woas,
    )
    # woas_start_node Pulse button
    patch_file(
        "lib/wave_on_a_string/view/woas_start_node.dart",
        [
            ("'Pulse',", "WoasStrings.pulse,"),
        ],
        woas,
    )
    patch_file(
        "lib/wave_on_a_string/view/controls/woas_bottom_control_panel.dart",
        [
            ("title: 'Amplitude',", "title: WoasStrings.amplitude,"),
            ("title: 'Frequency',", "title: WoasStrings.frequency,"),
            ("label: 'Stopwatch',", "label: WoasStrings.stopwatch,"),
        ],
        woas,
    )
    # damping/tension if present
    p = ROOT / "lib/wave_on_a_string/view/controls/woas_bottom_control_panel.dart"
    t = p.read_text(encoding="utf-8")
    for a, b in [
        ("title: 'Damping',", "title: WoasStrings.damping,"),
        ("title: 'Tension',", "title: WoasStrings.tension,"),
        ("label: 'Reference Line',", "label: WoasStrings.referenceLine,"),
    ]:
        if a in t:
            t = t.replace(a, b)
    if woas not in t:
        t = ensure_import(t, woas)
    p.write_text(t, encoding="utf-8")
    print("updated woas_bottom_control_panel (extra)")

    patch_file(
        "lib/wave_on_a_string/view/controls/woas_time_controls.dart",
        [
            ("label: 'Normal',", "label: WoasStrings.normal,"),
            ("label: 'Slow',", "label: WoasStrings.slow,"),
            ("tooltip: 'Reset All',", "tooltip: WoasStrings.resetAll,"),
        ],
        woas,
    )

    # --- waves intro ---
    patch_file(
        "lib/waves_intro/model/scene_kind.dart",
        [("graphVerticalAxisLabel: 'Electric Field',", "graphVerticalAxisLabel: WavesIntroStrings.electricField,")],
        wi,
    )
    # add electricField to waves_intro_strings if needed via separate write later
    patch_file(
        "lib/waves_intro/screens/waves_intro_medium_screen.dart",
        [
            ("return 'Water';", "return WavesIntroStrings.water;"),
            ("return 'Sound';", "return WavesIntroStrings.sound;"),
            ("return 'Light';", "return WavesIntroStrings.light;"),
        ],
        wi,
    )

    # --- color vision ---
    patch_file(
        "lib/color_vision/painters/single_bulb_painter.dart",
        [("filterLabel = 'Custom';", "filterLabel = ColorVisionStrings.custom;")],
        cv,
    )

    # --- QM ---
    patch_file(
        "lib/quantum_measurement/spin/components/spin_source.dart",
        [("label: 'Continuous',", "label: QmStrings.continuous,")],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/spin/model/spin_model.dart",
        [("return 'Custom';", "return QmStrings.custom;")],
        qm,
    )
    for f in [
        "lib/quantum_measurement/spin/view/spin_screen.dart",
        "lib/quantum_measurement/photons/view/photons_screen.dart",
        "lib/quantum_measurement/coins/view/coins_screen.dart",
        "lib/quantum_measurement/bloch_sphere/view/bloch_screen.dart",
    ]:
        patch_file(f, [("tooltip: 'Reset All',", "tooltip: QmStrings.resetAll,")], qm)

    patch_file(
        "lib/quantum_measurement/photons/components/photon_controls.dart",
        [
            ("label: 'Vertical (V)',", "label: QmStrings.verticalV,"),
            ("label: 'Horizontal (H)',", "label: QmStrings.horizontalH,"),
            ("label: 'Unpolarized',", "label: QmStrings.unpolarized,"),
            ("label: 'Custom',", "label: QmStrings.custom,"),
            ("label: 'Normal',", "label: QmStrings.normal,"),
            ("label: 'Slow',", "label: QmStrings.slow,"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/photons/components/photon_result_display.dart",
        [("'Probability',", "QmStrings.probability,")],
        qm,
    )

    # --- QWI ---
    patch_file(
        "lib/physics/quantum_wave_interference/view/common/qwi_number_control.dart",
        [("'Wavelength',", "QwiStrings.wavelength,")],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/common/qwi_particle_selector.dart",
        [
            ("SourceType.photons: 'Photons',", "SourceType.photons: QwiStrings.photons,"),
            ("SourceType.electrons: 'Electrons',", "SourceType.electrons: QwiStrings.electrons,"),
            ("SourceType.neutrons: 'Neutrons',", "SourceType.neutrons: QwiStrings.neutrons,"),
            ("SourceType.heliumAtoms: 'Helium Atoms',", "SourceType.heliumAtoms: QwiStrings.heliumAtoms,"),
        ],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/common/qwi_tools_panel.dart",
        [
            ("label: 'Measuring Tape',", "label: QwiStrings.measuringTape,"),
            ("label: 'Stopwatch',", "label: QwiStrings.stopwatch,"),
            ("label: 'Time Plot',", "label: QwiStrings.timePlot,"),
            ("label: 'Position Plot',", "label: QwiStrings.positionPlot,"),
            ("label: 'Detector Probe',", "label: QwiStrings.detectorProbe,"),
        ],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/experiment/experiment_controls.dart",
        [
            ("title: 'Speed',", "title: QwiStrings.speed,"),
            ("title: 'Slit Separation',", "title: QwiStrings.slitSeparation,"),
            ("DetectorMode.intensity: 'Intensity',", "DetectorMode.intensity: QwiStrings.intensity,"),
            ("DetectorMode.hits: 'Hits',", "DetectorMode.hits: QwiStrings.hits,"),
            ("'Screen Brightness',", "QwiStrings.screenBrightness,"),
            ("child: Text(clock.isPlaying ? 'Pause' : 'Play', style: const TextStyle(fontSize: 11))", "child: Text(clock.isPlaying ? QwiStrings.pause : QwiStrings.play, style: const TextStyle(fontSize: 11))"),
            ("label: 'Normal',", "label: QwiStrings.normal,"),
            ("label: 'Slow',", "label: QwiStrings.slow,"),
            ("label: 'Fast',", "label: QwiStrings.fast,"),
        ],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/experiment/experiment_graph.dart",
        [("final yLabel = hits ? 'Count' : 'Intensity';", "final yLabel = hits ? QwiStrings.count : QwiStrings.intensity;")],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/layout/single_particles_layout_composer.dart",
        [
            ("'Wave Display',", "QwiStrings.waveDisplay,"),
            ("label: 'Snap',", "label: QwiStrings.snap,"),
            ("label: 'View',", "label: QwiStrings.view,"),
            ("const Text('Snapshots', style: TextStyle(fontWeight: FontWeight.bold))", "Text(QwiStrings.snapshots, style: const TextStyle(fontWeight: FontWeight.bold))"),
            ("child: const Text('Close'),", "child: Text(QwiStrings.close),"),
        ],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/single_particles/single_particles_controls.dart",
        [
            ("title: 'Speed',", "title: QwiStrings.speed,"),
            ("const Text('Configuration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11))", "Text(QwiStrings.configuration, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11))"),
            ("title: 'Slit Separation',", "title: QwiStrings.slitSeparation,"),
            ("WaveDisplayMode.electricField: 'Electric Field',", "WaveDisplayMode.electricField: QwiStrings.electricField,"),
            ("WaveDisplayMode.amplitude: 'Amplitude',", "WaveDisplayMode.amplitude: QwiStrings.amplitude,"),
            ("WaveDisplayMode.realPart: 'Real Part',", "WaveDisplayMode.realPart: QwiStrings.realPart,"),
            ("SlitConfiguration.bothOpen: 'Both Slits Open',", "SlitConfiguration.bothOpen: QwiStrings.bothSlitsOpen,"),
            ("SlitConfiguration.leftCovered: 'Top Covered',", "SlitConfiguration.leftCovered: QwiStrings.topCovered,"),
            ("SlitConfiguration.rightCovered: 'Bottom Covered',", "SlitConfiguration.rightCovered: QwiStrings.bottomCovered,"),
            ("SlitConfiguration.leftDetector: 'Detector on Top',", "SlitConfiguration.leftDetector: QwiStrings.detectorOnTop,"),
            ("SlitConfiguration.rightDetector: 'Detector on Bottom',", "SlitConfiguration.rightDetector: QwiStrings.detectorOnBottom,"),
            ("SlitConfiguration.bothDetectors: 'Detectors Both',", "SlitConfiguration.bothDetectors: QwiStrings.detectorsBoth,"),
            ("SlitConfiguration.noBarrier: 'No Barrier',", "SlitConfiguration.noBarrier: QwiStrings.noBarrier,"),
            ("leftLabel: 'Screen',", "leftLabel: QwiStrings.screen,"),
            ("rightLabel: 'Graph',", "rightLabel: QwiStrings.graph,"),
            ("const Text('Probe', style: TextStyle(fontSize: 11))", "Text(QwiStrings.probe, style: const TextStyle(fontSize: 11))"),
            ("const Text('Screen Brightness', style: TextStyle(fontFamily: 'Arial', fontSize: 11))", "Text(QwiStrings.screenBrightness, style: const TextStyle(fontFamily: 'Arial', fontSize: 11))"),
            ("child: Text(clock.isPlaying ? 'Pause' : 'Play', style: const TextStyle(fontSize: 11))", "child: Text(clock.isPlaying ? QwiStrings.pause : QwiStrings.play, style: const TextStyle(fontSize: 11))"),
            ("child: const Text('Step', style: TextStyle(fontSize: 11))", "child: Text(QwiStrings.step, style: const TextStyle(fontSize: 11))"),
            ("TimeSpeed.slow: 'Slow',", "TimeSpeed.slow: QwiStrings.slow,"),
            ("TimeSpeed.normal: 'Normal',", "TimeSpeed.normal: QwiStrings.normal,"),
            ("TimeSpeed.fast: 'Fast',", "TimeSpeed.fast: QwiStrings.fast,"),
        ],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/high_intensity/high_intensity_controls.dart",
        [
            ("const Text('Screen Brightness', style: TextStyle(fontFamily: 'Arial', fontSize: 11))", "Text(QwiStrings.screenBrightness, style: const TextStyle(fontFamily: 'Arial', fontSize: 11))"),
            ("TimeSpeed.slow: 'Slow',", "TimeSpeed.slow: QwiStrings.slow,"),
            ("TimeSpeed.normal: 'Normal',", "TimeSpeed.normal: QwiStrings.normal,"),
            ("TimeSpeed.fast: 'Fast',", "TimeSpeed.fast: QwiStrings.fast,"),
        ],
        qwi,
    )

    # high intensity layout wave display if remaining
    patch_file(
        "lib/physics/quantum_wave_interference/view/layout/high_intensity_layout_composer.dart",
        [
            ("'Wave Display',", "QwiStrings.waveDisplay,"),
        ],
        qwi,
    )

    print("DONE pass2")


if __name__ == "__main__":
    main()
