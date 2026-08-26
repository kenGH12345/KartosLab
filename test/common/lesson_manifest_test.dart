import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/scenario/lesson_manifest.dart';

/// T-P1-03 · lesson_manifest.dart 单测（降级路径全覆盖）。
void main() {
  bool playable(String sim, String scenarioId) =>
      sim == 'circuit' &&
      const {'controlled-switch', 'open-circuit-debug'}.contains(scenarioId);

  Map<String, dynamic> lessonJson(String id) => {
        'lessonId': id,
        'name': '课时 $id',
        'version': '1.0',
        'description': '测试课时',
        'entry': 'a',
        'nodes': [
          {
            'id': 'a',
            'title': 'A',
            'scenario': {'sim': 'circuit', 'scenarioId': 'controlled-switch'},
            'advance': {'type': 'next'},
          },
          {
            'id': 'b',
            'title': 'B',
            'scenario': {'sim': 'circuit', 'scenarioId': 'open-circuit-debug'},
            'advance': {'type': 'onCompleted', 'to': 'n-end'},
          },
          {'id': 'n-end', 'title': '完', 'scenario': null, 'advance': null},
        ],
      };

  /// 内存资源桩：path → 内容；缺失路径抛异常（模拟 rootBundle 资产缺失）。
  LessonManifestLoader loaderWith(Map<String, String> assets) {
    return LessonManifestLoader(
      assetLoader: (path) async {
        final content = assets[path];
        if (content == null) {
          throw FlutterErrorForTest('asset missing: $path');
        }
        return content;
      },
    );
  }

  String manifestJson(List<Map<String, String>> entries) =>
      jsonEncode({'version': '1.0', 'lessons': entries});

  Map<String, String> entry(String id, [String? file, String? sim]) => {
        'id': id,
        'file': file ?? '$id.json',
        'name': '课时 $id',
        'sim': sim ?? 'circuit',
      };

  group('LessonManifestLoader.loadEntries（AC-14）', () {
    test('正常解析 manifest 注册表', () async {
      final loader = loaderWith({
        'assets/lessons/manifest.json':
            manifestJson([entry('l-1'), entry('l-2', 'l-2.json', 'color_vision')]),
      });
      final entries = await loader.loadEntries();
      expect(entries, hasLength(2));
      expect(entries[0].id, 'l-1');
      expect(entries[1].sim, 'color_vision');
    });

    test('manifest 缺失 → 返回空列表（首页无入口，AC-14 降级）', () async {
      final loader = loaderWith(const {});
      expect(await loader.loadEntries(), isEmpty);
    });

    test('manifest JSON 损坏 → 返回空列表', () async {
      final loader = loaderWith({
        'assets/lessons/manifest.json': '{broken json',
      });
      expect(await loader.loadEntries(), isEmpty);
    });

    test('单条 entry 字段非法 → 跳过该条，其余正常', () async {
      final loader = loaderWith({
        'assets/lessons/manifest.json': manifestJson([
          {'id': 'bad', 'file': 'bad.json', 'name': '坏条目', 'sim': ''},
          entry('good'),
        ]),
      });
      final entries = await loader.loadEntries();
      expect(entries, hasLength(1));
      expect(entries.single.id, 'good');
    });
  });

  group('LessonManifestLoader.loadAll（AC-6 / AC-15 课时级降级）', () {
    test('全部课时正常加载', () async {
      final loader = loaderWith({
        'assets/lessons/manifest.json':
            manifestJson([entry('l-1'), entry('l-2')]),
        'assets/lessons/l-1.json': jsonEncode(lessonJson('l-1')),
        'assets/lessons/l-2.json': jsonEncode(lessonJson('l-2')),
      });
      final plans = await loader.loadAll(scenarioPlayable: playable);
      expect(plans, hasLength(2));
      expect(plans[0].lessonId, 'l-1');
    });

    test('单课时文件缺失 → 跳过，其余正常（AC-15）', () async {
      final loader = loaderWith({
        'assets/lessons/manifest.json':
            manifestJson([entry('missing'), entry('good')]),
        // missing.json 不存在
        'assets/lessons/good.json': jsonEncode(lessonJson('good')),
      });
      final plans = await loader.loadAll(scenarioPlayable: playable);
      expect(plans, hasLength(1));
      expect(plans.single.lessonId, 'good');
    });

    test('单课时 FormatException（引用不存在场景）→ 跳过，其余正常（AC-6）', () async {
      final bad = lessonJson('bad');
      (bad['nodes'] as List)[0]['scenario'] = {
        'sim': 'circuit',
        'scenarioId': 'not-exist',
      };
      final loader = loaderWith({
        'assets/lessons/manifest.json':
            manifestJson([entry('bad'), entry('good')]),
        'assets/lessons/bad.json': jsonEncode(bad),
        'assets/lessons/good.json': jsonEncode(lessonJson('good')),
      });
      final plans = await loader.loadAll(scenarioPlayable: playable);
      expect(plans, hasLength(1));
      expect(plans.single.lessonId, 'good');
    });

    test('单课时非 JSON 内容 → 跳过不 crash（宽类型 Exception 捕获）', () async {
      final loader = loaderWith({
        'assets/lessons/manifest.json':
            manifestJson([entry('garbage'), entry('good')]),
        'assets/lessons/garbage.json': '这不是 JSON',
        'assets/lessons/good.json': jsonEncode(lessonJson('good')),
      });
      final plans = await loader.loadAll(scenarioPlayable: playable);
      expect(plans, hasLength(1));
      expect(plans.single.lessonId, 'good');
    });
  });
}

/// 测试用资产缺失异常（避免依赖 Flutter binding 的 PlatformException）。
class FlutterErrorForTest implements Exception {
  FlutterErrorForTest(this.message);
  final String message;
  @override
  String toString() => 'FlutterErrorForTest: $message';
}
