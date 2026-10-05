import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_a_molecule/controller/bam_controller.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_molecule_catalog.dart';
import 'package:kratos/chemistry/build_a_molecule/data/bam_strings.dart';
import 'package:kratos/chemistry/build_a_molecule/model/bam_screen_configurations.dart';
import 'package:kratos/chemistry/build_a_molecule/screens/bam_screen_body.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    BamMoleculeCatalog.initialList.completeMolecules.clear();
    BamMoleculeCatalog.initialList.moleculeNameMap.clear();
    BamMoleculeCatalog.mainInstance = null;
    BamMoleculeCatalog.initialized = false;
    await BamMoleculeCatalog.ensureInitialLoaded();
    await BamStrings.load();
  });

  testWidgets('atoms drag from bucket onto canvas; tap does not spawn',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final c = BamController(
      BamScreenConfigurations.createSingle(random: math.Random(1)),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BamScreenBody(controller: c, embedded: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(c.kit!.atomsInPlayArea, isEmpty);
    expect(find.byType(KratosResetAllButton), findsOneWidget);

    final oxygen = find.byKey(const ValueKey('bam_bucket_O'));
    expect(oxygen, findsOneWidget);

    await tester.tap(oxygen);
    await tester.pump();
    expect(
      c.kit!.atomsInPlayArea,
      isEmpty,
      reason: 'tap on bucket must not teleport an atom into play',
    );

    await tester.drag(oxygen, const Offset(0, -220));
    await tester.pump();
    expect(c.kit!.atomsInPlayArea, isNotEmpty);
    expect(c.draggingAtom, isNull);
  });
}
