import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/projectile_motion/controller/projectile_motion_controller.dart';
import 'package:kratos/projectile_motion/model/screen_models.dart';
import 'package:kratos/projectile_motion/pm_constants.dart';
import 'package:kratos/projectile_motion/view/pm_image_cache.dart';
import 'package:kratos/projectile_motion/widgets/pm_screen_layout.dart';
import 'package:kratos/projectile_motion/widgets/pm_scene.dart';
import 'package:kratos/projectile_motion/widgets/pm_simulation_shell.dart';

/// M4 Interaction 测试：拖拽语义逐行对照 CannonNode.ts:451-541 /
/// TargetNode.ts:112-133 / ToolboxPanel.ts:86-127。
///
/// 场景坐标系：1024×618（layout bounds），VIEW_ORIGIN = (80, 510)，
/// zoom=1 时 1m = 10 view px，y 轴翻转。
ProjectileMotionController _makeController() {
  return ProjectileMotionController(
    IntroModel(),
    PmViewProperties(
      hasForceVectors: false,
      hasAccelerationVectors: true,
      usesDisplayEnumeration: false,
    ),
  );
}

Widget _wrap(ProjectileMotionController controller,
    {PmScreenKind kind = PmScreenKind.intro}) {
  return MaterialApp(
    home: Scaffold(
      body: PmSimulationShell(
        child: PmScreenLayout(
          controller: controller,
          images: PmImageCache(const []),
          kind: kind,
        ),
      ),
    ),
  );
}

