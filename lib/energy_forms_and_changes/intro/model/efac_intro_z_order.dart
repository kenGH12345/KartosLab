import 'package:kratos/energy_forms_and_changes/common/model/beaker.dart';
import 'package:kratos/energy_forms_and_changes/common/model/model_rect.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/thermal_block.dart';

/// PhET `EFACIntroScreenView` block / beaker z-order rules (source-faithful).
///
/// Evidence: `js/intro/view/EFACIntroScreenView.ts` blockChangeListener /
/// beakerChangeListener + `BeakerView.moveToFront` (back+front+grab).
class EfacIntroZOrder {
  EfacIntroZOrder._();

  /// Comparator for two blocks: positive → [a] should be in front of [b].
  ///
  /// Rules (model Y-up):
  /// 1. Completely to the right of the other → in front
  /// 2. Else if X-overlap: higher `bounds.minY` → in front
  static int compareBlocks(ModelRect a, ModelRect b) {
    if (a.minX >= b.maxX) return 1;
    if (a.maxX <= b.minX) return -1;
    if (a.minY > b.minY) return 1;
    if (b.minY > a.minY) return -1;
    return 0;
  }

  /// Assigns `zIndex = 0..n-1` (higher = more in front), matching PhET.
  static void applyBlockZIndices(List<ThermalBlock> blocks) {
    if (blocks.length <= 1) {
      if (blocks.length == 1) blocks.first.zIndex = 0;
      return;
    }
    final ordered = [...blocks]
      ..sort((a, b) => compareBlocks(a.bounds, b.bounds));
    for (var i = 0; i < ordered.length; i++) {
      ordered[i].zIndex = i;
    }
  }

  /// Beakers sorted back→front: higher `bounds.centerY` is in front (PhET).
  static List<Beaker> beakersBackToFront(List<Beaker> beakers) {
    if (beakers.length <= 1) return [...beakers];
    final ordered = [...beakers]
      ..sort((a, b) => a.bounds.center.dy.compareTo(b.bounds.center.dy));
    return ordered;
  }

  /// Blocks sorted back→front by [ThermalBlock.zIndex].
  static List<ThermalBlock> blocksBackToFront(List<ThermalBlock> blocks) {
    final ordered = [...blocks]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return ordered;
  }
}
