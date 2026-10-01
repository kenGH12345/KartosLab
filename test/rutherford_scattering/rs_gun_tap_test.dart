import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/rutherford_scattering/controller/rs_simulation_controller.dart';
import 'package:kratos/rutherford_scattering/model/rutherford_atom_model.dart';
import 'package:kratos/rutherford_scattering/painters/rs_observation_painter.dart';
import 'package:kratos/rutherford_scattering/rs_colors.dart';
import 'package:kratos/rutherford_scattering/rs_constants.dart';
import 'package:kratos/rutherford_scattering/rs_layout.dart';
import 'package:kratos/rutherford_scattering/rs_strings.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_base_screen_layout.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_control_panels.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_gun_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Alpha Particles gun red button toggles emission', (tester) async {
    final model = RutherfordAtomModel()..setRunning(false);
    final controller = RsSimulationController(model);

    await tester.binding.setSurfaceSize(
      const Size(RsLayout.layoutW, RsLayout.layoutH),
    );
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
      controller.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: RsLayout.layoutW,
            height: RsLayout.layoutH,
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return RsBaseScreenLayout(
                  controller: controller,
                  mode: RsObservationMode.atomicAtoms,
                  particleStyle: RsParticleStyle.particle,
                  scaleLabel:
                      RsStrings.atomicScale(RsConstants.atomicScaleValue),
                  beamColor: RsColors.atomBeam,
                  sceneRadio: RsSceneRadio(
                    scene: model.scene,
                    onChanged: controller.setScene,
                  ),
                  panels: [
                    RsAlphaParticlePanel(controller: controller),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(model.gun.on, isFalse);
    expect(find.byType(RsGunAssembly), findsOneWidget);

    // Tap the red button center in layout coordinates (not Stack center).
    final gunCenter = Offset(
      RsLayout.gunCenterX,
      RsLayout.gunTop + RsLayout.gunH * 0.58,
    );
    await tester.tapAt(gunCenter);
    await tester.pump();
    expect(model.gun.on, isTrue);

    await tester.tapAt(gunCenter);
    await tester.pump();
    expect(model.gun.on, isFalse);
  });
}
