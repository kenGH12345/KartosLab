import 'package:flutter/material.dart';
import '../model/sound_state.dart';

/// 球面波俯视图 painter（完整 360°）。
///
/// 把 [SoundState.amplitudes] 一维数组投影为同心圆环，灰度随振幅：
/// - 128 中灰 = 静止
/// - →255 亮 = 压缩区（正压）
/// - →0 暗 = 稀疏区（负压）
class SphericalViewPainter extends CustomPainter {
  SphericalViewPainter(this.state);

  final SoundState state;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0B1220);
    canvas.drawRect(Offset.zero & size, bg);
    _drawGrid(canvas, size);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = (size.shortestSide / 2) * 0.92;

    final amps = state.amplitudes;
    final n = amps.length;
    final pixelStep = maxR / n;

    for (int i = n - 1; i >= 0; i--) {
      final r = pixelStep + i * pixelStep;
      final color = _amplitudeToColor(amps[i]);
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = pixelStep + 0.6;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    _drawSpeaker(canvas, cx, cy);
  }

  Color _amplitudeToColor(double amp) {
    final int gray = (128 + amp * 127).clamp(0, 255).round();
    return Color.fromARGB(255, gray, gray, gray);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0x22334155)
      ..strokeWidth = 0.6;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  void _drawSpeaker(Canvas canvas, double x, double y) {
    canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(x, y),
      5,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant SphericalViewPainter oldDelegate) => true;
}