/// 把 1024×618 场景坐标换算为 tester 屏幕坐标（FittedBox contain 居中）。
Offset sceneToScreen(WidgetTester tester, Offset scenePos) {
  final shellSize = tester.getSize(find.byType(PmSimulationShell));
  final shellTopLeft = tester.getTopLeft(find.byType(PmSimulationShell));
  final scale = math.min(shellSize.width / PmConstants.layoutWidth,
      shellSize.height / PmConstants.layoutHeight);
  final fittedW = PmConstants.layoutWidth * scale;
  final fittedH = PmConstants.layoutHeight * scale;
  final offset = Offset(
    shellTopLeft.dx + (shellSize.width - fittedW) / 2,
    shellTopLeft.dy + (shellSize.height - fittedH) / 2,
  );
  return offset + scenePos * scale;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // VIEW_ORIGIN（zoom=1）：(70, 510)，1 m = 30 view px
  final origin = PmConstants.viewOrigin;
  final double m2v = PmConstants.defaultScale;

  group('AC-DRAG 拖拽语义', () {
    testWidgets('DRAG-1 炮管拖拽改变角度并吸附 5°（CannonNode:462-491）',
        (tester) async {
      final c = _makeController();
      addTearDown(c.dispose);
      await tester.pumpWidget(_wrap(c));
      await tester.pump();

      // IntroModel 默认 θ=0°，h=10
      expect(c.model.cannonAngle, 0.0);
      final pivot = Offset(origin.dx, origin.dy - m2v * c.model.cannonHeight);
      Offset barrelPoint(double deg, double distPx) {
        final r = deg * math.pi / 180;
        return pivot + Offset(distPx * math.cos(r), -distPx * math.sin(r));
      }

      final s = sceneToScreen(tester, barrelPoint(0, 60));
      final e = sceneToScreen(tester, barrelPoint(20, 60));
      await tester.dragFrom(s, e - s);
      await tester.pump();
      expect(c.model.cannonAngle, 20.0);
    });

    testWidgets('DRAG-2 炮座拖拽改变高度（连续跟手，松手 0.1 m 吸附）',
        (tester) async {
      final c = _makeController();
      addTearDown(c.dispose);
      await tester.pumpWidget(_wrap(c));
      await tester.pump();

      // h=10 → pivot；base 区域取 pivot 下方 50px
      final pivot = Offset(origin.dx, origin.dy - m2v * 10);
      final start = pivot + const Offset(0, 50);
      final s = sceneToScreen(tester, start);
      // 向上拖 60 view px → +2 m → h=12
      final e = sceneToScreen(tester, start - const Offset(0, 60));
      await tester.dragFrom(s, e - s);
      await tester.pump();
      expect(c.model.cannonHeight, 12.0);
    });

    testWidgets('DRAG-2c 小幅拖高连续跟手，不再整米跳动', (tester) async {
      final c = _makeController();
      addTearDown(c.dispose);
      await tester.pumpWidget(_wrap(c));
      await tester.pump();

      final pivot = Offset(origin.dx, origin.dy - m2v * 10);
      final start = pivot + const Offset(0, 50);
      final s = sceneToScreen(tester, start);
      // 12 view px → +0.4 m；旧逻辑 round 后仍为 10
      final e = sceneToScreen(tester, start - const Offset(0, 12));
      await tester.dragFrom(s, e - s);
      await tester.pump();
      expect(c.model.cannonHeight, closeTo(10.4, 1e-6));
    });

    testWidgets('DRAG-2b 枢轴黑色十字上下拖改高度（全屏通用）', (tester) async {
      final c = _makeController();
      addTearDown(c.dispose);
      await tester.pumpWidget(_wrap(c));
      await tester.pump();

      // 按在黑色十字（pivot）上向上拖，应改高度而非角度
      final pivot = Offset(origin.dx, origin.dy - m2v * 10);
      final s = sceneToScreen(tester, pivot);
      final e = sceneToScreen(tester, pivot - const Offset(0, 60));
      await tester.dragFrom(s, e - s);
      await tester.pump();
      expect(c.model.cannonHeight, 12.0);
      expect(c.model.cannonAngle, 0.0);
    });

    testWidgets('TOOL-0 探针拖出后再拖回 toolbox 则收回', (tester) async {
      final c = _makeController();
      addTearDown(c.dispose);
      await tester.pumpWidget(_wrap(c));
      await tester.pump();

      final scene = tester.state<PmSceneState>(find.byType(PmScene));
      scene.startToolDrag(PmDragTarget.probe, const Offset(400, 100));
      expect(c.model.dataProbe.isActive, isTrue);
      // 先拖离 toolbox（滞回），再交叠收回
      scene.dragToolTo(const Offset(120, 400));
      await tester.pump();
      expect(c.model.dataProbe.isActive, isTrue);

      final probeView = Offset(
        origin.dx + m2v * c.model.dataProbe.position.dx,
        origin.dy - m2v * c.model.dataProbe.position.dy,
      );
      scene.endToolDrag(
          Rect.fromCenter(center: probeView, width: 300, height: 200));
      await tester.pump();
      expect(c.model.dataProbe.isActive, isFalse);
    });

    testWidgets('TOOL-0b 刚拖出仍叠在 toolbox 上松手不收回', (tester) async {
      final c = _makeController();
      addTearDown(c.dispose);
      await tester.pumpWidget(_wrap(c));
      await tester.pump();

      final scene = tester.state<PmSceneState>(find.byType(PmScene));
      scene.startToolDrag(PmDragTarget.probe, const Offset(400, 100));
      final originView = Offset(
        origin.dx + m2v * c.model.dataProbe.position.dx,
        origin.dy - m2v * c.model.dataProbe.position.dy,
      );
      scene.endToolDrag(
          Rect.fromCenter(center: originView, width: 400, height: 200));
      await tester.pump();
      expect(c.model.dataProbe.isActive, isTrue);
    });

    testWidgets('DRAG-3 靶子水平拖拽吸附 0.1 m（TargetNode:112-133）',
        (tester) async {
      final c = _makeController();
      addTearDown(c.dispose);
      await tester.pumpWidget(_wrap(c));
      await tester.pump();

      final x0 = c.model.target.x; // 15
      final center = Offset(origin.dx + m2v * x0, origin.dy);
      final s = sceneToScreen(tester, center);
      // 向右拖 23 view px → +0.7667 m → snap 0.1 → 15.8
      final e = sceneToScreen(tester, center + const Offset(23, 0));
      await tester.dragFrom(s, e - s);
      await tester.pump();
      expect(c.model.target.x, closeTo(15.8, 1e-9));
    });
  });

  group('AC-TOOL 测量工具', () {
    testWidgets('TOOL-1 卷尺 tip 独立拖拽，base 不变', (tester) async {
      final c = _makeController();
      addTearDown(c.dispose);
      c.model.measuringTape.isActive = true;
      c.model.measuringTape.basePosition = const Offset(5, 0);
      c.model.measuringTape.tipPosition = const Offset(8, 0);
      await tester.pumpWidget(_wrap(c));
      await tester.pump();

      // tip view = (70+8*30, 510) = (310, 510)
      final tipView = Offset(origin.dx + m2v * 8, origin.dy);
      final s = sceneToScreen(tester, tipView);
      final e = sceneToScreen(tester, tipView - const Offset(0, 50));
      await tester.dragFrom(s, e - s);
      await tester.pump();
      // tip 上移 50 view px → y +50/30 m；base 不动
      expect(c.model.measuringTape.tipPosition.dy, closeTo(50 / 30, 1e-9));
      expect(c.model.measuringTape.basePosition, const Offset(5, 0));
    });
  });

  group('AC-BTN 按钮语义', () {
    testWidgets('BTN-1 fire 触发发射，轨迹挂载当前参数', (tester) async {
      final c = _makeController();
      addTearDown(c.dispose);
      await tester.pumpWidget(_wrap(c));
      await tester.pump();
      expect(c.model.trajectories, isEmpty);
      c.fire();
      expect(c.model.trajectories.length, 1);
      expect(c.model.trajectories.single.mass, c.model.projectileMass);
    });

    testWidgets('BTN-2 resetAll 恢复默认并清空轨迹', (tester) async {
      final c = _makeController();
      addTearDown(c.dispose);
      c.fire();
      c.model.setCannonAngle(30);
      c.reset();
      expect(c.model.trajectories, isEmpty);
      expect(c.model.cannonAngle, 0.0); // IntroModel 默认
      expect(c.model.isPlaying, isTrue);
    });
  });
}
