import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/states_of_matter/controller/atomic_interactions_controller.dart';
import 'package:kratos/chemistry/states_of_matter/controller/phase_changes_controller.dart';
import 'package:kratos/chemistry/states_of_matter/controller/states_of_matter_controller.dart';
import 'package:kratos/chemistry/states_of_matter/model/dual_atom_model.dart';
import 'package:kratos/chemistry/states_of_matter/model/force_display_mode.dart';
import 'package:kratos/chemistry/states_of_matter/model/multiple_particle_model.dart';
import 'package:kratos/chemistry/states_of_matter/model/phase_changes_model.dart';
import 'package:kratos/chemistry/states_of_matter/model/som_random.dart';
import 'package:kratos/chemistry/states_of_matter/model/substance_type.dart';
import 'package:kratos/chemistry/states_of_matter/screens/atomic_interactions_screen.dart';
import 'package:kratos/chemistry/states_of_matter/screens/phase_changes_screen.dart';
import 'package:kratos/chemistry/states_of_matter/screens/states_screen.dart';
import 'package:kratos/chemistry/states_of_matter/som_constants.dart';
import 'package:kratos/chemistry/states_of_matter/som_strings.dart';
import 'package:kratos/chemistry/states_of_matter/widgets/bicycle_pump_button.dart';
import 'package:kratos/chemistry/states_of_matter/widgets/pointing_hand_lid_control.dart';
import 'package:kratos/chemistry/states_of_matter/widgets/som_reset_button.dart';
import 'package:kratos/chemistry/states_of_matter/widgets/som_time_control.dart';

/// Browser-QA style interaction smoke after Major Geometry refresh.
///
/// Exercises controller-backed UI paths (not Diff %). Source: PhET 1.3.0-dev.3.
void main() {
  Future<void> pumpScreen(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: child),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('States: substance / phase / heat / pause / reset', (tester) async {
    final c = StatesOfMatterController(
      model: MultipleParticleModel(
        random: SomRandom(42),
        validSubstances: const {
          SubstanceType.neon,
          SubstanceType.argon,
          SubstanceType.diatomicOxygen,
          SubstanceType.water,
        },
      ),
    );
    addTearDown(c.dispose);

    await pumpScreen(tester, StatesScreen(controller: c));

    expect(c.model.substance, SubstanceType.neon);
    expect(find.text(SomStrings.neon), findsWidgets);

    await tester.tap(find.text(SomStrings.argon).first);
    await tester.pump();
    expect(c.model.substance, SubstanceType.argon);

    await tester.tap(find.text(SomStrings.liquid).first);
    await tester.pump();
    expect(c.model.scaledAtoms.length, greaterThan(0));

    c.setHeatingCoolingAmount(1);
    await tester.pump();
    expect(c.model.heatingCoolingAmount, 1);

    await tester.tap(find.byType(SomTimeControl));
    await tester.pump();
    expect(c.model.isPlaying, isFalse);

    await tester.tap(find.byType(SomResetButton));
    await tester.pump();
    expect(c.model.substance, SubstanceType.neon);
    expect(c.model.heatingCoolingAmount, 0);
  });

  testWidgets('Phase Changes: pump / piston / pause / reset', (tester) async {
    final c = PhaseChangesController(
      model: PhaseChangesModel(random: SomRandom(42)),
    );
    addTearDown(c.dispose);

    await pumpScreen(tester, PhaseChangesScreen(controller: c));

    final before = c.model.scaledAtoms.length;
    await tester.tap(find.byType(BicyclePumpButton));
    await tester.pump();
    expect(before, greaterThan(0));

    final h0 = c.model.containerHeight;
    c.setTargetContainerHeight(h0 * 0.7);
    for (var i = 0; i < 30; i++) {
      c.model.step(SomConstants.nominalTimeStep);
    }
    await tester.pump();
    expect(c.model.containerHeight, lessThan(h0));

    expect(find.byType(PointingHandLidControl), findsOneWidget);

    await tester.tap(find.byType(SomTimeControl));
    await tester.pump();
    expect(c.model.isPlaying, isFalse);

    await tester.tap(find.byType(SomResetButton));
    await tester.pump();
    expect(
      c.model.containerHeight,
      closeTo(MultipleParticleModel.particleContainerInitialHeight, 1),
    );
  });

  testWidgets('Interaction: drag / force / speed / reset', (tester) async {
    final c = AtomicInteractionsController(model: DualAtomModel());
    addTearDown(c.dispose);

    await pumpScreen(tester, AtomicInteractionsScreen(controller: c));

    final x0 = c.model.movableAtom.getX();
    c.dragTo(x0 + 80);
    c.endDrag();
    await tester.pump();
    expect(c.model.movableAtom.getX(), greaterThan(x0));
    expect(c.model.movementHintVisible, isFalse);

    c.setForcesDisplayMode(ForceDisplayMode.total);
    await tester.pump();
    expect(c.model.forcesDisplayMode, ForceDisplayMode.total);

    c.setTimeSpeed(InteractionTimeSpeed.slow);
    await tester.pump();
    expect(c.model.timeSpeed, InteractionTimeSpeed.slow);

    await tester.tap(find.byType(SomTimeControl));
    await tester.pump();
    expect(c.model.isPlaying, isFalse);

    await tester.tap(find.byType(SomResetButton));
    await tester.pump();
    expect(c.model.movementHintVisible, isTrue);
    expect(c.model.forcesDisplayMode, ForceDisplayMode.hidden);
    expect(c.model.timeSpeed, InteractionTimeSpeed.normal);
  });
}
