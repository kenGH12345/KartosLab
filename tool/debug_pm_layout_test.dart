import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/projectile_motion/controller/projectile_motion_controller.dart';
import 'package:kratos/projectile_motion/model/screen_models.dart';
import 'package:kratos/projectile_motion/view/pm_image_cache.dart';
import 'package:kratos/projectile_motion/widgets/pm_screen_layout.dart';
import 'package:kratos/projectile_motion/widgets/pm_simulation_shell.dart';

void main() {
  testWidgets('debug layout sizes', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final c = ProjectileMotionController(
      IntroModel(),
      PmViewProperties(
          hasForceVectors: false,
          hasAccelerationVectors: true,
          usesDisplayEnumeration: false),
    );
    addTearDown(c.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PmSimulationShell(
          child: PmScreenLayout(
            controller: c,
            images: PmImageCache(const []),
            kind: PmScreenKind.intro,
          ),
        ),
      ),
    ));
    await tester.pump();

    // 打印所有 Positioned 的位置与尺寸
    final renderObj =
        tester.renderObject(find.byType(PmScreenLayout)) as RenderBox;
    debugPrint('PmScreenLayout size: ${renderObj.size}');
    tester.elementList(find.byType(Positioned)).forEach((e) {
      final p = e.widget as Positioned;
      final r = e.renderObject as RenderBox;
      debugPrint(
          'Positioned(l=${p.left},t=${p.top},r=${p.right},b=${p.bottom}) '
          'size=${r.size} offset=${r.localToGlobal(Offset.zero)}');
    });

    // 所有 Row：位置 + 子类型
    tester
        .elementList(find.descendant(
            of: find.byType(PmScreenLayout), matching: find.byType(Row)))
        .forEach((e) {
      final r = e.renderObject as RenderBox;
      final row = e.widget as Row;
      debugPrint('Row @ ${r.localToGlobal(Offset.zero)} size=${r.size} '
          'children=${row.children.map((c) => c.runtimeType.toString()).join("|")}');
    });
  });
}
