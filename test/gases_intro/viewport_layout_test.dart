import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gases_intro/model/ideal_gas_law_model.dart';
import 'package:kratos/gases_intro/view/layout_policy.dart';
import 'package:kratos/gases_intro/widgets/gases_intro_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpAt(WidgetTester tester, Size viewport) async {
    final view = tester.view;
    view.physicalSize = viewport;
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    final scale = GasesIntroLayoutPolicy.fitScale(viewport.width, viewport.height);
    final phys = GasesIntroLayoutPolicy.physicalSize(scale);
    final model = IdealGasLawModel(hasHoldConstantControls: true, autoTick: false);
    addTearDown(model.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: phys.width,
              height: phys.height,
              child: GasesIntroShell(
                model: model,
                showHoldConstant: true,
                layoutScale: scale,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('Desktop 1280×800 shell builds without exception', (tester) async {
    await pumpAt(tester, const Size(1280, 800));
    expect(tester.takeException(), isNull);
    expect(find.byType(GasesIntroShell), findsOneWidget);
  });

  testWidgets('Tablet 1024×768 shell builds without exception', (tester) async {
    await pumpAt(tester, const Size(1024, 768));
    expect(tester.takeException(), isNull);
    expect(find.byType(GasesIntroShell), findsOneWidget);
  });

  testWidgets('Narrow 720×480 shell builds without exception', (tester) async {
    await pumpAt(tester, const Size(720, 480));
    expect(tester.takeException(), isNull);
    expect(find.byType(GasesIntroShell), findsOneWidget);
  });
}
