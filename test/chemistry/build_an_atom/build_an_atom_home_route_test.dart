import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/build_an_atom_home.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/symbol_screen.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> openBaa(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    final card = find.text(BuildAnAtomHome.title);
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('Home → 构建原子 opens Atom tab by default', (tester) async {
    await setDesktop(tester);
    await openBaa(tester);
    expect(find.byType(BuildAnAtomHome), findsOneWidget);
    expect(find.text(BuildAnAtomHome.atomTabLabel), findsOneWidget);
    expect(find.byType(BuildAnAtomAtomScreen), findsOneWidget);
  });

  testWidgets('tabs reach Symbol and Game', (tester) async {
    await setDesktop(tester);
    await openBaa(tester);

    await tester.tap(find.text(BuildAnAtomHome.symbolTabLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BuildAnAtomSymbolScreen), findsOneWidget);

    await tester.tap(find.text(BuildAnAtomHome.gameTabLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BuildAnAtomGameScreen), findsOneWidget);
  });
}
