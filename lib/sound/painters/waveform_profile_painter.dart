import 'dart:math';

import 'package:flutter/material.dart';
import '../model/sound_state.dart';

/// 一维波形剖面图 painter。
///
/// 用数学公式逐像素计算距离-压强曲线（而非读取离散振幅数组），
/// 保证三角函数级平滑（消除 propagationSpeed=3 引入的阶梯伪影）：
/// - 横轴 = 距离 r (m) · 0m ~ maxDistanceMeters
/// - 纵轴 = 压强偏移 ΔP · -A ~ +A
/// - 波峰（正压）用红色半透明填充 · 波谷（负压）用蓝色半透明填充
/// - 主曲线用白色描边
///
/// 视觉上呈现"衰减的正弦波"，与球面视图形成互补：
/// - 亮环 (球面) ↔ 波峰 (剖面)
/// - 暗环 (球面) ↔ 波谷 (剖面)
class WaveformProfilePainter extends CustomPainter {
  WaveformProfilePainter(
    this.state, {
    this.maxDistanceMeters = 10.0,
    this.padding = const EdgeInsets.fromLTRB(46, 24, 24, 40),
    this.soundSpeed = 343.0,
  });

  final SoundState state;
  final double maxDistanceMeters;
  final EdgeInsets padding;
  final double soundSpeed;

  static const _colorFillPos = Color(0x66E11D48); // 半透明红：压缩区（正压/波峰）
  static const _colorFillNeg = Color(0x663B82F6); // 半透明蓝：稀疏区（负压/波谷）
  static const _colorLine = Colors.white;
  static const _colorAxis = Color(0xFF64748B);
  static const _colorGrid = Color(0x22334155);
  static const _colorLabel = Color(0xFF94A3B8);
  static const _colorRuler = Color(0xFF60A5FA); // 蓝色 · 波长标尺

