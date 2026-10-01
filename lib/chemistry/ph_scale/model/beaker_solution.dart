import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'ph_chemistry.dart';
import 'ph_scale_constants.dart';
import 'solute.dart';
import 'water.dart';

/// Beaker solution for Macro / Micro — PhET `Solution.ts`.
///
/// Intrinsic state: [soluteVolume] + [waterVolume] + [solute].
/// Derived: [totalVolume], [pH], [color].
class BeakerSolution extends ChangeNotifier {
  BeakerSolution({
    Solute? solute,
    this.soluteVolume = 0,
    this.waterVolume = 0,
    this.maxVolume = 1.2,
  }) : solute = solute ?? Solute.water {
    assert(soluteVolume >= 0);
    assert(waterVolume >= 0);
    assert(maxVolume > 0);
    assert(soluteVolume + waterVolume <= maxVolume);
  }

  Solute solute;
  double soluteVolume;
  double waterVolume;
  final double maxVolume;

  /// When true, suppress intermediate pH/color during atomic drain.
  bool _ignoreVolumeUpdate = false;
  PhValue? _cachedPH;
  Color? _cachedColor;

  double get totalVolume => soluteVolume + waterVolume;

  PhValue get pH {
    if (_ignoreVolumeUpdate && _cachedPH != null) return _cachedPH;
    return PhChemistry.computePH(
      solutePH: solute.pH,
      soluteVolume: soluteVolume,
      waterVolume: waterVolume,
    );
  }

  Color get color {
    if (_ignoreVolumeUpdate && _cachedColor != null) return _cachedColor!;
    final total = totalVolume;
    if (total == 0) return const Color(0xFF000000);
    if (soluteVolume == 0 || PhChemistry.isEquivalentToWater(pH)) {
      return Water.color;
    }
    return solute.computeColor(soluteVolume / total);
  }

  double get freeVolume => maxVolume - totalVolume;

  /// Changing solute resets volumes to initial (0) — PhET `soluteProperty.link`.
  void setSolute(Solute next, {bool resetVolumes = true}) {
    solute = next;
    if (resetVolumes) {
      soluteVolume = 0;
      waterVolume = 0;
    }
    notifyListeners();
  }

  void addSolute(double deltaVolume) {
    if (deltaVolume <= 0) return;
    final minV = PhScaleConstants.minVolume;
    soluteVolume =
        mathMax(minV, soluteVolume + mathMin(deltaVolume, freeVolume));
    notifyListeners();
  }

  void addWater(double deltaVolume) {
    if (deltaVolume <= 0) return;
    final minV = PhScaleConstants.minVolume;
    waterVolume =
        mathMax(minV, waterVolume + mathMin(deltaVolume, freeVolume));
    notifyListeners();
  }

  /// Drain equal percentages of water and solute atomically.
  void drainSolution(double deltaVolume) {
    if (deltaVolume <= 0) return;
    final total = totalVolume;
    if (total <= 0) return;
    final minV = PhScaleConstants.minVolume;
    if (total - deltaVolume < minV) {
      _setVolumeAtomic(0, 0);
    } else {
      _setVolumeAtomic(
        waterVolume - (deltaVolume * waterVolume / total),
        soluteVolume - (deltaVolume * soluteVolume / total),
      );
    }
  }

  void _setVolumeAtomic(double nextWater, double nextSolute) {
    final bothChanging =
        nextWater != waterVolume && nextSolute != soluteVolume;
    if (bothChanging) {
      _cachedPH = pH;
      _cachedColor = color;
      _ignoreVolumeUpdate = true;
    }
    waterVolume = nextWater;
    if (bothChanging) {
      _ignoreVolumeUpdate = false;
      _cachedPH = null;
      _cachedColor = null;
    }
    soluteVolume = nextSolute;
    notifyListeners();
  }

  void reset({double soluteVolume = 0, double waterVolume = 0}) {
    this.soluteVolume = soluteVolume;
    this.waterVolume = waterVolume;
    notifyListeners();
  }

  static double mathMin(double a, double b) => a < b ? a : b;
  static double mathMax(double a, double b) => a > b ? a : b;
}
