import 'dart:ui' show Offset, Path;

import '../transform/yaw_pitch_mvt.dart';

/// Four view-space corners of a box face (parallelogram / rectangle).
class BoxFacePoints {
  const BoxFacePoints(this.p0, this.p1, this.p2, this.p3);

  final Offset p0;
  final Offset p1;
  final Offset p2;
  final Offset p3;

  List<Offset> get points => [p0, p1, p2, p3];

  Path toPath() {
    return Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
  }
}

/// Creates 2D projections of 3D box faces —
/// `scenery-phet/.../BoxShapeCreator.js`
///
/// Origin is the center of the top face.
class BoxShapeCreator {
  BoxShapeCreator(this.modelViewTransform);

  final YawPitchMvt modelViewTransform;

  /// Top face parallelogram — js:47-55
  ///
  /// ```
  ///    p0 -------------- p1
  ///   /                /
  ///  /                /
  /// p3 --------------p2
  /// ```
  BoxFacePoints createTopFace(
    double x,
    double y,
    double z,
    double width,
    double height,
    double depth,
  ) {
    final p0 = modelViewTransform.modelToViewXYZ(
      x - (width / 2),
      y,
      z + (depth / 2),
    );
    final p1 = modelViewTransform.modelToViewXYZ(
      x + (width / 2),
      y,
      z + (depth / 2),
    );
    final p2 = modelViewTransform.modelToViewXYZ(
      x + (width / 2),
      y,
      z - (depth / 2),
    );
    final p3 = modelViewTransform.modelToViewXYZ(
      x - (width / 2),
      y,
      z - (depth / 2),
    );
    return BoxFacePoints(p0, p1, p2, p3);
  }

  /// Front face rectangle — js:85-93
  BoxFacePoints createFrontFace(
    double x,
    double y,
    double z,
    double width,
    double height,
    double depth,
  ) {
    final p0 = modelViewTransform.modelToViewXYZ(
      x - (width / 2),
      y,
      z - (depth / 2),
    );
    final p1 = modelViewTransform.modelToViewXYZ(
      x + (width / 2),
      y,
      z - (depth / 2),
    );
    final p2 = modelViewTransform.modelToViewXYZ(
      x + (width / 2),
      y + height,
      z - (depth / 2),
    );
    final p3 = modelViewTransform.modelToViewXYZ(
      x - (width / 2),
      y + height,
      z - (depth / 2),
    );
    return BoxFacePoints(p0, p1, p2, p3);
  }

  /// Right-side face parallelogram — js:130-137
  BoxFacePoints createRightSideFace(
    double x,
    double y,
    double z,
    double width,
    double height,
    double depth,
  ) {
    final p0 = modelViewTransform.modelToViewXYZ(
      x + (width / 2),
      y,
      z - (depth / 2),
    );
    final p1 = modelViewTransform.modelToViewXYZ(
      x + (width / 2),
      y,
      z + (depth / 2),
    );
    final p2 = modelViewTransform.modelToViewXYZ(
      x + (width / 2),
      y + height,
      z + (depth / 2),
    );
    final p3 = modelViewTransform.modelToViewXYZ(
      x + (width / 2),
      y + height,
      z - (depth / 2),
    );
    return BoxFacePoints(p0, p1, p2, p3);
  }
}
