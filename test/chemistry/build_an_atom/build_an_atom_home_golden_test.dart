import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/screens/build_an_atom_home.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 8 — Home card goldens (chemistry / 原子结构 with Build an Atom).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('chemistry_category_with_baa', (tester) async {
    await setDesktop(tester);
    await pumpHome(tester);
    await tester.ensureVisible(find.text('化学').first);
    await tester.pump();
    await tester.ensureVisible(find.text(BuildAnAtomHome.title).first);
    await tester.pump();
    expect(find.text(BuildAnAtomHome.title), findsOneWidget);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('golden/home/chemistry_category_with_baa.png'),
    );
  });

  testWidgets('atomic_structure_with_baa', (tester) async {
    await setDesktop(tester);
    await pumpHome(tester);
    await tester.ensureVisible(find.text('原子结构').first);
    await tester.pump();
    await tester.ensureVisible(find.text(BuildAnAtomHome.title).first);
    await tester.pump();
    expect(find.text(BuildAnAtomHome.title), findsOneWidget);
    expect(find.text('同位素与原子质量'), findsOneWidget);
    expect(find.text('构建原子 (QA)'), findsNothing);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('golden/home/atomic_structure_with_baa.png'),
    );
  });
}
