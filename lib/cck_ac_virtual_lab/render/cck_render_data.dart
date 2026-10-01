import '../model/cck_vec.dart';
import '../model/enums.dart';

class CckRenderCharge {
  const CckRenderCharge({
    required this.x,
    required this.y,
    required this.angle,
    required this.sign,
  });

  final double x;
  final double y;
  final double angle;
  final int sign;
}

class CckRenderElement {
  const CckRenderElement({
    required this.id,
    required this.kind,
    required this.start,
    required this.end,
    required this.current,
    required this.selected,
    this.resistorKind,
    this.closed,
    this.tripped,
    this.sparkProgress = -1,
    this.brightness = 0,
    this.inductance = 5,
    this.label,
    this.valueText,
    this.reversed = false,
  });

  final int id;
  final CckElementKind kind;
  final CckVec start;
  final CckVec end;
  final double current;
  final bool selected;
  final CckResistorKind? resistorKind;
  final bool? closed;
  final bool? tripped;
  final double sparkProgress;
  final double brightness;
  final double inductance;
  final String? label;
  final String? valueText;
  final bool reversed;
}

class CckRenderVertex {
  const CckRenderVertex({
    required this.id,
    required this.pos,
    required this.connected,
    required this.selected,
    this.voltageText,
  });

  final int id;
  final CckVec pos;
  final bool connected;
  final bool selected;
  final String? voltageText;
}

class CckRenderVoltmeter {
  const CckRenderVoltmeter({
    required this.body,
    required this.redProbe,
    required this.blackProbe,
    required this.active,
    this.reading,
  });

  final CckVec body;
  final CckVec redProbe;
  final CckVec blackProbe;
  final bool active;
  final double? reading;
}

/// Read-only DTO. Painters must not re-solve MNA.
class CckRenderData {
  const CckRenderData({
    required this.viewType,
    required this.currentType,
    required this.showCurrent,
    required this.zoom,
    required this.elements,
    required this.vertices,
    required this.charges,
    required this.voltmeters,
    required this.stopwatchVisible,
    required this.stopwatchTime,
  });

  final CckViewType viewType;
  final CckCurrentType currentType;
  final bool showCurrent;
  final double zoom;
  final List<CckRenderElement> elements;
  final List<CckRenderVertex> vertices;
  final List<CckRenderCharge> charges;
  final List<CckRenderVoltmeter> voltmeters;
  final bool stopwatchVisible;
  final double stopwatchTime;
}
