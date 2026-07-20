import 'dart:math';
import 'circuit_state.dart';

class CircuitSolver {
  static SolvedCircuit solve(CircuitState state) {
    if (state.components.isEmpty) return SolvedCircuit.empty;

    final compStates = <String, bool>{};
    final batteries = state.components.where((c) => c.type == ComponentType.battery).toList();
    if (batteries.isEmpty) {
      for (final c in state.components) compStates[c.id] = false;
      return SolvedCircuit(componentStates: compStates, bulbBrightness: {}, openNodes: {});
    }

    // 构建"导线+闭合开关"连通图（不包含灯泡/电阻/电池/断开开关）
    final adj = <String, List<String>>{};
    void link(String u, String v) {
      adj.putIfAbsent(u, () => []);
      adj.putIfAbsent(v, () => []);
      adj[u]!.add(v);
      adj[v]!.add(u);
    }

    for (final w in state.wires) link(w.startVertexId, w.endVertexId);

    for (final c in state.components) {
      if (c.type == ComponentType.switch_ && c.isClosed) {
        link(c.startVertexId, c.endVertexId);
      }
    }

    // BFS
    Set<String> bfs(String start) {
      final q = <String>[start];
      final vis = <String>{start};
      while (q.isNotEmpty) {
        final v = q.removeAt(0);
        for (final n in (adj[v] ?? [])) {
          if (vis.add(n)) q.add(n);
        }
      }
      return vis;
    }

    // 逐电池判断：元件两端分属正极区和负极区 → 形成回路
    for (final bat in batteries) {
      compStates[bat.id] = true;
      final pos = bfs(bat.endVertexId);
      final neg = bfs(bat.startVertexId);

      for (final c in state.components) {
        if (c.type == ComponentType.battery) continue;
        if (c.type == ComponentType.switch_ && !c.isClosed) {
          compStates[c.id] = false;
          continue;
        }

        final sv = c.startVertexId, ev = c.endVertexId;
        // 一端在正极区、另一端在负极区 = 该电池的电流流过此元件
        final powered = (pos.contains(sv) && neg.contains(ev)) ||
                        (pos.contains(ev) && neg.contains(sv));
        compStates[c.id] = powered;
      }
    }

    // 亮度计算
    final brightness = <String, double>{};
    final poweredBulbs = state.components.where((c) =>
        c.type == ComponentType.lightBulb && compStates[c.id] == true);
    if (poweredBulbs.isNotEmpty) {
      final totalR = state.components
          .where((x) => x.type == ComponentType.resistor || x.type == ComponentType.lightBulb)
          .fold<double>(0, (s, x) => s + x.value);
      final totalV = batteries
          .where((b) => compStates[b.id] == true)
          .fold<double>(0, (s, b) => s + b.value);
      if (totalR > 0 && totalV > 0) {
        final current = totalV / totalR;
        for (final c in poweredBulbs) {
          final power = current * current * c.value;
          const k = 0.1;
          final temperature = (300.0 + power / k).clamp(0.0, 3000.0);
          if (temperature < 3000.0) {
            final nt = temperature / 3000.0;
            brightness[c.id] = sqrt(nt * nt).clamp(0.0, 1.0);
          }
        }
      }
    }

    final openNodes = <String>{};
    for (final c in state.components) {
      if (compStates[c.id] == false && c.type != ComponentType.switch_) openNodes.add(c.id);
    }
    return SolvedCircuit(componentStates: compStates, bulbBrightness: brightness, openNodes: openNodes);
  }
}
