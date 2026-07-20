import 'dart:math' as math;
import 'dart:ui';

import 'optics_state.dart';

class RayPath {
  const RayPath({
    required this.points,
    this.virtualPoints = const [],
    this.isBoundary = false,
  });

  final List<Offset> points;
  final List<Offset> virtualPoints;
  final bool isBoundary;
}

class SolvedOptics {
  const SolvedOptics({
    required this.focalLength,
    required this.objectPoint,
    required this.imagePoint,
    required this.imageHeight,
    required this.imageX,
    required this.isVirtual,
    required this.rays,
  });

  final double focalLength;
  final Offset objectPoint;
  final Offset imagePoint;
  final double imageHeight;
  final double imageX;
  final bool isVirtual;
  final List<RayPath> rays;
}

class OpticsSolver {
  static const double elementX = 0;

  SolvedOptics solve(OpticsState state) {
    return switch (state.mode) {
      SimMode.lens => _solveLens(state),
      SimMode.mirror => _solveMirror(state),
    };
  }

  SolvedOptics _solveLens(OpticsState state) {
    final sign = state.lensKind == LensKind.convex ? 1.0 : -1.0;
    final focalLength =
        sign * state.radius / (2 * math.max(0.1, state.refractiveIndex - 1));
    final objectDistance = elementX - state.objectX;
    final imageDistance = _imageDistance(objectDistance, focalLength);
    final imageX = elementX + imageDistance;
    final magnification = -imageDistance / objectDistance;
    final imageHeight = state.objectHeight * magnification;
    final isVirtual = imageDistance < 0;
    final objectPoint = Offset(state.objectX, -state.objectHeight);
    final imagePoint = Offset(imageX, -imageHeight);

    return SolvedOptics(
      focalLength: focalLength,
      objectPoint: objectPoint,
      imagePoint: imagePoint,
      imageHeight: imageHeight,
      imageX: imageX,
      isVirtual: isVirtual,
      rays: _lensRays(state, objectPoint, imagePoint, isVirtual),
    );
  }

  SolvedOptics _solveMirror(OpticsState state) {
    final focalLength = switch (state.mirrorKind) {
      MirrorKind.concave => state.radius / 2,
      MirrorKind.convex => -state.radius / 2,
      MirrorKind.plane => double.infinity,
    };

    final objectDistance = elementX - state.objectX;
    final imageDistance = focalLength.isInfinite
        ? -objectDistance
        : _imageDistance(objectDistance, focalLength);
    final imageX = elementX - imageDistance;
    final magnification = focalLength.isInfinite
        ? 1.0
        : -imageDistance / objectDistance;
    final imageHeight = state.objectHeight * magnification;
    final isVirtual = imageDistance < 0 || focalLength.isInfinite;
    final objectPoint = Offset(state.objectX, -state.objectHeight);
    final imagePoint = Offset(imageX, -imageHeight);

    return SolvedOptics(
      focalLength: focalLength,
      objectPoint: objectPoint,
      imagePoint: imagePoint,
      imageHeight: imageHeight,
      imageX: imageX,
      isVirtual: isVirtual,
      rays: _mirrorRays(state, objectPoint, imagePoint, isVirtual),
    );
  }

  double _imageDistance(double objectDistance, double focalLength) {
    final denominator = (1 / focalLength) - (1 / objectDistance);
    if (denominator.abs() < 0.002) {
      return denominator.isNegative ? -900 : 900;
    }
    return (1 / denominator).clamp(-900, 900);
  }

  List<RayPath> _lensRays(
    OpticsState state,
    Offset objectPoint,
    Offset imagePoint,
    bool isVirtual,
  ) {
    final lensHalf = state.diameter / 2;
    final sampleY = switch (state.rayMode) {
      RayMode.edge => [-lensHalf, 0.0, lensHalf],
      RayMode.principal => [-lensHalf * 0.72, 0.0, lensHalf * 0.72],
      RayMode.many => [
        -lensHalf,
        -lensHalf * 0.66,
        -lensHalf * 0.33,
        0.0,
        lensHalf * 0.33,
        lensHalf * 0.66,
        lensHalf,
      ],
      RayMode.none => <double>[],
    };

    return [
      for (final y in sampleY)
        if (isVirtual)
          RayPath(
            points: [
              objectPoint,
              Offset(elementX, y),
              _extendFrom(Offset(elementX, y), Offset(460, y - 28), 460),
            ],
            virtualPoints: [Offset(elementX, y), imagePoint],
            isBoundary: y.abs() == lensHalf,
          )
        else
          RayPath(
            points: [
              objectPoint,
              Offset(elementX, y),
              imagePoint,
              _extendFrom(imagePoint, imagePoint - Offset(elementX, y), 380),
            ],
            isBoundary: y.abs() == lensHalf,
          ),
    ];
  }

  List<RayPath> _mirrorRays(
    OpticsState state,
    Offset objectPoint,
    Offset imagePoint,
    bool isVirtual,
  ) {
    final half = state.diameter / 2;
    final sampleY = switch (state.rayMode) {
      RayMode.edge => [-half, 0.0, half],
      RayMode.principal => [-half * 0.72, 0.0, half * 0.72],
      RayMode.many => [
        -half,
        -half * 0.66,
        -half * 0.33,
        0.0,
        half * 0.33,
        half * 0.66,
        half,
      ],
      RayMode.none => <double>[],
    };

    return [
      for (final y in sampleY)
        if (isVirtual)
          RayPath(
            points: [
              objectPoint,
              Offset(elementX, y),
              _extendFrom(Offset(elementX, y), Offset(-360, y - 80), 360),
            ],
            virtualPoints: [Offset(elementX, y), imagePoint],
            isBoundary: y.abs() == half,
          )
        else
          RayPath(
            points: [
              objectPoint,
              Offset(elementX, y),
              imagePoint,
              _extendFrom(imagePoint, imagePoint - Offset(elementX, y), 260),
            ],
            isBoundary: y.abs() == half,
          ),
    ];
  }

  Offset _extendFrom(Offset start, Offset direction, double length) {
    final d = math.sqrt(
      direction.dx * direction.dx + direction.dy * direction.dy,
    );
    if (d == 0) {
      return start;
    }
    return Offset(
      start.dx + direction.dx / d * length,
      start.dy + direction.dy / d * length,
    );
  }
}
