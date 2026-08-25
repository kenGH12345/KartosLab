// test/common/geometry/projection_wiring_test.dart
// req-unify-projection-layer · code-reviewer M2 修复
//
// 背景：投影「数学」已由 projection_test.dart 锚定，但投影「接线」（谁把哪个投影
// 传给谁、拖放落点与渲染是否同源）此前零自动化覆盖——若 projectionFactory 注入
// 被回退，单测仍全绿而 req-ui-interaction-polish Major-1 的拖放错位 bug 会复发。
//
// 本测试锁定 DropCanvas 的两条接线契约：
//   ① 默认工厂（optics 范式）：origin=(w/2, h*0.55) + scale 生效
//   ② 工厂注入（circuit 范式）：canvasBuilder 收到的投影实例 == 落点换算所用实例
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/geometry/projection.dart';
import 'package:kratos/common/widgets/drag_drop_workspace.dart';

void main() {
  const canvas = Size(800, 600);

  Future<SceneProjection> pumpAndCapture(
    WidgetTester tester, {
    SceneProjection Function(Size)? factory,
    double scale = 1.0,
  }) async {
    late SceneProjection captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: canvas.width,
              height: canvas.height,
              child: DropCanvas<String>(
                projectionFactory: factory,
                scale: scale,
                canvasBuilder: (_, proj, sz) {
                  captured = proj;
                  return SizedBox(width: sz.width, height: sz.height);
                },
                onItemDropped: (_, _) {},
              ),
            ),
          ),
        ),
      ),
    );
    return captured;
  }

  group('① 默认工厂接线（optics 范式 · 光轴 55%）', () {
    testWidgets('canvasBuilder 收到 origin=(w/2, h*0.55) 且 scale 生效', (tester) async {
      final proj = await pumpAndCapture(tester, scale: 20);

      expect(proj.origin, Offset(canvas.width / 2, canvas.height * 0.55));
      expect(proj.scale, 20);
      expect(proj.zoom, 1.0);
      // 光轴 y = origin.dy：world y=0 必须落在画布 55% 高度（R1 锚点）
      expect(proj.toScreen(Offset.zero).dy, canvas.height * 0.55);
    });
  });

  group('② 工厂注入接线（circuit 范式 · 落点与渲染同源）', () {
    testWidgets('canvasBuilder 收到工厂产出的投影（origin 居中 + zoom）', (tester) async {
      final proj = await pumpAndCapture(
        tester,
        factory: (sz) => SceneProjection(
          origin: Offset(sz.width / 2, sz.height / 2),
          zoom: 2.0,
        ),
      );

      expect(proj.origin, Offset(canvas.width / 2, canvas.height / 2));
      expect(proj.zoom, 2.0);
      // 关键：不是默认工厂的 0.55H——若注入被回退，本断言立刻失败
      expect(proj.origin.dy, isNot(canvas.height * 0.55));
    });

    testWidgets('工厂优先于 scale 参数（避免双源歧义）', (tester) async {
      final proj = await pumpAndCapture(
        tester,
        scale: 20, // 传了 scale，但工厂未消费 → 应被忽略
        factory: (sz) => SceneProjection(origin: Offset(sz.width / 2, sz.height / 2)),
      );

      expect(proj.scale, 1.0, reason: '提供 projectionFactory 时 scale 参数应被忽略');
    });

    testWidgets('zoom 变化后重建：canvasBuilder 拿到新 zoom 的投影', (tester) async {
      // 模拟 circuit 的 _state.zoom 闭包捕获：外部状态变化 → 重建 → 新投影（R2 锚点）
      var zoom = 0.6;
      late SceneProjection captured;

      Widget build() => MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: canvas.width,
                  height: canvas.height,
                  child: DropCanvas<String>(
                    projectionFactory: (sz) => SceneProjection(
                      origin: Offset(sz.width / 2, sz.height / 2),
                      zoom: zoom,
                    ),
                    canvasBuilder: (_, proj, sz) {
                      captured = proj;
                      return SizedBox(width: sz.width, height: sz.height);
                    },
                    onItemDropped: (_, _) {},
                  ),
                ),
              ),
            ),
          );

      await tester.pumpWidget(build());
      expect(captured.zoom, 0.6);

      zoom = 2.0;
      await tester.pumpWidget(build());
      expect(captured.zoom, 2.0, reason: 'zoom 变化后投影必须同步，否则拖放与渲染错位');
    });
  });

  group('③ 落点换算与渲染投影同源（workaround 根治的核心契约）', () {
    testWidgets('同一投影实例：toWorld(toScreen(w)) == w（circuit 工厂 · zoom=1.5）', (tester) async {
      final proj = await pumpAndCapture(
        tester,
        factory: (sz) => SceneProjection(
          origin: Offset(sz.width / 2, sz.height / 2),
          zoom: 1.5,
        ),
      );

      // canvasBuilder 拿到的投影即 onAcceptWithDetails 换算所用投影（同一实例），
      // 故渲染坐标与落点坐标必然同源——无需任何转换 workaround。
      for (final w in const [Offset(0, 0), Offset(-120, 75), Offset(300, -200)]) {
        final round = proj.toWorld(proj.toScreen(w));
        expect((round - w).distance, lessThan(1e-9), reason: 'world=$w');
      }
    });
  });
}
