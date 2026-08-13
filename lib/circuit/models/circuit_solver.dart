import 'dart:math';
import 'circuit_state.dart';

/// 电路求解器（M1 升级版）。
///
/// 旧实现把所有电阻/灯泡当作串联简单相加，并联电路必然算错。
/// 新实现采用 **节点电压法（Modified Nodal Analysis, MNA）**：
/// - 导线/闭合开关合并为超节点（零电阻短路）
/// - 对每个含电池的连通分量建立 MNA 方程组并精确求解
/// - 支持任意串并联拓扑、多电池、多支路电流分配
/// - 输出每元件电流/端电压（供黑盒行为对比）
class CircuitSolver {
  static SolvedCircuit solve(CircuitState state) {
    if (state.components.isEmpty) return SolvedCircuit.empty;

    // ------------------------------------------------------------------
    // 1. 并查集：合并导线 + 闭合开关端点 → 超节点
    // ------------------------------------------------------------------
    final uf = _UnionFind();
    for (final w in state.wires) {
      uf.union(w.startVertexId, w.endVertexId);
    }
    for (final c in state.components) {
      if (c.type == ComponentType.switch_ && c.isClosed) {
        uf.union(c.startVertexId, c.endVertexId);
      }
      if (c.type == ComponentType.ground) {
        // 接地元件两端视为同一点（地），并作为参考节点
        uf.union(c.startVertexId, c.endVertexId);
      }
    }

    // ------------------------------------------------------------------
    // 2. 收集所有参与求解的元件 → 超节点对
    // ------------------------------------------------------------------
    // superRoot -> 节点索引（0 号保留给参考节点，见分量求解）
    final nodeSet = <String>{};
    final compSuper = <String, _SuperEdge>{}; // compId -> edge
    final batteryIds = <String>[];

    void addComp(CircuitComponent c) {
      if (c.type == ComponentType.wire) return; // 导线已并入 uf
      if (c.type == ComponentType.switch_ && !c.isClosed) return; // 开路开关 = 断开
      final a = uf.find(c.startVertexId);
      final b = uf.find(c.endVertexId);
      nodeSet.add(a);
      nodeSet.add(b);
      compSuper[c.id] = _SuperEdge(a, b);
      if (c.type == ComponentType.battery) batteryIds.add(c.id);
    }

    for (final c in state.components) {
      addComp(c);
    }

    if (nodeSet.isEmpty) {
      // 没有任何导电元件（仅开路开关/空导线），全部未通电
      return SolvedCircuit(
        componentStates: {for (final c in state.components) c.id: false},
        openNodes: {for (final c in state.components) if (c.type != ComponentType.switch_) c.id},
      );
    }

    // 参考节点：优先选接地超节点，否则取第一个
    String? groundRoot;
    for (final c in state.components) {
      if (c.type == ComponentType.ground) {
        groundRoot = uf.find(c.startVertexId);
        break;
      }
    }

    // ------------------------------------------------------------------
    // 3. 按连通分量分组，分别求解
    // ------------------------------------------------------------------
    // 构建超节点邻接图（仅通过元件相连）
    final adj = <String, List<String>>{};
    for (final e in compSuper.values) {
      adj.putIfAbsent(e.a, () => []);
      adj.putIfAbsent(e.b, () => []);
      if (e.a != e.b) {
        adj[e.a]!.add(e.b);
        adj[e.b]!.add(e.a);
      }
    }

    final allNodes = nodeSet.toList();
    final visited = <String>{};
    final nodeVoltage = <String, double>{}; // superRoot -> V
    final componentCurrent = <String, double>{}; // compId -> A
    final componentVoltage = <String, double>{}; // compId -> V
    final shorted = <String>{};

    for (final start in allNodes) {
      if (visited.contains(start)) continue;

      // BFS 收集一个连通分量
      final comp = <String>[start];
      visited.add(start);
      var qi = 0;
      while (qi < comp.length) {
        final cur = comp[qi++];
        for (final nb in adj[cur] ?? const []) {
          if (visited.add(nb)) comp.add(nb);
        }
      }

      // 分量内元件
      final compIds = compSuper.entries
          .where((e) => comp.contains(e.value.a) && comp.contains(e.value.b))
          .map((e) => e.key)
          .toList();
      final hasBattery = compIds.any((id) => batteryIds.contains(id));

      if (!hasBattery) {
        // 无电池的独立分量：无电流
        for (final id in compIds) {
          componentCurrent[id] = 0;
          componentVoltage[id] = 0;
        }
        continue;
      }

      // 求解该分量
      _solveComponent(
        nodes: comp,
        compIds: compIds,
        compSuper: compSuper,
        batteryIds: batteryIds,
        groundRoot: groundRoot != null && comp.contains(groundRoot) ? groundRoot : null,
        nodeVoltage: nodeVoltage,
        componentCurrent: componentCurrent,
        componentVoltage: componentVoltage,
        shorted: shorted,
        state: state,
      );
    }

    // ------------------------------------------------------------------
    // 4. 汇总结果
    // ------------------------------------------------------------------
    final compStates = <String, bool>{};
    final openNodes = <String>{};
    const epsilon = 1e-9;

    for (final c in state.components) {
      if (c.type == ComponentType.wire) continue;
      if (c.type == ComponentType.switch_) {
        compStates[c.id] = c.isClosed;
        continue;
      }
      final iAbs = (componentCurrent[c.id] ?? 0).abs();
      final powered = iAbs > epsilon;
      compStates[c.id] = powered;
      if (!powered && c.type != ComponentType.switch_) openNodes.add(c.id);
    }

    // 亮度：由实际功率 P = I²R 映射到 0..1（沿用旧曲线形状）
    final brightness = <String, double>{};
    for (final c in state.components) {
      if (c.type != ComponentType.lightBulb) continue;
      final r = max(c.value, 0.01);
      final i = (componentCurrent[c.id] ?? 0).abs();
      final power = i * i * r;
      const k = 0.1;
      final temperature = (300.0 + power / k).clamp(0.0, 3000.0);
      brightness[c.id] = (temperature / 3000.0).clamp(0.0, 1.0);
    }

    return SolvedCircuit(
      bulbBrightness: brightness,
      componentStates: compStates,
      openNodes: openNodes,
      shortedNodes: shorted,
      currents: componentCurrent,
      voltages: componentVoltage,
    );
  }

