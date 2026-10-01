import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/screens/build_an_atom_home.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Home → Build an Atom → Back returns to Home', (tester) async {
    await setDesktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(BuildAnAtomHome.title));
    await tester.tap(find.text(BuildAnAtomHome.title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BuildAnAtomHome), findsOneWidget);

    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(BuildAnAtomHome), findsNothing);
    expect(find.text(BuildAnAtomHome.title), findsOneWidget);
    expect(find.text('原子结构'), findsOneWidget);
  });
}
