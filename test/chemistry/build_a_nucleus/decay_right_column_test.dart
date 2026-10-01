import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/widgets/decay_right_column.dart';

/// P2-1：右栏结构 — counters | symbol 同行，Available Decays 在下。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  testWidgets('counters 与 symbol 同行，decays 在 symbol 下方', (tester) async {
    final c = BuildANucleusController(repository: repo);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 104,
            height: 400,
            child: DecayRightColumn(
              state: c.state,
              decays: const Text('Available Decays'),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('ban_decay_right_column')), findsOneWidget);
    expect(tester.takeException(), isNull);

    final counters = tester.getRect(find.byKey(const ValueKey('ban_proton_count')));
    final symbol = tester.getRect(find.byKey(const ValueKey('ban_symbol')));
    final decays = tester.getRect(find.text('Available Decays'));

    expect(counters.center.dx, lessThan(symbol.center.dx));
    expect((counters.center.dy - symbol.center.dy).abs(), lessThan(40));
    expect(decays.top, greaterThan(symbol.bottom));
    c.dispose();
  });
}
