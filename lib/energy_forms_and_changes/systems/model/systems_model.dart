import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kratos/energy_forms_and_changes/common/model/beaker.dart';
import 'package:kratos/energy_forms_and_changes/common/model/energy_type.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_layout_constants.dart';

/// Discrete energy packet — PhET `Energy.ts`.
class EnergyPacket {
  const EnergyPacket({
    required this.type,
    required this.amount,
    required this.direction,
  });

  final EnergyType type;
  final double amount;
  final double direction;
}

enum EnergySourceId { biker, faucet, sun, teaKettle }

enum EnergyConverterId { generator, solarPanel }

enum EnergyUserId { beakerHeater, incandescentBulb, fluorescentBulb, fan }

/// CUBIC_IN_OUT from PhET twixt (same as Flutter Curves.easeInOutCubic).
double cubicInOut(double t) {
  t = t.clamp(0.0, 1.0);
  return t < 0.5
      ? 4 * t * t * t
      : 1 - math.pow(-2 * t + 2, 3) / 2;
}

/// PhET `EnergySystemElementCarousel` with 0.75s CUBIC_IN_OUT.
class EnergyCarousel<T> extends ChangeNotifier {
  EnergyCarousel({
    required this.ids,
    required this.selectedElementPosition,
  }) : assert(ids.isNotEmpty);

  final List<T> ids;
  final Offset selectedElementPosition;

  int targetIndex = 0;
  int _fromIndex = 0;
  double elapsedTransitionTime = 0;
  bool get animationInProgress => _animating;

  bool _animating = false;

  T get selected => ids[targetIndex];

  /// Offset of carousel so that targetIndex sits at selectedElementPosition.
  Offset get currentCarouselOffset {
    final fromOff = Offset(0, _fromIndex * EfacConstants.carouselElementOffsetY);
    final toOff = Offset(0, targetIndex * EfacConstants.carouselElementOffsetY);
    if (!_animating) return toOff;
    final t = (elapsedTransitionTime / EfacConstants.carouselTransitionDuration)
        .clamp(0.0, 1.0);
    final e = cubicInOut(t);
    return Offset(
      fromOff.dx + (toOff.dx - fromOff.dx) * e,
      fromOff.dy + (toOff.dy - fromOff.dy) * e,
    );
  }

  Offset positionForIndex(int index) {
    // Element world pos = selectedPos + index*offset - carouselOffset
    final base = Offset(
      0,
      index * EfacConstants.carouselElementOffsetY,
    );
    return selectedElementPosition + base - currentCarouselOffset;
  }

  double opacityForIndex(int index) {
    final pos = positionForIndex(index);
    final distance = (pos - selectedElementPosition).distance;
    final maxDist = EfacConstants.carouselElementOffsetY.abs();
    return (1 - distance / maxDist).clamp(0.0, 1.0);
  }

  void selectIndex(int index) {
    if (index < 0 || index >= ids.length || index == targetIndex) return;
    _fromIndex = targetIndex;
    targetIndex = index;
    elapsedTransitionTime = 0;
    _animating = true;
    notifyListeners();
  }

  void selectId(T id) {
    final i = ids.indexOf(id);
    if (i >= 0) selectIndex(i);
  }

  void step(double dt) {
    if (!_animating) return;
    elapsedTransitionTime += dt;
    if (elapsedTransitionTime >= EfacConstants.carouselTransitionDuration) {
      elapsedTransitionTime = EfacConstants.carouselTransitionDuration;
      _fromIndex = targetIndex;
      _animating = false;
    }
    notifyListeners();
  }

  void reset() {
    targetIndex = 0;
    _fromIndex = 0;
    elapsedTransitionTime = 0;
    _animating = false;
    notifyListeners();
  }
}

/// Path mover for systems energy chunks — PhET EnergyChunkPathMover subset.
class EnergyChunkPathMover {
  EnergyChunkPathMover({
    required this.chunkId,
    required this.path,
    this.speed = EfacConstants.energyChunkVelocity,
  });

  final int chunkId;
  final List<Offset> path;
  final double speed;
  int _segment = 0;
  Offset position = Offset.zero;
  bool get pathFullyTraversed => _segment >= path.length - 1 &&
      (path.isEmpty || (position - path.last).distance < 1e-6);

  void start() {
    if (path.isEmpty) return;
    position = path.first;
    _segment = 0;
  }

