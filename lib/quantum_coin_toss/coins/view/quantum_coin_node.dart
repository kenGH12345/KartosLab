// Copyright 2024-2026, University of Colorado Boulder
/// QuantumCoinNode 渲染量子硬币
/// 显示自旋向上、自旋向下或叠加态
///
/// 对应官方：js/coins/view/QuantumCoinNode.ts
library;


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../common/quantum_measurement_colors.dart';
import 'coin_node.dart';

const _minMarginFactor = 0.35;

class QuantumCoinNode extends StatefulWidget {
  final ValueListenable<String> coinStateNotifier;
  final ValueListenable<double> stateProbabilityNotifier;
  final double radius;
  final ValueNotifier<bool>? showSuperpositionNotifier;

  const QuantumCoinNode({
    super.key,
    required this.coinStateNotifier,
    required this.stateProbabilityNotifier,
    required this.radius,
    this.showSuperpositionNotifier,
  });

  @override
  State<QuantumCoinNode> createState() => _QuantumCoinNodeState();
}

class _QuantumCoinNodeState extends State<QuantumCoinNode> {
  late final ValueNotifier<bool> _showSuperposition;
  late final ValueNotifier<double> _crossFade;
  bool _ownsShowSuperposition = false;

  @override
  void initState() {
    super.initState();
    
    // showSuperposition 默认 true
    if (widget.showSuperpositionNotifier == null) {
      _showSuperposition = ValueNotifier(true);
      _ownsShowSuperposition = true;
    } else {
      _showSuperposition = widget.showSuperpositionNotifier!;
    }
    
    _crossFade = ValueNotifier(_computeCrossFade());
    
    // 监听三个属性变化
    widget.coinStateNotifier.addListener(_updateCrossFade);
    widget.stateProbabilityNotifier.addListener(_updateCrossFade);
    _showSuperposition.addListener(_updateCrossFade);
  }

  void _updateCrossFade() {
    _crossFade.value = _computeCrossFade();
  }

  double _computeCrossFade() {
    final coinState = widget.coinStateNotifier.value;
    final stateProbability = widget.stateProbabilityNotifier.value;
    final showSuperposition = _showSuperposition.value;
    
    if (showSuperposition) {
      return stateProbability; // 显示叠加态：使用概率值
    } else {
      return coinState == 'up' ? 1.0 : 0.0; // 离散态
    }
  }

  @override
  void dispose() {
    widget.coinStateNotifier.removeListener(_updateCrossFade);
    widget.stateProbabilityNotifier.removeListener(_updateCrossFade);
    _showSuperposition.removeListener(_updateCrossFade);
    _crossFade.dispose();
    if (_ownsShowSuperposition) {
      _showSuperposition.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arrowLength = widget.radius * 1.2;
    final headHeight = arrowLength / 3.5;
    final headWidth = arrowLength / 1.75;
    final tailWidth = arrowLength / 7;
    
    // Up 面参数
    final upFace = CoinFaceParameters(
      fill: QuantumMeasurementColors.upFill,
      stroke: QuantumMeasurementColors.upColor,
      content: CustomPaint(
        size: Size(headWidth, arrowLength),
        painter: _ArrowPainter(
          direction: AxisDirection.up,
          color: QuantumMeasurementColors.upColor,
          headHeight: headHeight,
          headWidth: headWidth,
          tailWidth: tailWidth,
        ),
      ),
      minYMarginFactor: _minMarginFactor,
    );
    
    // Down 面参数
    final downFace = CoinFaceParameters(
      fill: QuantumMeasurementColors.downFill,
      stroke: QuantumMeasurementColors.downColor,
      content: CustomPaint(
        size: Size(headWidth, arrowLength),
        painter: _ArrowPainter(
          direction: AxisDirection.down,
          color: QuantumMeasurementColors.downColor,
          headHeight: headHeight,
          headWidth: headWidth,
          tailWidth: tailWidth,
        ),
      ),
      minYMarginFactor: _minMarginFactor,
    );
    
    return CoinNode(
      radius: widget.radius,
      crossFadeNotifier: _crossFade,
      coinFaceParameters: [upFace, downFace],
    );
  }
}

/// 箭头 Painter（向上/向下）
class _ArrowPainter extends CustomPainter {
  final AxisDirection direction;
  final Color color;
  final double headHeight;
  final double headWidth;
  final double tailWidth;

  _ArrowPainter({
    required this.direction,
    required this.color,
    required this.headHeight,
    required this.headWidth,
    required this.tailWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final isUp = direction == AxisDirection.up;
    
    if (isUp) {
      // 向上箭头：从底部 (0, arrowLength) 到顶部 (0, 0)
      final tipY = 0.0;
      final baseY = size.height;
      final neckY = tipY + headHeight;
      
      path.moveTo(0, tipY); // 箭头尖
      path.lineTo(headWidth / 2, neckY); // 右侧头
      path.lineTo(tailWidth / 2, neckY); // 右侧尾
      path.lineTo(tailWidth / 2, baseY); // 右下
      path.lineTo(-tailWidth / 2, baseY); // 左下
      path.lineTo(-tailWidth / 2, neckY); // 左侧尾
      path.lineTo(-headWidth / 2, neckY); // 左侧头
      path.close();
    } else {
      // 向下箭头：从顶部 (0, 0) 到底部 (0, arrowLength)
      final tipY = size.height;
      final baseY = 0.0;
      final neckY = tipY - headHeight;
      
      path.moveTo(0, tipY); // 箭头尖
      path.lineTo(headWidth / 2, neckY); // 右侧头
      path.lineTo(tailWidth / 2, neckY); // 右侧尾
      path.lineTo(tailWidth / 2, baseY); // 右上
      path.lineTo(-tailWidth / 2, baseY); // 左上
      path.lineTo(-tailWidth / 2, neckY); // 左侧尾
      path.lineTo(-headWidth / 2, neckY); // 左侧头
      path.close();
    }
    
    canvas.save();
    canvas.translate(size.width / 2, 0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.color != color ||
        oldDelegate.headHeight != headHeight ||
        oldDelegate.headWidth != headWidth ||
        oldDelegate.tailWidth != tailWidth;
  }
}
