import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometric_optics/forces/config/forces_scenario.dart';
import 'package:geometric_optics/forces/config/scenario_manager.dart';

void main() {
  const jsonDefault = '''
{
  "scenarioId": "default",
  "name": "自由探索",
  "mode": "motion",
  "initialParams": {"mass": 50, "position": 0, "velocity": 0, "appliedForce": 0, "frictionCoeff": 0},
  "objects": [
    {"id": "box_10", "label": "小箱 (10kg)", "mass": 10, "icon": "inventory_2"},
    {"id": "box_50", "label": "大箱 (50kg)", "mass": 50, "icon": "warehouse"}
  ],
  "successCriteria": [
    {"id": "sc-1", "type": "speedReached", "description": "加速到 5 m/s", "params": {"minSpeed": 5}}
  ],
  "hints": [
    {"trigger": "always", "message": "测试提示"}
  ]
}''';

  const jsonNetforce = '''
{
  "scenarioId": "netforce-tug",
  "name": "拔河比赛",
  "mode": "netForce",
  "gameRules": {"gameLength": 400, "cartStep": 0.003},
  "pullers": [
    {"id": "s1", "force": 50, "side": "left", "color": "FF3B82F6"},
    {"id": "s2", "force": 50, "side": "right", "color": "FFEF4444"}
  ],
  "successCriteria": [{"id": "sc-1", "type": "gameWon", "description": "获胜", "params": {}}]
}''';

  const jsonAccel = '''
{
  "scenarioId": "accel-demo",
  "name": "加速度演示",
  "mode": "acceleration",
  "initialParams": {"mass": 100, "frictionCoeff": 0.3, "showAccelerometer": true},
  "objects": [{"id": "b1", "label": "重箱", "mass": 100, "icon": "warehouse"}],
  "constraints": [{"id": "c1", "type": "maxSpeed", "description": "限速", "params": {"maxSpeed": 40}}]
}''';

  test('ForcesScenario.fromJson parses motion mode correctly', () {
    final data = jsonDecode(jsonDefault) as Map<String, dynamic>;
    final scenario = ForcesScenario.fromJson(data);
    expect(scenario.scenarioId, equals('default'));
    expect(scenario.mode, equals(ForcesMode.motion));
    expect(scenario.mass, equals(50));
    expect(scenario.position, isZero);
    expect(scenario.objects.length, equals(2));
    expect(scenario.objects[0].label, equals('小箱 (10kg)'));
    expect(scenario.objects[0].mass, equals(10));
    expect(scenario.objects[0].icon, equals('inventory_2'));
    expect(scenario.successCriteria.length, equals(1));
    expect(scenario.successCriteria[0].type, equals('speedReached'));
    expect(scenario.successCriteria[0].params['minSpeed'], equals(5));
    expect(scenario.hints.length, equals(1));
    expect(scenario.hints[0].trigger, equals('always'));
  });

  test('ForcesScenario.fromJson parses netForce mode correctly', () {
    final data = jsonDecode(jsonNetforce) as Map<String, dynamic>;
    final scenario = ForcesScenario.fromJson(data);
    expect(scenario.scenarioId, equals('netforce-tug'));
    expect(scenario.mode, equals(ForcesMode.netForce));
    expect(scenario.gameLength, equals(400));
    expect(scenario.cartStep, equals(0.003));
    expect(scenario.pullers.length, equals(2));
    expect(scenario.pullers[0].force, equals(50));
    expect(scenario.pullers[1].side, isTrue);
    expect(scenario.successCriteria[0].type, equals('gameWon'));
  });

  test('ForcesScenario.fromJson parses acceleration mode with accelerometer', () {
    final data = jsonDecode(jsonAccel) as Map<String, dynamic>;
    final scenario = ForcesScenario.fromJson(data);
    expect(scenario.mode, equals(ForcesMode.acceleration));
    expect(scenario.mass, equals(100));
    expect(scenario.frictionCoeff, equals(0.3));
    expect(scenario.showAccelerometer, isTrue);
    expect(scenario.objects.first.mass, equals(100));
    expect(scenario.constraints.length, equals(1));
    expect(scenario.constraints[0].type, equals('maxSpeed'));
  });

  test('ForcesScenario.fromJson uses defaults for missing optional fields', () {
    final data = <String, dynamic>{'scenarioId': 'min', 'name': '最小配置', 'mode': 'motion'};
    final scenario = ForcesScenario.fromJson(data);
    expect(scenario.mass, equals(50));
    expect(scenario.frictionCoeff, isZero);
    expect(scenario.objects, isEmpty);
    expect(scenario.pullers, isEmpty);
    expect(scenario.constraints, isEmpty);
    expect(scenario.successCriteria, isEmpty);
    expect(scenario.hints, isEmpty);
  });

  test('ForcesScenario.fromJson throws for unknown mode', () {
    final data = <String, dynamic>{'scenarioId': 'x', 'name': 'x', 'mode': 'quantum'};
    expect(() => ForcesScenario.fromJson(data), throwsA(isA<ArgumentError>()));
  });

  testWidgets('forces manifest loads via rootBundle and all 5 scenarios parse', (tester) async {
    final mgr = ForcesScenarioManager();
    await mgr.loadScenarios();
    expect(mgr.scenarios.length, equals(5));
    final ids = mgr.scenarios.map((s) => s.scenarioId).toSet();
    expect(ids, contains('default'));
    expect(ids, contains('netforce-tug'));
    expect(ids, contains('motion-explore'));
    expect(ids, contains('friction-explore'));
    expect(ids, contains('acceleration-explore'));
    final modes = mgr.scenarios.map((s) => s.mode).toSet();
    expect(modes, contains(ForcesMode.netForce));
    expect(modes, contains(ForcesMode.motion));
    expect(modes, contains(ForcesMode.friction));
    expect(modes, contains(ForcesMode.acceleration));
  });

  testWidgets('netforce-tug scenario has valid pullers', (tester) async {
    final mgr = ForcesScenarioManager();
    await mgr.loadScenarios();
    final s = mgr.loadScenario('netforce-tug');
    expect(s.pullers.length, greaterThanOrEqualTo(2));
    final lefts = s.pullers.where((p) => !p.side).length;
    final rights = s.pullers.where((p) => p.side).length;
    expect(lefts, greaterThanOrEqualTo(1));
    expect(rights, greaterThanOrEqualTo(1));
    expect(s.gameLength, greaterThan(0));
  });
}