  void moveAlongPath(double dt) {
    if (path.length < 2 || pathFullyTraversed) return;
    var remaining = speed * dt;
    while (remaining > 0 && _segment < path.length - 1) {
      final target = path[_segment + 1];
      final delta = target - position;
      final dist = delta.distance;
      if (dist <= remaining) {
        position = target;
        remaining -= dist;
        _segment++;
      } else {
        position += delta * (remaining / dist);
        remaining = 0;
      }
    }
  }
}

class SystemsModel extends ChangeNotifier {
  SystemsModel() {
    sources = EnergyCarousel<EnergySourceId>(
      ids: EnergySourceId.values,
      selectedElementPosition: const Offset(-0.15, 0),
    );
    converters = EnergyCarousel<EnergyConverterId>(
      ids: EnergyConverterId.values,
      selectedElementPosition: const Offset(-0.025, 0),
    );
    users = EnergyCarousel<EnergyUserId>(
      ids: EnergyUserId.values,
      selectedElementPosition: const Offset(0.09, 0),
    );
    beakerHeaterBeaker = Beaker(
      id: 'systems-beaker-heater',
      beakerType: BeakerType.water,
      position: Offset.zero,
      width: EfacLayoutConstants.beakerWidth,
      height: EfacLayoutConstants.beakerHeight,
    );
  }

  late final EnergyCarousel<EnergySourceId> sources;
  late final EnergyCarousel<EnergyConverterId> converters;
  late final EnergyCarousel<EnergyUserId> users;

  /// Systems beaker on heater — PhET `BeakerHeater.beaker` (width 0.075).
  late final Beaker beakerHeaterBeaker;

  bool energyChunksVisible = false;
  bool isPlaying = true;

  double bikerTargetCrankAngularVelocity = 0;
  double faucetFlowProportion = 0;
  double sunCloudinessProportion = 0;
  double teaKettleHeatProportion = 0;

  /// Animation state (Systems Biker/Generator) — advanced in stepModel.
  double bikerCrankAngle = 0;
  double bikerRearWheelAngle = 0;
  double generatorWheelAngle = 0;
  int bikerEnergyChunksRemaining = 21; // Biker.ts INITIAL
  double beakerHeaterHeatProportion = 0;
  double _bikerEnergySinceLastChunk = 0;

  /// PhET BeakerHeater.ts MAX_HEAT_GENERATION_RATE / HEAT_ENERGY_CHANGE_RATE.
  static const double _maxHeatGenerationRate = 5000; // J/s
  static const double _heatEnergyChangeRate = 0.5; // proportion / s
  static const double _waterAirHeatTransfer = 30.0;

  EnergyPacket? lastFromSource;
  EnergyPacket? lastFromConverter;
  double lastUserConsumed = 0;

  final List<EnergyChunkPathMover> pathMovers = <EnergyChunkPathMover>[];
  int _chunkId = 1;

  bool get beltVisible =>
      sources.selected == EnergySourceId.biker &&
      converters.selected == EnergyConverterId.generator &&
      !sources.animationInProgress &&
      !converters.animationInProgress;

  String get sourceAsset => switch (sources.selected) {
        EnergySourceId.biker => EfacAssets.png('bicycleFrame'),
        EnergySourceId.faucet => EfacAssets.faucetIcon,
        EnergySourceId.sun => EfacAssets.sunIcon,
        EnergySourceId.teaKettle => EfacAssets.png('teaKettle'),
      };

  String get converterAsset => switch (converters.selected) {
        EnergyConverterId.generator => EfacAssets.png('generator'),
        EnergyConverterId.solarPanel => EfacAssets.png('solarPanel'),
      };

  String get userAsset => switch (users.selected) {
        EnergyUserId.beakerHeater => EfacAssets.waterIcon,
        EnergyUserId.incandescentBulb => EfacAssets.png('incandescent'),
        EnergyUserId.fluorescentBulb => EfacAssets.png('fluorescentFront'),
        EnergyUserId.fan => EfacAssets.png('fan01'),
      };

  void step(double dt) {
    final capped = dt > EfacConstants.maxDt ? EfacConstants.maxDt : dt;
    sources.step(capped);
    converters.step(capped);
    users.step(capped);
    for (final m in pathMovers) {
      m.moveAlongPath(capped);
    }
    pathMovers.removeWhere((m) => m.pathFullyTraversed);
    if (isPlaying) {
      stepModel(capped);
    }
    notifyListeners();
  }

  void manualStep() {
    stepModel(EfacConstants.simTimePerTickNormal);
    notifyListeners();
  }

