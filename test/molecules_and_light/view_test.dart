import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/molecules_and_light/molecules_and_light_constants.dart';
import 'package:kratos/molecules_and_light/view/molecules_and_light_screen.dart';

void main() {
  Future<void> pumpSim(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: MoleculesAndLightScreen()));
    await tester.pump();
  }

  testWidgets('screen builds with default infrared CO and emitter off',
      (tester) async {
    await pumpSim(tester);
    expect(find.byType(MoleculesAndLightScreen), findsOneWidget);
    expect(find.byKey(const Key('light-selector')), findsOneWidget);
    expect(find.byKey(const Key('molecule-selector')), findsOneWidget);
    expect(find.byKey(const Key('light-Infrared')), findsOneWidget);
    expect(find.byKey(const Key('molecule-CO')), findsOneWidget);

    final state = tester.state<MoleculesAndLightScreenState>(
      find.byType(MoleculesAndLightScreen),
    );
    expect(state.model.light, LightType.infrared);
    expect(state.model.emitterOn, isFalse);
    expect(state.model.moleculeType, MoleculeType.carbonMonoxide);
  });

  testWidgets('light and molecule selectors mutate the model', (tester) async {
    await pumpSim(tester);
    final state = tester.state<MoleculesAndLightScreenState>(
      find.byType(MoleculesAndLightScreen),
    );

    await tester.tap(find.byKey(const Key('light-Visible')));
    await tester.pump();
    expect(state.model.light, LightType.visible);

    await tester.tap(find.byKey(const Key('molecule-H₂O')));
    await tester.pump();
    expect(state.model.moleculeType, MoleculeType.water);
  });

  testWidgets('pause step reset and spectrum dialog', (tester) async {
    await pumpSim(tester);
    final state = tester.state<MoleculesAndLightScreenState>(
      find.byType(MoleculesAndLightScreen),
    );

    await tester.tap(find.byKey(const Key('play-pause')));
    await tester.pump();
    expect(state.model.running, isFalse);

    final before = state.model.photons.length;
    state.model.setEmitterOn(true);
    await tester.tap(find.byKey(const Key('step-forward')));
    await tester.pump();
    expect(state.model.photons.length, greaterThanOrEqualTo(before));

    await tester.tap(find.byKey(const Key('spectrum-button')));
    await tester.pump();
    expect(find.byKey(const Key('spectrum-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('spectrum-close')));
    await tester.pump();
    expect(find.byKey(const Key('spectrum-dialog')), findsNothing);

    await tester.tap(find.byType(KratosResetAllButton));
    await tester.pump();
    expect(state.model.light, LightType.infrared);
    expect(state.model.emitterOn, isFalse);
    expect(state.model.moleculeType, MoleculeType.carbonMonoxide);
    expect(state.model.running, isTrue);
  });

  testWidgets('turning emitter on creates photons while clock runs',
      (tester) async {
    await pumpSim(tester);
    final state = tester.state<MoleculesAndLightScreenState>(
      find.byType(MoleculesAndLightScreen),
    );
    state.model.setEmitterOn(true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(state.model.photons, isNotEmpty);
  });
}
