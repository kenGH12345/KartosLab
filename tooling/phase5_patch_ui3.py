# -*- coding: utf-8 -*-
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def ensure_import(text: str, import_line: str) -> str:
    if import_line in text:
        return text
    lines = text.splitlines(keepends=True)
    idx = 0
    for i, line in enumerate(lines):
        if line.startswith("import ") or line.startswith("export "):
            idx = i + 1
    lines.insert(idx, import_line + "\n")
    return "".join(lines)


def patch_file(rel: str, replacements: list[tuple[str, str]], import_line: str | None = None) -> None:
    path = ROOT / rel
    if not path.exists():
        print(f"MISSING FILE {rel}")
        return
    text = path.read_text(encoding="utf-8")
    orig = text
    if import_line:
        text = ensure_import(text, import_line)
    for a, b in replacements:
        if a not in text:
            print(f"MISS {rel}: {a[:80]!r}")
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
    qm = "import 'package:kratos/quantum_measurement/qm_strings.dart';"
    qwi = "import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';"

    patch_file(
        "lib/bending_light/view/prisms_play_area.dart",
        [
            ("title: 'Environment',", "title: BlStrings.environment,"),
            ("title: 'Objects',", "title: BlStrings.objects,"),
            ("row('Reflections', reflections, onReflections),", "row(BlStrings.reflections, reflections, onReflections),"),
            ("row('Protractor', protractorOn, onProtractor, icon: true),", "row(BlStrings.protractor, protractorOn, onProtractor, icon: true),"),
        ],
        bl,
    )
    patch_file(
        "lib/bending_light/view/more_tools_play_area.dart",
        [
            ("'Time',", "BlStrings.time,"),
            ("title: 'Material',", "title: BlStrings.material,"),
            ("semanticsLabel: 'Protractor',", "semanticsLabel: BlStrings.protractor,"),
            ("semanticsLabel: 'Velocity',", "semanticsLabel: BlStrings.velocity,"),
            ("semanticsLabel: 'Wave',", "semanticsLabel: BlStrings.wave,"),
        ],
        bl,
    )
    patch_file(
        "lib/bending_light/view/intro_play_area.dart",
        [
            ("title: 'Material',", "title: BlStrings.material,"),
            ("semanticsLabel: 'Protractor',", "semanticsLabel: BlStrings.protractor,"),
        ],
        bl,
    )

    patch_file(
        "lib/wave_on_a_string/view/controls/woas_time_controls.dart",
        [
            ("label: 'Slow Motion',", "label: WoasStrings.slowMotion,"),
            ("label: 'Restart String',", "label: WoasStrings.restartString,"),
        ],
        woas,
    )
    patch_file(
        "lib/wave_on_a_string/view/controls/woas_bottom_control_panel.dart",
        [
            ("title: 'Pulse Width',", "title: WoasStrings.pulseWidth,"),
            ("label: 'Rulers',", "label: WoasStrings.rulers,"),
        ],
        woas,
    )
    patch_file(
        "lib/wave_on_a_string/view/woas_play_area.dart",
        [
            ("semanticLabel: 'Wave Mode',", "semanticLabel: WoasStrings.waveMode,"),
            ("semanticLabel: 'End Type',", "semanticLabel: WoasStrings.endType,"),
            ("'Fixed End',", "WoasStrings.fixedEnd,"),
            ("'Loose End',", "WoasStrings.looseEnd,"),
            ("'No End',", "WoasStrings.noEnd,"),
        ],
        woas,
    )

    # QM remaining
    patch_file(
        "lib/quantum_measurement/screens/quantum_measurement_home.dart",
        [("static const String subtitle = 'Coins · Photons · Spin · Bloch';", "static const String subtitle = QmStrings.subtitle;")],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/coins/view/coins_screen.dart",
        [
            ("(SystemType.classical, 'Classical Coin'),", "(SystemType.classical, QmStrings.classicalCoin),"),
            ("(SystemType.quantum, \"Quantum 'Coin'\"),", "(SystemType.quantum, QmStrings.quantumCoinQuoted),"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/photons/view/photons_screen.dart",
        [
            ("'Single Photon'", "QmStrings.singlePhoton"),
            ("'Many Photons'", "QmStrings.manyPhotons"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/photons/components/photon_controls.dart",
        [
            ("'Photon Polarization Angle',", "QmStrings.photonPolarizationAngle,"),
            ("'Propagation (into page)',", "QmStrings.propagationIntoPage,"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/coins/components/coin_bias_controls.dart",
        [("'Coin Bias (State)',", "QmStrings.coinBiasState,")],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/spin/components/spin_source.dart",
        [
            ("'Spin-1/2 Source',", "QmStrings.spinHalfSource,"),
            ("label: 'Single Particle',", "label: QmStrings.singleParticle,"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/spin/model/spin_model.dart",
        [
            ("return 'Experiment 1 [SGz]';", "return QmStrings.experiment1;"),
            ("return 'Experiment 2 [SGx]';", "return QmStrings.experiment2;"),
            ("return 'Experiment 3 [SGz, SGx]';", "return QmStrings.experiment3;"),
            ("return 'Experiment 4 [SGz, SGz]';", "return QmStrings.experiment4;"),
            ("return 'Experiment 5 [SGx, SGz]';", "return QmStrings.experiment5;"),
            ("return 'Experiment 6 [SGx, SGx]';", "return QmStrings.experiment6;"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/spin/view/spin_scene.dart",
        [("'Stern-Gerlach (SG) Measurements',", "QmStrings.sternGerlachMeasurements,")],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/spin/components/stern_gerlach_apparatus.dart",
        [
            ("label: 'None',", "label: QmStrings.none,"),
            ("label: 'Block ↑',", "label: QmStrings.blockUp,"),
            ("label: 'Block ↓',", "label: QmStrings.blockDown,"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/photons/components/average_polarization_panel.dart",
        [
            ("'Average Polarization',", "QmStrings.averagePolarization,"),
            ("'Vector Representation',", "QmStrings.vectorRepresentation,"),
            ("'Expectation Value',", "QmStrings.expectationValue,"),
            ("'Decimal Values',", "QmStrings.decimalValues,"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/photons/view/photons_scene.dart",
        [
            ("label: 'Vertical Polarization Detector',", "label: QmStrings.verticalPolarizationDetector,"),
            ("highlightWord: 'Vertical',", "highlightWord: QmStrings.vertical,"),
            ("label: 'Horizontal Polarization Detector',", "label: QmStrings.horizontalPolarizationDetector,"),
            ("highlightWord: 'Horizontal',", "highlightWord: QmStrings.horizontal,"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/photons/components/measurement_element.dart",
        [("'Polarizing\\nBeam Splitter',", "QmStrings.polarizingBeamSplitter.replaceAll('分束器', '分束器').replaceAll('偏振分束器', '偏振\\n分束器') if False else '偏振\\n分束器',")],
        qm,
    )
    # fix botched polarizing - do clean replace
    patch_file(
        "lib/quantum_measurement/photons/components/measurement_element.dart",
        [],
        qm,
    )
    p = ROOT / "lib/quantum_measurement/photons/components/measurement_element.dart"
    t = p.read_text(encoding="utf-8")
    # undo bad replace if any
    bad = "QmStrings.polarizingBeamSplitter.replaceAll"
    if bad in t:
        # restore simply
        import re

        t = re.sub(
            r"QmStrings\.polarizingBeamSplitter\.replaceAll\([^)]+\)[^,]*,",
            "'偏振\\n分束器',",
            t,
        )
    t = t.replace("'Polarizing\\nBeam Splitter',", "'偏振\\n分束器',")
    t = t.replace("'Polarizing\nBeam Splitter',", "'偏振\n分束器',")
    if qm not in t:
        t = ensure_import(t, qm)
    # prefer constant - add multiline via using existing if we add to bag
    t = t.replace("'偏振\\n分束器',", "QmStrings.polarizingBeamSplitter,")
    t = t.replace("'偏振\n分束器',", "QmStrings.polarizingBeamSplitter,")
    p.write_text(t, encoding="utf-8")
    print("fixed measurement_element")

    # Update polarizingBeamSplitter to include newline
    qs = ROOT / "lib/quantum_measurement/qm_strings.dart"
    qs_t = qs.read_text(encoding="utf-8")
    qs_t = qs_t.replace(
        "static const String polarizingBeamSplitter = '偏振分束器';",
        "static const String polarizingBeamSplitter = '偏振\\n分束器';",
    )
    qs.write_text(qs_t, encoding="utf-8")

    patch_file(
        "lib/quantum_measurement/coins/view/quantum_coins_scene.dart",
        [
            ('final title = preparing ? "Quantum \'Coin\' to Prepare" : \'Prepared State\';',
             "final title = preparing ? QmStrings.quantumCoinToPrepare : QmStrings.preparedState;"),
            ("const CoinsSectionTitle('Single Coin Measurements'),", "CoinsSectionTitle(QmStrings.singleCoinMeasurements),"),
            ("const CoinsSectionTitle('Multiple Coin Measurements'),", "CoinsSectionTitle(QmStrings.multipleCoinMeasurements),"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/coins/view/classical_coins_scene.dart",
        [
            ("final title = preparing ? 'Coin to Prepare' : 'Coin';",
             "final title = preparing ? QmStrings.coinToPrepare : QmStrings.coin;"),
            ("const CoinsSectionTitle('Single Coin Measurements'),", "CoinsSectionTitle(QmStrings.singleCoinMeasurements),"),
            ("const CoinsSectionTitle('Multiple Coin Measurements'),", "CoinsSectionTitle(QmStrings.multipleCoinMeasurements),"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/coins/components/coin_controls.dart",
        [
            ("if (_isRevealed) return 'Hide';", "if (_isRevealed) return QmStrings.hide;"),
            ("return systemType == SystemType.classical ? 'Reveal' : 'Observe';",
             "return systemType == SystemType.classical ? QmStrings.reveal : QmStrings.observe;"),
        ],
        qm,
    )
    patch_file(
        "lib/quantum_measurement/photons/components/angle_visualization.dart",
        [("lab('Propagation',", "lab(QmStrings.propagation,")],
        qm,
    )

    # QWI remaining
    patch_file(
        "lib/physics/quantum_wave_interference/screens/quantum_wave_interference_home.dart",
        [("static const String subtitle = 'Experiment · High Intensity · Single Particles';",
          "static const String subtitle = QwiStrings.subtitle;")],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/single_particles/single_particles_controls.dart",
        [
            ("const Flexible(child: Text('Auto-fire Mode', style: TextStyle(fontSize: 11))),",
             "Flexible(child: Text(QwiStrings.autoFireMode, style: const TextStyle(fontSize: 11))),"),
            ("const Text('Detector: Hits', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),",
             "Text(QwiStrings.detectorHits, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),"),
            ("Text('Hits ${scene.hits.length}', style: const TextStyle(fontSize: 10)),",
             "Text(QwiStrings.hitsCount(scene.hits.length), style: const TextStyle(fontSize: 10)),"),
            ("Text('Zoom ${controller.model.graphZoom.level}', style: const TextStyle(fontSize: 10)),",
             "Text(QwiStrings.zoomLevel(controller.model.graphZoom.level), style: const TextStyle(fontSize: 10)),"),
        ],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/high_intensity/high_intensity_controls.dart",
        [
            ("Text('Zoom ${controller.model.graphZoom.level}', style: const TextStyle(fontSize: 10)),",
             "Text(QwiStrings.zoomLevel(controller.model.graphZoom.level), style: const TextStyle(fontSize: 10)),"),
        ],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/experiment/experiment_controls.dart",
        [
            ("title: 'Source Intensity',", "title: QwiStrings.sourceIntensity,"),
            ("SlitConfiguration.bothOpen: 'Both Slits Open',", "SlitConfiguration.bothOpen: QwiStrings.bothSlitsOpen,"),
            ("SlitConfiguration.leftCovered: 'Left Slit Covered',", "SlitConfiguration.leftCovered: QwiStrings.leftSlitCovered,"),
            ("SlitConfiguration.rightCovered: 'Right Slit Covered',", "SlitConfiguration.rightCovered: QwiStrings.rightSlitCovered,"),
            ("SlitConfiguration.leftDetector: 'Detector on Left Slit',", "SlitConfiguration.leftDetector: QwiStrings.detectorOnLeftSlit,"),
            ("SlitConfiguration.rightDetector: 'Detector on Right Slit',", "SlitConfiguration.rightDetector: QwiStrings.detectorOnRightSlit,"),
            ("SlitConfiguration.bothDetectors: 'Detectors on Both Slits',", "SlitConfiguration.bothDetectors: QwiStrings.detectorsOnBothSlits,"),
            ("title: 'Barrier-Screen Distance',", "title: QwiStrings.barrierScreenDistance,"),
            ("const Text('Configuration', style: TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.w600)),",
             "Text(QwiStrings.configuration, style: const TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.w600)),"),
        ],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/experiment/experiment_graph.dart",
        [("final title = hits ? 'Hits Graph' : 'Intensity Graph';",
          "final title = hits ? QwiStrings.hitsGraph : QwiStrings.intensityGraph;")],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/common/qwi_probe_node.dart",
        [
            ("return 'Particle\\nDetected';", "return QwiStrings.particleDetected;"),
            ("return 'Not\\nDetected';", "return QwiStrings.notDetected;"),
        ],
        qwi,
    )
    # also try without escaped
    p = ROOT / "lib/physics/quantum_wave_interference/view/common/qwi_probe_node.dart"
    t = p.read_text(encoding="utf-8")
    t2 = t.replace("return 'Particle\nDetected';", "return QwiStrings.particleDetected;")
    t2 = t2.replace("return 'Not\nDetected';", "return QwiStrings.notDetected;")
    if qwi not in t2:
        t2 = ensure_import(t2, qwi)
    if t2 != t:
        p.write_text(t2, encoding="utf-8")
        print("updated qwi_probe_node multiline")

    patch_file(
        "lib/physics/quantum_wave_interference/view/common/qwi_time_plot.dart",
        [("'Time',", "QwiStrings.time,")],
        qwi,
    )
    patch_file(
        "lib/physics/quantum_wave_interference/view/common/qwi_position_plot.dart",
        [("'Position',", "QwiStrings.position,")],
        qwi,
    )

    print("DONE pass3")


if __name__ == "__main__":
    main()
