import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/scenario/lesson_manifest.dart';
import 'package:kratos/common/scenario/lesson_sim_host.dart';
import 'package:kratos/common/widgets/lesson_entry_section.dart';
import 'package:kratos/screens/lesson_screen.dart';

/// T-P1-11 · 首页课时入口测试（AC-16/17 · AC-R2）。
void main() {
  LessonManifestEntry entryOf(String id, String sim) => LessonManifestEntry(
        id: id,
        file: '$id.json',
        name: '课时 $id',
        sim: sim,
      );

  setUp(() => LessonEntrySection.entriesOverride = null);
  tearDown(() => LessonEntrySection.entriesOverride = null);

  testWidgets('AC-16 · 有注册课时 sim → 入口卡片渲染', (tester) async {
    LessonEntrySection.entriesOverride = () async => [
          entryOf('circuit-switch-basics', 'circuit'),
          entryOf('cv-additive-linear', 'color_vision'),
        ];
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: LessonEntrySection(sim: 'circuit')),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('课时 circuit-switch-basics'), findsOneWidget);
    // 他 sim 课时不渲染
    expect(find.text('课时 cv-additive-linear'), findsNothing);
  });

  testWidgets('AC-17/AC-R2 · 无课时 sim → 渲染空（首页布局不变）', (tester) async {
    LessonEntrySection.entriesOverride = () async => [
          entryOf('circuit-switch-basics', 'circuit'),
        ];
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: LessonEntrySection(sim: 'forces')),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byType(LessonEntryCard), findsNothing);
    // 整区塌缩为零尺寸（不影响首页布局）
    final box = tester.renderObject<RenderBox>(find.byType(SizedBox).first);
    expect(box.size.height, 0);
  });

  testWidgets('AC-18 · _launch 全链路：点卡片 → 真实 loader 解析 → push LessonScreen'
      '（Major-2 修复补测）', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LessonSimHosts.ensureManagersLoaded(); // 预加载真实 managers（幂等）
    LessonEntrySection.entriesOverride = () async => [
          entryOf('circuit-switch-basics', 'circuit'),
        ];
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: LessonEntrySection(sim: 'circuit')),
    ));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('课时 circuit-switch-basics'));
    // _launch：ensureManagersLoaded（已预载）→ loadAll 真实解析 5 剧本 →
    // push LessonScreen（真实 dispatch host）
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(LessonScreen).evaluate().isNotEmpty) break;
    }
    expect(find.byType(LessonScreen), findsOneWidget);
    // AppBar 显示剧本名（真实解析产物）
    expect(find.textContaining('开关与电路诊断'), findsWidgets);
  });

  testWidgets('manifest 加载异常 → SizedBox.shrink（降级不 crash）', (tester) async {
    LessonEntrySection.entriesOverride = () async =>
        throw Exception('manifest broken');
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: LessonEntrySection(sim: 'circuit')),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byType(LessonEntryCard), findsNothing);
  });
}
