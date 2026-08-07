import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'package:geometric_optics/circuit/config/circuit_scenario.dart';
import 'package:geometric_optics/circuit/config/scenario_manager.dart';
import 'package:geometric_optics/circuit/models/circuit_solver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('circuit inquiryTask 解析（AC-2.1 / AC-2.3）', () {
    test('simple-series.json 从 assets 加载并解析 inquiryTask', () async {
      final jsonStr = await rootBundle.loadString('assets/scenarios/circuit/simple-series.json');
      final scenario = CircuitScenario.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

      expect(scenario.scenarioId, 'simple-series');
      expect(scenario.inquiryTask, isNotNull);
      final task = scenario.inquiryTask!;
      expect(task.question, contains('电阻'));
      expect(task.steps.length, 2);
      expect(task.referenceConclusion, contains('欧姆定律'));
      expect(task.snapshotColumns.length, 4);
      // snapshotColumns key 与 screen 的 _circuitSnapshot() 返回 key 一致（AC-2.4）
      final keys = task.snapshotColumns.map((c) => c.key).toSet();
      expect(keys, {'resistance', 'voltage', 'current', 'brightness'});
    });

    test('无 inquiryTask 字段的旧 JSON 向后兼容（inquiryTask == null）', () {
      const jsonStr = '''
{
  "scenarioId": "legacy",
  "name": "legacy",
  "version": "1.0",
  "initialLayout": {"components": [], "wires": [], "vertices": []}
}''';
      final scenario = CircuitScenario.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      expect(scenario.inquiryTask, isNull);
    });
  });

  group('circuit snapshotProvider 集成（AC-2.4 / AC-3.2）', () {
    test('_circuitSnapshot 数据来源字段可用', () async {
      final mgr = CircuitScenarioManager();
      await mgr.loadScenarios();
      final state = mgr.loadScenario('simple-series');
      final solved = CircuitSolver.solve(state);

      // 与 screen 内 _circuitSnapshot() 相同的字段路径
      final res = state.findComp('res_1');
      expect(res, isNotNull);
      final snapshot = <String, dynamic>{
        'resistance': res!.value,
        'voltage': solved.voltageFor('res_1'),
        'current': solved.currentFor('res_1'),
        'brightness': solved.brightnessFor('bulb_1'),
      };
      expect(snapshot['resistance'], isA<num>());
      expect(snapshot['voltage'], isA<num>());
      expect(snapshot['current'], isA<num>());
      expect(snapshot['brightness'], isA<num>());
    });
  });
}
