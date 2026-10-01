import 'dart:ui' show Color;

import '../gas_properties_colors.dart';
import '../gas_properties_constants.dart';
import '../model/hold_constant.dart';
import '../model/ideal_gas_law_model.dart';
import '../model/particle_type.dart';
import '../solver/histogram_solver.dart';

/// Immutable snapshot for painters — no physics in the view.
class GasRenderState {
  const GasRenderState({
    required this.containerLeft,
    required this.containerRight,
    required this.containerBottom,
    required this.containerTop,
    required this.wallThickness,
    required this.lidIsOn,
    required this.lidWidth,
    required this.isOpen,
    required this.openingLeft,
    required this.openingRight,
    required this.particles,
    required this.temperatureK,
    required this.pressureKpa,
    required this.displayedPressureKpa,
    required this.volumePm3,
    required this.numberOfHeavy,
    required this.numberOfLight,
    required this.isPlaying,
    required this.heatCoolFactor,
    required this.holdConstant,
    required this.widthPm,
    required this.leftWallVelocityX,
    required this.widthVisible,
    required this.wallVelocityVisible,
    required this.particleCollisionsEnabled,
    required this.energy,
    required this.profile,
    required this.stopwatchPs,
    required this.collisionCount,
    this.temperatureUnitsKelvin = true,
    this.pressureUnitsAtm = true,
  });

  final double containerLeft;
  final double containerRight;
  final double containerBottom;
  final double containerTop;
  final double wallThickness;
  final bool lidIsOn;
  final double lidWidth;
  final bool isOpen;
  final double openingLeft;
  final double openingRight;
  final List<ParticleRenderDatum> particles;
  final double? temperatureK;
  final double pressureKpa;
  final double displayedPressureKpa;
  final double volumePm3;
  final int numberOfHeavy;
  final int numberOfLight;
  final bool isPlaying;
  final double heatCoolFactor;
  final HoldConstant holdConstant;
  final double widthPm;
  final double leftWallVelocityX;
  final bool widthVisible;
  final bool wallVelocityVisible;
  final bool particleCollisionsEnabled;
  final EnergyRenderDatum? energy;
  final IdealGasProfile profile;
  final double stopwatchPs;
  final int collisionCount;
  final bool temperatureUnitsKelvin;
  final bool pressureUnitsAtm;

