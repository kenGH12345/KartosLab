import 'package:flutter/material.dart';

import '../model/woas_end_type.dart';
import '../model/woas_model.dart';
import '../woas_constants.dart';
import 'woas_layout.dart';

/// Right apparatus (`EndNode` + window sandwich).
class WoasEndNode extends StatelessWidget {
  const WoasEndNode({super.key, required this.model});

  final WoasModel model;

  @override
  Widget build(BuildContext context) {
    final end = model.stringEndType;
    final lastY = model.yDrawAt(lastIndex);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (end == WoasEndType.noEnd) _windowBack(),
        if (end == WoasEndType.fixedEnd) _clamp(),
        if (end == WoasEndType.looseEnd) ...[
          _ringBack(lastY),
          _loosePost(),
          _ringFront(lastY),
        ],
      ],
    );
  }

  Widget _clamp() {
    // Image x=-17,y=-31, scale 0.4, then EndNode scale SCALE_FROM_ORIGINAL at VIEW_END.
    const imgScale = 0.4;
    final s = imgScale * scaleFromOriginal;
    return Positioned(
      left: viewEndX - 17 * s,
      top: viewOriginY - 31 * s,
      child: Image.asset(
        WoasAssets.clamp,
        width: 120 * s,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  Widget _loosePost() {
    return Positioned(
      left: viewEndX + 20 * scaleFromOriginal - 5 * scaleFromOriginal,
      top: viewOriginY - 130 * scaleFromOriginal,
      child: Container(
        width: 10 * scaleFromOriginal,
        height: 260 * scaleFromOriginal,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF666666), Color(0xFFFFFFFF), Color(0xFF666666)],
            stops: [0, 0.3, 1],
          ),
        ),
      ),
    );
  }

  Widget _ringBack(double lastY) {
    final s = 0.5 * scaleFromOriginal;
    return Positioned(
      left: viewEndX + 5 * s,
      top: modelToViewY(lastY) - 7 * s,
      child: Image.asset(WoasAssets.ringBack, width: 40 * s),
    );
  }

  Widget _ringFront(double lastY) {
    final s = 0.5 * scaleFromOriginal;
    return Positioned(
      left: viewEndX + 4.7 * s,
      top: modelToViewY(lastY),
      child: Image.asset(WoasAssets.ringFront, width: 40 * s),
    );
  }

  Widget _windowBack() {
    // windowScale 0.6 * SCALE; positioned at VIEW_END
    final s = 0.6 * scaleFromOriginal;
    return Positioned(
      left: viewEndX - 80 * s,
      top: viewOriginY - 60 * s,
      child: Image.asset(WoasAssets.windowBack, height: 120 * s),
    );
  }
}

/// Front window pane (above string) for No End — source `windowImage`.
class WoasWindowFront extends StatelessWidget {
  const WoasWindowFront({super.key, required this.model});

  final WoasModel model;

  @override
  Widget build(BuildContext context) {
    if (model.stringEndType != WoasEndType.noEnd) {
      return const SizedBox.shrink();
    }
    final s = 0.6 * scaleFromOriginal;
    return Positioned(
      left: viewEndX - 40 * s,
      top: viewOriginY - 60 * s,
      child: Image.asset(WoasAssets.windowFront, height: 120 * s),
    );
  }
}
