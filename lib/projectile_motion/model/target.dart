import '../pm_constants.dart';

/// PhET `Target.ts`：靶心位置 + 命中计分（Target.ts:65-78）。
class PmTarget {
  PmTarget({double initialX = PmConstants.targetXDefault})
      : x = initialX,
        _initialX = initialX;

  double x;
  final double _initialX;

  /// 命中时回调星数（3/2/1），未命中不回调。
  void Function(int stars)? onScored;

  void reset() => x = _initialX;

  bool checkIfHitTarget(double projectileX) {
    final distance = (projectileX - x).abs();
    final hasHit = distance <= PmConstants.targetWidth / 2;
    if (distance <= PmConstants.targetWidth / 6) {
      onScored?.call(3);
    } else if (distance <= PmConstants.targetWidth / 3) {
      onScored?.call(2);
    } else if (distance <= PmConstants.targetWidth / 2) {
      onScored?.call(1);
    }
    return hasHit;
  }
}