  void stepModel(double dt) {
    lastFromSource = _stepSource(dt);
    lastFromConverter = _stepConverter(dt, lastFromSource!);
    lastUserConsumed = _stepUser(dt, lastFromConverter!);

    // Biker crank / wheel / generator wheel — stop when out of chemical energy.
    if (sources.selected == EnergySourceId.biker) {
      final omega = bikerEnergyChunksRemaining > 0
          ? bikerTargetCrankAngularVelocity
          : 0.0;
      bikerCrankAngle = (bikerCrankAngle + omega * dt) % (2 * math.pi);
      bikerRearWheelAngle = (bikerRearWheelAngle + omega * dt) % (2 * math.pi);
      if (converters.selected == EnergyConverterId.generator) {
        generatorWheelAngle =
            (generatorWheelAngle + omega * dt) % (2 * math.pi);
      }
      _depleteBikerEnergy(omega, dt);
    }

    // Faucet / tea kettle drive generator paddles (proportion * ~3π).
    if (converters.selected == EnergyConverterId.generator) {
      double drive = 0;
      if (sources.selected == EnergySourceId.faucet &&
          faucetFlowProportion > 0) {
        drive = faucetFlowProportion * 3 * math.pi;
      } else if (sources.selected == EnergySourceId.teaKettle &&
          teaKettleHeatProportion > 0) {
        drive = teaKettleHeatProportion * 3 * math.pi;
      }
      if (drive > 0) {
        generatorWheelAngle =
            (generatorWheelAngle + drive * dt) % (2 * math.pi);
      }
    }

    // BeakerHeater.ts — coil heat proportion + thermal energy into beaker.
    if (users.selected == EnergyUserId.beakerHeater) {
      _stepBeakerHeater(dt, lastFromConverter!);
    } else {
      beakerHeaterHeatProportion *= (1 - math.min(1.0, dt));
    }

    if (energyChunksVisible && lastFromSource!.amount > 0) {
      _spawnPipelineChunk(lastFromSource!.type, lastFromConverter!.type);
    }
  }

  /// Biker.ts: emit chemical chunks while pedaling → remaining decreases.
  void _depleteBikerEnergy(double omega, double dt) {
    if (omega <= 0 || bikerEnergyChunksRemaining <= 0) return;
    final fraction = (omega / (3 * math.pi)).clamp(0.0, 1.0);
    _bikerEnergySinceLastChunk +=
        EfacConstants.maxEnergyProductionRate * fraction * dt;
    while (_bikerEnergySinceLastChunk >= EfacConstants.energyPerChunk &&
        bikerEnergyChunksRemaining > 0) {
      _bikerEnergySinceLastChunk -= EfacConstants.energyPerChunk;
      bikerEnergyChunksRemaining--;
    }
  }

  /// BeakerHeater.ts:208-257 — heatProportion + changeEnergy + air loss.
  void _stepBeakerHeater(double dt, EnergyPacket fromConverter) {
    final energyFraction = (fromConverter.type == EnergyType.electrical &&
            fromConverter.amount > 0 &&
            dt > 0)
        ? (fromConverter.amount / (EfacConstants.maxEnergyProductionRate * dt))
            .clamp(0.0, 1.0)
        : 0.0;
    beakerHeaterHeatProportion = math.min(
      energyFraction,
      beakerHeaterHeatProportion + _heatEnergyChangeRate * dt,
    );

    final beaker = beakerHeaterBeaker;
    beaker.changeEnergy(
      beakerHeaterHeatProportion * _maxHeatGenerationRate * dt,
    );

    final temperatureGradient =
        beaker.temperature - EfacConstants.roomTemperature;
    if (temperatureGradient.abs() >
        EfacConstants.temperaturesEqualThreshold) {
      final w = beaker.width;
      final h = beaker.height;
      final thermalContactArea =
          (w * 2 + h * 2) * beaker.fluidProportion;
      final thermalEnergyLost =
          temperatureGradient * _waterAirHeatTransfer * thermalContactArea * dt;
      beaker.changeEnergy(-thermalEnergyLost);
      final beyond = beaker.energyBeyondMaxTemperature;
      if (beyond > 0) beaker.changeEnergy(-beyond);
    }
    beaker.step(dt);
  }

  void feedBiker() {
    bikerEnergyChunksRemaining = 21;
    _bikerEnergySinceLastChunk = 0;
    notifyListeners();
  }

