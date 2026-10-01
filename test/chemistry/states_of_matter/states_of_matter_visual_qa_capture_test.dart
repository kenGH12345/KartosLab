import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/states_of_matter/controller/atomic_interactions_controller.dart';
import 'package:kratos/chemistry/states_of_matter/controller/phase_changes_controller.dart';
import 'package:kratos/chemistry/states_of_matter/controller/states_of_matter_controller.dart';
import 'package:kratos/chemistry/states_of_matter/model/dual_atom_model.dart';
import 'package:kratos/chemistry/states_of_matter/model/force_display_mode.dart';
import 'package:kratos/chemistry/states_of_matter/model/multiple_particle_model.dart';
import 'package:kratos/chemistry/states_of_matter/model/phase_changes_model.dart';
import 'package:kratos/chemistry/states_of_matter/model/phase_state.dart';
import 'package:kratos/chemistry/states_of_matter/model/som_random.dart';
import 'package:kratos/chemistry/states_of_matter/model/substance_type.dart';
import 'package:kratos/chemistry/states_of_matter/screens/atomic_interactions_screen.dart';
import 'package:kratos/chemistry/states_of_matter/screens/phase_changes_screen.dart';
import 'package:kratos/chemistry/states_of_matter/screens/states_screen.dart';
import 'package:kratos/chemistry/states_of_matter/som_assets.dart';
import 'package:kratos/chemistry/states_of_matter/som_constants.dart';
import 'package:kratos/chemistry/states_of_matter/transform/som_coordinate_transform.dart';