  @override
  void paint(Canvas canvas, Size size) {
    // 背景
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0B1220));

    final chartRect = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.horizontal,
      size.height - padding.vertical,
    );
    if (chartRect.width <= 0 || chartRect.height <= 0) return;

    _drawGrid(canvas, chartRect);
    _drawAxes(canvas, chartRect);
    _drawWave(canvas, chartRect);
    _drawXLabels(canvas, chartRect);
    _drawYLabels(canvas, chartRect);
    _drawSourceMarker(canvas, chartRect);
    _drawWavelengthRuler(canvas, chartRect);
    _drawWaveAnnotations(canvas, chartRect);
  }

  /// 波长标尺 · 位于图顶部，布局：标题在上 → 括号 → 数值在下。
  ///
  /// 教学价值：直观演示 频率↑ → 波长↓（标尺缩短）；
  /// 与曲线上任一个完整波峰-波峰间隔视觉对齐。
  void _drawWavelengthRuler(Canvas canvas, Rect r) {
    final f = state.frequency;
    if (f <= 1.0) return;
    final lambdaM = soundSpeed / f;
    if (lambdaM >= maxDistanceMeters) return;

    final pxPerMeter = r.width / maxDistanceMeters;
    final rulerLen = (lambdaM * pxPerMeter).clamp(60.0, r.width - 16);

    final startX = r.left + 8;
    final endX = startX + rulerLen;
    final titleY = r.top + 4;       // "波长标尺" 标题 · 图顶
    final bracketY = r.top + 16;    // 括号横线
    final valueY = r.top + 30;      // 数值在括号下方

    final rulerPaint = Paint()
      ..color = _colorRuler
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // 标题
    _paintText(canvas, '波长标尺', Offset(startX + rulerLen / 2 - 24, titleY),
        fontSize: 12, color: _colorRuler);

    // 括号横线
    canvas.drawLine(Offset(startX, bracketY), Offset(endX, bracketY), rulerPaint);

    // 两端竖杠
    final double tickH = 6;
    canvas.drawLine(Offset(startX, bracketY - tickH), Offset(startX, bracketY + tickH), rulerPaint);
    canvas.drawLine(Offset(endX, bracketY - tickH), Offset(endX, bracketY + tickH), rulerPaint);

    // 两端小横杠（形成 [  ] 括号）
    final double bracketW = 4;
    canvas.drawLine(Offset(startX - bracketW, bracketY - tickH), Offset(startX, bracketY - tickH), rulerPaint);
    canvas.drawLine(Offset(startX - bracketW, bracketY + tickH), Offset(startX, bracketY + tickH), rulerPaint);
    canvas.drawLine(Offset(endX, bracketY - tickH), Offset(endX + bracketW, bracketY - tickH), rulerPaint);
    canvas.drawLine(Offset(endX, bracketY + tickH), Offset(endX + bracketW, bracketY + tickH), rulerPaint);

    // 数值在括号下方
    _paintText(
      canvas,
      '${lambdaM.toStringAsFixed(2)} m',
      Offset(startX + rulerLen / 2 - 16, valueY),
      fontSize: 12,
      color: _colorRuler,
    );
  }

  /// 在波形曲线上标注"压缩区（正压/波峰）"和"稀疏区（负压/波谷）"。
  ///
  /// 根据公式 r_peak = c·(t + (4n+1)/(4f)) 计算第一个可见波峰位置，
  /// 根据公式 r_trough = c·(t + (4n+3)/(4f)) 计算第一个可见波谷位置。
  void _drawWaveAnnotations(Canvas canvas, Rect r) {
    final f = state.frequency;
    final A = state.amplitude;
    final t = state.time;
    if (f <= 0 || A < 0.02) return;

    final mid = r.center.dy;
    final halfH = r.height / 2;
    final pxPerMeter = r.width / maxDistanceMeters;

    // 第一个波峰（sin=+1）：r = c·(t + (4·0+1)/(4f)) = c·(t + 1/(4f))
    final rPeak0 = soundSpeed * (t + 1.0 / (4.0 * f));
    // 第一个波谷（sin=-1）：r = c·(t + 3/(4f))
    final rTrough0 = soundSpeed * (t + 3.0 / (4.0 * f));

    // 如果第一个在 0 左边（距离为负），取下一个周期
    final rPeak = rPeak0 < 0.2 ? soundSpeed * (t + 5.0 / (4.0 * f)) : rPeak0;
    final rTrough = rTrough0 < 0.2 ? soundSpeed * (t + 7.0 / (4.0 * f)) : rTrough0;

    // 确保在可见范围内且衰减不过于严重
    final double k = 0.30;
    final annotPaint = Paint()
      ..color = const Color(0xAAFFFFFF)
      ..strokeWidth = 1.0;

    if (rPeak > 0.2 && rPeak < maxDistanceMeters * 0.6) {
      final atten = 1.0 / (1.0 + rPeak * k);
      final py = mid - A * atten * halfH;
      final px = r.left + rPeak * pxPerMeter;
      final labelY = (py - 28).clamp(r.top + 2, mid - 20);

      canvas.drawLine(Offset(px, py), Offset(px, labelY + 8), annotPaint);
      canvas.drawLine(Offset(px - 14, labelY + 8), Offset(px + 14, labelY + 8), annotPaint);
      _paintText(canvas, '压缩区（正压/波峰）',
          Offset(px - 52, labelY - 2),
          fontSize: 10, color: const Color(0xFFFCA5A5));
    }

    if (rTrough > 0.2 && rTrough < maxDistanceMeters * 0.6) {
      final atten = 1.0 / (1.0 + rTrough * k);
      final py = mid + A * atten * halfH;
      final px = r.left + rTrough * pxPerMeter;
      final labelY = (py + 20).clamp(mid + 8, r.bottom - 4);

      canvas.drawLine(Offset(px, py), Offset(px, labelY - 4), annotPaint);
      canvas.drawLine(Offset(px - 14, labelY - 4), Offset(px + 14, labelY - 4), annotPaint);
      _paintText(canvas, '稀疏区（负压/波谷）',
          Offset(px - 52, labelY),
          fontSize: 10, color: const Color(0xFF93C5FD));
    }
  }

  void _drawGrid(Canvas canvas, Rect r) {
    final grid = Paint()
      ..color = _colorGrid
      ..strokeWidth = 0.6;
    // 垂直网格 · 每 1m 一条
    for (int m = 0; m <= maxDistanceMeters.toInt(); m++) {
      final x = r.left + (m / maxDistanceMeters) * r.width;
      canvas.drawLine(Offset(x, r.top), Offset(x, r.bottom), grid);
    }
    // 水平网格 · 中线 + ±0.5A
    final mid = r.center.dy;
    canvas.drawLine(Offset(r.left, mid), Offset(r.right, mid), grid);
    canvas.drawLine(Offset(r.left, mid - r.height * 0.25),
        Offset(r.right, mid - r.height * 0.25), grid);
    canvas.drawLine(Offset(r.left, mid + r.height * 0.25),
        Offset(r.right, mid + r.height * 0.25), grid);
  }

  void _drawAxes(Canvas canvas, Rect r) {
    final axis = Paint()
      ..color = _colorAxis
      ..strokeWidth = 1.0;
    // 中线（0 压强）加粗
    final mid = r.center.dy;
    canvas.drawLine(Offset(r.left, mid), Offset(r.right, mid),
        axis..color = const Color(0xFF475569));
    // 左侧 Y 轴
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left, r.bottom), axis);
  }

  /// 用数学公式逐像素计算波形（而非读取离散振幅数组）。
  ///
  /// 原因：SoundState.propagationSpeed=3 导致振幅数组中连续 3 个元素值相同，
  /// 直接绘制会产生阶梯状轮廓。计算式渲染绕开此限制，保证三角函数级平滑。
  ///
  /// 公式：y = A × 1/(1 + r·k) × sin(2π·f·(r/c − t))
  ///   r = 距声源距离 (m)
  ///   f = 频率 (Hz) · c = 声速 (m/s) · t = 仿真时间 (s)
  void _drawWave(Canvas canvas, Rect r) {
    final f = state.frequency;
    final A = state.amplitude;
    final t = state.time;

    final mid = r.center.dy;
    final halfH = r.height / 2;

    final posFill = Path()..moveTo(r.left, mid);
    final negFill = Path()..moveTo(r.left, mid);
    final line = Path();

    final stepCount = r.width.toInt().clamp(1, 2000);
    bool first = true;

    for (int px = 0; px <= stepCount; px++) {
      final x = r.left + px.toDouble();
      final distM = (px / stepCount) * maxDistanceMeters;

      // 球面衰减：1/(1 + r·k)，k=0.30 使 10m 处剩约 25%
      final attenuation = 1.0 / (1.0 + distM * 0.30);
      // 正弦波：sin(2π·f·(r/c − t))
      final phase = 2 * pi * f * (distM / soundSpeed - t);
      final y0 = A * attenuation * sin(phase);

      final y = mid - y0 * halfH;

      if (first) {
        line.moveTo(x, y);
        first = false;
      } else {
        line.lineTo(x, y);
      }

      if (y0 >= 0) {
        posFill.lineTo(x, y);
        negFill.lineTo(x, mid);
      } else {
        posFill.lineTo(x, mid);
        negFill.lineTo(x, y);
      }
    }

    posFill.lineTo(r.right, mid);
    posFill.close();
    negFill.lineTo(r.right, mid);
    negFill.close();

    canvas.drawPath(posFill, Paint()..color = _colorFillPos);
    canvas.drawPath(negFill, Paint()..color = _colorFillNeg);
    canvas.drawPath(
      line,
      Paint()
        ..color = _colorLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _drawXLabels(Canvas canvas, Rect r) {
    for (int m = 0; m <= maxDistanceMeters.toInt(); m += 2) {
      final x = r.left + (m / maxDistanceMeters) * r.width;
      _paintText(canvas, '${m}m', Offset(x - 8, r.bottom + 4), fontSize: 10);
    }
    _paintText(canvas, '距离 r (m)',
        Offset(r.center.dx - 26, r.bottom + 22),
        fontSize: 11, color: _colorLabel);
  }

  void _drawYLabels(Canvas canvas, Rect r) {
    _paintText(canvas, '+A', Offset(r.left - 22, r.top - 4), fontSize: 10);
    _paintText(canvas, '0', Offset(r.left - 12, r.center.dy - 6), fontSize: 10);
    _paintText(canvas, '-A', Offset(r.left - 22, r.bottom - 10), fontSize: 10);
    // 纵轴标题（旋转显示）
    canvas.save();
    canvas.translate(r.left - 34, r.center.dy + 24);
    canvas.rotate(-1.5708); // -π/2
    _paintText(canvas, '压强偏移 ΔP', const Offset(0, 0),
        fontSize: 11, color: _colorLabel);
    canvas.restore();
  }

  void _drawSourceMarker(Canvas canvas, Rect r) {
    // 声源图标 · 左端圆点 + "声源" 文字
    final mid = r.center.dy;
    canvas.drawCircle(Offset(r.left, mid), 4, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(r.left, mid),
      4,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    _paintText(canvas, '声源', Offset(r.left + 6, mid - 14),
        fontSize: 10, color: _colorLabel);
  }

  void _paintText(Canvas canvas, String text, Offset pos,
      {double fontSize = 12, Color color = _colorLabel}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant WaveformProfilePainter oldDelegate) => true;
}
