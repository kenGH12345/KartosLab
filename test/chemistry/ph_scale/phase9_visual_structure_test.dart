import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/ph_scale/model/beaker.dart';
import 'package:kratos/chemistry/ph_scale/model/macro_model.dart';
import 'package:kratos/chemistry/ph_scale/model/ph_scale_constants.dart';
import 'package:kratos/chemistry/ph_scale/ph_scale_assets.dart';
import 'package:kratos/chemistry/ph_scale/view/screens/macro_screen_view.dart';
import 'package:kratos/chemistry/ph_scale/view/screens/ph_scale_screen.dart';
import 'package:kratos/chemistry/ph_scale/view/widgets/common_controls.dart';
import 'package:kratos/chemistry/ph_scale/view/widgets/ph_scale_faucet_node.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// Phase 9 — structural visual gate (no SimulationClock + toImage).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final beaker = Beaker();

  test('source layout constants still identity-MVT', () {
    expect(PhScaleConstants.layoutBounds, const Size(1100, 700));
    expect(beaker.position, PhScaleConstants.beakerPosition);
    expect(beaker.size, PhScaleConstants.beakerSize);
    // Macro combo: left = beaker.left − 20; top = 15
    expect(beaker.left - 20, closeTo(505, 0.5));
    // My Solution accordion: left = beaker.left
    expect(beaker.left, closeTo(525, 0.5));
    // My Solution graph.right = beaker.left − 70
    expect(beaker.left - 70, closeTo(455, 0.5));
    // Neutral bottom = beaker.bottom − 30
    expect(beaker.position.dy - 30, closeTo(550, 0.5));
  });

  test('PhScaleAssets paths are original PNG registrations', () {
    expect(PhScaleAssets.eyeDropperBackground, contains('eyeDropperBackground.png'));
    expect(PhScaleAssets.faucetBody, contains('faucetBody.png'));
    expect(PhScaleAssets.macroNavbar, contains('macroNavbarIcon.png'));
    expect(PhScaleAssets.microNavbar, contains('microNavbarIcon.png'));
    expect(PhScaleAssets.mySolutionNavbar, contains('mySolutionNavbarIcon.png'));
  });

  testWidgets('Macro structure: combo / Neutral / Reset / faucet / no Graph',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final model = MacroModel();
    model.completeAutofillNow();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1100,
            height: 700,
            child: MacroScreenView(model: model),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SoluteComboBox), findsOneWidget);
    expect(find.byType(NeutralIndicator), findsOneWidget);
    expect(find.text('Neutral'), findsOneWidget);
    // Solute "Water" + faucet label "Water"
    expect(find.text('Water'), findsWidgets);
    expect(find.byType(PhScaleFaucetNode), findsNWidgets(2));
    expect(find.byType(DropperNode), findsOneWidget);
    expect(find.byType(KratosResetAllButton), findsOneWidget);
    expect(find.textContaining('Concentration'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Micro structure: Graph + Ratio/Counts + faucet', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MicroScreenView())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Concentration'), findsWidgets);
    expect(find.text('Logarithmic'), findsOneWidget);
    expect(find.text('Linear'), findsOneWidget);
    expect(find.text('Particle Counts'), findsOneWidget);
    expect(find.textContaining('Ratio'), findsOneWidget);
    expect(find.byType(PhScaleFaucetNode), findsNWidgets(2));
    expect(find.byType(DropperNode), findsOneWidget);
    expect(find.byType(KratosResetAllButton), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('My Solution structure: accordion + Graph log-only; no faucet/dropper',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MySolutionScreenView())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('7.00'), findsOneWidget);
    expect(find.textContaining('Concentration'), findsWidgets);
    expect(find.text('Logarithmic'), findsNothing);
    expect(find.text('Linear'), findsNothing);
    expect(find.text('Particle Counts'), findsOneWidget);
    expect(find.byType(PhScaleFaucetNode), findsNothing);
    expect(find.byType(DropperNode), findsNothing);
    expect(find.byType(KratosResetAllButton), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Screen icons use original navbar PNGs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PhScaleScreen()));
    await tester.pump();

    expect(find.image(AssetImage(PhScaleAssets.macroNavbar)), findsWidgets);
    expect(find.image(AssetImage(PhScaleAssets.microNavbar)), findsWidgets);
    expect(find.image(AssetImage(PhScaleAssets.mySolutionNavbar)), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
