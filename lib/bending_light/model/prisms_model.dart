import '../bending_light_constants.dart';
import '../physics/vector_snell.dart';
import 'bending_light_model.dart';
import 'bl_vec2.dart';
import 'enums.dart';
import 'intersection.dart';
import 'laser_color.dart';
import 'light_ray.dart';
import 'prism.dart';
import 'prism_geometry.dart';
import 'substance.dart';

/// Prisms screen model (`PrismsModel.ts`) — vector Snell + recursive tracing.
class PrismsModel extends BendingLightModel {
  PrismsModel()
      : super(
          laserAngle: mathPi,
          topLeftQuadrant: false,
          laserDistanceFromPivot: 1e-16,
        ) {
    environmentMedium = Medium(
      substance: Substance.air,
      colorArgb: mediumColorFactory
          .getColor(Substance.air.indexOfRefractionForRedLight),
    );
    prismMedium = Medium(
      substance: Substance.glass,
      colorArgb: mediumColorFactory
          .getColor(Substance.glass.indexOfRefractionForRedLight),
    );
    _initialEnv = environmentMedium;
    _initialPrism = prismMedium;
    updateModel();
  }

  static const double mathPi = 3.141592653589793;

  late Medium environmentMedium;
  late Medium prismMedium;
  late Medium _initialEnv;
  late Medium _initialPrism;

  int manyRays = 1;
  bool showReflections = false;
  bool showNormals = false;
  bool showProtractor = false;

  final List<Prism> prisms = [];
  final List<Intersection> intersections = [];
  bool dirty = true;

  List<(PrismShape, String)> getPrismPrototypes() =>
      PrismPrototypes.createAll();

  void addPrism(Prism prism) {
    prisms.add(prism);
    dirty = true;
    updateModel();
  }

  void removePrism(Prism prism) {
    prisms.remove(prism);
    dirty = true;
    updateModel();
  }

  void setEnvironmentSubstance(Substance s) {
    environmentMedium = Medium(
      substance: s,
      colorArgb: mediumColorFactory.getColor(s.indexOfRefractionForRedLight),
    );
    updateModel();
  }

  void setPrismSubstance(Substance s) {
    prismMedium = Medium(
      substance: s,
      colorArgb: mediumColorFactory.getColor(s.indexOfRefractionForRedLight),
    );
    updateModel();
  }

  void setManyRays(int count) {
    manyRays = count;
    updateModel();
  }

  void setShowReflections(bool v) {
    showReflections = v;
    updateModel();
  }

  void setShowNormals(bool v) {
    showNormals = v;
    notifyListeners();
  }

  void setShowProtractor(bool v) {
    showProtractor = v;
    notifyListeners();
  }

  /// Laser-type radios: 1× / 5× / white (`PrismsScreenView` adapter).
  void setLightType(LightType type) {
    switch (type) {
      case LightType.singleColor:
        manyRays = 1;
        laser.colorMode = ColorModeEnum.singleColor;
      case LightType.singleColor5x:
        manyRays = 5;
        laser.colorMode = ColorModeEnum.singleColor;
      case LightType.white:
        manyRays = 1;
        laser.colorMode = ColorModeEnum.white;
    }
    updateModel();
  }

  void setCustomIndex({required bool environment, required double indexForRed}) {
    final s = Substance.customWith(indexForRed);
    if (environment) {
      setEnvironmentSubstance(s);
    } else {
      setPrismSubstance(s);
    }
  }

  @override
  void clearModel() {
    super.clearModel();
    intersections.clear();
  }

  bool isRayInPrism(BlVec2 emissionPoint) {
    for (final p in prisms) {
      if (p.contains(emissionPoint)) return true;
    }
    return false;
  }

  @override
  void propagateRays() {
    if (!laser.on) return;

    final tail = laser.emissionPoint;
    final direction = laser.getDirectionUnitVector();

    if (manyRays == 1) {
      _propagate(tail, direction, 1.0, isRayInPrism(tail));
    } else {
      final wr = BendingLightConstants.wavelengthRed;
      for (var x = -wr; x <= wr * 1.1; x += wr / 2) {
        final offset = direction.rotated(mathPi / 2) * x;
        final rayTail = offset + tail;
        _propagate(rayTail, direction, 1.0, isRayInPrism(rayTail));
      }
    }
  }

  void _propagate(
    BlVec2 tail,
    BlVec2 direction,
    double power,
    bool laserInPrism,
  ) {
    if (laser.colorMode == ColorModeEnum.white) {
      final wavelengths = BendingLightConstants.whiteLightWavelengthsNm;
      for (var i = 0; i < wavelengths.length; i++) {
        final wavelength = wavelengths[i] / 1e9;
        final n = laserInPrism
            ? prismMedium.getIndexOfRefraction(wavelength)
            : environmentMedium.getIndexOfRefraction(wavelength);
        final showIntersection =
            i == 0 || i == wavelengths.length - 1;
        _propagateTheRay(
          ColoredRay(
            tail: tail,
            directionUnitVector: direction,
            power: power,
            wavelength: wavelength,
            mediumIndexOfRefraction: n,
            frequency: BendingLightConstants.speedOfLight / wavelength,
          ),
          0,
          showIntersection,
        );
      }
    } else {
      final wl = laser.getWavelength();
      final n = laserInPrism
          ? prismMedium.getIndexOfRefraction(wl)
          : environmentMedium.getIndexOfRefraction(wl);
      _propagateTheRay(
        ColoredRay(
          tail: tail,
          directionUnitVector: direction,
          power: power,
          wavelength: wl,
          mediumIndexOfRefraction: n,
          frequency: laser.getFrequency(),
        ),
        0,
        true,
      );
    }
  }

