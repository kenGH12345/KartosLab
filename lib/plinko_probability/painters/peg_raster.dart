import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../plinko_colors.dart';
import '../plinko_constants.dart';

/// Runtime peg/shadow rasters — mirrors `PegsNode.js` `toCanvas` / `toImage`.
///
/// PhET has **no** peg PNG/SVG; it rasterizes Path + RadialGradient once, then
/// `drawImage`s the bitmaps. We do the same bake once and cache [ui.Image]s.
class PegRaster {
  PegRaster._();

  static ui.Image? circlePeg;
  static ui.Image? flatPeg;
  static ui.Image? shadow;

  /// Layout-space radius used when baking (PhET `largestPegRadius`).
  static double get bakeRadius =>
      PlinkoConstants.pegRadiusAtOneRow *
      (2 / (PlinkoConstants.rowsMin + 1)); // 50 when minRow=1

  static bool get isReady =>
      circlePeg != null && flatPeg != null && shadow != null;

  static Future<void> ensureLoaded({double pixelRatio = 2.0}) async {
    if (isReady) return;
    final r = bakeRadius;
    circlePeg = await _bakeCirclePeg(r, pixelRatio);
    flatPeg = await _bakeFlatPeg(r, pixelRatio);
    shadow = await _bakeShadow(r, pixelRatio);
  }

  static Future<ui.Image> _bakeCirclePeg(double r, double pr) async {
    final pad = 2.0;
    final logical = (r + pad) * 2;
    final size = (logical * pr).ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pr);
    canvas.translate(logical / 2, logical / 2);
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()..color = PlinkoColors.peg,
    );
    final picture = recorder.endRecording();
    return picture.toImage(size, size);
  }

  /// Flat-top peg: kite `arc(0,0,r,-0.75π,-0.25π,true)` then fill (chord close).
  static Future<ui.Image> _bakeFlatPeg(double r, double pr) async {
    final pad = 2.0;
    final logical = (r + pad) * 2;
    final size = (logical * pr).ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pr);
    canvas.translate(logical / 2, logical / 2);
    // Anticlockwise 270° from -0.75π → -0.25π ≡ sweep +1.5π in Flutter (CCW).
    final path = Path()
      ..moveTo(r * math.cos(-0.75 * math.pi), r * math.sin(-0.75 * math.pi))
      ..arcToPoint(
        Offset(
          r * math.cos(-0.25 * math.pi),
          r * math.sin(-0.25 * math.pi),
        ),
        radius: Radius.circular(r),
        largeArc: true,
        clockwise: false,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = PlinkoColors.peg);
    final picture = recorder.endRecording();
    return picture.toImage(size, size);
  }

  /// `shadowNode` Circle(1.4r) + RadialGradient matching PegsNode.js.
  static Future<ui.Image> _bakeShadow(double r, double pr) async {
    final shadowR = 1.4 * r;
    final pad = 2.0;
    final logical = (shadowR + pad) * 2;
    final size = (logical * pr).ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pr);
    canvas.translate(logical / 2, logical / 2);

    const stops = <double>[
      0.0,
      0.1809,
      0.3135,
      0.4307,
      0.539,
      0.6412,
      0.7388,
      0.8328,
      0.9217,
      1.0,
    ];
    const colors = <Color>[
      Color.fromRGBO(0, 0, 0, 1),
      Color.fromRGBO(3, 3, 3, 0.8191),
      Color.fromRGBO(12, 12, 12, 0.6865),
      Color.fromRGBO(28, 28, 28, 0.5693),
      Color.fromRGBO(48, 48, 48, 0.461),
      Color.fromRGBO(80, 80, 80, 0.3588),
      Color.fromRGBO(116, 116, 116, 0.2612),
      Color.fromRGBO(158, 158, 158, 0.1672),
      Color.fromRGBO(206, 206, 206, 0.0783),
      Color.fromRGBO(255, 255, 255, 0),
    ];

    // Scenery RadialGradient(x0,y0,r0, x1,y1,r1):
    //   start (0.3r, 0.5r, 0) → end (0.1r, -0.6r, 1.4r)
    final shader = ui.Gradient.radial(
      Offset(r * 0.1, -r * 0.6),
      shadowR,
      colors,
      stops,
      TileMode.clamp,
      null,
      Offset(r * 0.3, r * 0.5),
      0,
    );
    canvas.drawCircle(
      Offset.zero,
      shadowR,
      Paint()..shader = shader,
    );
    final picture = recorder.endRecording();
    return picture.toImage(size, size);
  }
}
