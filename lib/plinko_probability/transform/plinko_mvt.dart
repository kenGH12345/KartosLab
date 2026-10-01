import 'dart:ui';

import '../plinko_constants.dart';

/// Rectangle inverted-Y mapping —
/// `ModelViewTransform2.createRectangleInvertedYMapping(modelBoard, viewBoard)`.
///
/// PhET `ScreenView.DEFAULT_LAYOUT_BOUNDS`: **1024 × 618**
/// (not HomeScreen’s legacy 768×504).
/// Board face: **600 × 300**, origin at triangle top-center
/// (`hopper.centerX = layout.maxX/2 - 80`, `board.top = hopper.bottom + 10`).
class PlinkoMvt {
  PlinkoMvt({
    required this.viewBoardLeft,
    required this.viewBoardTop,
    required this.viewBoardWidth,
    required this.viewBoardHeight,
    required this.layoutScale,
    required this.layoutOriginX,
    required this.layoutOriginY,
  });

  final double viewBoardLeft;
  final double viewBoardTop;
  final double viewBoardWidth;
  final double viewBoardHeight;

  /// Canvas pixels per PhET layout pixel.
  final double layoutScale;
  final double layoutOriginX;
  final double layoutOriginY;

  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;
  static const double referenceBoardWidth = 600;
  static const double referenceBoardHeight = 300;
  static const double hopperCenterXLayout = layoutWidth / 2 - 80; // 432
  static const double hopperTopLayout = 10;
  static const double hopperThicknessLayout = 28;
  static const double hopperRimLayout = 3;
  static const double boardGapBelowHopper = 10;
  static const double panelRightPadding = 30;

  factory PlinkoMvt.fromCanvasSize(Size size) {
    final scaleX = size.width / layoutWidth;
    final scaleY = size.height / layoutHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final originX = (size.width - layoutWidth * scale) / 2;
    final originY = (size.height - layoutHeight * scale) / 2;

    final boardW = referenceBoardWidth * scale;
    final boardH = referenceBoardHeight * scale;
    final hopperCenterX = originX + hopperCenterXLayout * scale;
    final hopperTop = originY + hopperTopLayout * scale;
    final hopperHeight = (hopperThicknessLayout + hopperRimLayout) * scale;
    final boardTop = hopperTop + hopperHeight + boardGapBelowHopper * scale;
    final boardLeft = hopperCenterX - boardW / 2;

    return PlinkoMvt(
      viewBoardLeft: boardLeft,
      viewBoardTop: boardTop,
      viewBoardWidth: boardW,
      viewBoardHeight: boardH,
      layoutScale: scale,
      layoutOriginX: originX,
      layoutOriginY: originY,
    );
  }

  Offset layoutToView(Offset layout) => Offset(
        layoutOriginX + layout.dx * layoutScale,
        layoutOriginY + layout.dy * layoutScale,
      );

  double layoutToViewDelta(double d) => d * layoutScale;

  double get scaleX =>
      viewBoardWidth / PlinkoConstants.boardWidth;

  double get scaleY =>
      viewBoardHeight /
      (PlinkoConstants.boardMaxY - PlinkoConstants.boardMinY);

  Offset modelToView(Offset m) {
    final nx = (m.dx - PlinkoConstants.boardMinX) / PlinkoConstants.boardWidth;
    final ny = (PlinkoConstants.boardMaxY - m.dy) /
        (PlinkoConstants.boardMaxY - PlinkoConstants.boardMinY);
    return Offset(
      viewBoardLeft + nx * viewBoardWidth,
      viewBoardTop + ny * viewBoardHeight,
    );
  }

  double modelToViewDeltaX(double dx) => dx * scaleX;

  /// Inverted-Y: positive model-up becomes negative view-down.
  double modelToViewDeltaY(double dy) => -dy * scaleY;

  double modelToViewRadius(double modelRadius) => modelRadius * scaleX;
}
