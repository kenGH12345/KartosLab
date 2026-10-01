/// Read-only drawing DTO. Painters must not recompute vis viva / Kepler.
library;

import 'package:flutter/material.dart';

import '../model/kl_vec.dart';
import '../model/orbit_types.dart';
import '../model/period_tracker.dart';
import '../model/target_orbit.dart';
import 'keplers_mvt.dart';

class SweptAreaDraw {
  const SweptAreaDraw({
    required this.start,
    required this.end,
    required this.dot,
    required this.fill,
    required this.active,
    required this.alreadyEntered,
    required this.inside,
    required this.completion,
    required this.sweptArea,
    required this.durationYears,
    required this.startAngle,
    required this.endAngle,
  });

  final KlVec start;
  final KlVec end;
  final KlVec dot;
  final Color fill;
  final bool active;
  final bool alreadyEntered;
  final bool inside;
  final double completion;
  final double sweptArea;
  final double durationYears;
  final double startAngle;
  final double endAngle;
}

class OrbitRenderData {
  const OrbitRenderData({
    required this.mvt,
    required this.a,
    required this.b,
    required this.c,
    required this.e,
    required this.w,
    required this.nu,
    required this.allowed,
    required this.orbitType,
    required this.sunPos,
    required this.planetPos,
    required this.sunRadius,
    required this.planetRadius,
    required this.velocity,
    required this.planetGravity,
    required this.sunGravity,
    required this.areas,
    required this.periodYears,
    required this.velocityArrowScale,
    required this.gravityArrowScale,
    required this.retrograde,
    required this.periodTraceStart,
    required this.periodTraceEnd,
    required this.periodTracking,
    required this.periodFadeOpacity,
    required this.afterPeriodThreshold,
    required this.targetOrbit,
    required this.showTargetOrbit,
    required this.showAreaValues,
    required this.showTimeValues,
  });

  final KeplersMvt mvt;
  final double a;
  final double b;
  final double c;
  final double e;
  final double w;
  final double nu;
  final bool allowed;
  final OrbitType orbitType;
  final KlVec sunPos;
  final KlVec planetPos;
  final double sunRadius;
  final double planetRadius;
  final KlVec velocity;
  final KlVec planetGravity;
  final KlVec sunGravity;
  final List<SweptAreaDraw> areas;
  final double periodYears;
  final double velocityArrowScale;
  final double gravityArrowScale;
  final bool retrograde;
  final double periodTraceStart;
  final double periodTraceEnd;
  final TrackingState periodTracking;
  final double periodFadeOpacity;
  final bool afterPeriodThreshold;
  final TargetOrbit targetOrbit;
  final bool showTargetOrbit;
  final bool showAreaValues;
  final bool showTimeValues;
}
