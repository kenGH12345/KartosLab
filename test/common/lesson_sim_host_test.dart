import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/circuit/screens/circuit_screen.dart';
import 'package:kratos/color_vision/screens/rgb_bulbs_screen.dart';
import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/common/scenario/lesson_runtime.dart';
import 'package:kratos/common/scenario/lesson_sim_host.dart';

/// T-P1-08 · LessonSimHosts 单测（dispatch 分派 + scenarioPlayable 守卫）。
void main() {
  // rootBundle 依赖 ServicesBinding（纯 test 环境需显式初始化）
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // 真实加载两 sim manifest（dispatch cv host 与 scenarioPlayable 共用）
    await LessonSimHosts.ensureManagersLoaded();
  });

  LessonNode nodeOf(String sim, String scenarioId) => LessonNode(
        id: 'n',
        title: 'n',
        scenario: LessonScenarioRef(sim: sim, scenarioId: scenarioId),
        advance: const LessonAdvance(type: 'onCompleted', to: 'n-end'),
      );

  const hooks = LessonHooks();

  group('LessonSimHosts.dispatch（D9 跨 sim 分派）', () {
    test('circuit 节点 → CircuitScreen（showScenarioMenu:false + 钩子透传）', () {
      var successCalls = 0;
      final builder = LessonSimHosts.dispatch();
      final w = builder(
        _FakeContext(),
        nodeOf('circuit', 'controlled-switch'),
        LessonHooks(onScenarioSuccess: () => successCalls++),
      );
      expect(w, isA<CircuitScreen>());
      final cs = w as CircuitScreen;
      expect(cs.initialScenarioId, 'controlled-switch');
      expect(cs.showScenarioMenu, isFalse); // D11 · Major-3 禁用节点内逃逸
      expect(cs.onScenarioSuccess, isNotNull);
      cs.onScenarioSuccess!();
      expect(successCalls, 1);
    });

    test('color_vision 节点 → MagicLabScreen（scenarioList 空列表菜单自隐）', () {
      final builder = LessonSimHosts.dispatch();
      final w = builder(
        _FakeContext(),
        nodeOf('color_vision', 'rgb-challenge-basic'),
        hooks,
      );
      expect(w, isA<MagicLabScreen>());
      final ms = w as MagicLabScreen;
      expect(ms.scenarioList, isEmpty); // D11 · 零新参数菜单自隐
      expect(ms.scenario?.scenarioId, 'rgb-challenge-basic');
      expect(ms.manager, isNotNull);
    });

    test('未注册 sim 节点 → SizedBox.shrink 防御（AC-3 前置已拦截，此双重保险）', () {
      final builder = LessonSimHosts.dispatch();
      final w = builder(_FakeContext(), nodeOf('forces', 'x'), hooks);
      expect(w, isA<SizedBox>());
    });
  });

  group('LessonSimHosts.scenarioPlayable（D10 存在+可完成守卫）', () {
    final playable = LessonSimHosts.scenarioPlayable();

    test('可完成场景 → true（含资产修复后场景 · Blocker-2）', () {
      expect(playable('circuit', 'controlled-switch'), isTrue);
      expect(playable('color_vision', 'rgb-challenge-basic'), isTrue);
      // 2026-08-25 资产修复：criteria 改单一目标后应可完成
      expect(playable('color_vision', 'rgb-yellow-only'), isTrue);
      expect(playable('color_vision', 'rgb-cyan-challenge'), isTrue);
      expect(playable('color_vision', 'rgb-make-white'), isTrue);
    });

    test('不存在场景 → false（AC-3 解析期拦截）', () {
      expect(playable('circuit', 'not-exist'), isFalse);
      expect(playable('color_vision', 'not-exist'), isFalse);
    });

    test('不可完成场景 → false（D10）', () {
      // rgb-dark-room：评审实证的不可完成场景（无 objectives 或叶子未实现）
      expect(playable('color_vision', 'rgb-dark-room'), isFalse);
      // rgb-inquiry-additive：评审点名的永不完成场景
      expect(playable('color_vision', 'rgb-inquiry-additive'), isFalse);
    });

    test('singleBulb 屏场景 → false（试点仅 rgb 屏 · §0.1）', () {
      expect(playable('color_vision', 'single-white-red-filter'), isFalse);
      expect(playable('color_vision', 'single-inquiry-subtractive'), isFalse);
    });

    test('未注册 sim → false（D8 封闭集）', () {
      expect(playable('forces', 'x'), isFalse);
      expect(playable('sound', 'x'), isFalse);
    });
  });
}

/// dispatch builder 的 BuildContext 实参——builder 内部未使用 context，
/// 用最小 fake 满足签名（无 pump 纯函数断言）。
class _FakeContext extends Fake implements BuildContext {}
