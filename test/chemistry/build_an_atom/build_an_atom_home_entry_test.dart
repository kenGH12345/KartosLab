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

  testWidgets('formal Home card: 构建原子 in 原子结构, no QA cards', (tester) async {
    await setDesktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('原子结构'), findsOneWidget);
    expect(find.text(BuildAnAtomHome.title), findsOneWidget);
    expect(find.text('构建原子 (QA)'), findsNothing);
    expect(find.text('构建原子 Symbol (QA)'), findsNothing);
    expect(find.text('构建原子 Game (QA)'), findsNothing);
    expect(find.text('同位素与原子质量'), findsOneWidget);
  });
}