/// Flutter screenshot matrix for States of Matter Visual QA.
///
/// Run (dedicated tool, NOT part of `tool/_run_som_tests.bat` gate):
///   tool\run_som_capture.bat
///
/// Same FakeAsync/toImage caveat as pendulum: PNG is written synchronously
/// as the last statement; a TimeoutException after write is expected on some
/// machines. Success = all 15 PNG + meta files exist with CAPTURED markers.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final arial = FontLoader('Arial')
      ..addFont(
        File(r'C:\Windows\Fonts\arial.ttf').readAsBytes().then(
              (bytes) => ByteData.view(bytes.buffer),
            ),
      );
    await arial.load();
  });

  const outDir = 'requirements/req-states-of-matter/visual-qa/FLUTTER';
  const viewport = Size(1280, 800);
  const dpr = 1.0;
  const perTestTimeout = Timeout(Duration(seconds: 20));

  void step(MultipleParticleModel m, int frames) {
    for (var i = 0; i < frames; i++) {
      m.step(SomConstants.nominalTimeStep);
    }
  }

  StatesOfMatterController statesCtrl({int seed = 42}) {
    return StatesOfMatterController(
      model: MultipleParticleModel(
        random: SomRandom(seed),
        validSubstances: const {
          SubstanceType.neon,
          SubstanceType.argon,
          SubstanceType.diatomicOxygen,
          SubstanceType.water,
        },
      ),
    );
  }

  PhaseChangesController phaseCtrl({int seed = 42}) {
    return PhaseChangesController(
      model: PhaseChangesModel(random: SomRandom(seed)),
    );
  }

  Future<void> capture(
    WidgetTester tester,
    String name,
    Widget child,
  ) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = dpr;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Arial', useMaterial3: false),
        home: Scaffold(
          body: SizedBox(
            width: viewport.width,
            height: viewport.height,
            child: RepaintBoundary(
              key: key,
              // Screens use SomSceneShell — fills viewport with Joist-like scale.
              child: child,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // Decode PhET assets before toImage — otherwise hand/pin are invisible.
    await tester.runAsync(() async {
      final ctx = key.currentContext!;
      await Future.wait([
        precacheImage(AssetImage(SomAssets.pointingHand), ctx),
        precacheImage(AssetImage(SomAssets.hand), ctx),
        precacheImage(AssetImage(SomAssets.pushPin), ctx),
        precacheImage(AssetImage(SomAssets.solidIcon), ctx),
        precacheImage(AssetImage(SomAssets.liquidIcon), ctx),
        precacheImage(AssetImage(SomAssets.gasIcon), ctx),
      ]);
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: dpr);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    File('$outDir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List(), flush: true);
    File('$outDir/$name.meta.txt').writeAsStringSync(
      [
        'state: $name',
        'viewport: ${viewport.width.toInt()}x${viewport.height.toInt()}',
        'DPR: $dpr',
        'design: ${SomCoordinateTransform.layoutBoundsWidth}x'
            '${SomCoordinateTransform.layoutBoundsHeight}',
        'scene_scale: joist-fit (SomSceneShell)',
        'paused: true',
        'source: local-flutter-widget-test',
        'captured_at: ${DateTime.now().toIso8601String()}',
      ].join('\n'),
      flush: true,
    );
    // ignore: avoid_print
    print('CAPTURED $name');
  }

  testWidgets('01_States_neon_solid_initial', (tester) async {
    final c = statesCtrl()..setPlaying(false);
    addTearDown(c.dispose);
    await capture(
      tester,
      '01_States_neon_solid_initial',
      StatesScreen(controller: c),
    );
  }, timeout: perTestTimeout);

  testWidgets('02_States_neon_liquid', (tester) async {
    final c = statesCtrl()
      ..setPhase(PhaseState.liquid)
      ..setPlaying(false);
    addTearDown(c.dispose);
    await capture(tester, '02_States_neon_liquid', StatesScreen(controller: c));
  }, timeout: perTestTimeout);

  testWidgets('03_States_neon_gas', (tester) async {
    final c = statesCtrl()
      ..setPhase(PhaseState.gas)
      ..setPlaying(false);
    addTearDown(c.dispose);
    await capture(tester, '03_States_neon_gas', StatesScreen(controller: c));
  }, timeout: perTestTimeout);

  testWidgets('04_States_argon_solid', (tester) async {
    final c = statesCtrl(seed: 43)
      ..setSubstance(SubstanceType.argon)
      ..setPhase(PhaseState.solid)
      ..setPlaying(false);
    addTearDown(c.dispose);
    await capture(tester, '04_States_argon_solid', StatesScreen(controller: c));
  }, timeout: perTestTimeout);

  testWidgets('05_States_oxygen_solid', (tester) async {
    final c = statesCtrl(seed: 44)
      ..setSubstance(SubstanceType.diatomicOxygen)
      ..setPhase(PhaseState.solid)
      ..setPlaying(false);
    addTearDown(c.dispose);
    await capture(tester, '05_States_oxygen_solid', StatesScreen(controller: c));
  }, timeout: perTestTimeout);

  testWidgets('06_States_water_solid', (tester) async {
    final c = statesCtrl(seed: 45)
      ..setSubstance(SubstanceType.water)
      ..setPhase(PhaseState.solid)
      ..setPlaying(false);
    addTearDown(c.dispose);
    await capture(tester, '06_States_water_solid', StatesScreen(controller: c));
  }, timeout: perTestTimeout);

  testWidgets('07_States_heated', (tester) async {
    final c = statesCtrl();
    addTearDown(c.dispose);
    c.setPlaying(true);
    c.setHeatingCoolingAmount(1.0);
    step(c.model, 90);
    c.setPlaying(false);
    await capture(tester, '07_States_heated', StatesScreen(controller: c));
  }, timeout: perTestTimeout);

  testWidgets('08_States_paused', (tester) async {
    final c = statesCtrl();
    addTearDown(c.dispose);
    c.setPlaying(true);
    step(c.model, 30);
    c.setPlaying(false);
    await capture(tester, '08_States_paused', StatesScreen(controller: c));
  }, timeout: perTestTimeout);

  testWidgets('09_States_reset', (tester) async {
    final c = statesCtrl();
    addTearDown(c.dispose);
    c.setSubstance(SubstanceType.argon);
    c.setPhase(PhaseState.gas);
    step(c.model, 10);
    c.resetAll();
    c.setPlaying(false);
    await capture(tester, '09_States_reset', StatesScreen(controller: c));
  }, timeout: perTestTimeout);

  testWidgets('10_PhaseChanges_initial', (tester) async {
    final c = phaseCtrl()..setPlaying(false);
    addTearDown(c.dispose);
    await capture(
      tester,
      '10_PhaseChanges_initial',
      PhaseChangesScreen(controller: c),
    );
  }, timeout: perTestTimeout);

  testWidgets('11_PhaseChanges_compressed', (tester) async {
    final c = phaseCtrl(seed: 50);
    addTearDown(c.dispose);
    c.setPlaying(true);
    c.setTargetContainerHeight(5000);
    step(c.model, 240);
    c.setPlaying(false);
    await capture(
      tester,
      '11_PhaseChanges_compressed',
      PhaseChangesScreen(controller: c),
    );
  }, timeout: perTestTimeout);

  testWidgets('12_PhaseChanges_adjustable', (tester) async {
    final c = phaseCtrl(seed: 51)
      ..setSubstance(SubstanceType.adjustableAtom)
      ..setEpsilon(200)
      ..setPlaying(false);
    addTearDown(c.dispose);
    await capture(
      tester,
      '12_PhaseChanges_adjustable',
      PhaseChangesScreen(controller: c),
    );
  }, timeout: perTestTimeout);

  testWidgets('13_Interaction_neon_initial', (tester) async {
    final c = AtomicInteractionsController(model: DualAtomModel())
      ..setPlaying(false);
    addTearDown(c.dispose);
    await capture(
      tester,
      '13_Interaction_neon_initial',
      AtomicInteractionsScreen(controller: c),
    );
  }, timeout: perTestTimeout);

  testWidgets('14_Interaction_forces_total', (tester) async {
    final c = AtomicInteractionsController(model: DualAtomModel());
    addTearDown(c.dispose);
    c.setForcesDisplayMode(ForceDisplayMode.total);
    c.dragTo(400);
    c.endDrag();
    c.setPlaying(false);
    await capture(
      tester,
      '14_Interaction_forces_total',
      AtomicInteractionsScreen(controller: c),
    );
  }, timeout: perTestTimeout);

  testWidgets('15_Interaction_reset', (tester) async {
    final c = AtomicInteractionsController(model: DualAtomModel());
    addTearDown(c.dispose);
    c.setForcesDisplayMode(ForceDisplayMode.components);
    c.dragTo(350);
    c.endDrag();
    c.resetAll();
    c.setPlaying(false);
    await capture(
      tester,
      '15_Interaction_reset',
      AtomicInteractionsScreen(controller: c),
    );
  }, timeout: perTestTimeout);
}
