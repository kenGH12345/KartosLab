import '../model/enums.dart';
import '../model/root_vector.dart';
import '../model/va_vec.dart';
import '../model/vector.dart';

/// Non-interactive component vector — mirrors PhET `ComponentVector.ts`.
class ComponentVector extends RootVector {
  ComponentVector({
    required this.parent,
    required this.componentType,
    required this.styleOf,
  }) : super(
          tailPosition: parent.tailPosition,
          xyComponents: VaVec.zero,
          symbol: '',
        );

  final VaVector parent;
  final ComponentVectorType componentType;
  final ComponentVectorStyle Function() styleOf;

  double projectionXOffset = 0;
  double projectionYOffset = 0;

  bool get isOnGraph => parent.isOnGraph;

  void setProjectionOffsets(double x, double y) {
    projectionXOffset = x;
    projectionYOffset = y;
    update();
  }

  void update() {
    final style = styleOf();
    final parentTail = parent.tailPosition;
    final parentTip = parent.tip;

    if (componentType == ComponentVectorType.xComponent) {
      if (style == ComponentVectorStyle.triangle ||
          style == ComponentVectorStyle.parallelogram) {
        tailPosition = parentTail;
        setTip(VaVec(parentTip.x, parentTail.y));
      } else if (style == ComponentVectorStyle.projection) {
        tailPosition = VaVec(parentTail.x, projectionYOffset);
        // setTip keeps tail — set xy directly for clarity
        xyComponents = VaVec(parentTip.x - parentTail.x, 0);
        // tip y must stay on projectionYOffset
        // xy = tip - tail => tip = (parentTip.x, projectionYOffset)
        // already have tail at (parentTail.x, projectionYOffset)
        xyComponents = VaVec(parentTip.x - parentTail.x, 0);
      } else {
        // invisible — still keep triangle-like components for magnitude readout
        tailPosition = parentTail;
        xyComponents = VaVec(parent.xComponent, 0);
      }
    } else {
      if (style == ComponentVectorStyle.triangle) {
        // Shared tip with parent; tail at (parentTip.x, parentTail.y)
        // Setting tip first then tail via RootVector APIs is awkward;
        // set fields to match PhET setTip/setTail order.
        final sharedTip = parentTip;
        tailPosition = VaVec(parentTip.x, parentTail.y);
        xyComponents = sharedTip - tailPosition;
      } else if (style == ComponentVectorStyle.parallelogram) {
        tailPosition = parentTail;
        setTip(VaVec(parentTail.x, parentTip.y));
      } else if (style == ComponentVectorStyle.projection) {
        tailPosition = VaVec(projectionXOffset, parentTail.y);
        xyComponents = VaVec(0, parentTip.y - parentTail.y);
      } else {
        tailPosition = parentTail;
        xyComponents = VaVec(0, parent.yComponent);
      }
    }
  }

  /// Scalar shown on label (may be negative); null if values hidden or zero.
  double? labelMagnitude(bool valuesVisible) {
    final mag = componentType == ComponentVectorType.xComponent
        ? xyComponents.x
        : xyComponents.y;
    if (!valuesVisible || mag == 0) return null;
    return mag;
  }
}
