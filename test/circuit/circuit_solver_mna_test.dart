import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/circuit/models/circuit_state.dart';
import 'package:kratos/circuit/models/circuit_solver.dart';

/// M1 求解器升级测试：验证 MNA 支持并联/精确电流。
///
/// 覆盖：串并联混合、并联分流、多电池、短路、开路、灯泡亮度与电流。
void main() {
  // 辅助：构建一个简单回路
  CircuitState buildLoop({
    required double batteryVoltage,
    required List<double> resistances,
  }) {
    // 拓扑：电池 b（v0-v1）→ r1 → r2 → … → 回到 v0
    final components = <CircuitComponent>[];
    final wires = <WireSegment>[];
    final vertices = <Vertex>[];

    // 电池
    components.add(CircuitComponent(
      id: 'bat', type: ComponentType.battery, x: 0, y: 0,
      value: batteryVoltage, startVertexId: 'v0', endVertexId: 'v1'));
    vertices.add(const Vertex(id: 'v0', x: 0, y: 0));
    vertices.add(const Vertex(id: 'v1', x: 100, y: 0));

    // 电阻链
    var prev = 'v1';
    for (var i = 0; i < resistances.length; i++) {
      final vIn = 'v${i + 2}';
      final vOut = 'v${i + 3}';
      components.add(CircuitComponent(
        id: 'r$i', type: ComponentType.resistor, x: 0, y: 0,
        value: resistances[i], startVertexId: vIn, endVertexId: vOut));
      wires.add(WireSegment(id: 'w$i', startVertexId: prev, endVertexId: vIn));
      vertices.add(Vertex(id: vIn, x: 200 + i * 100.0, y: 0));
      vertices.add(Vertex(id: vOut, x: 250 + i * 100.0, y: 0));
      prev = vOut;
    }
    // 闭合回路
    wires.add(WireSegment(id: 'wClose', startVertexId: prev, endVertexId: 'v0'));

    return CircuitState(components: components, wires: wires, vertices: vertices);
  }

  test('series: current matches I = V / Rtotal', () {
    final s = buildLoop(batteryVoltage: 10, resistances: [5, 5]); // 串联 10Ω
    final sol = CircuitSolver.solve(s);
    // I = 10 / 10 = 1A，两电阻各 1A
    expect(sol.currentFor('r0'), closeTo(1.0, 1e-9));
    expect(sol.currentFor('r1'), closeTo(1.0, 1e-9));
    // 串联分压各 5V
    expect(sol.voltageFor('r0'), closeTo(5.0, 1e-9));
    expect(sol.voltageFor('r1'), closeTo(5.0, 1e-9));
  });

  test('parallel: current splits proportionally to conductance', () {
    // 电池 10V，两条并联支路：10Ω 和 5Ω
    final s = CircuitState(
      components: [
        CircuitComponent(id: 'bat', type: ComponentType.battery, x: 0, y: 0,
          value: 10, startVertexId: 'v0', endVertexId: 'v1'),
        CircuitComponent(id: 'rA', type: ComponentType.resistor, x: 0, y: 0,
          value: 10, startVertexId: 'v1', endVertexId: 'v2'),
        CircuitComponent(id: 'rB', type: ComponentType.resistor, x: 0, y: 0,
          value: 5, startVertexId: 'v1', endVertexId: 'v2'),
      ],
      wires: [
        WireSegment(id: 'w1', startVertexId: 'v2', endVertexId: 'v0'),
      ],
      vertices: const [
        Vertex(id: 'v0', x: 0, y: 0),
        Vertex(id: 'v1', x: 100, y: 0),
        Vertex(id: 'v2', x: 200, y: 0),
      ],
    );
    final sol = CircuitSolver.solve(s);
    // 10Ω 支路：1A；5Ω 支路：2A（并联分流）
    expect(sol.currentFor('rA'), closeTo(1.0, 1e-9));
    expect(sol.currentFor('rB'), closeTo(2.0, 1e-9));
    expect(sol.voltageFor('rA'), closeTo(10.0, 1e-9));
    expect(sol.voltageFor('rB'), closeTo(10.0, 1e-9));
  });

  test('parallel: equal resistance bulbs share equal current & brightness', () {
    // 两个 10Ω 灯泡并联，10V → 各 1A
    final s = CircuitState(
      components: [
        CircuitComponent(id: 'bat', type: ComponentType.battery, x: 0, y: 0,
          value: 10, startVertexId: 'v0', endVertexId: 'v1'),
        CircuitComponent(id: 'b1', type: ComponentType.lightBulb, x: 0, y: 0,
          value: 10, startVertexId: 'v1', endVertexId: 'v2'),
        CircuitComponent(id: 'b2', type: ComponentType.lightBulb, x: 0, y: 0,
          value: 10, startVertexId: 'v1', endVertexId: 'v2'),
      ],
      wires: [WireSegment(id: 'w1', startVertexId: 'v2', endVertexId: 'v0')],
      vertices: const [
        Vertex(id: 'v0', x: 0, y: 0),
        Vertex(id: 'v1', x: 100, y: 0),
        Vertex(id: 'v2', x: 200, y: 0),
      ],
    );
    final sol = CircuitSolver.solve(s);
    expect(sol.isPowered('b1'), true);
    expect(sol.isPowered('b2'), true);
    expect(sol.currentFor('b1'), closeTo(1.0, 1e-9));
    expect(sol.currentFor('b2'), closeTo(1.0, 1e-9));
    expect(sol.brightnessFor('b1'), closeTo(sol.brightnessFor('b2'), 1e-9));
  });

  test('series-parallel hybrid: total current = V / Req', () {
    // 电池 12V：(R1=6 串联) + (R2=6 || R3=6)
    // Req = 6 + (6||6=3) = 9Ω → I = 12/9 = 1.333A
    final s = CircuitState(
      components: [
        CircuitComponent(id: 'bat', type: ComponentType.battery, x: 0, y: 0,
          value: 12, startVertexId: 'v0', endVertexId: 'v1'),
        CircuitComponent(id: 'r1', type: ComponentType.resistor, x: 0, y: 0,
          value: 6, startVertexId: 'v1', endVertexId: 'v2'),
        CircuitComponent(id: 'r2', type: ComponentType.resistor, x: 0, y: 0,
          value: 6, startVertexId: 'v2', endVertexId: 'v3'),
        CircuitComponent(id: 'r3', type: ComponentType.resistor, x: 0, y: 0,
          value: 6, startVertexId: 'v2', endVertexId: 'v3'),
      ],
      wires: [WireSegment(id: 'w1', startVertexId: 'v3', endVertexId: 'v0')],
      vertices: const [
        Vertex(id: 'v0', x: 0, y: 0),
        Vertex(id: 'v1', x: 100, y: 0),
        Vertex(id: 'v2', x: 200, y: 0),
        Vertex(id: 'v3', x: 300, y: 0),
      ],
    );
    final sol = CircuitSolver.solve(s);
    // r1 通过总电流
    expect(sol.currentFor('r1'), closeTo(12.0 / 9.0, 1e-9));
    // r2/r3 平分：I = (12/9)/2
    expect(sol.currentFor('r2'), closeTo((12.0 / 9.0) / 2, 1e-9));
    expect(sol.currentFor('r3'), closeTo((12.0 / 9.0) / 2, 1e-9));
  });

  test('open switch isolates branch', () {
    // 电池 + 开关(断开) → 灯泡不通电
    final s = CircuitState(
      components: [
        CircuitComponent(id: 'bat', type: ComponentType.battery, x: 0, y: 0,
          value: 10, startVertexId: 'v0', endVertexId: 'v1'),
        CircuitComponent(id: 's', type: ComponentType.switch_, x: 0, y: 0,
          isClosed: false, startVertexId: 'v1', endVertexId: 'v2'),
        CircuitComponent(id: 'l', type: ComponentType.lightBulb, x: 0, y: 0,
          value: 10, startVertexId: 'v2', endVertexId: 'v3'),
      ],
      wires: [WireSegment(id: 'w1', startVertexId: 'v3', endVertexId: 'v0')],
      vertices: const [
        Vertex(id: 'v0', x: 0, y: 0),
        Vertex(id: 'v1', x: 100, y: 0),
        Vertex(id: 'v2', x: 200, y: 0),
        Vertex(id: 'v3', x: 300, y: 0),
      ],
    );
    final sol = CircuitSolver.solve(s);
    expect(sol.isPowered('l'), false);
    expect(sol.currentFor('l'), 0.0);
    expect(sol.isOpen('l'), true);
  });

  test('multi-battery: two series batteries sum voltage', () {
    // 两个 5V 电池串联 + 10Ω 电阻 → 10V/10Ω = 1A
    final s = CircuitState(
      components: [
        CircuitComponent(id: 'b1', type: ComponentType.battery, x: 0, y: 0,
          value: 5, startVertexId: 'v0', endVertexId: 'v1'),
        CircuitComponent(id: 'b2', type: ComponentType.battery, x: 0, y: 0,
          value: 5, startVertexId: 'v1', endVertexId: 'v2'),
        CircuitComponent(id: 'r', type: ComponentType.resistor, x: 0, y: 0,
          value: 10, startVertexId: 'v2', endVertexId: 'v3'),
      ],
      wires: [WireSegment(id: 'w1', startVertexId: 'v3', endVertexId: 'v0')],
      vertices: const [
        Vertex(id: 'v0', x: 0, y: 0),
        Vertex(id: 'v1', x: 100, y: 0),
        Vertex(id: 'v2', x: 200, y: 0),
        Vertex(id: 'v3', x: 300, y: 0),
      ],
    );
    final sol = CircuitSolver.solve(s);
    expect(sol.currentFor('r'), closeTo(1.0, 1e-9));
    expect(sol.isPowered('r'), true);
  });

  test('shorted battery is flagged', () {
    // 电池两端被导线直接短接 → v0-v1 同节点
    final s = CircuitState(
      components: [
        CircuitComponent(id: 'bat', type: ComponentType.battery, x: 0, y: 0,
          value: 10, startVertexId: 'v0', endVertexId: 'v1'),
      ],
      wires: [WireSegment(id: 'w1', startVertexId: 'v0', endVertexId: 'v1')],
      vertices: const [
        Vertex(id: 'v0', x: 0, y: 0),
        Vertex(id: 'v1', x: 100, y: 0),
      ],
    );
    final sol = CircuitSolver.solve(s);
    expect(sol.isShorted('bat'), true);
  });

  test('no battery: all components unpowered', () {
    final s = CircuitState(
      components: [
        CircuitComponent(id: 'r', type: ComponentType.resistor, x: 0, y: 0,
          value: 10, startVertexId: 'v0', endVertexId: 'v1'),
      ],
      wires: const [],
      vertices: const [
        Vertex(id: 'v0', x: 0, y: 0),
        Vertex(id: 'v1', x: 100, y: 0),
      ],
    );
    final sol = CircuitSolver.solve(s);
    expect(sol.isPowered('r'), false);
    expect(sol.isOpen('r'), true);
  });
}
