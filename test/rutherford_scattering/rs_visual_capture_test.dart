import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/rutherford_scattering/controller/rs_simulation_controller.dart';
import 'package:kratos/rutherford_scattering/model/plum_pudding_atom_model.dart';
import 'package:kratos/rutherford_scattering/model/rutherford_atom_model.dart';
import 'package:kratos/rutherford_scattering/painters/rs_observation_painter.dart';
import 'package:kratos/rutherford_scattering/rs_colors.dart';
import 'package:kratos/rutherford_scattering/rs_constants.dart';
import 'package:kratos/rutherford_scattering/rs_layout.dart';
import 'package:kratos/rutherford_scattering/rs_strings.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_base_screen_layout.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_control_panels.dart';

/// 1024×618 visual QA captures → requirements/.../visual-qa/V1/
///
/// Does NOT attach SimulationClock (avoids pending-frame hangs in widget tests).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final outDir = Directory(
    'requirements/req-rutherford-scattering/visual-qa/V1',
  );

  setUpAll(() {
    if (!outDir.existsSync()) outDir.createSync(recursive: true);
  });

  Future<void> pumpAndSave(
    WidgetTester tester,
    String name,
    Widget child,
  ) async {
    await tester.binding.setSurfaceSize(
      const Size(RsLayout.layoutW, RsLayout.layoutH),
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: ValueKey('rs-capture-$name'),
              child: SizedBox(
                width: RsLayout.layoutW,
                height: RsLayout.layoutH,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(ValueKey('rs-capture-$name')),
    );
    final file = File('${outDir.path}/$name.png');
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bd = await image.toByteData(format: ui.ImageByteFormat.png);
      await file.writeAsBytes(bd!.buffer.asUint8List());
    });
    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(1000));
  }

  testWidgets('rutherford_initial', (tester) async {
    await pumpAndSave(
      tester,
      'rutherford_initial',
      _RutherfordCapture(scene: RutherfordScene.atom),
    );
  });

  testWidgets('rutherford_atomic_scale', (tester) async {
    await pumpAndSave(
      tester,
      'rutherford_atomic_scale',
      _RutherfordCapture(scene: RutherfordScene.atom),
    );
  });

  testWidgets('rutherford_nuclear_scale', (tester) async {
    await pumpAndSave(
      tester,
      'rutherford_nuclear_scale',
      _RutherfordCapture(scene: RutherfordScene.nucleus),
    );
  });

  testWidgets('rutherford_energy_changed', (tester) async {
    await pumpAndSave(
      tester,
      'rutherford_energy_changed',
      _RutherfordCapture(scene: RutherfordScene.atom, energy: 55),
    );
  });

  testWidgets('rutherford_protons_changed', (tester) async {
    await pumpAndSave(
      tester,
      'rutherford_protons_changed',
      _RutherfordCapture(scene: RutherfordScene.atom, protons: 40),
    );
  });

  testWidgets('plum_pudding_initial', (tester) async {
    await pumpAndSave(
      tester,
      'plum_pudding_initial',
      const _PlumCapture(),
    );
  });
}

class _RutherfordCapture extends StatefulWidget {
  const _RutherfordCapture({
    required this.scene,
    this.energy,
    this.protons,
  });

  final RutherfordScene scene;
  final double? energy;
  final int? protons;

  @override
  State<_RutherfordCapture> createState() => _RutherfordCaptureState();
}

class _RutherfordCaptureState extends State<_RutherfordCapture> {
  late final RutherfordAtomModel model;
  late final RsSimulationController controller;

  @override
  void initState() {
    super.initState();
    model = RutherfordAtomModel()..setRunning(false);
    if (widget.scene != RutherfordScene.atom) {
      model.setScene(widget.scene);
    }
    if (widget.energy != null) model.setAlphaParticleEnergy(widget.energy!);
    if (widget.protons != null) model.setProtonCount(widget.protons!);
    // Controller without ticker attach — static snapshot only.
    controller = RsSimulationController(model);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNucleus = model.scene == RutherfordScene.nucleus;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return RsBaseScreenLayout(
          controller: controller,
          mode: isNucleus
              ? RsObservationMode.nuclearCluster
              : RsObservationMode.atomicAtoms,
          particleStyle:
              isNucleus ? RsParticleStyle.nucleus : RsParticleStyle.particle,
          scaleLabel: isNucleus
              ? RsStrings.nuclearScale(RsConstants.nuclearScaleValue)
              : RsStrings.atomicScale(RsConstants.atomicScaleValue),
          beamColor: isNucleus ? RsColors.nucleusBeam : RsColors.atomBeam,
          sceneRadio: RsSceneRadio(
            scene: model.scene,
            onChanged: controller.setScene,
          ),
          panels: [
            RsLegendPanel(
              entries: isNucleus
                  ? [
                      (RsLegendPanel.protonDot(), RsStrings.proton),
                      (RsLegendPanel.neutronDot(), RsStrings.neutron),
                      (RsLegendPanel.alphaCluster(), RsStrings.alphaParticle),
                    ]
                  : [
                      (RsLegendPanel.nucleusDot(), RsStrings.nucleus),
                      (
                        RsLegendPanel.energyLevelIcon(),
                        RsStrings.electronEnergyLevel
                      ),
                      (
                        RsLegendPanel.traceArrow(),
                        RsStrings.alphaParticleTrace
                      ),
                    ],
            ),
            RsAlphaParticlePanel(controller: controller),
            RsAtomPropertiesPanel(controller: controller),
          ],
        );
      },
    );
  }
}

class _PlumCapture extends StatefulWidget {
  const _PlumCapture();

  @override
  State<_PlumCapture> createState() => _PlumCaptureState();
}

class _PlumCaptureState extends State<_PlumCapture> {
  late final PlumPuddingAtomModel model;
  late final RsSimulationController controller;
  ui.Image? _plumImage;

  @override
  void initState() {
    super.initState();
    model = PlumPuddingAtomModel()..setRunning(false);
    controller = RsSimulationController(model);
    // Fire-and-forget; capture may run before decode finishes — acceptable for V1.
    loadRsPlumPuddingImage().then((img) {
      if (mounted) setState(() => _plumImage = img);
    });
  }

  @override
  void dispose() {
    _plumImage?.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return RsBaseScreenLayout(
          controller: controller,
          mode: RsObservationMode.plumPudding,
          particleStyle: RsParticleStyle.nucleus,
          scaleLabel: RsStrings.atomicScale(RsConstants.plumPuddingScaleValue),
          beamColor: RsColors.atomBeam,
          plumPuddingImage: _plumImage,
          panels: [
            RsLegendPanel(
              entries: [
                (RsLegendPanel.electronDot(), RsStrings.electron),
                (RsLegendPanel.protonDot(), RsStrings.proton),
                (RsLegendPanel.neutronDot(), RsStrings.neutron),
                (RsLegendPanel.alphaCluster(), RsStrings.alphaParticle),
                (RsLegendPanel.positiveChargeIcon(), RsStrings.positiveCharge),
              ],
            ),
            RsAlphaParticlePanel(controller: controller),
          ],
        );
      },
    );
  }
}