  void _spawnPipelineChunk(EnergyType fromType, EnergyType toType) {
    final start = sources.selectedElementPosition;
    final mid = converters.selectedElementPosition;
    final end = users.selectedElementPosition;
    final mover = EnergyChunkPathMover(
      chunkId: _chunkId++,
      path: [start, mid, end + const Offset(0, 0.15)],
    )..start();
    pathMovers.add(mover);
  }

  EnergyPacket _stepSource(double dt) {
    final maxRate = EfacConstants.maxEnergyProductionRate;
    switch (sources.selected) {
      case EnergySourceId.biker:
        // Biker.ts: no chemical energy left → zero mechanical output.
        if (bikerEnergyChunksRemaining <= 0) {
          return const EnergyPacket(
            type: EnergyType.mechanical,
            amount: 0,
            direction: -math.pi / 2,
          );
        }
        final fraction =
            (bikerTargetCrankAngularVelocity / (3 * math.pi)).clamp(0.0, 1.0);
        return EnergyPacket(
          type: EnergyType.mechanical,
          amount: maxRate * fraction * dt,
          direction: -math.pi / 2,
        );
      case EnergySourceId.faucet:
        return EnergyPacket(
          type: EnergyType.mechanical,
          amount: maxRate * faucetFlowProportion * dt,
          direction: -math.pi / 2,
        );
      case EnergySourceId.sun:
        final sun = (1 - sunCloudinessProportion).clamp(0.0, 1.0);
        return EnergyPacket(
          type: EnergyType.light,
          amount: maxRate * sun * dt,
          direction: 0,
        );
      case EnergySourceId.teaKettle:
        return EnergyPacket(
          type: EnergyType.mechanical,
          amount: maxRate * teaKettleHeatProportion * 0.8 * dt,
          direction: math.pi / 2,
        );
    }
  }

  EnergyPacket _stepConverter(double dt, EnergyPacket fromSource) {
    switch (converters.selected) {
      case EnergyConverterId.generator:
        if (fromSource.type != EnergyType.mechanical) {
          return const EnergyPacket(
            type: EnergyType.electrical,
            amount: 0,
            direction: 0,
          );
        }
        return EnergyPacket(
          type: EnergyType.electrical,
          amount: fromSource.amount,
          direction: 0,
        );
      case EnergyConverterId.solarPanel:
        if (fromSource.type != EnergyType.light) {
          return const EnergyPacket(
            type: EnergyType.electrical,
            amount: 0,
            direction: 0,
          );
        }
        return EnergyPacket(
          type: EnergyType.electrical,
          amount: fromSource.amount * 0.68,
          direction: 0,
        );
    }
  }

  double _stepUser(double dt, EnergyPacket fromConverter) {
    if (fromConverter.type != EnergyType.electrical) return 0;
    return fromConverter.amount;
  }

  void setEnergyChunksVisible(bool v) {
    energyChunksVisible = v;
    notifyListeners();
  }

  void setPlaying(bool v) {
    isPlaying = v;
    notifyListeners();
  }

  void selectSourceIndex(int index) {
    sources.selectIndex(index);
    notifyListeners();
  }

  void selectConverterIndex(int index) {
    converters.selectIndex(index);
    notifyListeners();
  }

  void selectUserIndex(int index) {
    users.selectIndex(index);
    notifyListeners();
  }

  void setBikerSpeed(double v) {
    bikerTargetCrankAngularVelocity = v.clamp(0, 3 * math.pi);
    notifyListeners();
  }

  void setFaucetFlow(double v) {
    faucetFlowProportion = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setCloudiness(double v) {
    sunCloudinessProportion = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setTeaKettleHeat(double v) {
    teaKettleHeatProportion = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  void reset() {
    energyChunksVisible = false;
    isPlaying = true;
    bikerTargetCrankAngularVelocity = 0;
    faucetFlowProportion = 0;
    sunCloudinessProportion = 0;
    teaKettleHeatProportion = 0;
    bikerCrankAngle = 0;
    bikerRearWheelAngle = 0;
    generatorWheelAngle = 0;
    bikerEnergyChunksRemaining = 21;
    _bikerEnergySinceLastChunk = 0;
    beakerHeaterHeatProportion = 0;
    beakerHeaterBeaker.reset(home: Offset.zero);
    lastFromSource = null;
    lastFromConverter = null;
    lastUserConsumed = 0;
    pathMovers.clear();
    sources.reset();
    converters.reset();
    users.reset();
    notifyListeners();
  }
}
