/// 顶部 mini-atom 的不可变渲染快照。
///
/// 只从 [ChartIntroState] 计数 + [NuclideRepository] 云半径派生。
/// 不创建第二份 Particle 世界，避免原版 issue #220 的双 ParticleAtom。
library;

import 'package:flutter/material.dart';

import '../../ban_constants.dart';
import '../../model/electron_cloud.dart';
import '../../model/nucleon.dart';
import '../../model/nucleus_layout.dart';
import '../../data/nuclide_repository.dart';
import '../chart_intro_visuals.dart';
import '../model/chart_intro_state.dart';

class MiniAtomNucleonVisual {
  const MiniAtomNucleonVisual({
    required this.type,
    required this.offset,
    required this.zLayer,
  });

  final NucleonType type;
  final Offset offset;
  final int zLayer;
}

class MiniAtomRender {
  const MiniAtomRender({
    required this.protonCount,
    required this.neutronCount,
    required this.nucleons,
    required this.cloudRadius,
    required this.showEmptyCircle,
    required this.scale,
    required this.interactive,
  });

  factory MiniAtomRender.from(
    ChartIntroState state,
    NuclideRepository repository,
  ) {
    final protons = [
      for (var i = 0; i < state.protonCount; i++)
        Nucleon(id: i + 1, type: NucleonType.proton),
    ];
    final neutrons = [
      for (var i = 0; i < state.neutronCount; i++)
        Nucleon(id: 1000 + i + 1, type: NucleonType.neutron),
    ];
    if (protons.isNotEmpty || neutrons.isNotEmpty) {
      NucleusLayout.reconfigure(
        protons,
        neutrons,
        nucleonRadius: ChartIntroVisuals.nucleonRadius,
      );
    }

    final laidOut = <MiniAtomNucleonVisual>[
      for (final n in [...protons, ...neutrons])
        MiniAtomNucleonVisual(
          type: n.type,
          offset: Offset(n.destX, n.destY),
          zLayer: n.zLayer,
        ),
    ]..sort((a, b) => b.zLayer.compareTo(a.zLayer));

    final cloud = ElectronCloudReading(
      protonCount: state.protonCount,
      atomicRadius: repository.electronCloudRadius(state.protonCount),
    );
    final diameter = cloud.compressedDiameter(
      maxElectrons: BanConstants.chartMaxProtons.toDouble(),
    );
    final cloudRadius = cloud.isTransparent
        ? 0.0
        : (BanConstants.screenViewAtomCenterX - diameter / 2) *
            BanConstants.electronCloudSizeFactor;

    return MiniAtomRender(
      protonCount: state.protonCount,
      neutronCount: state.neutronCount,
      nucleons: List.unmodifiable(laidOut),
      cloudRadius: cloudRadius,
      showEmptyCircle: state.isEmptyNucleus,
      scale: ChartIntroVisuals.miniAtomScale,
      interactive: state.miniAtom.interactive,
    );
  }

  final int protonCount;
  final int neutronCount;
  final List<MiniAtomNucleonVisual> nucleons;
  final double cloudRadius;
  final bool showEmptyCircle;
  final double scale;
  final bool interactive;

  int get massNumber => protonCount + neutronCount;
}
