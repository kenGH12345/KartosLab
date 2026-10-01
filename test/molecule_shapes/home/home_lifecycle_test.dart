import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/molecule_shapes/model/vec3.dart';
import 'package:kratos/molecule_shapes/molecule_shapes_strings.dart';
import 'package:kratos/molecule_shapes/screens/molecule_shapes_home.dart';
import 'package:kratos/molecule_shapes/view/model_molecules_screen.dart';
import 'package:kratos/molecule_shapes/view/real_molecules_screen.dart';
import 'package:kratos/screens/home_screen.dart';

class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
  }
}

Future<void> _openHome(WidgetTester tester, {NavigatorObserver? observer}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: const HomeScreen(),
      navigatorObservers: [?observer],
    ),
  );
  await tester.pump();
}

Future<void> _enter(WidgetTester tester) async {
  await tester.ensureVisible(find.text(MoleculeShapesHome.title).first);
  await tester.tap(find.text(MoleculeShapesHome.title).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(MoleculeShapesHome), findsOneWidget);
  expect(find.byType(ModelMoleculesScreen), findsOneWidget);
}

Future<void> _back(WidgetTester tester, _PopObserver observer) async {
  final before = observer.popCount;
  final backButton = find.byType(BackButton);
  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton);
  } else {
    await tester.tap(find.byType(IconButton).first);
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  expect(observer.popCount, greaterThan(before));
  expect(find.byType(MoleculeShapesHome), findsNothing);
}

ModelMoleculesScreenState _modelState(WidgetTester tester) {
  return tester.state<ModelMoleculesScreenState>(
    find.byType(ModelMoleculesScreen),
  );
}

RealMoleculesScreenState _realState(WidgetTester tester) {
  return tester.state<RealMoleculesScreenState>(
    find.byType(RealMoleculesScreen),
  );
}

Future<void> _openRealTab(WidgetTester tester) async {
  await tester.tap(find.text(MoleculeShapesStrings.screenRealMolecules));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(RealMoleculesScreen), findsOneWidget);
}

void main() {
  testWidgets('Home lists Molecule Shapes under 化学 / 分子形状', (tester) async {
    await _openHome(tester);
    await tester.ensureVisible(find.text('化学').first);
    expect(find.text('化学'), findsWidgets);
    await tester.ensureVisible(find.text('分子形状').first);
    expect(find.text('分子形状'), findsOneWidget);
    await tester.ensureVisible(find.text(MoleculeShapesHome.title).first);
    expect(find.text(MoleculeShapesHome.title), findsOneWidget);
    expect(find.text(MoleculeShapesHome.subtitle), findsOneWidget);
    expect(find.byIcon(Icons.hub_outlined), findsOneWidget);
  });

  testWidgets('A: Home → entry → Back → re-entry is fresh', (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enter(tester);

    final model = _modelState(tester);
    expect(model.model.molecule.domainCount, 2);
    expect(model.model.quaternion, Quat.identity);

    await _back(tester, observer);
    expect(find.byType(HomeScreen), findsOneWidget);

    await _enter(tester);
    final again = _modelState(tester);
    expect(identical(again.model, model.model), isFalse);
    expect(again.model.molecule.domainCount, 2);
    expect(again.model.quaternion, Quat.identity);
  });

  testWidgets('B: Model active → Back → re-entry defaults', (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enter(tester);

    final first = _modelState(tester);
    first.model.removeAll();
    first.model.addPairGroup(3);
    first.model.addPairGroup(0);
    first.model.rotateByPointer(30, 12);
    first.model.showBondAngles = true;
    await tester.pump(const Duration(milliseconds: 100));
    expect(first.model.molecule.domainCount, 2);
    expect(first.model.quaternion, isNot(Quat.identity));

    await _back(tester, observer);
    expect(find.byType(ModelMoleculesScreen), findsNothing);

    await _enter(tester);
    final second = _modelState(tester);
    expect(identical(second.model, first.model), isFalse);
    expect(second.model.molecule.domainCount, 2);
    expect(second.model.molecule.bonds.map((b) => b.order), [1, 1]);
    expect(second.model.showBondAngles, isFalse);
    expect(second.model.quaternion, Quat.identity);
  });

  testWidgets('C: Real active → Back → re-entry H2O Real', (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enter(tester);
    await _openRealTab(tester);

    final first = _realState(tester);
    first.model.selectMolecule(first.model.shape); // no-op if same
    // Switch away from water via model API after ensuring Real screen built.
    expect(first.model.shape.displayName, 'H2O');
    expect(first.model.showRealView, isTrue);
    expect(first.model.molecule.bondAngles().single.label, '104.5°');

    // Mutate Real view.
    first.model.setShowRealView(false);
    first.model.rotateByPointer(18, -6);
    first.model.showBondAngles = true;
    await tester.pump();
    expect(first.model.molecule.bondAngles().single.label, '109.5°');

    await _back(tester, observer);

    await _enter(tester);
    await _openRealTab(tester);
    final second = _realState(tester);
    expect(identical(second.model, first.model), isFalse);
    expect(second.model.shape.displayName, 'H2O');
    expect(second.model.showRealView, isTrue);
    expect(second.model.molecule.bondAngles().single.label, '104.5°');
    expect(second.model.showBondAngles, isFalse);
    expect(second.model.quaternion, Quat.identity);
  });

  testWidgets('D: Model modified → Real → Back → re-entry both fresh',
      (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    await _enter(tester);

    final model = _modelState(tester);
    model.model.addPairGroup(2);
    model.model.rotateByPointer(10, 4);
    await tester.pump();

    await _openRealTab(tester);
    final real = _realState(tester);
    real.model.rotateByPointer(5, 5);
    real.model.showLonePairs = false;
    await tester.pump();

    // Isolation while both live under Home shell.
    expect(model.model.molecule.domainCount, greaterThan(2));
    expect(real.model.shape.displayName, 'H2O');
    expect(real.model.showLonePairs, isFalse);
    expect(model.model.showLonePairs, isTrue);

    await _back(tester, observer);
    await _enter(tester);

    final model2 = _modelState(tester);
    expect(model2.model.molecule.domainCount, 2);
    expect(model2.model.quaternion, Quat.identity);

    await _openRealTab(tester);
    final real2 = _realState(tester);
    expect(real2.model.shape.displayName, 'H2O');
    expect(real2.model.showRealView, isTrue);
    expect(real2.model.showLonePairs, isTrue);
    expect(real2.model.molecule.bondAngles().single.label, '104.5°');
  });

  testWidgets('H2O Real/Model angle survives Home entry path', (tester) async {
    await _openHome(tester);
    await _enter(tester);
    await _openRealTab(tester);
    final real = _realState(tester);
    expect(real.model.molecule.bondAngles().single.label, '104.5°');
    real.model.setShowRealView(false);
    expect(real.model.molecule.bondAngles().single.label, '109.5°');
    real.model.setShowRealView(true);
    expect(real.model.molecule.bondAngles().single.label, '104.5°');
  });

  testWidgets('open/close twice does not leak MoleculeShapesHome',
      (tester) async {
    final observer = _PopObserver();
    await _openHome(tester, observer: observer);
    for (var i = 0; i < 2; i++) {
      await _enter(tester);
      await tester.pump(const Duration(milliseconds: 50));
      await _back(tester, observer);
    }
    expect(observer.popCount, 2);
    expect(find.byType(MoleculeShapesHome), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
