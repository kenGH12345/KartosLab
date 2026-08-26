import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 剧本层「零场景加载」源码守卫（req-lesson-runtime · AC-12 / C-R3）。
///
/// ## 背景
///
/// 方案 D3 / C-R3 承诺：场景加载**只**发生在各 sim screen 内部
/// （circuit_screen.dart manager.loadScenario / rgb_bulbs_screen.dart
/// findById+setCurrentScenario），剧本层（lesson_* / LessonScreen /
/// LessonEntrySection）**不得出现**平行加载路径——否则会出现「剧本绕过
/// ScenarioManager 加载体系」的架构回归。
///
/// 代码评审 Major-1（2026-08-25）：方案 §10 承诺的自动化守卫此前缺失，
/// 仅有人工 grep（process.txt:20）。
///
/// ## 守卫规则
///
/// 1. 剧本层文件不得包含 `loadScenario(`（单场景加载调用）。
///    `loadScenarios(`（sim manager 批量 manifest 加载 · scenarioPlayable
///    守卫数据源）是合法例外——正则 `loadScenario\(` 不会误伤
///    （`loadScenarios(` 的 `loadScenario` 后是 `s(` 而非 `(`）。
/// 2. 新增剧本层文件须登记进 [lessonLayerFiles]（防新文件逃逸守卫）。
void main() {
  const lessonLayerFiles = <String>[
    'lib/common/scenario/lesson_plan.dart',
    'lib/common/scenario/lesson_manifest.dart',
    'lib/common/scenario/lesson_runtime.dart',
    'lib/common/scenario/lesson_sim_host.dart',
    'lib/screens/lesson_screen.dart',
    'lib/common/widgets/lesson_entry_section.dart',
  ];

  test('剧本层零平行加载路径（AC-12 · C-R3）', () {
    final root = Directory.current.path;
    for (final rel in lessonLayerFiles) {
      final file = File('$root/$rel');
      expect(file.existsSync(), isTrue, reason: '$rel 应存在（防新文件逃逸守卫）');
      final source = file.readAsStringSync();
      expect(
        source.contains('loadScenario('),
        isFalse,
        reason: '$rel 不得出现 loadScenario(——场景加载只在 sim screen 内部'
            '（D3 复用既有路径 · C-R3 零改动）；loadScenarios( 批量加载为合法例外',
      );
    }
  });
}
