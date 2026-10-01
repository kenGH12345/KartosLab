/// Constants from PhET `js/common/EFACConstants.ts` (v1.5.0-dev.5).
///
/// Evidence tags refer to that file unless noted.
class EfacConstants {
  EfacConstants._();

  // —— layout / time ——
  /// Joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` (joist#640).
  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;

  static const double maxDt = 0.1;
  static const double framesPerSecond = 60;
  static const double simTimePerTickNormal = 1 / framesPerSecond;
  static const double maxHeatExchangeTimeStep = simTimePerTickNormal;
  static const double fastForwardMultiplier = 4;

  static const double introMvtScaleFactor = 1700;
  static const double systemsMvtScaleFactor = 2200;

  // —— temperature ——
  static const double roomTemperature = 296; // K
  static const double waterFreezingPointTemperature = 273.15;
  static const double waterBoilingPointTemperature = 373.15;
  static const double oliveOilBoilingPointTemperature = 573.15;
  static const double significantTemperatureDifference = 1e-3;
  static const double temperaturesEqualThreshold = 1e-6;

  // —— materials / geometry ——
  static const double brickDensity = 3300; // kg/m³
  static const double brickSpecificHeat = 840; // J/kg·K
  static const double ironDensity = 7800;
  static const double ironSpecificHeat = 450;
  static const double waterDensity = 1000;
  static const double waterSpecificHeat = 3000; // tuned in PhET, not 4186
  static const double oliveOilDensity = 916;
  static const double oliveOilSpecificHeat = 1411;
  static const double blockSurfaceWidth = 0.045; // m
  static const double initialFluidProportion = 0.5;

  static const double zToXOffsetMultiplier = -0.25;
  static const double zToYOffsetMultiplier = -0.25;
  static const double zDistanceWhereFullyFaded = 0.1; // m

  // —— energy / chunks ——
  static const double maxEnergyProductionRate = 10000; // J/s
  static const double energyChunkVelocity = 0.04; // m/s
  static const double energyChunkWidth = 19; // screen coords
  static const double introScreenEnergyChunkMaxTravelHeight = 0.85;
  static const double systemsScreenEnergyChunkMaxTravelHeight = 0.55;
  static const int maxNumberOfInitializationDistributionCycles = 500;

  /// Brick energy at freezing / room — used for chunk mapping.
  static final double brickEnergyAtFreezingTemperature =
      _brickEnergyAt(waterFreezingPointTemperature);
  static final double brickEnergyAtRoomTemperature =
      _brickEnergyAt(roomTemperature);

  static const double numEnergyChunksInBrickAtFreezing = 1.25;
  static const double numEnergyChunksInBrickAtRoomTemp = 2.4;

  /// `ENERGY_PER_CHUNK` = MAP_NUM_CHUNKS_TO_ENERGY(2) − MAP_NUM_CHUNKS_TO_ENERGY(1)
  /// [已确认公式] EFACConstants.ts:105-109
  static final double energyPerChunk =
      mapNumChunksToEnergy(2) - mapNumChunksToEnergy(1);

  static double _brickEnergyAt(double temperatureKelvin) {
    final volume = blockSurfaceWidth * blockSurfaceWidth * blockSurfaceWidth;
    return volume * brickDensity * brickSpecificHeat * temperatureKelvin;
  }

  /// Linear map energy → chunk count (symmetric round applied by caller).
  static double mapEnergyToNumChunks(double energy) {
    return _lerp(
      brickEnergyAtFreezingTemperature,
      brickEnergyAtRoomTemperature,
      numEnergyChunksInBrickAtFreezing,
      numEnergyChunksInBrickAtRoomTemp,
      energy,
    );
  }

  static double mapNumChunksToEnergy(double numChunks) {
    return _lerp(
      numEnergyChunksInBrickAtFreezing,
      numEnergyChunksInBrickAtRoomTemp,
      brickEnergyAtFreezingTemperature,
      brickEnergyAtRoomTemperature,
      numChunks,
    );
  }

  static int energyToNumChunksMapper(double energy) {
    final mapped = mapEnergyToNumChunks(energy);
    final rounded = mapped.round(); // PhET roundSymmetric ≈ Dart round for +ve
    return rounded < 0 ? 0 : rounded;
  }

  static double _lerp(
    double x1,
    double x2,
    double y1,
    double y2,
    double x,
  ) {
    if (x2 == x1) return y1;
    return y1 + (x - x1) * (y2 - y1) / (x2 - x1);
  }

  // —— intro layout ——
  static const int maxNumberOfIntroElements = 4;
  static const int maxNumberOfIntroBurners = 2;
  static const int maxNumberOfIntroBeakers = 2;

  /// `BURNER_EDGE_TO_HEIGHT_RATIO` — EFACConstants.ts:185
  static const double burnerEdgeToHeightRatio = 0.2;

  // —— systems carousel ——
  // OFFSET_BETWEEN_ELEMENTS_ON_CAROUSEL = (0, -0.4) — SystemsModel.ts:38
  static const double carouselElementOffsetY = -0.4;
  static const double carouselTransitionDuration = 0.75;

  // —— appearance (colors in EfacColors) ——
  static const double nominalWaterOpacity = 0.7;
  static const double energySymbolsPanelMinWidth = 215;
  static const double controlPanelCornerRadius = 10;
  static const double resetAllButtonRadius = 20;
  static const double playPauseButtonRadius = 20;
  static const double stepForwardButtonRadius = 15;
  static const double elementBaseWidth = 72;
  static const double wireImageScale = 0.48;
  static const double fadeCoefficientInAir = 0.005;
}
