import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/scenario/lesson_manifest.dart';
import 'package:kratos/common/scenario/lesson_plan.dart';
import 'package:kratos/lesson_editor/models/editable_lesson_model.dart';
import 'package:kratos/lesson_editor/validation/lesson_importer.dart';
import 'package:kratos/lesson_editor/validation/lesson_saver.dart';

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('lesson_importer_test_');
  });

  tearDown(() {
    tmp.deleteSync(recursive: true);
  });

  bool playable(String sim, String scenarioId) => true;

  /// 用 LessonSaver 造一份可导入的剧本（真实闭环：保存 → 导入）。
  Future<void> seedSaved() async {
    final err = await LessonSaver(lessonsDir: tmp.path).save(
      EditableLessonModel(
        lessonId: 'import-me',
        name: '导入测试课时',
        entry: 'n1',
        nodes: const [
          EditableNode(
            id: 'n1',
            title: '场景1',
            scenario: LessonScenarioRef(sim: 'circuit', scenarioId: 'rgb'),
            advance: LessonAdvance(type: 'onCompleted', to: 'n2'),
          ),
          EditableNode(id: 'n2', title: '终点'),
        ],
        layout: const {'n1': Offset(0, 0), 'n2': Offset(0, 100)},
      ),
    );
    expect(err, isNull);
  }

  group('LessonImporter（T17）', () {
    test('listAvailable 读 manifest 条目', () async {
      await seedSaved();
      final importer = LessonImporter(lessonsDir: tmp.path);
      final entries = await importer.listAvailable();
      // 测试注入 loadString 拦截 manifest 路径；此处读取的是项目根真实
      // manifest（含存量课时）——断言含本次保存的条目即可
      expect(entries.map((e) => e.id), contains('import-me'));
      final imported = entries.firstWhere((e) => e.id == 'import-me');
      expect(imported.sim, 'circuit');
    });

    test('importByEntry 回读模型（节点/场景/布局）', () async {
      await seedSaved();
      final importer = LessonImporter(lessonsDir: tmp.path);
      final model = await importer.importByEntry(
        const LessonManifestEntry(id: 'import-me', file: 'import-me.json', name: 'x', sim: 'circuit'),
        scenarioPlayable: playable,
      );
      expect(model.lessonId, 'import-me');
      expect(model.entry, 'n1');
      expect(model.nodes, hasLength(2));
      expect(model.nodes.first.scenario?.sim, 'circuit');
      // 布局从 .layout.json 还原（非自动布局）
      expect(model.layout['n1'], Offset(0, 0));
      expect(model.layout['n2'], Offset(0, 100));
    });

    test('layout 缺失 → 自动布局兜底（entry 起 BFS 分层，不再堆叠同一坐标 · M1）', () async {
      await seedSaved();
      final importer = LessonImporter(lessonsDir: tmp.path);
      // 删除 layout 文件后再导入 → 布局降级为 LessonAutoLayout 计算结果
      File('${tmp.path}/import-me.layout.json').deleteSync();
      final degraded = await importer.importByEntry(
        const LessonManifestEntry(id: 'import-me', file: 'import-me.json', name: 'x', sim: 'circuit'),
        scenarioPlayable: playable,
      );
      expect(degraded.nodes, hasLength(2)); // 剧本本体不受影响
      expect(degraded.layout, hasLength(2));
      // n1 为 entry（层级 0），n2 为其 onCompleted 后继（层级 1）——
      // 两节点必须落在不同坐标，不再重叠堆叠在硬编码 (40,40)。
      expect(degraded.layout['n1'], isNotNull);
      expect(degraded.layout['n2'], isNotNull);
      expect(degraded.layout['n1'], isNot(equals(degraded.layout['n2'])));
      expect(degraded.layout['n2']!.dy, greaterThan(degraded.layout['n1']!.dy));
    });

    test('layout 部分缺失 → 保留已有坐标 + 自动布局仅填充缺失节点', () async {
      await seedSaved();
      // 手工改写 layout 文件，仅保留 n1 坐标，模拟"部分损坏/手工漏填 n2"。
      final layoutFile = File('${tmp.path}/import-me.layout.json');
      layoutFile.writeAsStringSync(jsonEncode({
        'nodes': {'n1': {'x': 999.0, 'y': 999.0}},
      }));
      final importer = LessonImporter(lessonsDir: tmp.path);
      final model = await importer.importByEntry(
        const LessonManifestEntry(id: 'import-me', file: 'import-me.json', name: 'x', sim: 'circuit'),
        scenarioPlayable: playable,
      );
      // 已有坐标（n1）原样保留，不被自动布局覆盖。
      expect(model.layout['n1'], const Offset(999, 999));
      // 缺失坐标（n2）由自动布局填充，不再是 null/堆叠。
      expect(model.layout['n2'], isNotNull);
      expect(model.layout['n2'], isNot(equals(model.layout['n1'])));
    });

    test('损坏 JSON → 抛 FormatException', () async {
      File('${tmp.path}/bad.json').writeAsStringSync('{not json');
      File('${tmp.path}/manifest.json').writeAsStringSync(jsonEncode({
        'version': '1.0',
        'lessons': [
          {'id': 'bad', 'file': 'bad.json', 'name': 'bad', 'sim': 'circuit'},
        ],
      }));
      final importer = LessonImporter(lessonsDir: tmp.path);
      expect(
        () => importer.importByEntry(
          const LessonManifestEntry(id: 'bad', file: 'bad.json', name: 'bad', sim: 'circuit'),
          scenarioPlayable: playable,
        ),
        throwsFormatException,
      );
    });
  });
}
