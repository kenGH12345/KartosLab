import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/projectile_motion/controller/projectile_motion_controller.dart';
import 'package:kratos/projectile_motion/model/projectile_motion_model.dart';
import 'package:kratos/projectile_motion/model/screen_models.dart';
import 'package:kratos/projectile_motion/pm_constants.dart';
import 'package:kratos/projectile_motion/view/pm_image_cache.dart';
import 'package:kratos/projectile_motion/widgets/pm_screen_layout.dart';
import 'package:kratos/projectile_motion/widgets/pm_simulation_shell.dart';

/// Flutter screenshot matrix for Visual QA (1024×618 design space).
///
/// NOT part of the unit-test gate — run standalone:
///   flutter test test/projectile_motion/projectile_visual_qa_capture_test.dart
///
/// 与 pendulum_lab capture 相同的环境约束：toImage 之后 FakeAsync 收尾 pump
/// 永不完成 → 每个用例在 PNG 同步落盘后可能报 TimeoutException，属设计内。
/// 成功判据：20 个 PNG + meta 全部落盘，日志含 `CAPTURED <name>`。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final trebuchet = FontLoader('Trebuchet MS')
      ..addFont(File(r'C:\Windows\Fonts\trebuc.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    final arial = FontLoader('Arial')
      ..addFont(File(r'C:\Windows\Fonts\arial.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    await trebuchet.load();
    await arial.load();
  });

  const outDir = 'requirements/req-projectile-motion/visual-qa/FLUTTER';
  const viewport = Size(1280, 800);
  const dpr = 1.0;
  const perTestTimeout = Timeout(Duration(seconds: 15));

  // 与 ORIGINAL（joist 在 1280×800 窗口、底部黑色 navbar 区的实际布局）
  // 逐像素对齐：实测 scale = 1.1918（黄虚线 y=607 ↔ VIEW_ORIGIN.y=510，
  // 内容高 736 ↔ 618），内容区水平居中、顶部对齐，底部黑色留边。
  const contentScale = 1.1918;
  const contentW = PmConstants.layoutWidth * contentScale; // ≈1220.4
  const contentH = PmConstants.layoutHeight * contentScale; // ≈736.5

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  Future<void> captureState(
    WidgetTester tester,
    String name,
    ProjectileMotionModel model,
    PmViewProperties viewProperties,
    PmScreenKind kind,
    FutureOr<void> Function(ProjectileMotionModel m,
            PmViewProperties vp, ProjectileMotionController c)
        arrange,
  ) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = dpr;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final key = GlobalKey();
    final controller = ProjectileMotionController(model, viewProperties);
    addTearDown(controller.dispose);
    final images = PmImageCache.createDefault();
    // rootBundle/instantiateImageCodec 是真实异步，须在 runAsync 真实事件
    // 循环中完成，否则 FakeAsync 区内触发 guarded function conflict。
    await tester.runAsync(() => images.load());

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          fontFamily: 'Arial',
          useMaterial3: false,
          textTheme: ThemeData(fontFamily: 'Arial').textTheme.apply(
                fontFamily: 'Arial',
                bodyColor: Colors.black,
                displayColor: Colors.black,
              ),
        ),
        home: Scaffold(
          body: RepaintBoundary(
            key: key,
            child: Container(
              width: viewport.width,
              height: viewport.height,
              color: Colors.black,
              child: Stack(
                children: [
                  Positioned(
                    left: (viewport.width - contentW) / 2,
                    top: 0,
                    width: contentW,
                    height: contentH,
                    child: PmSimulationShell(
                      child: ListenableBuilder(
                        listenable: controller,
                        builder: (_, _) => PmScreenLayout(
                          controller: controller,
                          images: images,
                          kind: kind,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
    await arrange(model, viewProperties, controller);
    await settle(tester);

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: dpr);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    File('$outDir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List(), flush: true);
    File('$outDir/$name.meta.txt').writeAsStringSync([
      'state: $name',
      'viewport: ${viewport.width.toInt()}x${viewport.height.toInt()}',
      'DPR: $dpr',
      'design: ${PmConstants.layoutWidth}x${PmConstants.layoutHeight}',
      'source: local-flutter-widget-test',
      'captured_at: ${DateTime.now().toIso8601String()}',
    ].join('\n'), flush: true);
    // ignore: avoid_print
    print('CAPTURED $name');
  }

  /// 推进 n 帧（1/60 s 墙钟 → 内部按 0.012s 切片）
  void step(ProjectileMotionModel m, int frames) {
    m.setPlaying(true);
    for (var i = 0; i < frames; i++) {
      m.step(1 / 60);
    }
  }

  PmViewProperties vpIntro() => PmViewProperties(
      hasForceVectors: false,
      hasAccelerationVectors: true,
      usesDisplayEnumeration: false);
  PmViewProperties vpVectors() => PmViewProperties(
      hasForceVectors: true,
      hasAccelerationVectors: true,
      usesDisplayEnumeration: true);
  PmViewProperties vpDrag() => PmViewProperties(
      hasForceVectors: true,
      hasAccelerationVectors: false,
      usesDisplayEnumeration: true);
  PmViewProperties vpLab() => PmViewProperties(
      hasForceVectors: false,
      hasAccelerationVectors: false,
      usesDisplayEnumeration: false);

  // ---------------- Intro ----------------

  testWidgets('01_Intro_initial', (tester) async {
    await captureState(
        tester, '01_Intro_initial', IntroModel(), vpIntro(),
        PmScreenKind.intro, (_, _, _) {});
  }, timeout: perTestTimeout);

  testWidgets('02_Intro_running', (tester) async {
    await captureState(tester, '02_Intro_running', IntroModel(), vpIntro(),
        PmScreenKind.intro, (m, _, c) {
      c.fire();
      step(m, 42);
    });
  }, timeout: perTestTimeout);

  testWidgets('03_Intro_paused', (tester) async {
    await captureState(tester, '03_Intro_paused', IntroModel(), vpIntro(),
        PmScreenKind.intro, (m, _, c) {
      c.fire();
      step(m, 30);
      m.setPlaying(false);
    });
  }, timeout: perTestTimeout);

  testWidgets('04_Intro_modified', (tester) async {
    await captureState(tester, '04_Intro_modified', IntroModel(), vpIntro(),
        PmScreenKind.intro, (m, _, c) {
      m.setCannonAngle(30);
      m.setInitialSpeed(20);
      m.setSelectedObjectType(m.objectTypes[0]);
      c.fire();
      step(m, 30);
    });
  }, timeout: perTestTimeout);

  testWidgets('05_Intro_tools', (tester) async {
    await captureState(tester, '05_Intro_tools', IntroModel(), vpIntro(),
        PmScreenKind.intro, (m, _, c) {
      c.fire();
      step(m, 30);
      m.setPlaying(false);
      m.measuringTape.isActive = true;
      m.measuringTape.basePosition = const Offset(3, 0);
      m.measuringTape.tipPosition = const Offset(8, 4);
      m.dataProbe.isActive = true;
      m.dataProbe.position = const Offset(6, 6);
      m.dataProbe.updateData();
    });
  }, timeout: perTestTimeout);

  testWidgets('06_Intro_reset', (tester) async {
    await captureState(tester, '06_Intro_reset', IntroModel(), vpIntro(),
        PmScreenKind.intro, (m, _, c) {
      c.fire();
      step(m, 10);
      c.reset();
    });
  }, timeout: perTestTimeout);

  // ---------------- Vectors ----------------

  testWidgets('07_Vectors_initial', (tester) async {
    await captureState(tester, '07_Vectors_initial', VectorsModel(),
        vpVectors(), PmScreenKind.vectors, (_, _, _) {});
  }, timeout: perTestTimeout);

  testWidgets('08_Vectors_running', (tester) async {
    await captureState(tester, '08_Vectors_running', VectorsModel(),
        vpVectors(), PmScreenKind.vectors, (m, vp, c) {
      vp.setVelocityVectorsOn(true);
      c.fire();
      step(m, 30);
    });
  }, timeout: perTestTimeout);

  testWidgets('09_Vectors_modified', (tester) async {
    await captureState(tester, '09_Vectors_modified', VectorsModel(),
        vpVectors(), PmScreenKind.vectors, (m, vp, c) {
      m.setProjectileDiameter(0.5);
      m.setProjectileMass(10);
      vp.setVelocityVectorsOn(true);
      c.fire();
      step(m, 30);
    });
  }, timeout: perTestTimeout);

  testWidgets('10_Vectors_reset', (tester) async {
    await captureState(tester, '10_Vectors_reset', VectorsModel(),
        vpVectors(), PmScreenKind.vectors, (m, _, c) {
      c.fire();
      step(m, 10);
      c.reset();
    });
  }, timeout: perTestTimeout);

  // ---------------- Drag ----------------

  testWidgets('11_Drag_initial', (tester) async {
    await captureState(tester, '11_Drag_initial', DragModel(), vpDrag(),
        PmScreenKind.drag, (_, _, _) {});
  }, timeout: perTestTimeout);

  testWidgets('12_Drag_running', (tester) async {
    await captureState(tester, '12_Drag_running', DragModel(), vpDrag(),
        PmScreenKind.drag, (m, _, c) {
      c.fire();
      step(m, 42);
    });
  }, timeout: perTestTimeout);

  testWidgets('13_Drag_modified', (tester) async {
    await captureState(tester, '13_Drag_modified', DragModel(), vpDrag(),
        PmScreenKind.drag, (m, _, c) {
      m.setAltitude(1600); // flatirons 可见窗口 [1500,1700]
      m.setProjectileDragCoefficient(0.8);
      c.fire();
      step(m, 30);
    });
  }, timeout: perTestTimeout);

  testWidgets('14_Drag_reset', (tester) async {
    await captureState(tester, '14_Drag_reset', DragModel(), vpDrag(),
        PmScreenKind.drag, (m, _, c) {
      c.fire();
      step(m, 10);
      c.reset();
    });
  }, timeout: perTestTimeout);

  // ---------------- Lab ----------------

  testWidgets('15_Lab_initial', (tester) async {
    await captureState(tester, '15_Lab_initial', LabModel(), vpLab(),
        PmScreenKind.lab, (_, _, _) {});
  }, timeout: perTestTimeout);

  testWidgets('16_Lab_running', (tester) async {
    await captureState(tester, '16_Lab_running', LabModel(), vpLab(),
        PmScreenKind.lab, (m, _, c) {
      c.fire();
      step(m, 42);
    });
  }, timeout: perTestTimeout);

  testWidgets('17_Lab_modified', (tester) async {
    await captureState(tester, '17_Lab_modified', LabModel(), vpLab(),
        PmScreenKind.lab, (m, _, c) {
      m.setGravity(5);
      final piano = m.objectTypes.firstWhere(
          (t) => (t.name ?? '').toLowerCase().contains('piano'),
          orElse: () => m.objectTypes.first);
      m.setSelectedObjectType(piano);
      c.fire();
      step(m, 30);
    });
  }, timeout: perTestTimeout);

  testWidgets('18_Lab_dragged', (tester) async {
    await captureState(tester, '18_Lab_dragged', LabModel(), vpLab(),
        PmScreenKind.lab, (m, _, _) {
      m.setCannonHeight(5);
      m.setCannonAngle(45);
    });
  }, timeout: perTestTimeout);

  testWidgets('19_Lab_tools', (tester) async {
    await captureState(tester, '19_Lab_tools', LabModel(), vpLab(),
        PmScreenKind.lab, (m, _, c) {
      c.fire();
      step(m, 30);
      m.setPlaying(false);
      m.measuringTape.isActive = true;
      m.measuringTape.basePosition = const Offset(3, 0);
      m.measuringTape.tipPosition = const Offset(8, 4);
      m.dataProbe.isActive = true;
      m.dataProbe.position = const Offset(6, 6);
      m.dataProbe.updateData();
    });
  }, timeout: perTestTimeout);

  testWidgets('20_Lab_reset', (tester) async {
    await captureState(tester, '20_Lab_reset', LabModel(), vpLab(),
        PmScreenKind.lab, (m, _, c) {
      c.fire();
      step(m, 10);
      c.reset();
    });
  }, timeout: perTestTimeout);
}