  factory GasRenderState.fromModel(
    IdealGasLawModel model, {
    bool widthVisible = false,
    bool wallVelocityVisible = false,
    bool temperatureUnitsKelvin = true,
    bool pressureUnitsAtm = true,
  }) {
    final c = model.container;
    final particles = <ParticleRenderDatum>[
      for (final p in model.particleSystem.heavyParticles)
        ParticleRenderDatum(
          x: p.x,
          y: p.y,
          radius: p.radius,
          type: ParticleType.heavy,
          color: const Color(GasPropertiesColors.heavyParticle),
          highlight: const Color(GasPropertiesColors.heavyHighlight),
        ),
      for (final p in model.particleSystem.lightParticles)
        ParticleRenderDatum(
          x: p.x,
          y: p.y,
          radius: p.radius,
          type: ParticleType.light,
          color: const Color(GasPropertiesColors.lightParticle),
          highlight: const Color(GasPropertiesColors.lightHighlight),
        ),
      for (final p in model.particleSystem.heavyOutside)
        ParticleRenderDatum(
          x: p.x,
          y: p.y,
          radius: p.radius,
          type: ParticleType.heavy,
          color: const Color(GasPropertiesColors.heavyParticle),
          highlight: const Color(GasPropertiesColors.heavyHighlight),
        ),
      for (final p in model.particleSystem.lightOutside)
        ParticleRenderDatum(
          x: p.x,
          y: p.y,
          radius: p.radius,
          type: ParticleType.light,
          color: const Color(GasPropertiesColors.lightParticle),
          highlight: const Color(GasPropertiesColors.lightHighlight),
        ),
    ];

    EnergyRenderDatum? energy;
    final es = model.energySampling;
    if (es != null) {
      energy = EnergyRenderDatum(
        heavySpeedBins: List<double>.from(es.heavySpeedBins),
        lightSpeedBins: List<double>.from(es.lightSpeedBins),
        heavyKeBins: List<double>.from(es.heavyKeBins),
        lightKeBins: List<double>.from(es.lightKeBins),
        heavyAverageSpeed: es.heavyAverageSpeed,
        lightAverageSpeed: es.lightAverageSpeed,
        zoomLevelIndex: es.zoomLevelIndex,
        zoomYMax: es.zoomYMax,
        binCount: es.binCount,
        speedBinWidth: es.speedBinWidth,
        keBinWidth: es.keBinWidth,
      );
    }

    return GasRenderState(
      containerLeft: c.left,
      containerRight: c.right,
      containerBottom: c.bottom,
      containerTop: c.top,
      wallThickness: c.wallThickness,
      lidIsOn: c.lidIsOn,
      lidWidth: c.lidWidth,
      isOpen: c.isOpen,
      openingLeft: c.getOpeningLeft(),
      openingRight: c.getOpeningRight(),
      particles: particles,
      temperatureK: model.temperatureKelvin,
      pressureKpa: model.pressureKpa,
      displayedPressureKpa: model.displayedPressureKpa,
      volumePm3: model.volume,
      numberOfHeavy: model.particleSystem.numberOfHeavy,
      numberOfLight: model.particleSystem.numberOfLight,
      isPlaying: model.isPlaying,
      heatCoolFactor: model.heatCoolFactor,
      holdConstant: model.holdConstant,
      widthPm: c.width,
      leftWallVelocityX: c.leftWallVelocityX,
      widthVisible: widthVisible,
      wallVelocityVisible: wallVelocityVisible,
      particleCollisionsEnabled: model.particleCollisionsEnabled,
      energy: energy,
      profile: model.profile,
      stopwatchPs: model.clock.simulationTimePs,
      collisionCount: model.collisionCount,
      temperatureUnitsKelvin: temperatureUnitsKelvin,
      pressureUnitsAtm: pressureUnitsAtm,
    );
  }

  String get temperatureDisplay {
    if (temperatureK == null) return '-- ${temperatureUnitsKelvin ? 'K' : 'C'}';
    if (temperatureUnitsKelvin) {
      return '${temperatureK!.round()} K';
    }
    return '${(temperatureK! - 273.15).round()} C';
  }

  String get pressureDisplay {
    if (pressureUnitsAtm) {
      final atm =
          displayedPressureKpa * GasPropertiesConstants.atmPerKpa;
      if (atm < 0.05) return '0.0 atm';
      if (atm >= 10) return '${atm.toStringAsFixed(1)} atm';
      if (atm >= 1) return '${atm.toStringAsFixed(2)} atm';
      return '${atm.toStringAsFixed(3)} atm';
    }
    if (displayedPressureKpa < 0.5) return '0 kPa';
    return '${displayedPressureKpa.round()} kPa';
  }
}

class ParticleRenderDatum {
  const ParticleRenderDatum({
    required this.x,
    required this.y,
    required this.radius,
    required this.type,
    required this.color,
    required this.highlight,
  });

  final double x;
  final double y;
  final double radius;
  final ParticleType type;
  final Color color;
  final Color highlight;
}

class EnergyRenderDatum {
  const EnergyRenderDatum({
    required this.heavySpeedBins,
    required this.lightSpeedBins,
    required this.heavyKeBins,
    required this.lightKeBins,
    required this.heavyAverageSpeed,
    required this.lightAverageSpeed,
    required this.zoomLevelIndex,
    required this.zoomYMax,
    required this.binCount,
    required this.speedBinWidth,
    required this.keBinWidth,
  });

  final List<double> heavySpeedBins;
  final List<double> lightSpeedBins;
  final List<double> heavyKeBins;
  final List<double> lightKeBins;
  final double? heavyAverageSpeed;
  final double? lightAverageSpeed;
  final int zoomLevelIndex;
  final double zoomYMax;
  final int binCount;
  final double speedBinWidth;
  final double keBinWidth;
}

/// Re-export for callers that need EnergySamplingState type.
typedef EnergySamplingSnapshot = EnergySamplingState;
