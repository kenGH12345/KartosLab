import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/molarity/config/molarity_scenario_manager.dart';
import 'package:kratos/circuit/config/scenario_manager.dart';
import 'package:kratos/color_vision/config/color_vision_scenario_manager.dart';
import 'package:kratos/forces/config/scenario_manager.dart';
// optics 的类名无 sim 前缀（就叫 ScenarioManager），需 alias 避免歧义
import 'package:kratos/optics/config/scenario_manager.dart' as optics;
import 'package:kratos/radio_waves/config/radio_waves_scenario_manager.dart';
import 'package:kratos/sound/config/sound_scenario_manager.dart';
import 'package:kratos/wave_interference/config/wave_interference_scenario_manager.dart';

/// AI 场景生成工具链的一致性守卫。
///
/// 背景（实证）：`generate.py --write` 曾直接用 sim key 拼 assets 路径，而
/// 真实加载目录部分用连字符（color-vision / radio-waves / wave-interference）、
/// optics 更是平铺在根目录。结果生成的场景写进了 app 永不加载的孤儿目录
/// —— `assets/scenarios/color_vision/` 里留下 manifest.json + rgb-default.json
/// 两个死文件，且**不报任何错**。
///
/// 本测试把「Dart 加载路径」钉为唯一权威源，任何一侧改动都会立即失败。
void main() {
  final pyFile = File('scripts/ai_scenario_gen/generate.py');

  /// 从 `assets/scenarios/<sub>/manifest.json` 提取 `<sub>`（根目录则为空串）。
  String subdirOf(String manifestPath) {
    const prefix = 'assets/scenarios/';
    const suffix = '/manifest.json';
    expect(manifestPath, startsWith(prefix),
        reason: '$manifestPath 不在 assets/scenarios/ 下');
    if (manifestPath == '${prefix}manifest.json') return '';
    expect(manifestPath, endsWith(suffix));
    return manifestPath.substring(prefix.length, manifestPath.length - suffix.length);
  }

  /// 解析 generate.py 中的 SCENARIO_DIR_MAP 字面量。
  Map<String, String> parsePyDirMap() {
    final src = pyFile.readAsStringSync();
    final block = RegExp(r'SCENARIO_DIR_MAP\s*=\s*\{(.*?)\}', dotAll: true)
        .firstMatch(src);
    expect(block, isNotNull, reason: 'generate.py 中找不到 SCENARIO_DIR_MAP');
    final entries = RegExp(r'"([a-z_]+)"\s*:\s*"([a-z\-]*)"')
        .allMatches(block!.group(1)!);
    return {for (final m in entries) m.group(1)!: m.group(2)!};
  }

  /// 解析 generate.py 中的 SIM_MAP 字面量。
  Set<String> parsePySimMap() {
    final src = pyFile.readAsStringSync();
    final block =
        RegExp(r'SIM_MAP\s*=\s*\{(.*?)\}', dotAll: true).firstMatch(src);
    expect(block, isNotNull, reason: 'generate.py 中找不到 SIM_MAP');
    return RegExp(r'"([a-z_]+)"\s*:')
        .allMatches(block!.group(1)!)
        .map((m) => m.group(1)!)
        .toSet();
  }

  // Dart 侧权威路径（新增 sim 时必须同步登记）
  final dartManifestPaths = <String, String>{
    'circuit': CircuitScenarioManager().manifestPath,
    'color_vision': ColorVisionScenarioManager().manifestPath,
    'forces': ForcesScenarioManager().manifestPath,
    'molarity': MolarityScenarioManager().manifestPath,
    'optics': optics.ScenarioManager().manifestPath,
    'radio_waves': RadioWavesScenarioManager().manifestPath,
    'sound': SoundScenarioManager().manifestPath,
    'wave_interference': WaveInterferenceScenarioManager().manifestPath,
  };

  test('generate.py SCENARIO_DIR_MAP 与 Dart ScenarioManager 加载路径一致',
      () {
    final pyMap = parsePyDirMap();
    for (final entry in dartManifestPaths.entries) {
      final expected = subdirOf(entry.value);
      expect(pyMap[entry.key], isNotNull,
          reason: 'generate.py SCENARIO_DIR_MAP 缺少 ${entry.key}');
      expect(pyMap[entry.key], expected,
          reason: '${entry.key} 路径不一致：generate.py 写入 '
              '"${pyMap[entry.key]}" 但 app 从 "$expected" 加载 '
              '→ 生成的场景会进死目录');
    }
  });

  test('SIM_MAP / SCENARIO_DIR_MAP / schema / prompt 四者 sim 覆盖一致', () {
    final sims = parsePySimMap();
    expect(sims, dartManifestPaths.keys.toSet(),
        reason: 'SIM_MAP 与 Dart 侧 sim 清单不一致');
    expect(parsePyDirMap().keys.toSet(), sims,
        reason: 'SCENARIO_DIR_MAP 与 SIM_MAP 的 sim 清单不一致');

    for (final sim in sims) {
      expect(File('schemas/${sim}_scenario.schema.json').existsSync(), isTrue,
          reason: '$sim 缺 schema —— AI 生成结果将不被校验');
      expect(File('docs/prompts/${sim}_scenario.md').existsSync(), isTrue,
          reason: '$sim 缺 prompt —— AI 无法为该 sim 生成场景');
    }
  });

  test('每个 schema 都定义了 inquiryTask（含 predictions）', () {
    for (final sim in dartManifestPaths.keys) {
      final f = File('schemas/${sim}_scenario.schema.json');
      final json = jsonDecode(f.readAsStringSync().replaceFirst('\uFEFF', ''))
          as Map<String, dynamic>;
      final props = json['properties'] as Map<String, dynamic>;
      expect(props.containsKey('inquiryTask'), isTrue,
          reason: '$sim schema 缺 inquiryTask —— 该字段在实际场景 JSON 中已使用，'
              '缺定义会导致 AI 生成时不产出探究任务且校验静默漏检');
      final inq = (props['inquiryTask'] as Map)['properties'] as Map;
      for (final field in [
        'question',
        'predictions',
        'steps',
        'snapshotColumns',
        'referenceConclusion',
      ]) {
        expect(inq.containsKey(field), isTrue,
            reason: '$sim schema 的 inquiryTask 缺 $field');
      }
    }
  });

  test('inquiryTask 共享附录存在且被 generate.py 拼接（单一源）', () {
    final shared = File('docs/prompts/_shared/inquiry_task.md');
    expect(shared.existsSync(), isTrue,
        reason: '共享附录缺失 —— AI 不会被告知 inquiryTask 契约');

    final doc = shared.readAsStringSync();
    for (final key in [
      'predictions',
      'snapshotColumns',
      'referenceConclusion',
    ]) {
      expect(doc, contains(key), reason: '共享附录未说明 $key');
    }

    expect(pyFile.readAsStringSync(), contains('_shared'),
        reason: 'generate.py 未拼接共享附录 —— prompt 里将没有 inquiryTask 说明');

    // 各 sim prompt 不应复制附录正文（避免 8 份副本漂移）
    for (final sim in dartManifestPaths.keys) {
      final p = File('docs/prompts/${sim}_scenario.md').readAsStringSync();
      expect(p.contains('## 2. predictions[] —— 猜测阶段'), isFalse,
          reason: '$sim prompt 复制了共享附录正文，应改为引用');
    }
  });

  test('每个 schema 的所有 object 节点都声明了 additionalProperties（严格校验）', () {
    // 背景：schema 若不写 additionalProperties:false，AI 生成的拼错字段（如把
    // soluteAmount 写成 soluteAmmount）不会被拦截，而是静默变默认值 —— 学生看到
    // 的场景与作者意图不符，且无任何报错。
    final offenders = <String>[];

    void walk(Object? node, String path, String sim) {
      if (node is Map<String, dynamic>) {
        final hasProps = node.containsKey('properties');
        if (hasProps && !node.containsKey('additionalProperties')) {
          offenders.add('$sim $path');
        }
        for (final key in ['properties', 'definitions', r'$defs']) {
          final sub = node[key];
          if (sub is Map<String, dynamic>) {
            for (final e in sub.entries) {
              walk(e.value, '$path.${e.key}', sim);
            }
          }
        }
        if (node['items'] != null) walk(node['items'], '$path[]', sim);
        for (final comb in ['oneOf', 'anyOf', 'allOf']) {
          final list = node[comb];
          if (list is List) {
            for (var i = 0; i < list.length; i++) {
              walk(list[i], '$path<$comb$i>', sim);
            }
          }
        }
        final addl = node['additionalProperties'];
        if (addl is Map<String, dynamic>) walk(addl, '$path.*', sim);
      }
    }

    for (final sim in dartManifestPaths.keys) {
      final raw = File('schemas/${sim}_scenario.schema.json')
          .readAsStringSync()
          .replaceFirst('\uFEFF', '');
      walk(jsonDecode(raw) as Map<String, dynamic>, r'$', sim);
    }

    expect(offenders, isEmpty,
        reason: '以下 schema 节点有 properties 但未声明 additionalProperties，'
            '拼错字段会静默漏检：\n  ${offenders.join('\n  ')}\n'
            '故意允许扩展的节点请显式写 additionalProperties: true 或 {...}');
  });

  test('color_vision schema 定义了 challenge（Dart 侧真实解析的字段）', () {
    final raw = File('schemas/color_vision_scenario.schema.json')
        .readAsStringSync()
        .replaceFirst('\uFEFF', '');
    final props = (jsonDecode(raw) as Map<String, dynamic>)['properties'] as Map;
    expect(props.containsKey('challenge'), isTrue,
        reason: 'CVChallengeConfig 在 lib/color_vision/config/ 中被解析且已用于'
            '2 个场景，schema 缺定义会导致 AI 不生成该块 → 挑战模式回退硬编码');

    final ch = (props['challenge'] as Map)['properties'] as Map;
    for (final f in [
      'enabled',
      'mode',
      'difficulty',
      'timeLimit',
      'timeBonusPerLevel',
      'accuracyThreshold',
      'targets',
      'randomTargets',
    ]) {
      expect(ch.containsKey(f), isTrue, reason: 'challenge 缺字段 $f');
    }

    // prompt 也必须说明，否则 AI 不知道该字段存在
    final prompt = File('docs/prompts/color_vision_scenario.md').readAsStringSync();
    expect(prompt, contains('accuracyThreshold'),
        reason: 'color_vision prompt 未说明 challenge 配置块');
  });

  test('所有场景 JSON 无 schema 未定义的字段（schema 与数据双向同步）', () {
    // 这是「配置化」的闭环校验：
    //   - 场景多了字段而 schema 没定义 -> 该字段永远不被校验，写错也不报错
    //   - schema 加了 additionalProperties:false 却误伤现有场景 -> 立即暴露
    // 实证：曾漏掉 color_vision 的 challenge（Dart 在用、schema 未定义）。
    final problems = <String>[];

    Map<String, dynamic> resolveRef(
        Map<String, dynamic> node, Map<String, dynamic> root) {
      var cur = node;
      var guard = 0;
      while (cur.containsKey(r'$ref') && guard++ < 10) {
        final ref = cur[r'$ref'] as String;
        if (!ref.startsWith('#/')) break;
        Object? target = root;
        for (final part in ref.substring(2).split('/')) {
          target = (target as Map<String, dynamic>)[part];
        }
        cur = target as Map<String, dynamic>;
      }
      return cur;
    }

    /// 返回本次 walk 发现的问题（不直接写全局——oneOf 分支需要试错回滚）。
    List<String> walk(Object? instance, Map<String, dynamic> rawSchema,
        Map<String, dynamic> root, String path) {
      final schema = resolveRef(rawSchema, root);
      final found = <String>[];

      for (final comb in ['oneOf', 'anyOf', 'allOf']) {
        if (schema[comb] is List) {
          if (comb == 'allOf') {
            for (final sub in schema[comb] as List) {
              if (sub is Map<String, dynamic>) {
                found.addAll(walk(instance, sub, root, path));
              }
            }
            return found;
          }
          // oneOf / anyOf：任一分支完全接受即通过（标准 JSON Schema 语义）。
          // 支持 criterion 的「叶子 | 组合」分发——组合对象在叶子分支必然
          // 报未定义字段，须靠 not/any/all 分支接受。
          final branchProblems = <String>[];
          for (final sub in schema[comb] as List) {
            if (sub is! Map<String, dynamic>) continue;
            final p = walk(instance, sub, root, path);
            if (p.isEmpty) return const [];
            branchProblems.addAll(p);
          }
          return branchProblems;
        }
      }

      if (instance is Map<String, dynamic>) {
        final props = schema['properties'] as Map<String, dynamic>?;
        final addl = schema['additionalProperties'];
        if (props != null) {
          for (final e in instance.entries) {
            final sub = props[e.key];
            if (sub is Map<String, dynamic>) {
              found.addAll(walk(e.value, sub, root, '$path.${e.key}'));
            } else if (addl is Map<String, dynamic>) {
              found.addAll(walk(e.value, addl, root, '$path.${e.key}'));
            } else if (addl == null || addl == false) {
              found.add('$path.${e.key}');
            }
          }
        } else if (addl is Map<String, dynamic>) {
          for (final e in instance.entries) {
            found.addAll(walk(e.value, addl, root, '$path.${e.key}'));
          }
        }
      } else if (instance is List) {
        final items = schema['items'];
        if (items is Map<String, dynamic>) {
          for (var i = 0; i < instance.length; i++) {
            found.addAll(walk(instance[i], items, root, '$path[$i]'));
          }
        }
      }
      return found;
    }

    var scanned = 0;
    for (final entry in dartManifestPaths.entries) {
      final sim = entry.key;
      final sub = subdirOf(entry.value);
      final dir = Directory(sub.isEmpty ? 'assets/scenarios' : 'assets/scenarios/$sub');
      if (!dir.existsSync()) continue;

      final schema = jsonDecode(File('schemas/${sim}_scenario.schema.json')
          .readAsStringSync()
          .replaceFirst('\uFEFF', '')) as Map<String, dynamic>;

      for (final f in dir.listSync().whereType<File>()) {
        if (!f.path.endsWith('.json')) continue;
        final name = f.path.split(RegExp(r'[/\\]')).last;
        if (name == 'manifest.json') continue;

        final data = jsonDecode(f.readAsStringSync().replaceFirst('\uFEFF', ''));
        if (data is! Map<String, dynamic>) continue;
        // optics 与其他 sim 共用根目录，用 scenarioId 粗筛
        if (sub.isEmpty && !data.containsKey('scenarioId')) continue;

        scanned++;
        problems.addAll(
            walk(data, schema, schema, r'$').map((p) => '$sim/$name  $p'));
      }
    }

    expect(scanned, greaterThan(20), reason: '扫描到的场景文件过少，路径推导可能有误');
    expect(problems, isEmpty,
        reason: '以下字段在场景 JSON 中使用但 schema 未定义（共 ${problems.length} 处）：\n'
            '  ${problems.join('\n  ')}\n'
            '若该字段 Dart 侧确实在解析 -> 补进 schema；否则从 JSON 清理');
  });

  test('pubspec.yaml 声明了每个 sim 的场景目录（漏声明会导致场景加载失败）', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final entry in dartManifestPaths.entries) {
      final sub = subdirOf(entry.value);
      final declared = sub.isEmpty
          ? 'assets/scenarios/'
          : 'assets/scenarios/$sub/';
      expect(pubspec, contains(declared),
          reason: '${entry.key} 的场景目录 $declared 未在 pubspec.yaml assets 中声明 '
              '→ 该目录下的 JSON 不会被打包，运行时加载失败');
    }
  });

  test('不存在与真实目录同名但风格不同的孤儿场景目录', () {
    final realDirs = dartManifestPaths.values
        .map(subdirOf)
        .where((s) => s.isNotEmpty)
        .toSet();
    final root = Directory('assets/scenarios');
    if (!root.existsSync()) return;

    final actual = root
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path.split(RegExp(r'[/\\]')).last)
        .toSet();

    final orphans = actual.difference(realDirs);
    expect(orphans, isEmpty,
        reason: '发现孤儿场景目录 $orphans —— 不在任何 ScenarioManager 的加载路径上，'
            '通常是 generate.py 用错目录命名风格（下划线 vs 连字符）写入的死文件');
  });
}
