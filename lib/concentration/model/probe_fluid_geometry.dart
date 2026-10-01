import 'dart:ui';

import 'beaker.dart';
import 'concentration_constants.dart';
import 'concentration_solution.dart';
import 'dropper_model.dart';
import 'faucet_model.dart';
import 'probe_region.dart';
import 'solute_form.dart';

/// Fluid shape intersection for the concentration probe.
///
/// Mirrors beers-law-lab `ConcentrationProbeNode.isInNode` /
/// `ConcentrationMeterNode.updateValue`: probe **position** (sensor center)
/// against axis-aligned fluid rectangles derived from the same geometry as
/// SolutionNode / FaucetFluidNode / StockSolutionNode.
///
/// Priority (source):
/// 1. solution OR drain → solution reading
/// 2. solvent (water) stream → 0
/// 3. stock stream → stock concentration
/// 4. else → null
abstract final class ProbeFluidGeometry {
  /// Dropper stock stream tip width — `StockSolutionNode` / EyeDropper tip.
  static const double stockTipWidth = 14;

  /// Returns true when [point] is inside a non-degenerate [rect].
  /// Source issue #65: empty (zero-size) shapes never contain.
  static bool containsPoint(Offset point, Rect rect) {
    if (rect.width <= 0 || rect.height <= 0) return false;
    return rect.contains(point);
  }

  /// Solution rectangle — same as [SolutionNode] liquid.
  static Rect solutionRect({
    required Beaker beaker,
    required double volume,
  }) {
    if (volume <= 0) return Rect.zero;
    var h = (volume / beaker.volume) * beaker.size.height;
    if (h < ConcentrationConstants.minNonzeroSolutionHeight) {
      h = ConcentrationConstants.minNonzeroSolutionHeight;
    }
    return Rect.fromLTWH(
      beaker.left,
      beaker.position.dy - h,
      beaker.size.width,
      h,
    );
  }

  /// Solvent faucet stream — `FaucetFluidNode` for water.
  static Rect waterStreamRect({
    required FaucetModel faucet,
    required Beaker beaker,
  }) {
    if (faucet.flowRate <= 0 || faucet.maxFlowRate <= 0) return Rect.zero;
    final w = faucet.spoutWidth * (faucet.flowRate / faucet.maxFlowRate);
    final h = beaker.position.dy - faucet.position.dy;
    if (w <= 0 || h <= 0) return Rect.zero;
    return Rect.fromLTWH(
      faucet.position.dx - w / 2,
      faucet.position.dy,
      w,
      h,
    );
  }

  /// Drain faucet stream — `FaucetFluidNode` with `DRAIN_FLUID_HEIGHT`.
  static Rect drainStreamRect({
    required FaucetModel faucet,
  }) {
    if (faucet.flowRate <= 0 || faucet.maxFlowRate <= 0) return Rect.zero;
    final w = faucet.spoutWidth * (faucet.flowRate / faucet.maxFlowRate);
    if (w <= 0) return Rect.zero;
    return Rect.fromLTWH(
      faucet.position.dx - w / 2,
      faucet.position.dy,
      w,
      ConcentrationConstants.drainFluidHeight,
    );
  }

  /// Dropper stock stream — `StockSolutionNode`.
  static Rect stockStreamRect({
    required DropperModel dropper,
    required Beaker beaker,
    required SoluteForm soluteForm,
  }) {
    if (!dropper.isDispensing ||
        dropper.isEmpty ||
        !dropper.isVisible(soluteForm)) {
      return Rect.zero;
    }
    final h = beaker.position.dy - dropper.position.dy;
    if (h <= 0) return Rect.zero;
    return Rect.fromLTWH(
      dropper.position.dx - stockTipWidth / 2,
      dropper.position.dy,
      stockTipWidth,
      h,
    );
  }

  /// Source `updateValue` region selection from probe sensor position.
  static ProbeRegion detect({
    required Offset probePosition,
    required Beaker beaker,
    required ConcentrationSolution solution,
    required FaucetModel solventFaucet,
    required FaucetModel drainFaucet,
    required DropperModel dropper,
    required SoluteForm soluteForm,
  }) {
    final inSolution = containsPoint(
      probePosition,
      solutionRect(beaker: beaker, volume: solution.volume),
    );
    final inDrain = containsPoint(
      probePosition,
      drainStreamRect(faucet: drainFaucet),
    );
    if (inSolution || inDrain) {
      // Prefer labeling solution when both (same numeric reading).
      return inSolution ? ProbeRegion.solution : ProbeRegion.drainStream;
    }
    if (containsPoint(
      probePosition,
      waterStreamRect(faucet: solventFaucet, beaker: beaker),
    )) {
      return ProbeRegion.waterStream;
    }
    if (containsPoint(
      probePosition,
      stockStreamRect(
        dropper: dropper,
        beaker: beaker,
        soluteForm: soluteForm,
      ),
    )) {
      return ProbeRegion.stockSolution;
    }
    return ProbeRegion.none;
  }
}
