// Copyright 2024-2026, University of Colorado Boulder
/// CoinNode 是显示硬币两面的基础 Widget
/// 通过 crossFade 参数实现两面之间的交叉淡入淡出效果
///
/// 对应官方：js/coins/view/CoinNode.ts
library;


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _defaultMarginFactor = 0.1;

/// 硬币面参数
class CoinFaceParameters {
  final Color? stroke;
  final Color? fill;
  final Widget? content;
  final double minXMarginFactor;
  final double minYMarginFactor;

  const CoinFaceParameters({
    this.stroke,
    this.fill,
    this.content,
    this.minXMarginFactor = _defaultMarginFactor,
    this.minYMarginFactor = _defaultMarginFactor,
  });
}

/// 硬币节点 Widget
class CoinNode extends StatelessWidget {
  final double radius;
  final ValueListenable<double> crossFadeNotifier;
  final List<CoinFaceParameters> coinFaceParameters; // [face0, face1]

  const CoinNode({
    super.key,
    required this.radius,
    required this.crossFadeNotifier,
    required this.coinFaceParameters,
  }) : assert(coinFaceParameters.length == 2);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: crossFadeNotifier,
      builder: (context, crossFade, child) {
        return SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Face 0
              Opacity(
                opacity: crossFade,
                child: _buildCoinFace(coinFaceParameters[0]),
              ),
              // Face 1
              Opacity(
                opacity: 1.0 - crossFade,
                child: _buildCoinFace(coinFaceParameters[1]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoinFace(CoinFaceParameters params) {
    final lineWidth = (radius / 6).floor().toDouble();
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // 硬币圆圈
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: params.fill,
            border: params.stroke != null
                ? Border.all(color: params.stroke!, width: lineWidth)
                : null,
          ),
        ),
        // 内容（箭头等）
        if (params.content != null)
          _buildScaledContent(params),
      ],
    );
  }

  Widget _buildScaledContent(CoinFaceParameters params) {
    // 计算内容可用空间
    final availableWidth = 2 * radius * (1 - params.minXMarginFactor);
    final availableHeight = 2 * radius * (1 - params.minYMarginFactor);
    
    return SizedBox(
      width: availableWidth,
      height: availableHeight,
      child: FittedBox(
        fit: BoxFit.contain,
        child: params.content,
      ),
    );
  }
}