  // ------------------------------------------------------------------
  // MNA 分量求解
  // ------------------------------------------------------------------
  static void _solveComponent({
    required List<String> nodes,
    required List<String> compIds,
    required Map<String, _SuperEdge> compSuper,
    required List<String> batteryIds,
    required String? groundRoot,
    required Map<String, double> nodeVoltage,
    required Map<String, double> componentCurrent,
    required Map<String, double> componentVoltage,
    required Set<String> shorted,
    required CircuitState state,
  }) {
    // 参考节点：地 或 该分量第一个节点
    final ref = groundRoot ?? nodes.first;
    final nodeIdx = <String, int>{};
    final nonRefNodes = nodes.where((n) => n != ref).toList();
    for (var i = 0; i < nonRefNodes.length; i++) {
      nodeIdx[nonRefNodes[i]] = i;
    }

    // 分量内电池
    final compBatteryIds = compIds.where((id) => batteryIds.contains(id)).toList();

    // 短路电池：两端同节点 → 跳过，标记短路
    final validBatteries = <String>[];
    for (final id in compBatteryIds) {
      final e = compSuper[id]!;
      if (e.a == e.b) {
        shorted.add(id);
        componentCurrent[id] = double.infinity;
        componentVoltage[id] = 0;
      } else {
        validBatteries.add(id);
      }
    }

    final n = nonRefNodes.length; // 电压未知数
    final m = validBatteries.length; // 电池电流未知数
    final N = n + m;
    final A = List.generate(N, (_) => List.filled(N, 0.0));
    final b = List.filled(N, 0.0);

    // KCL：导纳贡献
    for (final id in compIds) {
      final c = state.findComp(id);
      if (c == null) continue;
      final e = compSuper[id]!;
      final a = nodeIdx[e.a], bb = nodeIdx[e.b];

      if (c.type == ComponentType.battery) continue; // 电池走 B 矩阵

      // 导电元件：电阻 / 灯泡 / 保险丝 / 闭合开关（并入后同节点则跳过）
      if (a != null && bb != null && a == bb) continue;
      double r;
      switch (c.type) {
        case ComponentType.resistor:
        case ComponentType.lightBulb:
          r = max(c.value, 0.01);
          break;
        case ComponentType.fuse:
          r = 0.01; // 保险丝视为低阻导线（熔断逻辑由外部处理）
          break;
        case ComponentType.switch_:
          r = 0.01; // 闭合开关视为低阻
          break;
        default:
          continue;
      }
      final g = 1.0 / r;

      if (a == null && bb == null) {
        // 两端都直接连参考？参考电压 0，仍贡献导纳
        // a/bb 均非参考时正常，这里不可能同时 null（至少一端非参考）
        continue;
      }
      // 端电压：V[nodeIdx] 或 0（参考节点）
      final iA = a; // 可为 null → 参考
      final iB = bb; // 可为 null → 参考
      if (iA != null) A[iA][iA] += g;
      if (iB != null) A[iB][iB] += g;
      if (iA != null && iB != null) {
        A[iA][iB] -= g;
        A[iB][iA] -= g;
      }
    }

    // 电池：B 矩阵（电流注入） + 电压约束行
    // 约定：startVertexId=负极，endVertexId=正极（与 CCK 一致，电流从正极流出）
    for (var k = 0; k < validBatteries.length; k++) {
      final id = validBatteries[k];
      final e = compSuper[id]!;
      final c = state.findComp(id);
      if (c == null) continue;
      final iNeg = nodeIdx[e.a]; // 负极 = startVertexId
      final iPos = nodeIdx[e.b]; // 正极 = endVertexId

      // KCL：正极流出 +I，负极流入 -I
      if (iPos != null) A[iPos][n + k] += 1.0;
      if (iNeg != null) A[iNeg][n + k] -= 1.0;

      // 电压约束：V[正极] - V[负极] = E
      final row = n + k;
      if (iPos != null) A[row][iPos] += 1.0;
      if (iNeg != null) A[row][iNeg] -= 1.0;
      b[row] = c.value;
    }

    // 高斯消元求解
    final x = _solveLinear(A, b);
    if (x.isEmpty) {
      // 奇异/无解（不应发生），保守置零
      for (final id in compIds) {
        componentCurrent[id] = 0;
        componentVoltage[id] = 0;
      }
      return;
    }

    // 记录节点电压
    nodeVoltage[ref] = 0;
    for (var i = 0; i < nonRefNodes.length; i++) {
      nodeVoltage[nonRefNodes[i]] = x[i];
    }

    // 计算各元件电流/电压
    double vOf(String root) => root == ref ? 0 : (nodeVoltage[root] ?? 0);

    for (final id in compIds) {
      final c = state.findComp(id);
      if (c == null) continue;
      final e = compSuper[id]!;
      if (e.a == e.b) {
        // 端点短路
        componentCurrent[id] = c.type == ComponentType.battery ? double.infinity : 0;
        componentVoltage[id] = 0;
        if (c.type == ComponentType.battery) shorted.add(id);
        continue;
      }
      final vA = vOf(e.a), vB = vOf(e.b);
      final dv = vA - vB;
      if (c.type == ComponentType.battery) {
        final k = validBatteries.indexOf(id);
        componentCurrent[id] = k >= 0 ? x[n + k] : 0;
        componentVoltage[id] = c.value;
      } else {
        double r;
        switch (c.type) {
          case ComponentType.resistor:
          case ComponentType.lightBulb:
            r = max(c.value, 0.01);
            break;
          case ComponentType.fuse:
            r = 0.01;
            break;
          case ComponentType.switch_:
            r = 0.01;
            break;
          default:
            r = 0.01;
        }
        final i = dv / r;
        componentCurrent[id] = i;
        componentVoltage[id] = dv.abs();
      }
    }
  }

