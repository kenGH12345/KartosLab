import 'package:flutter_test/flutter_test.dart';

import 'package:geometric_optics/circuit/models/circuit_state.dart';
import 'package:geometric_optics/circuit/models/circuit_solver.dart';

void main() {
  test('simple circuit component test', () {
    final c = CircuitComponent(
      id: 'a',
      type: ComponentType.battery,
      x: 0,
      y: 0,
      startVertexId: 'v1',
      endVertexId: 'v2',
    );
    expect(c.value, 10.0);
    expect(c.label, '10V');
  });

  test('circuit state with wires', () {
    final s = CircuitState(
      components: [
        CircuitComponent(id: 'b', type: ComponentType.battery, x: 0, y: 0, startVertexId: 'v1', endVertexId: 'v2'),
      ],
      wires: [
        WireSegment(id: 'w1', startVertexId: 'v1', endVertexId: 'v2'),
      ],
      vertices: [
        const Vertex(id: 'v1', x: 0, y: 0),
        const Vertex(id: 'v2', x: 100, y: 0),
      ],
    );
    expect(s.components.length, 1);
    expect(s.wires.length, 1);
    expect(s.vertices.length, 2);
  });

  test('empty state solves', () {
    final sol = CircuitSolver.solve(const CircuitState());
    expect(sol.componentStates.isEmpty, true);
  });

  test('battery powers bulb', () {
    // 电路设计：电池 -> 导线 -> 灯泡 -> 导线 -> 电池
    // 电流路径：v1 -> 电池 -> v2 -> 导线w1 -> v3 -> 灯泡 -> v4 -> 导线w2 -> v1
    final s = CircuitState(
      components: [
        CircuitComponent(id: 'b', type: ComponentType.battery, x: 0, y: 0, value: 10, startVertexId: 'v1', endVertexId: 'v2'),
        CircuitComponent(id: 'l', type: ComponentType.lightBulb, x: 200, y: 0, value: 10, startVertexId: 'v3', endVertexId: 'v4'),
      ],
      wires: [
        WireSegment(id: 'w1', startVertexId: 'v2', endVertexId: 'v3'),
        WireSegment(id: 'w2', startVertexId: 'v4', endVertexId: 'v1'),
      ],
      vertices: [
        const Vertex(id: 'v1', x: 0, y: 0),
        const Vertex(id: 'v2', x: 100, y: 0),
        const Vertex(id: 'v3', x: 200, y: 0),
        const Vertex(id: 'v4', x: 300, y: 0),
      ],
    );
    final sol = CircuitSolver.solve(s);
    expect(sol.isPowered('l'), true);
    expect(sol.brightnessFor('l'), greaterThan(0));
  });

  test('open switch blocks', () {
    // 电路设计：电池 -> 导线 -> 开关（断开）-> 导线 -> 灯泡 -> 导线 -> 电池
    // 开关断开，所以v3不可达，灯泡不通电
    final s = CircuitState(
      components: [
        CircuitComponent(id: 'b', type: ComponentType.battery, x: 0, y: 0, value: 10, startVertexId: 'v1', endVertexId: 'v2'),
        CircuitComponent(id: 's', type: ComponentType.switch_, x: 100, y: 0, isClosed: false, startVertexId: 'v3', endVertexId: 'v4'),
        CircuitComponent(id: 'l', type: ComponentType.lightBulb, x: 200, y: 0, value: 10, startVertexId: 'v5', endVertexId: 'v6'),
      ],
      wires: [
        WireSegment(id: 'w1', startVertexId: 'v2', endVertexId: 'v3'), // 电池连接到开关
        WireSegment(id: 'w2', startVertexId: 'v4', endVertexId: 'v5'), // 开关连接到灯泡
        WireSegment(id: 'w3', startVertexId: 'v6', endVertexId: 'v1'), // 灯泡连接回电池
      ],
      vertices: [
        const Vertex(id: 'v1', x: 0, y: 0),
        const Vertex(id: 'v2', x: 50, y: 0),
        const Vertex(id: 'v3', x: 100, y: 0),
        const Vertex(id: 'v4', x: 150, y: 0),
        const Vertex(id: 'v5', x: 200, y: 0),
        const Vertex(id: 'v6', x: 250, y: 0),
      ],
    );
    final sol = CircuitSolver.solve(s);
    expect(sol.isPowered('l'), false);
  });
}
