import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/states_of_matter/screens/states_of_matter_home.dart';
import 'package:kratos/chemistry/states_of_matter/som_strings.dart';

void main() {
  testWidgets('StatesOfMatterHome shows Neon / Solid / Gas', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: StatesOfMatterHome(),
      ),
    );

    // Allow first frame + clock attach; avoid pumpAndSettle (ticker never ends).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(SomStrings.neon), findsWidgets);
    expect(find.text(SomStrings.solid), findsOneWidget);
    expect(find.text(SomStrings.gas), findsOneWidget);
    expect(find.text(SomStrings.states), findsWidgets);
  });
}
