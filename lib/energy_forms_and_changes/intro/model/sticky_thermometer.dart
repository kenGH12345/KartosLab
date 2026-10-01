import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/common/model/beaker.dart';
import 'package:kratos/energy_forms_and_changes/efac_colors.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/air.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/thermal_block.dart';
import 'package:kratos/energy_forms_and_changes/common/model/burner.dart';

/// PhET `StickyTemperatureAndColorSensor` + `ElementFollower`.
class StickyThermometer {
  StickyThermometer({required this.id, required this.position});

  final String id;
  Offset position;
  bool active = false;
  bool userControlled = false;
  ThermalBlock? followingBlock;
  Beaker? followingBeaker;

  /// Offset from followed element's model position at stick time
  /// (`ElementFollower.ts` offset = follower − followed).
  Offset _followOffset = Offset.zero;

  double sensedTemperature = EfacConstants.roomTemperature;
  Color sensedColor = EfacColors.temperatureSensorInactive;
  String sensedName = '';

  bool get isFollowing => followingBlock != null || followingBeaker != null;

  void stopFollowing() {
    followingBlock = null;
    followingBeaker = null;
    _followOffset = Offset.zero;
  }

  void startFollowingBlock(ThermalBlock block) {
    followingBeaker = null;
    followingBlock = block;
    _followOffset = position - block.position;
  }

  void startFollowingBeaker(Beaker beaker) {
    followingBlock = null;
    followingBeaker = beaker;
    _followOffset = position - beaker.position;
  }

  void stepFollow() {
    if (followingBlock != null) {
      position = followingBlock!.position + _followOffset;
    } else if (followingBeaker != null) {
      position = followingBeaker!.position + _followOffset;
    }
  }

  /// Sense temperature at tip. Order: blocks(high z) → beaker fluid → steam → burner → air.
  void updateSense({
    required List<ThermalBlock> blocks,
    required List<Beaker> beakers,
    required List<Burner> burners,
    required Air air,
  }) {
    if (!active) {
      sensedTemperature = EfacConstants.roomTemperature;
      sensedColor = EfacColors.temperatureSensorInactive;
      sensedName = '';
      return;
    }

    final tip = position;
    final sorted = [...blocks]..sort((a, b) => b.zIndex.compareTo(a.zIndex));
    for (final block in sorted) {
      if (block.projectedShape.containsPoint(tip)) {
        sensedTemperature = block.temperature;
        sensedColor = block.blockType == BlockType.iron
            ? const Color(0xFFB0B0B0)
            : const Color(0xFFB55239);
        sensedName = block.id;
        return;
      }
    }
    for (final beaker in beakers) {
      if (beaker.thermalContactArea.containsPoint(tip)) {
        sensedTemperature = beaker.temperature;
        sensedColor = beaker.beakerType == BeakerType.water
            ? EfacColors.waterOpaque
            : EfacColors.oliveOilInBeaker;
        sensedName = beaker.id;
        return;
      }
    }
    for (final beaker in beakers) {
      if (beaker.steamingProportion > 0 &&
          beaker.steamArea.containsPoint(tip)) {
        sensedTemperature = beaker.temperature;
        sensedColor = beaker.beakerType == BeakerType.water
            ? EfacColors.waterSteam
            : EfacColors.oliveOilSteam;
        sensedName = '${beaker.id}-steam';
        return;
      }
    }
    for (final burner in burners) {
      final flameRect = burner.bounds;
      if (flameRect.containsPoint(tip) && burner.heatCoolLevel != 0) {
        sensedTemperature = burner.temperature;
        sensedColor = burner.heatCoolLevel > 0
            ? EfacColors.flameOrange
            : EfacColors.iceBlue;
        sensedName = burner.id;
        return;
      }
    }
    sensedTemperature = air.temperature;
    sensedColor = const Color(0xFFE8F4FF);
    sensedName = 'air';
  }

  void reset(Offset storagePos) {
    position = storagePos;
    active = false;
    userControlled = false;
    stopFollowing();
    sensedTemperature = EfacConstants.roomTemperature;
    sensedColor = EfacColors.temperatureSensorInactive;
    sensedName = '';
  }
}
