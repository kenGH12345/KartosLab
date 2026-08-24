import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 运行时接线守卫（req-criteria-composable · 层 1 防御）。
///
/// ## 背景（为什么需要本守卫）
///
/// B 类 4 sim（sound / radio_waves / wave_interference / forces）曾长期处于
/// 「AI 可生成 + schema 可校验 + fromJson 可解析 + **判定永不生效**」的静默断链
/// 状态——生成侧每一环各自合规，合起来是一句谎言；molarity / optics 则是
/// 判定器实现了但 view 层无消费点。根因：没有任何守卫覆盖
/// 「schema 定义 → 运行时生效」这最后一公里。
///
/// ## 守卫规则
///
/// 1. **分类完备**：schemas/ 目录发现的每个 sim 必须登记在
///    [_wiredSims]（白名单）或 [_exemptions]（豁免表）之一。
///    **新 sim 不给默认豁免**——接入时必须四环齐或显式登记豁免理由。
/// 2. **白名单四环齐**：schema 的 criterionLeaf.type.enum ⊆ 求值器 case
///    分支 + view 层有 `.checkObjectives(` 消费点。
/// 3. **豁免显性化**：存量债务带状态描述（接线后删除条目并收进白名单，
///    守卫自动收紧）。
/// 4. **schema 结构锁定**：criterion oneOf 分发 + criterionLeaf.type.enum
///    不可回退为平铺单定义。
///
/// 四环齐 = schema + prompt + JSON + 判定生效（见
/// `docs/knowledge/kratos-java-simulations/shared-abstraction-plan.md` 候选 9）。

/// 已完全接线（四环齐）的 sim 白名单。
const Set<String> _wiredSims = {'circuit'};

/// 存量债务豁免（显式登记 · 接线后删除条目并收进 [_wiredSims]）。
const Map<String, String> _exemptions = {
  'molarity': '半接线：evaluateLeaf 4/4 已实现 · view 层无 .checkObjectives( 消费点',
  'optics': '半接线：evaluateLeaf 3/3 已实现 · view 层无 .checkObjectives( 消费点',
  'color_vision': '部分实现：evaluateLeaf 1/3（colorMatch）· view 消费 ✓',
  'sound': '未接线：无求值器（解析即终点 · B 类）',
  'radio_waves': '未接线：无求值器（解析即终点 · B 类）',
  'wave_interference': '未接线：无求值器（解析即终点 · B 类）',
  'forces': '未接线：无求值器（解析即终点 · B 类）',
};

/// sim → 求值器源文件（含 evaluateLeaf · 相对 package 根）。
/// 未接线的 sim 不登记（文件不存在）。
const Map<String, String> _evaluatorPaths = {
  'circuit': 'lib/circuit/config/circuit_learning_objective.dart',
  'molarity': 'lib/chemistry/molarity/config/molarity_criterion.dart',
  'optics': 'lib/optics/config/learning_objective.dart',
  'color_vision': 'lib/color_vision/config/color_vision_scenario.dart',
};

/// sim → lib 模块目录（view 消费点检查范围）。
const Map<String, String> _simLibDirs = {
  'molarity': 'lib/chemistry/molarity',
  'color_vision': 'lib/color_vision',
  'circuit': 'lib/circuit',
  'optics': 'lib/optics',
  'sound': 'lib/sound',
  'radio_waves': 'lib/radio_waves',
  'wave_interference': 'lib/wave_interference',
  'forces': 'lib/forces',
};

/// 从 schemas/ 目录发现全部 sim（文件名 <sim>_scenario.schema.json → sim 名）。
/// 这是权威发现源：新 sim 交付 schema 时自动进入守卫范围。
Set<String> _discoverSims() {
  final dir = Directory('schemas');
  expect(dir.existsSync(), isTrue, reason: 'schemas/ 目录必须存在');
  return dir
      .listSync()
      .whereType<File>()
      .map((f) => f.path.replaceAll('\\', '/').split('/').last)
      .where((name) => name.endsWith('_scenario.schema.json'))
      .map((name) => name.replaceAll('_scenario.schema.json', ''))
      .toSet();
}

/// 提取 schema 的 criterionLeaf.type.enum（合法判定 type 权威清单）。
List<String> _schemaEnumFor(String sim) {
  final f = File('schemas/${sim}_scenario.schema.json');
  final schema = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
  final defs = schema['definitions'] as Map<String, dynamic>;
  final leaf = defs['criterionLeaf'] as Map<String, dynamic>;
  final type =
      (leaf['properties'] as Map<String, dynamic>)['type'] as Map<String, dynamic>;
  return (type['enum'] as List<dynamic>).cast<String>();
}

