import 'package:flutter/material.dart';

import '../../clb_constants.dart';
import '../model/capacitor.dart';
import '../render/circuit_render_data.dart';
import '../transform/plate_area_drag_handler.dart';
import '../transform/plate_separation_drag_handler.dart';
import '../transform/yaw_pitch_mvt.dart';

/// Plate separation (Y) + plate area/width (X) drag hit targets.
///
/// Separation: PhET `PlateSeparationDragHandler.js` (clickYOffset, absolute Y).
/// Area: PhET `PlateAreaDragHandler.js` (diagonal via view-x LinearFunction).
class PlateHandleGestureLayer extends StatefulWidget {
  const PlateHandleGestureLayer({
    super.key,
    required this.capacitor,
    required this.data,
    this.mvt,
  });

  final Capacitor capacitor;
  final CircuitRenderData data;
  final YawPitchMvt? mvt;

  @override
  State<PlateHandleGestureLayer> createState() =>
      _PlateHandleGestureLayerState();
}

class _PlateHandleGestureLayerState extends State<PlateHandleGestureLayer> {
  PlateAreaDragHandler? _areaHandler;
  double _areaHitLeft = 0;
  double _areaHitTop = 0;

  PlateSeparationDragHandler? _sepHandler;
  double _sepHitLeft = 0;
  double _sepHitTop = 0;

  YawPitchMvt get _mvt => widget.mvt ?? YawPitchMvt();

  @override
  Widget build(BuildContext context) {
    final sep = widget.data.plateSeparationHandleAnchor;
    final area = widget.data.plateAreaHandleAnchor;

    return Stack(
      children: [
        Positioned(
          left: sep.dx - 30,
          top: sep.dy - ClbConstants.dragHandleArrowLength - 70,
          width: 60,
          height: ClbConstants.dragHandleArrowLength + 80,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) {
              _sepHitLeft = sep.dx - 30;
              _sepHitTop = sep.dy - ClbConstants.dragHandleArrowLength - 70;
              final pMouse = Offset(
                _sepHitLeft + d.localPosition.dx,
                _sepHitTop + d.localPosition.dy,
              );
              _sepHandler = PlateSeparationDragHandler(mvt: _mvt)
                ..start(
                  pMouse: pMouse,
                  plateSeparation: widget.capacitor.plateSeparation,
                );
            },
            onPanUpdate: (d) {
              final handler = _sepHandler;
              if (handler == null) return;
              final pMouse = Offset(
                _sepHitLeft + d.localPosition.dx,
                _sepHitTop + d.localPosition.dy,
              );
              widget.capacitor.setPlateSeparation(handler.separationAt(pMouse));
            },
            onPanEnd: (_) => _sepHandler = null,
            onPanCancel: () => _sepHandler = null,
          ),
        ),
        Positioned(
          left: area.dx - 20,
          top: area.dy - 20,
          width: 90,
          height: 90,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) {
              _areaHitLeft = area.dx - 20;
              _areaHitTop = area.dy - 20;
              final pMouse = Offset(
                _areaHitLeft + d.localPosition.dx,
                _areaHitTop + d.localPosition.dy,
              );
              _areaHandler = PlateAreaDragHandler(mvt: _mvt)
                ..start(
                  pMouse: pMouse,
                  plateWidth: widget.capacitor.plateWidth,
                );
            },
            onPanUpdate: (d) {
              final handler = _areaHandler;
              if (handler == null) return;
              final pMouse = Offset(
                _areaHitLeft + d.localPosition.dx,
                _areaHitTop + d.localPosition.dy,
              );
              widget.capacitor.setPlateWidth(handler.plateWidthAt(pMouse));
            },
            onPanEnd: (_) => _areaHandler = null,
            onPanCancel: () => _areaHandler = null,
          ),
        ),
      ],
    );
  }
}
