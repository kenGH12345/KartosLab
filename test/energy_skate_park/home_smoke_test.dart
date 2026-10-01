import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/screens/energy_skate_park_home.dart';

void main() {
  testWidgets('EnergySkateParkHome shows four tabs with screen PNG icons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: EnergySkateParkHome()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(EspStrings.intro), findsWidgets);
    expect(find.text(EspStrings.measure), findsOneWidget);
    expect(find.text(EspStrings.graphs), findsOneWidget);
    expect(find.text(EspStrings.playground), findsOneWidget);
    expect(find.text(EspStrings.title), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });
}
