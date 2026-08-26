import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/scenario/lesson_manifest.dart';
import 'package:kratos/common/scenario/lesson_sim_host.dart';

/// T-P1-12 验证 · 真实 assets 试点剧本端到端解析（loader + 真实
/// scenarioPlayable 守卫 + 真实 rootBundle）。
///
/// 同时是 T-P3-06 守卫测试雏形：剧本 → 场景引用存在性/可完成性全链路断言。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await LessonSimHosts.ensureManagersLoaded();
  });

  test('assets/lessons 全部试点剧本解析通过（fail loud 降级零发生）', () async {
    final loader = LessonManifestLoader();
    final entries = await loader.loadEntries();
    expect(entries, hasLength(5), reason: 'manifest 应有 5 条试点剧本 entry');

    final plans = await loader.loadAll(
        scenarioPlayable: LessonSimHosts.scenarioPlayable());
    expect(plans, hasLength(5), reason: '5 条试点剧本应全部解析通过（零降级）');

    final byId = {for (final p in plans) p.lessonId: p};

    // circuit 线性剧本：3 场景节点 + 终点 · AC-24/25
    final circuit = byId['circuit-switch-basics']!;
    expect(circuit.requiredNodes, hasLength(3));
    expect(circuit.entry, 'n1');
    expect(circuit.find('n1')!.scenario!.scenarioId, 'controlled-switch');
    expect(circuit.find('n2')!.scenario!.scenarioId, 'open-circuit-debug');
    expect(circuit.find('n3')!.scenario!.scenarioId, 'fuse-blown');
    expect(circuit.find('n-end')!.isEnd, isTrue);

    // color_vision 线性剧本：3 场景节点 + 终点
    final cv = byId['cv-additive-linear']!;
    expect(cv.requiredNodes, hasLength(3));
    expect(cv.find('n1')!.scenario!.scenarioId, 'rgb-yellow-only');
    expect(cv.find('n2')!.scenario!.scenarioId, 'rgb-cyan-challenge');
    expect(cv.find('n3')!.scenario!.scenarioId, 'rgb-challenge-basic');

    // P2 条件剧本（T-P2-07 · AC-43/44/45）
    final ohm = byId['circuit-ohm-diagnosis']!;
    expect(ohm.find('n1')!.advance!.type, 'routes');
    expect(ohm.find('n1')!.advance!.routes, hasLength(2));
    expect(ohm.find('n2-hunt')!.unlock, isNotNull);
    expect(ohm.find('n3')!.unlock, isNotNull); // any 组合
    expect(ohm.totalRequiredNodes, 4);

    final cvPath = byId['cv-challenge-path']!;
    expect(cvPath.find('n2')!.unlock, isNotNull); // all 组合
    expect(cvPath.find('n3')!.unlock, isNotNull); // any 组合
    expect(cvPath.totalRequiredNodes, 3);

    // 跨 sim 混合剧本（AC-58 · T-P1-15）：circuit→cv→circuit 双向穿越
    final cross = byId['cross-sim-explore']!;
    expect(cross.requiredNodes, hasLength(3));
    expect(cross.find('n1')!.scenario!.sim, 'circuit');
    expect(cross.find('n2')!.scenario!.sim, 'color_vision');
    expect(cross.find('n3')!.scenario!.sim, 'circuit');
    // 混合剧本 manifest sim = entry 节点 sim（D9 入口归属 · circuit 组挂载）
    final crossEntry = entries.firstWhere((e) => e.id == 'cross-sim-explore');
    expect(crossEntry.sim, 'circuit');

    // manifest sim 字段与剧本 entry 节点 sim 一致（D9 入口归属语义）
    for (final e in entries) {
      final plan = byId[e.id]!;
      expect(plan.entryNode.scenario!.sim, e.sim,
          reason: '${e.id} 的 entry 节点 sim 应与 manifest.sim 一致');
    }
  });
}
