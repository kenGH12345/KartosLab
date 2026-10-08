import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_measuring_tape.dart';

void main() {
  testWidgets('KratosMeasuringTape shows housing asset and label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: KratosMeasuringTape(
              base: Offset(120, 150),
              tip: Offset(280, 150),
              label: '100 km',
              onBaseDelta: _noop,
              onTipDelta: _noop,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('100 km'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('hidden when visible=false', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KratosMeasuringTape(
            base: Offset(10, 10),
            tip: Offset(80, 10),
            label: 'x',
            visible: false,
            onBaseDelta: _noop,
            onTipDelta: _noop,
          ),
        ),
      ),
    );
    expect(find.text('x'), findsNothing);
  });
}

void _noop(Offset _) {}
