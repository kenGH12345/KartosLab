import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/circuit/config/circuit_scenario.dart';
import 'package:kratos/circuit/config/circuit_learning_objective.dart';
import 'package:kratos/circuit/config/scenario_manager.dart';
import 'package:kratos/circuit/models/circuit_state.dart';
import 'package:kratos/common/scenario/success_condition.dart';

void main() {
  // ---------- 1 · default scenario (empty topology) ----------

  test('CircuitScenario.fromJson parses default (empty topology)', () {
    const jsonStr = '''
{
  "scenarioId": "default",
  "name": "empty circuit",
  "description": "no pre-placed components",
  "version": "1.0",
  "initialLayout": {
    "components": [],
    "wires": [],
    "vertices": []
  }
}''';

    final scenario = CircuitScenario.fromJson(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );

    expect(scenario.scenarioId, equals('default'));
    expect(scenario.name, equals('empty circuit'));
    expect(scenario.version, equals('1.0'));
    expect(scenario.initialLayout.components, isEmpty);
    expect(scenario.initialLayout.wires, isEmpty);
    expect(scenario.initialLayout.vertices, isEmpty);
  });

  // ---------- 2 · simple-series (non-empty topology) ----------

  test('CircuitScenario.fromJson parses simple-series with 3+3+6 topology', () {
    const jsonStr = '''
{
  "scenarioId": "simple-series",
  "name": "series",
  "version": "1.0",
  "initialLayout": {
    "vertices": [
      {"id":"v_bat_l","x":100,"y":200,"isTerminal":true},
      {"id":"v_bat_r","x":220,"y":200,"isTerminal":true},
      {"id":"v_res_l","x":340,"y":200,"isTerminal":true},
      {"id":"v_res_r","x":460,"y":200,"isTerminal":true},
      {"id":"v_bulb_l","x":580,"y":200,"isTerminal":true},
      {"id":"v_bulb_r","x":700,"y":200,"isTerminal":true}
    ],
    "components": [
      {"id":"bat_1","type":"battery","x":160,"y":200,"value":10,"startVertexId":"v_bat_l","endVertexId":"v_bat_r"},
      {"id":"res_1","type":"resistor","x":400,"y":200,"value":10,"startVertexId":"v_res_l","endVertexId":"v_res_r"},
      {"id":"bulb_1","type":"lightBulb","x":640,"y":200,"value":10,"startVertexId":"v_bulb_l","endVertexId":"v_bulb_r"}
    ],
    "wires": [
      {"id":"w1","startVertexId":"v_bat_r","endVertexId":"v_res_l"},
      {"id":"w2","startVertexId":"v_res_r","endVertexId":"v_bulb_l"},
      {"id":"w3","startVertexId":"v_bulb_r","endVertexId":"v_bat_l","controlPoints":[{"x":760,"y":350},{"x":40,"y":350}]}
    ]
  }
}''';

    final scenario = CircuitScenario.fromJson(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );

    expect(scenario.scenarioId, equals('simple-series'));
    final layout = scenario.initialLayout;

    // vertices
    expect(layout.vertices.length, equals(6));
    expect(layout.vertices[0].id, equals('v_bat_l'));
    expect(layout.vertices[0].isTerminal, isTrue);

    // components
    expect(layout.components.length, equals(3));
    expect(layout.components[0].type, equals(ComponentType.battery));
    expect(layout.components[1].type, equals(ComponentType.resistor));
    expect(layout.components[2].type, equals(ComponentType.lightBulb));
    expect(layout.components[0].value, equals(10.0));

    // wires
    expect(layout.wires.length, equals(3));
    expect(layout.wires[2].controlPoints.length, equals(2));
    expect(layout.wires[2].controlPoints[0]['x'], equals(760.0));
  });

  // ---------- 3 · toJson round-trip ----------

  test('CircuitScenario.toJson round-trip preserves data', () {
    final original = CircuitScenario(
      scenarioId: 'test-roundtrip',
      name: 'rt',
      description: 'round-trip check',
      version: '2.0',
      initialLayout: CircuitLayout(
        components: [
          ComponentPlacement(
            id: 'c1',
            type: ComponentType.battery,
            x: 100,
            y: 200,
            startVertexId: 'v1',
            endVertexId: 'v2',
            value: 12.0,
          ),
        ],
        wires: [
          WirePlacement(
            id: 'w1',
            startVertexId: 'v1',
            endVertexId: 'v2',
            controlPoints: [{'x': 50.0, 'y': 30.0}],
          ),
        ],
        vertices: [
          VertexPlacement(id: 'v1', x: 100, y: 200, isTerminal: true),
          VertexPlacement(id: 'v2', x: 200, y: 200, isTerminal: true),
        ],
      ),
    );

    final json = original.toJson();
    final restored = CircuitScenario.fromJson(json);

    expect(restored.scenarioId, equals(original.scenarioId));
    expect(restored.version, equals(original.version));
    expect(restored.initialLayout.components.length, equals(1));
    expect(restored.initialLayout.components[0].type, equals(ComponentType.battery));
    expect(restored.initialLayout.components[0].value, equals(12.0));
    expect(restored.initialLayout.wires.length, equals(1));
    expect(restored.initialLayout.vertices.length, equals(2));
  });

  // ---------- 4 · missing required field ----------

  test('CircuitScenario.fromJson throws on missing scenarioId', () {
    const jsonStr = '{"name":"no-id","version":"1.0","initialLayout":{"components":[],"wires":[],"vertices":[]}}';

    expect(
      () => CircuitScenario.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      ),
      throwsA(isA<TypeError>()),
    );
  });

  // ---------- 5 · unknown ComponentType ----------

  test('parseComponentType throws on unknown type string', () {
    expect(
      () => parseComponentType('not_a_valid_type'),
      throwsA(isA<ArgumentError>()),
    );
  });

  // ---------- 6 · defaults for optional fields ----------

  test('CircuitScenario.fromJson applies defaults for optional fields', () {
    const jsonStr = '''
{
  "scenarioId": "minimal",
  "name": "min",
  "initialLayout": {
    "components": [
      {"id":"c1","type":"fuse","x":0,"y":0,"startVertexId":"v1","endVertexId":"v2"}
    ],
    "wires": [],
    "vertices": [
      {"id":"v1","x":0,"y":0},
      {"id":"v2","x":10,"y":10}
    ]
  }
}''';

    final scenario = CircuitScenario.fromJson(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );

    expect(scenario.description, equals(''));
    expect(scenario.version, equals('1.0'));

    final comp = scenario.initialLayout.components[0];
    expect(comp.rotation, equals(0.0));
    expect(comp.value, equals(10.0));
    expect(comp.isClosed, isTrue);

    final vtx = scenario.initialLayout.vertices[0];
    expect(vtx.isJunction, isFalse);
    expect(vtx.isTerminal, isFalse);
  });

  // ---------- 7 · constraints parsing ----------

  test('CircuitScenario.fromJson parses constraints section', () {
    const jsonStr = '''
{
  "scenarioId": "constrained",
  "name": "has-constraints",
  "version": "1.0",
  "initialLayout": {
    "components": [],
    "wires": [],
    "vertices": []
  },
  "constraints": [
    {
      "id": "c1",
      "type": "topology",
      "description": "must be closed loop",
      "params": { "requireClosed": true },
      "enforced": true
    },
    {
      "id": "c2",
      "type": "componentCount",
      "description": "need 1 battery",
      "params": { "componentType": "battery", "minCount": 1, "maxCount": 2 },
      "enforced": false
    }
  ]
}''';

    final scenario = CircuitScenario.fromJson(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );

    expect(scenario.constraints.length, equals(2));
    expect(scenario.constraints[0].id, equals('c1'));
    expect(scenario.constraints[0].type.name, equals('topology'));
    expect(scenario.constraints[0].enforced, isTrue);
    expect(scenario.objectives, isNull);
  });

  // ---------- 8 · objectives parsing ----------

  test('CircuitScenario.fromJson parses objectives section', () {
    const jsonStr = '''
{
  "scenarioId": "with-objectives",
  "name": "has-objectives",
  "version": "1.0",
  "initialLayout": {
    "components": [],
    "wires": [],
    "vertices": []
  },
  "objectives": {
    "type": "guided",
    "description": "make the bulb light up",
    "successCriteria": [
      {
        "id": "sc-1",
        "type": "circuitClosed",
        "description": "circuit forms a closed loop",
        "params": {}
      },
      {
        "id": "sc-2",
        "type": "bulbBrightness",
        "description": "bulb is visible",
        "params": { "minBrightness": 0.1 }
      }
    ],
    "hints": [
      { "trigger": "openNodes > 0", "message": "close the circuit" }
    ],
    "validation": { "autoCheck": true, "showFeedback": true }
  }
}''';

    final scenario = CircuitScenario.fromJson(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );

    expect(scenario.objectives, isNotNull);
    final obj = scenario.objectives!;
    expect(obj.type.name, equals('guided'));
    expect(obj.successCriteria.length, equals(2));
    expect((obj.successCriteria[0] as LeafCondition).type,
        equals('circuitClosed'));
    expect((obj.successCriteria[1] as LeafCondition).type,
        equals('bulbBrightness'));
    expect(obj.hints.length, equals(1));
    expect(obj.validation.autoCheck, isTrue);
  });

  // ---------- 9 · toJson round-trip with constraints + objectives ----------

  test('CircuitScenario.toJson round-trip preserves constraints and objectives', () {
    final original = CircuitScenario(
      scenarioId: 'rt-constraints',
      name: 'rt',
      description: 'round-trip constraints test',
      version: '1.0',
      initialLayout: CircuitLayout(
        components: [
          ComponentPlacement(
            id: 'bat',
            type: ComponentType.battery,
            x: 0,
            y: 0,
            startVertexId: 'v1',
            endVertexId: 'v2',
          ),
        ],
        wires: [],
        vertices: [
          VertexPlacement(id: 'v1', x: 0, y: 0),
          VertexPlacement(id: 'v2', x: 10, y: 10),
        ],
      ),
    );

    final json = original.toJson();
    final restored = CircuitScenario.fromJson(json);

    expect(restored.scenarioId, equals(original.scenarioId));
    expect(restored.constraints, isEmpty);
    expect(restored.objectives, isNull);
  });

  // ---------- 10 · inventory parsing ----------

  test('CircuitScenario.fromJson parses inventory section', () {
    const jsonStr = '''
{
  "scenarioId": "with-inventory",
  "name": "has-inventory",
  "version": "1.0",
  "initialLayout": {
    "components": [],
    "wires": [],
    "vertices": []
  },
  "inventory": {
    "availableComponents": {
      "battery": { "maxCount": 1, "locked": true, "defaultParams": { "value": 9.0 } },
      "resistor": { "maxCount": 3, "locked": false, "defaultParams": { "value": 20.0 } }
    }
  }
}''';

    final scenario = CircuitScenario.fromJson(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );

    expect(scenario.inventory, isNotNull);
    final inv = scenario.inventory!;
    expect(inv.availableComponents.length, equals(2));

    final batSpec = inv.availableComponents[ComponentType.battery];
    expect(batSpec, isNotNull);
    expect(batSpec!.maxCount, equals(1));
    expect(batSpec.locked, isTrue);
    expect(batSpec.defaultParams['value'], equals(9.0));

    expect(inv.canAdd(ComponentType.battery, 0), isTrue);
    expect(inv.canAdd(ComponentType.battery, 1), isFalse);

    final resSpec = inv.availableComponents[ComponentType.resistor]!;
    expect(resSpec.maxCount, equals(3));
    expect(resSpec.locked, isFalse);
  });

  // ---------- M-1 · hint trigger filtering ----------

  test('CircuitLearningObjective.getApplicableHints filters by trigger', () {
    // 构造 3 个 hint · 分别测试不同 trigger 语法
    final obj = CircuitLearningObjective.fromJson({
      'type': 'guided',
      'description': 'test',
      'successCriteria': <Map<String, dynamic>>[],
      'hints': [
        {'trigger': 'always', 'message': 'H-always'},
        {'trigger': 'openNodes > 0', 'message': 'H-open'},
        {'trigger': 'componentCount(battery) == 0', 'message': 'H-noBattery'},
      ],
      'validation': {'autoCheck': false, 'showFeedback': true},
    });

    // 空场景 · openNodes=0（solver 对空拓扑返回空），battery=0
    // H-always ✓ / H-open ✗（0>0 false） / H-noBattery ✓（0==0）
    final empty = const CircuitState();
    final hints = obj.getApplicableHints(empty);
    final msgs = hints.map((h) => h.message).toSet();
    expect(msgs.contains('H-always'), isTrue);
    expect(msgs.contains('H-open'), isFalse);
    expect(msgs.contains('H-noBattery'), isTrue);
  });

  test('CircuitLearningObjective._evalTrigger malformed trigger falls back to show', () {
    // 语法错误的 trigger 应保守回退为"永远显示"（避免 typo 让 hint 消失）
    final obj = CircuitLearningObjective.fromJson({
      'type': 'guided',
      'description': 'test',
      'successCriteria': <Map<String, dynamic>>[],
      'hints': [
        {'trigger': 'garbled ~~~', 'message': 'H-bad'},
      ],
      'validation': {'autoCheck': false, 'showFeedback': true},
    });
    final hints = obj.getApplicableHints(const CircuitState());
    expect(hints.length, equals(1));
    expect(hints.first.message, equals('H-bad'));
  });

  // ---------- 13 · fuse-blown end-to-end (rootBundle pipeline) ----------

  testWidgets('fuse-blown scenario loads via rootBundle and manager', (tester) async {
    final manager = CircuitScenarioManager();
    // 必须 runAsync：testWidgets 里直接 await rootBundle.loadString 会把 Future
    // 存进 CachingAssetBundle 缓存并绑定到本用例的 FakeAsync zone，用例结束后
    // 该缓存项永久 pending，导致后续任何读同一 asset 的用例挂到超时。
    await tester.runAsync(() => manager.loadScenarios());
    // 加载前验证场景已在 manifest 中
    expect(
      () => manager.loadScenario('fuse-blown'),
      returnsNormally,
    );
    final state = manager.loadScenario('fuse-blown');

    // 3 components: battery + fuse + lightBulb
    expect(state.components.length, equals(3));
    expect(state.components.any((c) => c.type == ComponentType.battery), isTrue);
    expect(state.components.any((c) => c.type == ComponentType.fuse), isTrue);
    expect(state.components.any((c) => c.type == ComponentType.lightBulb), isTrue);

    // 3 wires（闭合回路）
    expect(state.wires.length, equals(3));

    // 6 vertices（每个 component 2 个 terminal）
    expect(state.vertices.length, equals(6));

    // 检查 fuse value 正确解析（0.5A 额定电流）
    final fuse = state.components.firstWhere((c) => c.type == ComponentType.fuse);
    expect(fuse.value, equals(0.5));

    // 检查 battery value（12V）
    final bat = state.components.firstWhere((c) => c.type == ComponentType.battery);
    expect(bat.value, equals(12.0));
  });
}
