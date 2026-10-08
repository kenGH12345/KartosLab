/// Measuring tape for To Scale — L0 [KratosMeasuringTape] + GAO model endpoints.
library;

import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_measuring_tape.dart';

import '../controller/gao_controller.dart';
import '../render/gao_mvt.dart';

class GaoMeasuringTape extends StatelessWidget {
  const GaoMeasuringTape({
    super.key,
    required this.controller,
    required this.mvt,
  });

  final GaoController controller;
  final GaoMvt mvt;

  String _formatDistanceKm(double distM) {
    final km = distM / 1000.0;
    if (km >= 1000) {
      return '${(km / 1000).toStringAsFixed(0)} × 10⁶ km';
    }
    return '${km.toStringAsFixed(0)} km';
  }

  void _nudgeStart(Offset viewDelta) {
    final scene = controller.model.scene;
    final start = scene.measuringTapeStart;
    if (start == null) return;
    final next = mvt.viewToModel(mvt.modelToView(start) + viewDelta);
    start.setFrom(next);
    controller.touch();
  }

  void _nudgeEnd(Offset viewDelta) {
    final scene = controller.model.scene;
    final end = scene.measuringTapeEnd;
    if (end == null) return;
    final next = mvt.viewToModel(mvt.modelToView(end) + viewDelta);
    end.setFrom(next);
    controller.touch();
  }

  void _nudgeBody(Offset viewDelta) {
    _nudgeStart(viewDelta);
    _nudgeEnd(viewDelta);
  }

  @override
  Widget build(BuildContext context) {
    final scene = controller.model.scene;
    final start = scene.measuringTapeStart;
    final end = scene.measuringTapeEnd;
    if (start == null || end == null) {
      return const SizedBox.shrink();
    }

    final a = mvt.modelToView(start);
    final b = mvt.modelToView(end);
    final distM = (end - start).magnitude;

    return KratosMeasuringTape(
      key: const ValueKey('gao-measuring-tape'),
      base: a,
      tip: b,
      label: _formatDistanceKm(distM),
      onBaseDelta: _nudgeStart,
      onTipDelta: _nudgeEnd,
      onBodyDelta: _nudgeBody,
    );
  }
}
