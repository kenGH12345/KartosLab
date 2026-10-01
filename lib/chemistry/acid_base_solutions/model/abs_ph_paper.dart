import 'dart:math' as math;
import 'dart:ui';

import 'abs_beaker.dart';
import 'abs_colors.dart';
import 'abs_constants.dart';
import 'solutions/aqueous_solution.dart';

/// pH paper — PhET `PHPaper.ts` + float animation from `PHPaperNode.step`.
class AbsPhPaper {
  AbsPhPaper({
    required this.beaker,
    required this.pHOfSolution,
    required this.solution,
  })  : paperSize = const Size(16, 110),
        _position = Offset(beaker.right - 60, beaker.top - 10),
        _initialPosition = Offset(beaker.right - 60, beaker.top - 10) {
    _dragBounds = Rect.fromLTRB(
      beaker.left + paperSize.width / 2 + _beakerMargin,
      beaker.top - 20,
      beaker.right - paperSize.width / 2 - _beakerMargin,
      beaker.bottom - _beakerMargin,
    );
  }

  static const double _beakerMargin = 5;

  final AbsBeaker beaker;
  final double Function() pHOfSolution;
  final AqueousSolution Function() solution;

  final Size paperSize;
  late final Rect _dragBounds;

  Offset _position;
  final Offset _initialPosition;

  /// Percentage of paper colored [0, 1] — monotonically increases while dipped.
  double percentColored = 0;

  /// True while auto-floating toward the surface after release.
  bool animating = false;

  Offset get position => _position;

  set position(Offset value) {
    _position = Offset(
      value.dx.clamp(_dragBounds.left, _dragBounds.right),
      value.dy.clamp(_dragBounds.top, _dragBounds.bottom),
    );
    updateIndicatorHeight();
  }

  Rect get dragBounds => _dragBounds;

  /// Y of the top of the paper (origin = bottom-center).
  double get top => _position.dy - paperSize.height;

  Color get color => AbsColors.pHToColor(pHOfSolution());

  /// Called when solution or pH changes — clears indicator.
  void onSolutionOrPhChanged() {
    percentColored = 0;
    updateIndicatorHeight();
  }

  /// Indicator height only increases while dipped (`PHPaper.ts`).
  void updateIndicatorHeight() {
    if (beaker.containsPoint(_position)) {
      final min = percentColored;
      final percent = (_position.dy - beaker.top + 5) / paperSize.height;
      percentColored = percent.clamp(min, 1.0);
    }
  }

  /// View-layer drag pressed state drives whether float animation runs.
  void step(double dt, {required bool isPressed}) {
    if (!isPressed) {
      final minY = beaker.top + (0.6 * paperSize.height);
      if ((animating && _position.dy > minY) || (top > beaker.top)) {
        animating = true;
        final dy = dt * AbsConstants.phPaperFloatSpeed;
        final y = math.max(minY, _position.dy - dy);
        _position = Offset(_position.dx, y);
      }
    } else {
      animating = false;
    }
  }

  void reset() {
    percentColored = 0;
    _position = _initialPosition;
    animating = false;
  }
}
