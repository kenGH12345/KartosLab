import 'package:kratos/energy_skate_park/model/control_point.dart';
import 'package:kratos/energy_skate_park/model/track.dart';

/// PremadeTracks.ts — control-point coordinates for set tracks.
class PremadeTracks {
  PremadeTracks._();

  static const double endBoundsWidth = 2.5;
  static const double endBoundsHeight = 4;

  static List<ControlPoint> createParabolaControlPoints({
    double trackHeight = 6,
    double trackWidth = 8,
  }) {
    final p1x = -trackWidth / 2;
    final p1y = trackHeight;
    final p2x = 0.0;
    final p2y = 0.0;
    final p3x = trackWidth / 2;
    final p3y = trackHeight;

    return [
      ControlPoint(p1x, p1y),
      ControlPoint(p2x, p2y),
      ControlPoint(p3x, p3y),
    ];
  }

  static List<ControlPoint> createRampControlPoints({
    double trackWidth = 6,
    double trackHeight = 6,
  }) {
    return [
      ControlPoint(-4, trackHeight),
      ControlPoint(-2, 1.2),
      ControlPoint(-4 + trackWidth, 0),
    ];
  }

  static List<ControlPoint> createDoubleWellControlPoints({
    double trackHeight = 5,
    double trackWidth = 8,
    double trackMidHeight = 2,
  }) {
    return [
      ControlPoint(-trackWidth / 2, trackHeight),
      ControlPoint(-2, 0.0166015),
      ControlPoint(0, trackMidHeight),
      ControlPoint(2, 1),
      ControlPoint(trackWidth / 2, trackHeight),
    ];
  }

  static List<ControlPoint> createLoopControlPoints({
    double trackWidth = 9,
    double trackHeight = 6,
    double innerLoopWidth = 3,
    double innerLoopTop = 4,
  }) {
    const trackBottom = 0.3;
    const innerLoopHeight = 2.0;
    final loopTop = innerLoopTop;
    final loopWidth = trackWidth;

    return [
      ControlPoint(-loopWidth / 2, trackHeight),
      ControlPoint(-innerLoopWidth / 2, trackBottom),
      ControlPoint(innerLoopWidth / 2, innerLoopHeight),
      ControlPoint(0, loopTop),
      ControlPoint(-innerLoopWidth / 2, innerLoopHeight),
      ControlPoint(innerLoopWidth / 2, trackBottom),
      ControlPoint(loopWidth / 2, trackHeight),
    ];
  }

  static Track createTrack(
    List<ControlPoint> controlPoints, {
    bool physical = true,
    bool slopeToGround = false,
    bool draggable = false,
    bool configurable = false,
  }) {
    return Track(
      controlPoints,
      physical: physical,
      slopeToGround: slopeToGround,
      draggable: draggable,
      configurable: configurable,
    );
  }

  static Track createParabola({bool physical = true}) =>
      createTrack(createParabolaControlPoints(), physical: physical);

  static Track createRamp({bool physical = true}) =>
      createTrack(createRampControlPoints(), physical: physical);

  static Track createDoubleWell({bool physical = true}) =>
      createTrack(createDoubleWellControlPoints(), physical: physical);

  static Track createLoop({bool physical = true}) =>
      createTrack(createLoopControlPoints(), physical: physical);
}