  // ------------------------------------------------------------------
  // 高斯消元（部分主元）
  // ------------------------------------------------------------------
  static List<double> _solveLinear(List<List<double>> a, List<double> b) {
    final n = b.length;
    if (n == 0) return const [];
    for (var col = 0; col < n; col++) {
      // 选主元
      var piv = col;
      for (var r = col + 1; r < n; r++) {
        if (a[r][col].abs() > a[piv][col].abs()) piv = r;
      }
      if (a[piv][col].abs() < 1e-12) return const []; // 奇异
      if (piv != col) {
        final tA = a[col]; a[col] = a[piv]; a[piv] = tA;
        final tB = b[col]; b[col] = b[piv]; b[piv] = tB;
      }
      // 归一化当前行
      final d = a[col][col];
      for (var j = col; j < n; j++) {
        a[col][j] /= d;
      }
      b[col] /= d;
      // 消去其他行
      for (var r = 0; r < n; r++) {
        if (r == col) continue;
        final f = a[r][col];
        if (f.abs() < 1e-15) continue;
        for (var j = col; j < n; j++) {
          a[r][j] -= f * a[col][j];
        }
        b[r] -= f * b[col];
      }
    }
    return b;
  }
}

/// 超节点边（两个合并后的根节点）
class _SuperEdge {
  final String a, b;
  const _SuperEdge(this.a, this.b);
}

/// 并查集
class _UnionFind {
  final Map<String, String> _parent = {};
  String find(String x) {
    _parent.putIfAbsent(x, () => x);
    if (_parent[x] != x) _parent[x] = find(_parent[x]!);
    return _parent[x]!;
  }

  void union(String a, String b) {
    final ra = find(a), rb = find(b);
    if (ra != rb) _parent[ra] = rb;
  }
}