  void _propagateTheRay(
    ColoredRay incidentRay,
    int depth,
    bool showIntersection,
  ) {
    final waveWidth = BendingLightConstants.characteristicLength * 5;

    if (depth > BendingLightConstants.maxLightRaySteps ||
        incidentRay.power < 0.001) {
      return;
    }

    final intersection = _getIntersection(incidentRay);
    final L = incidentRay.directionUnitVector;
    final n1 = incidentRay.mediumIndexOfRefraction;
    final wavelengthInN1 = incidentRay.wavelength / n1;

    if (intersection != null) {
      if (showIntersection) {
        intersections.add(intersection);
      }

      final pointOnOtherSide =
          L.times(1e-12) + intersection.point;
      var outputInsidePrism = false;
      for (final prism in prisms) {
        // Odd number of intersections ahead ⇒ still inside (PhET winding)
        final aheadHits = prism.getIntersections(
          pointOnOtherSide,
          incidentRay.directionUnitVector,
        );
        if (aheadHits.length.isOdd) {
          outputInsidePrism = true;
        }
      }

      final baseWl = incidentRay
          .getBaseWavelength(BendingLightConstants.speedOfLight);
      final n2 = outputInsidePrism
          ? prismMedium.getIndexOfRefraction(baseWl)
          : environmentMedium.getIndexOfRefraction(baseWl);

      final point = intersection.point;
      final n = intersection.unitNormal;
      final snell = VectorSnell.compute(L: L, n: n, n1: n1, n2: n2);

      if (showReflections || snell.totalInternalReflection) {
        final reflectedRayTail =
            incidentRay.directionUnitVector.times(-1e-12) + point;
        _propagateTheRay(
          ColoredRay(
            tail: reflectedRayTail,
            directionUnitVector: snell.vReflect.normalize(),
            power: incidentRay.power * snell.reflectedPower,
            wavelength: incidentRay.wavelength,
            mediumIndexOfRefraction: incidentRay.mediumIndexOfRefraction,
            frequency: incidentRay.frequency,
          ),
          depth + 1,
          showIntersection,
        );
      }

      final refractedRayTail =
          incidentRay.directionUnitVector.times(1e-12) + point;
      _propagateTheRay(
        ColoredRay(
          tail: refractedRayTail,
          directionUnitVector: snell.vRefract,
          power: incidentRay.power * snell.transmittedPower,
          wavelength: incidentRay.wavelength,
          mediumIndexOfRefraction: n2,
          frequency: incidentRay.frequency,
        ),
        depth + 1,
        showIntersection,
      );

      final colorArgb = wavelengthToArgb(incidentRay.wavelength);
      addRay(
        LightRay(
          trapeziumWidth: BendingLightConstants.characteristicLength / 2,
          tail: incidentRay.tail,
          tip: intersection.point,
          indexOfRefraction: n1,
          wavelength: wavelengthInN1,
          wavelengthInVacuum: incidentRay.wavelength * 1e9,
          powerFraction: incidentRay.power,
          colorArgb: colorArgb,
          waveWidth: waveWidth,
          numWavelengthsPhaseOffset: 0,
          extend: true,
          extendBackwards: false,
          laserView: laserView,
          rayType: 'prism',
        ),
      );
    } else {
      final colorArgb = wavelengthToArgb(incidentRay.wavelength);
      addRay(
        LightRay(
          trapeziumWidth: BendingLightConstants.characteristicLength / 2,
          tail: incidentRay.tail,
          tip: incidentRay.tail +
              incidentRay.directionUnitVector *
                  BendingLightConstants.prismUnboundedRayLength,
          indexOfRefraction: n1,
          wavelength: wavelengthInN1,
          wavelengthInVacuum: incidentRay.wavelength * 1e9,
          powerFraction: incidentRay.power,
          colorArgb: colorArgb,
          waveWidth: waveWidth,
          numWavelengthsPhaseOffset: 0,
          extend: true,
          extendBackwards: false,
          laserView: laserView,
          rayType: 'prism',
        ),
      );
    }
  }

  Intersection? _getIntersection(ColoredRay incidentRay) {
    final all = <Intersection>[];
    for (final prism in prisms) {
      all.addAll(
        prism.getIntersections(
          incidentRay.tail,
          incidentRay.directionUnitVector,
        ),
      );
    }
    if (all.isEmpty) return null;
    all.sort(
      (a, b) => a.point
          .distance(incidentRay.tail)
          .compareTo(b.point.distance(incidentRay.tail)),
    );
    return all.first;
  }

  @override
  void reset() {
    super.reset();
    manyRays = 1;
    showReflections = false;
    showNormals = false;
    showProtractor = false;
    environmentMedium = _initialEnv;
    prismMedium = _initialPrism;
    prisms.clear();
    intersections.clear();
    // Restore laser to horizontal pointing right (π, near-zero distance)
    laser.setAngle(mathPi);
    updateModel();
  }
}
