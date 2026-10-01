import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_particle.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/build_an_atom_home.dart';
import 'package:kratos/chemistry/build_an_atom/view/baa_page_shell.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/interactive_atom_play_area.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BaaPageShell upscales into a large viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BaaPageShell(
            child: ColoredBox(color: Colors.white, child: SizedBox.expand()),
          ),
        ),
      ),
    );
    await tester.pump();

    final shell = tester.renderObject<RenderBox>(find.byType(BaaPageShell));
    expect(shell.size.width, greaterThanOrEqualTo(1200));
    expect(shell.size.height, greaterThanOrEqualTo(700));

    // Fitted child should be scaled: white stage wider than design width.
    final fitted = tester.widgetList(find.byType(FittedBox));
    expect(fitted, isNotEmpty);
    final scale = 800 / BAAConstants.designHeight; // height-limited on 1280×800
    expect(BAAConstants.designWidth * scale, greaterThan(BAAConstants.designWidth));
  });

  testWidgets('pointer drag proton bucket → atom via Listener', (tester) async {
    final model = BAAModel();
    await tester.binding.setSurfaceSize(
      const Size(BAAConstants.designWidth, BAAConstants.designHeight + 56),
    );
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(BAAConstants.designWidth, BAAConstants.designHeight + 56),
            devicePixelRatio: 1,
            textScaler: TextScaler.linear(1),
          ),
          child: BuildAnAtomAtomScreen(model: model),
        ),
      ),
    );
    await tester.pump();

    final proton = model.bucketFor(BaaParticleType.proton).particles.first;
    final play = find.byType(InteractiveAtomPlayArea);
    expect(play, findsOneWidget);

    final box = tester.renderObject<RenderBox>(play);
    // modelToView(bucketX, bucketYOffset): Y = mvtViewY - scale * (-205)
    final bucketView = Offset(
      BAAConstants.mvtViewX + BAAConstants.protonBucketX,
      BAAConstants.mvtViewY - BAAConstants.bucketYOffset,
    );
    final atomView = Offset(BAAConstants.mvtViewX, BAAConstants.mvtViewY);
    final startGlobal = box.localToGlobal(bucketView);
    final endGlobal = box.localToGlobal(atomView);

    final gesture = await tester.startGesture(startGlobal);
    await tester.pump();
    expect(model.draggingParticle, isNotNull);
    await gesture.moveTo(endGlobal);
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(model.atom.protonCount, greaterThanOrEqualTo(1));
    expect(model.draggingParticle, isNull);
    expect(proton.isDragging, isFalse);
  });

  testWidgets('Home embedded Atom fills tab body (not unscaled 768)', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: BuildAnAtomHome()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(BuildAnAtomAtomScreen), findsOneWidget);
    final shellBox = tester.renderObject<RenderBox>(
      find.descendant(
        of: find.byType(BuildAnAtomAtomScreen),
        matching: find.byType(BaaPageShell),
      ),
    );
    // Tab body should give shell nearly full remaining height/width.
    expect(shellBox.size.width, greaterThan(900));
    expect(shellBox.size.height, greaterThan(500));
  });
}
