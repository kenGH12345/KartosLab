import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/molecule_polarity/controller/molecule_polarity_controller.dart';
import 'package:kratos/chemistry/molecule_polarity/model/mp_preferences.dart';
import 'package:kratos/chemistry/molecule_polarity/model/real_molecules/real_molecules_model.dart';
import 'package:kratos/chemistry/molecule_polarity/mp_constants.dart';
import 'package:kratos/chemistry/molecule_polarity/screens/real_molecules_screen.dart';
import 'package:kratos/chemistry/molecule_polarity/screens/three_atoms_screen.dart';
import 'package:kratos/chemistry/molecule_polarity/screens/two_atoms_screen.dart';
import 'package:kratos/chemistry/molecule_polarity/widgets/mp_simulation_shell.dart';

/// Flutter screenshot matrix for Visual QA.
/// Run: flutter test test/chemistry/molecule_polarity/molecule_polarity_visual_qa_capture_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final arial = FontLoader('Arial')
      ..addFont(File(r'C:\Windows\Fonts\arial.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    await arial.load();
  });

  const outDir = 'requirements/req-molecule-polarity/visual-qa/FLUTTER';
  const viewport = Size(1280, 800);
  const dpr = 1.0;
  const contentScale = 1280 / MpConstants.layoutWidth;
  const contentW = MpConstants.layoutWidth * contentScale;
  const contentH = MpConstants.layoutHeight * contentScale;

  Future<void> dumpPng(GlobalKey key, String name) async {
    await TestAsyncUtils.guard(() async {});
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: dpr);
    final bd = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory(outDir).createSync(recursive: true);
    File('$outDir/$name.png').writeAsBytesSync(bd!.buffer.asUint8List());
    File('$outDir/$name.meta.txt').writeAsStringSync(
      [
        'state: $name',
        'viewport: ${viewport.width.toInt()}x${viewport.height.toInt()}',
        'DPR: $dpr',
        'contentScale: $contentScale',
        'captured_at: ${DateTime.now().toIso8601String()}',
      ].join('\n'),
    );
    // ignore: avoid_print
    print('CAPTURED $name');
  }

  Future<void> capture(
    WidgetTester tester,
    String name,
    Widget child, {
    Future<void> Function(WidgetTester tester)? afterPump,
  }) async {
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
          body: RepaintBoundary(
            key: key,
            child: Container(
              width: viewport.width,
              height: viewport.height,
              color: Colors.black,
              child: Stack(
                children: [
                  Positioned(
                    left: (viewport.width - contentW) / 2,
                    top: 0,
                    width: contentW,
                    height: contentH,
                    child: MpSimulationShell(child: child),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    if (afterPump != null) {
      await afterPump(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
    }

    await tester.runAsync(() => dumpPng(key, name));
  }

  testWidgets('01_TwoAtoms_initial', (tester) async {
    final c = MoleculePolarityController.shared();
    addTearDown(c.dispose);
    await capture(tester, '01_TwoAtoms_initial', TwoAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('02_TwoAtoms_partial_charges', (tester) async {
    final c = MoleculePolarityController.shared();
    c.setTwoPartialChargesVisible(true);
    addTearDown(c.dispose);
    await capture(
        tester, '02_TwoAtoms_partial_charges', TwoAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('03_TwoAtoms_surface_esp', (tester) async {
    final c = MoleculePolarityController.shared();
    c.setTwoSurfaceType(SurfaceType.electrostaticPotential);
    addTearDown(c.dispose);
    await capture(
        tester, '03_TwoAtoms_surface_esp', TwoAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('04_TwoAtoms_efield', (tester) async {
    final c = MoleculePolarityController.shared();
    c.setTwoEField(true);
    addTearDown(c.dispose);
    await capture(tester, '04_TwoAtoms_efield', TwoAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('05_TwoAtoms_rotated', (tester) async {
    final c = MoleculePolarityController.shared();
    c.twoAtoms.diatomic.angle = 0.785398163;
    addTearDown(c.dispose);
    await capture(tester, '05_TwoAtoms_rotated', TwoAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('06_TwoAtoms_reset', (tester) async {
    final c = MoleculePolarityController.shared();
    c.setTwoPartialChargesVisible(true);
    c.resetTwoAtoms();
    addTearDown(c.dispose);
    await capture(tester, '06_TwoAtoms_reset', TwoAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('07_ThreeAtoms_initial', (tester) async {
    final c = MoleculePolarityController.shared();
    addTearDown(c.dispose);
    await capture(
        tester, '07_ThreeAtoms_initial', ThreeAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('08_ThreeAtoms_bond_dipoles', (tester) async {
    final c = MoleculePolarityController.shared();
    c.setThreeBondDipolesVisible(true);
    addTearDown(c.dispose);
    await capture(tester, '08_ThreeAtoms_bond_dipoles',
        ThreeAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('09_ThreeAtoms_bond_angle', (tester) async {
    final c = MoleculePolarityController.shared();
    c.threeAtoms.triatomic.bondAngleAB = 3.1415926535;
    addTearDown(c.dispose);
    await capture(
        tester, '09_ThreeAtoms_bond_angle', ThreeAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('10_ThreeAtoms_efield', (tester) async {
    final c = MoleculePolarityController.shared();
    c.setThreeEField(true);
    addTearDown(c.dispose);
    await capture(
        tester, '10_ThreeAtoms_efield', ThreeAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('12_TwoAtoms_en_modified', (tester) async {
    final c = MoleculePolarityController.shared();
    c.setAtomEN(c.twoAtoms.diatomic.atomA, 3.6);
    c.setAtomEN(c.twoAtoms.diatomic.atomB, 2.2);
    addTearDown(c.dispose);
    await capture(
        tester, '12_TwoAtoms_en_modified', TwoAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('13_TwoAtoms_hints_hidden_after_rotate', (tester) async {
    final c = MoleculePolarityController.shared();
    c.twoAtoms.diatomic.angle = 0.4;
    expect(c.twoAtoms.diatomic.showHintArrows, false);
    addTearDown(c.dispose);
    await capture(tester, '13_TwoAtoms_hints_hidden_after_rotate',
        TwoAtomsScreenBody(controller: c));
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('20_Real_HF_initial', (tester) async {
    final c = MoleculePolarityController.shared();
    addTearDown(c.dispose);
    late RealMoleculesModel model;
    await tester.runAsync(() async {
      model = await RealMoleculeCatalog.load().then(
        (cat) => RealMoleculesModel(catalog: cat, preferences: c.preferences),
      );
    });
    await capture(
      tester,
      '20_Real_HF_initial',
      RealMoleculesScreenBody(controller: c, preloadedModel: model),
    );
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('21_Real_HF_esp_surface', (tester) async {
    final c = MoleculePolarityController.shared();
    addTearDown(c.dispose);
    late RealMoleculesModel model;
    await tester.runAsync(() async {
      model = await RealMoleculeCatalog.load().then(
        (cat) => RealMoleculesModel(catalog: cat, preferences: c.preferences),
      );
    });
    model.viewProperties.surfaceType = SurfaceType.electrostaticPotential;
    await capture(
      tester,
      '21_Real_HF_esp_surface',
      RealMoleculesScreenBody(controller: c, preloadedModel: model),
    );
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('22_Real_HF_rotated_dipole', (tester) async {
    final c = MoleculePolarityController.shared();
    addTearDown(c.dispose);
    late RealMoleculesModel model;
    await tester.runAsync(() async {
      model = await RealMoleculeCatalog.load().then(
        (cat) => RealMoleculesModel(catalog: cat, preferences: c.preferences),
      );
    });
    model.viewProperties.molecularDipoleVisible = true;
    model.applyDrag(90, 35);
    await capture(
      tester,
      '22_Real_HF_rotated_dipole',
      RealMoleculesScreenBody(controller: c, preloadedModel: model),
    );
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('23_Real_HF_density_advanced', (tester) async {
    final c = MoleculePolarityController.shared();
    addTearDown(c.dispose);
    late RealMoleculesModel model;
    await tester.runAsync(() async {
      model = await RealMoleculeCatalog.load().then(
        (cat) => RealMoleculesModel(catalog: cat, preferences: c.preferences),
      );
    });
    model.isAdvanced = true;
    model.viewProperties.surfaceType = SurfaceType.electronDensity;
    await capture(
      tester,
      '23_Real_HF_density_advanced',
      RealMoleculesScreenBody(controller: c, preloadedModel: model),
    );
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('24_Real_HF_reset', (tester) async {
    final c = MoleculePolarityController.shared();
    addTearDown(c.dispose);
    late RealMoleculesModel model;
    await tester.runAsync(() async {
      model = await RealMoleculeCatalog.load().then(
        (cat) => RealMoleculesModel(catalog: cat, preferences: c.preferences),
      );
    });
    model.viewProperties.bondDipolesVisible = true;
    model.viewProperties.surfaceType = SurfaceType.electrostaticPotential;
    model.applyDrag(50, 20);
    model.reset();
    await capture(
      tester,
      '24_Real_HF_reset',
      RealMoleculesScreenBody(controller: c, preloadedModel: model),
    );
  }, timeout: const Timeout(Duration(seconds: 60)));
}