/// 正则提取求值器文件里全部 case 分支名。
///
/// 同时兼容字符串 case（`case 'colorMatch':`）与枚举 case
/// （`case CircuitCriterionType.circuitClosed:`）；提取其他 switch 的
/// case 属无害超集（断言方向是「schema enum ⊆ cases」）。
Set<String> _evaluatorCasesFor(String sim) {
  final path = _evaluatorPaths[sim];
  expect(path, isNotNull, reason: '$sim 在 _evaluatorPaths 缺登记');
  final src = File(path!).readAsStringSync();
  final m = RegExp(r"case\s+(?:[A-Za-z_]\w*\.)?'([A-Za-z_]\w*)'")
      .allMatches(src);
  final m2 = RegExp(r'case\s+[A-Za-z_]\w*\.([A-Za-z_]\w*)').allMatches(src);
  return {...m.map((e) => e.group(1)!), ...m2.map((e) => e.group(1)!)};
}

/// 检查 sim 的 lib 目录下是否存在 `.checkObjectives(` 调用（view 消费点）。
bool _viewConsumesCheckObjectives(String sim) {
  final dir = Directory(_simLibDirs[sim]!);
  if (!dir.existsSync()) return false;
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      if (entity.readAsStringSync().contains('.checkObjectives(')) return true;
    }
  }
  return false;
}

void main() {
  test('分类完备：schemas 发现的每个 sim 必须在白名单或豁免表（新 sim 不给默认豁免）', () {
    final sims = _discoverSims();
    final classified = {..._wiredSims, ..._exemptions.keys};
    expect(sims.difference(classified), isEmpty,
        reason: '以下 sim 未分类——新 sim 接入必须四环齐（收进 _wiredSims）'
            '或显式登记 _exemptions：${sims.difference(classified).toList()}');
    expect(classified.difference(sims), isEmpty,
        reason: '白名单/豁免表存在过期条目（schema 已删除）：'
            '${classified.difference(sims).toList()}');
    expect(_simLibDirs.keys.toSet(), sims,
        reason: '_simLibDirs 与 schemas 发现的 sim 集合不一致');
  });

  test('schema 结构锁定：criterion oneOf 分发 + criterionLeaf.type.enum 不可回退', () {
    for (final sim in _discoverSims()) {
      final f = File('schemas/${sim}_scenario.schema.json');
      final schema = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      final defs = schema['definitions'] as Map<String, dynamic>;
      final criterion = defs['criterion'] as Map<String, dynamic>;
      expect(criterion['oneOf'], isA<List<dynamic>>(),
          reason: '$sim: criterion 必须是 oneOf 分发（叶子+组合），见候选 9');
      expect(_schemaEnumFor(sim), isNotEmpty,
          reason: '$sim: criterionLeaf.type.enum 不能为空');
    }
  });

  test('求值器路径存在（防文件改名后守卫静默失效）', () {
    for (final entry in _evaluatorPaths.entries) {
      expect(File(entry.value).existsSync(), isTrue,
          reason: '${entry.key} 的求值器路径失效：${entry.value}——'
              '若已重构请同步更新 _evaluatorPaths');
    }
  });

  test('白名单 sim 四环齐：schema enum ⊆ 求值器 case 分支 + view 有消费点', () {
    for (final sim in _wiredSims) {
      final enums = _schemaEnumFor(sim);
      final cases = _evaluatorCasesFor(sim);
      final missing = enums.where((e) => !cases.contains(e)).toSet();
      expect(missing, isEmpty,
          reason: '$sim schema 定义了判定 type 但求值器无对应 case：'
              '$missing——要么实现 evaluateLeaf 分支，要么从 schema enum 移除');

      expect(_viewConsumesCheckObjectives(sim), isTrue,
          reason: '$sim 判定器已实现但 view 层无 .checkObjectives( 消费点'
              '（半接线——判定永不触发）。接好 view 消费后收进白名单');
    }
  });

  test('豁免表状态快照（人工核对 · 接线后删除对应条目）', () {
    // 豁免是显式债务台账：本测试打印当前台账供人工审查，
    // 并对「半接线」类做 view 消费现状断言，防止台账与事实漂移。
    for (final entry in _exemptions.entries) {
      final sim = entry.key;
      final status = entry.value;
      if (status.startsWith('半接线')) {
        // 半接线 = 求值器在 + view 无消费：断言该现状仍属实
        expect(_viewConsumesCheckObjectives(sim), isFalse,
            reason: '$sim 豁免记录「view 无消费」，但实际已有 .checkObjectives('
                '消费点——豁免过期，请收进 _wiredSims');
        expect(_evaluatorPaths.containsKey(sim), isTrue);
      }
      if (status.startsWith('未接线')) {
        expect(_evaluatorPaths.containsKey(sim), isFalse,
            reason: '$sim 豁免记录「无求值器」，但 _evaluatorPaths 已登记'
                '——豁免过期，请更新状态或收进白名单');
      }
      // ignore: avoid_print
      print('  [豁免] $sim: $status');
    }
  });
}
