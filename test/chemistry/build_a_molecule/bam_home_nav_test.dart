import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_a_molecule/controller/bam_controller.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_molecule_catalog.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_strings.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_screen_configurations.dart';
import 'package:kratos/chemistry/build_a_molecule/screens/build_a_molecule_home.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  setUpAll(() async {
    BamMoleculeCatalog.initialList.completeMolecules.clear();
    BamMoleculeCatalog.initialList.moleculeNameMap.clear();
    BamMoleculeCatalog.mainInstance = null;
    BamMoleculeCatalog.initialized = false;
    await BamMoleculeCatalog.ensureInitialLoaded();
    await BamStrings.load();
  });

  testWidgets('pump home, open BAM, switch tabs, back', (tester) async {
    await setDesktop(tester);

    final rng = math.Random(1);
    final single = BamController(
      BamScreenConfigurations.createSingle(random: rng),
    );
    final multiple = BamController(
      BamScreenConfigurations.createMultiple(random: rng),
    );
    final playground = BamController(
      BamScreenConfigurations.createPlayground(random: rng),
    );

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('搭建分子'), findsOneWidget);
    expect(find.text('分子搭建'), findsOneWidget);

    await tester.ensureVisible(find.text('搭建分子').first);
    await tester.tap(find.text('搭建分子').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(
      MaterialApp(
        home: BuildAMoleculeHome(
          singleController: single,
          multipleController: multiple,
          playgroundController: playground,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(BuildAMoleculeHome.title), findsWidgets);
    expect(find.text(BuildAMoleculeHome.singleTabLabel), findsOneWidget);

    await tester.tap(find.text(BuildAMoleculeHome.multipleTabLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text(BuildAMoleculeHome.playgroundTabLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  });
}
