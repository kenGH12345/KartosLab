import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/lattice.dart';
import '../model/scene_kind.dart';
import '../waves_intro_constants.dart';

/// Heatmap of lattice values — one `drawVertices` (PhET `CanvasNode` / ImageData).
///
/// Do **not** `drawRect` per cell: 111² fills at 60 fps is the device stutter.
class LatticePainter extends CustomPainter {
  LatticePainter({
    required this.lattice,
    required this.kind,
    this.wavelengthNm,
  });

  final Lattice lattice;
  final SceneKind kind;
  final double? wavelengthNm;

  static Float32List? _positions;
  static Int32List? _colors;
  static List<Color>? _lut;
  static SceneKind? _lutKind;
  static int? _lutArgb;

  @override
  void paint(Canvas canvas, Size size) {
    final visW = lattice.visibleMaxX - lattice.visibleMinX;
    final visH = lattice.visibleMaxY - lattice.visibleMinY;
    if (visW <= 0 || visH <= 0) return;

    final cellW = size.width / visW;
    final cellH = size.height / visH;
    final vertCount = visW * visH * 6;
    final posLen = vertCount * 2;
    if (_positions == null || _positions!.length < posLen) {
      _positions = Float32List(posLen);
      _colors = Int32List(vertCount);
    }
    final pos = _positions!;
    final cols = _colors!;
    _ensureLut();

    var pi = 0;
    var ci = 0;
    for (var i = 0; i < visW; i++) {
      final x0 = i * cellW;
      final x1 = x0 + cellW + 0.25;
      final gi = i + lattice.visibleMinX;
      for (var j = 0; j < visH; j++) {
        final y0 = j * cellH;
        final y1 = y0 + cellH + 0.25;
        final v = lattice.getInterpolatedValue(gi, j + lattice.visibleMinY);
        var argb = _lut![_lutIndex(v)].toARGB32();
        if (kind == SceneKind.light &&
            !lattice.hasCellBeenVisited(gi, j + lattice.visibleMinY)) {
          argb = 0xFF000000;
        }
        pos[pi++] = x0;
        pos[pi++] = y0;
        pos[pi++] = x1;
        pos[pi++] = y0;
        pos[pi++] = x1;
        pos[pi++] = y1;
        pos[pi++] = x0;
        pos[pi++] = y0;
        pos[pi++] = x1;
        pos[pi++] = y1;
        pos[pi++] = x0;
        pos[pi++] = y1;
        for (var k = 0; k < 6; k++) {
          cols[ci++] = argb;
        }
      }
    }

    canvas.drawVertices(
      ui.Vertices.raw(
        VertexMode.triangles,
        Float32List.sublistView(pos, 0, posLen),
        colors: Int32List.sublistView(cols, 0, vertCount),
      ),
      BlendMode.srcOver,
      Paint(),
    );
  }

  void _ensureLut() {
    final nm = wavelengthNm ??
        WavesIntroConstants.wavelength(
          waveSpeedValue: WavesIntroConstants.lightWaveSpeed,
          frequency: WavesIntroConstants.rangeMidpoint(
            WavesIntroConstants.lightFreqMin,
            WavesIntroConstants.lightFreqMax,
          ),
        );
    final argb = WavesIntroConstants.wavelengthToArgb(nm);
    if (_lut != null && _lutKind == kind && _lutArgb == argb) return;
    _lutKind = kind;
    _lutArgb = argb;
    _lut = List<Color>.generate(257, (i) {
      final v = i / 256.0 * 4.0 - 2.0;
      return _colorForValue(v, argb);
    });
  }

  static int _lutIndex(double v) {
    final t = v.clamp(-2.0, 2.0);
    return ((t + 2) / 4 * 256).round().clamp(0, 256);
  }

  Color _colorForValue(double waveValue, int lightArgb) {
    final base = switch (kind) {
      SceneKind.water =>
        const Color(WavesIntroConstants.waterLatticeBaseArgb),
      SceneKind.sound => Colors.white,
      SceneKind.light => Color(lightArgb),
    };
    const cutoff = WavesIntroConstants.latticeCutoff;
    const minShade = WavesIntroConstants.latticeMinShade;
    final intensity = waveValue > 0
        ? WavesIntroConstants.linear(0, 2, cutoff, 1, waveValue)
            .clamp(cutoff, 1.0)
        : WavesIntroConstants.linear(-1.5, 0, minShade, cutoff, waveValue)
            .clamp(minShade, cutoff);
    return Color.fromARGB(
      255,
      (base.r * 255 * intensity).round().clamp(0, 255),
      (base.g * 255 * intensity).round().clamp(0, 255),
      (base.b * 255 * intensity).round().clamp(0, 255),
    );
  }

  @override
  bool shouldRepaint(covariant LatticePainter oldDelegate) => true;
}
