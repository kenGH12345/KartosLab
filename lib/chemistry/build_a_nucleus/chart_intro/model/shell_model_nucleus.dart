/// Chart Intro 壳层核：座位占用，不含像素、不含 Painter。
///
/// 对标 `js/chart-intro/model/ShellModelNucleus.ts`。
/// 质子 / 中子各有 3 行座位；入核顺序决定填座；绑定由计数派生。
library;

import '../../model/nucleon.dart';
import 'energy_level.dart';

/// 壳层上的一枚核子（只有座位，没有 Decay 的运动/换色字段）。
class ShellNucleon {
  ShellNucleon({
    required this.id,
    required this.type,
    required this.xPosition,
    required this.yPosition,
    required this.bound,
  });

  final int id;
  final NucleonType type;

  /// 模型 x 座（0–5）。[已确认] ParticleShellPosition.xPosition
  final int xPosition;

  /// 能级行（0–2）。
  final int yPosition;

  /// 该层已「填满并被更高层占用」时不可交互。
  /// [已确认] yPosition < levelFillProperty.yPosition → inputEnabled=false
  final bool bound;
}

/// 一层上的一个座位（可空）。不是 Offset。
class ShellSeat {
  const ShellSeat({required this.xPosition, this.nucleonId});

  final int xPosition;
  final int? nucleonId;

  bool get isEmpty => nucleonId == null;
}

class ShellModelNucleus {
  ShellModelNucleus();

  final List<ShellNucleon> _protons = [];
  final List<ShellNucleon> _neutrons = [];
  int _nextId = 1;

  List<ShellNucleon> get protons => List.unmodifiable(_protons);
  List<ShellNucleon> get neutrons => List.unmodifiable(_neutrons);

  int get protonCount => _protons.length;
  int get neutronCount => _neutrons.length;

  /// 三层座位结构始终存在，与当前计数无关。
  /// [已确认] ctor 初始化 protonShellPositions / neutronShellPositions 为 3 行
  int get levelCount => EnergyLevel.levels.length;

  EnergyLevel get protonFillLevel =>
      EnergyLevel.fillLevelForCount(protonCount);
  EnergyLevel get neutronFillLevel =>
      EnergyLevel.fillLevelForCount(neutronCount);

  List<ShellNucleon> nucleonsOf(NucleonType type) =>
      type == NucleonType.proton ? protons : neutrons;

  /// 该种类三层座位（空座 nucleonId 为 null）。
  List<List<ShellSeat>> seatsOf(NucleonType type) {
    final occupied = {for (final n in nucleonsOf(type)) (n.yPosition, n.xPosition): n.id};
    return [
      for (final level in EnergyLevel.levels)
        [
          for (final x in level.allowedX)
            ShellSeat(
              xPosition: x,
              nucleonId: occupied[(level.yPosition, x)],
            ),
        ],
    ];
  }

  ShellNucleon? add(NucleonType type) {
    final list = type == NucleonType.proton ? _protons : _neutrons;
    if (list.length >= _seatCapacity) return null;
    list.add(ShellNucleon(
      id: _nextId++,
      type: type,
      xPosition: 0,
      yPosition: 0,
      bound: false,
    ));
    _reconfigure(type);
    return list.last;
  }

  /// 取最高层最右核子并移除。[已确认] getLastParticleInShell
  ShellNucleon? removeLast(NucleonType type) {
    final list = type == NucleonType.proton ? _protons : _neutrons;
    if (list.isEmpty) return null;
    final last = _lastInShell(type);
    if (last == null) return null;
    list.removeWhere((n) => n.id == last.id);
    _reconfigure(type);
    return last;
  }

  ShellNucleon? getLastInShell(NucleonType type) => _lastInShell(type);

  /// 最高层最右起的 [n] 粒。[已确认] `getLastParticleInShell` 扫描顺序
  List<ShellNucleon> lastNInShell(NucleonType type, int n) {
    final sorted = [...nucleonsOf(type)]
      ..sort((a, b) {
        final byY = b.yPosition.compareTo(a.yPosition);
        if (byY != 0) return byY;
        return b.xPosition.compareTo(a.xPosition);
      });
    return sorted.take(n).toList();
  }

  void clear() {
    _protons.clear();
    _neutrons.clear();
  }

  static const int _seatCapacity =
      EnergyLevel.n0Capacity + EnergyLevel.n1Capacity + EnergyLevel.n2Capacity;

  void _reconfigure(NucleonType type) {
    final list = type == NucleonType.proton ? _protons : _neutrons;
    final fill = EnergyLevel.fillLevelForCount(list.length);
    final updated = <ShellNucleon>[];
    for (var i = 0; i < list.length; i++) {
      final level = EnergyLevel.forIndex(i);
      updated.add(ShellNucleon(
        id: list[i].id,
        type: type,
        xPosition: _localX(i, level.yPosition),
        yPosition: level.yPosition,
        bound: level.yPosition < fill.yPosition,
      ));
    }
    list
      ..clear()
      ..addAll(updated);
  }

  /// [已确认] getLocalXIndex：减去下层容量后取 ALLOWED_PARTICLE_POSITIONS[y][i]
  static int _localX(int index, int yPosition) {
    var indexForLevel = index;
    for (var y = yPosition - 1; y >= 0; y--) {
      indexForLevel -= EnergyLevel.levels[y].capacity;
    }
    return EnergyLevel.levels[yPosition].allowedX[indexForLevel];
  }

  ShellNucleon? _lastInShell(NucleonType type) {
    final list = nucleonsOf(type);
    if (list.isEmpty) return null;
    ShellNucleon? best;
    for (final n in list) {
      if (best == null ||
          n.yPosition > best.yPosition ||
          (n.yPosition == best.yPosition && n.xPosition > best.xPosition)) {
        best = n;
      }
    }
    return best;
  }
}
