import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kratos/energy_forms_and_changes/common/model/beaker.dart';
import 'package:kratos/energy_forms_and_changes/common/model/burner.dart';
import 'package:kratos/energy_forms_and_changes/common/model/thermal_container.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/air.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/intro_energy_chunk_system.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/efac_intro_z_order.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/sticky_thermometer.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/thermal_block.dart';


enum EfacTimeSpeed { normal, fastForward }

/// PhET `EFACIntroModel` — thermal playground with blocks, beakers, burners, thermometers.
class EfacIntroModel extends ChangeNotifier {
  EfacIntroModel() {
    _buildGroundSpots();
    air = Air();
    chunkSystem = IntroEnergyChunkSystem();
    leftBurner = Burner(
      id: 'leftBurner',
      position: Offset(_groundSpotX[leftBurnerGroundSpotIndex], 0),
    );
    rightBurner = Burner(
      id: 'rightBurner',
      position: Offset(_groundSpotX[leftBurnerGroundSpotIndex + 1], 0),
    );
    burners.addAll([leftBurner, rightBurner]);
    _createDefaultElements();
    _createThermometers();
  }

  static const double leftEdge = -0.30;
  static const double rightEdge = 0.30;
  static const double edgePad = 0.016;
  static const double beakerWidth = EfacIntroBeaker.beakerWidth;
  static const int leftBurnerGroundSpotIndex = 2;
  static const int numberOfGroundSpots =
      EfacConstants.maxNumberOfIntroBurners +
          EfacConstants.maxNumberOfIntroElements;
  static const double fallAcceleration = -9.8;
  static const int thermometerCount = 4;
  /// Temporary until view sets storage via MVT; must NOT be far off-screen.
  static const Offset thermometerIdleModel = Offset(-0.28, 0.42);

  late final Air air;
  late final Burner leftBurner;
  late final Burner rightBurner;
  late final IntroEnergyChunkSystem chunkSystem;

  final List<Burner> burners = <Burner>[];
  final List<ThermalBlock> blocks = <ThermalBlock>[];
  final List<Beaker> beakers = <Beaker>[];
  final List<StickyThermometer> thermometers = <StickyThermometer>[];
  final List<double> _groundSpotX = <double>[];
  final Map<String, Offset> _homePositions = <String, Offset>{};

  /// Thermometer storage positions in model space (set by view via MVT).
  final List<Offset> thermometerStoragePositions = List<Offset>.generate(
    thermometerCount,
    (_) => thermometerIdleModel,
  );

  bool energyChunksVisible = false;
  bool linkedHeaters = false;
  bool isPlaying = true;
  EfacTimeSpeed timeSpeed = EfacTimeSpeed.normal;

  double get spaceBetweenGroundSpotCenters =>
      numberOfGroundSpots <= 1 ? 0 : (_groundSpotX[1] - _groundSpotX[0]);

  List<double> get groundSpotXPositions =>
      List<double>.unmodifiable(_groundSpotX);

  List<ThermalContainer> get thermalContainers =>
      <ThermalContainer>[...blocks, ...beakers];

  void _buildGroundSpots() {
    final spaceBetween = (rightEdge - leftEdge - edgePad * 2 - beakerWidth) /
        (numberOfGroundSpots - 1);
    final leftPad = leftEdge + edgePad + beakerWidth / 2;
    _groundSpotX.clear();
    for (var i = 0; i < numberOfGroundSpots; i++) {
      // PhET: roundSymmetric(x * 1000) / 1000
      final x = ((spaceBetween * i + leftPad) * 1000).round() / 1000;
      _groundSpotX.add(x);
    }
  }

  void _createDefaultElements() {
    // Spot layout with 2 burners:
    // [0 iron][1 brick][2 L burner][3 R burner][4 water][5 olive oil]
    blocks
      ..clear()
      ..add(ThermalBlock(
        id: 'iron',
        blockType: BlockType.iron,
        position: Offset(_groundSpotX[0], 0),
        zIndex: 0,
      ))
      ..add(ThermalBlock(
        id: 'brick',
        blockType: BlockType.brick,
        position: Offset(_groundSpotX[1], 0),
        zIndex: 1,
      ));
    beakers
      ..clear()
      ..add(Beaker(
        id: 'water',
        beakerType: BeakerType.water,
        position: Offset(_groundSpotX[4], 0),
      ))
      ..add(Beaker(
        id: 'oliveOil',
        beakerType: BeakerType.oliveOil,
        position: Offset(_groundSpotX[5], 0),
      ));

    for (final b in blocks) {
      _homePositions[b.id] = b.position;
      chunkSystem.seedForEnergy(
        b.bounds.center,
        b.energy,
        b.energyChunks,
      );
    }
    for (final b in beakers) {
      _homePositions[b.id] = b.position;
      chunkSystem.seedForEnergy(
        b.thermalContactArea.center,
        b.energy,
        b.energyChunks,
      );
    }
    // Initial z from PhET position rules (right-of / higher-minY).
    EfacIntroZOrder.applyBlockZIndices(blocks);
  }

  void _createThermometers() {
    thermometers.clear();
    for (var i = 0; i < thermometerCount; i++) {
      thermometers.add(
        StickyThermometer(
          id: 'thermometer$i',
          position: thermometerStoragePositions[i],
        ),
      );
    }
  }

  void setThermometerStoragePositions(List<Offset> modelPositions) {
    for (var i = 0; i < thermometerCount && i < modelPositions.length; i++) {
      thermometerStoragePositions[i] = modelPositions[i];
      if (!thermometers[i].active) {
        thermometers[i].position = modelPositions[i];
      }
    }
    notifyListeners();
  }

  double get _speedMultiplier =>
      timeSpeed == EfacTimeSpeed.fastForward
          ? EfacConstants.fastForwardMultiplier
          : 1;

  void step(double dt) {
    final capped = dt > EfacConstants.maxDt ? EfacConstants.maxDt : dt;
    if (isPlaying) {
      stepModel(capped * _speedMultiplier);
    }
    for (final t in thermometers) {
      t.stepFollow();
      t.updateSense(
        blocks: blocks,
        beakers: beakers,
        burners: burners,
        air: air,
      );
    }
    notifyListeners();
  }

  void manualStep() {
    stepModel(EfacConstants.simTimePerTickNormal);
    for (final t in thermometers) {
      t.stepFollow();
      t.updateSense(
        blocks: blocks,
        beakers: beakers,
        burners: burners,
        air: air,
      );
    }
    notifyListeners();
  }

  /// Full thermal step order — EFACIntroModel.ts:424-651 (continuous energy + fall).
  /// Energy-chunk balance transfer is seeded/wandered; full transfer bookkeeping continues in Phase 7.
  void stepModel(double dt) {
    // 1) fall / snap
    for (final el in thermalContainers) {
      final atSpot = _groundSpotX.contains(el.position.dx);
      final raised = el.position.dy != 0;
      if (!el.userControlled &&
          el.supportingSurface == null &&
          (raised || !atSpot)) {
        fallToSurface(el, dt);
      }
    }
    // Position-driven block z-order (EFACIntroScreenView blockChangeListener).
    EfacIntroZOrder.applyBlockZIndices(blocks);

    // 2) fluid displacement
    final blockBounds = blocks.map((b) => b.bounds).toList();
    for (final beaker in beakers) {
      beaker.updateFluidDisplacement(blockBounds);
    }

    // 3) container ↔ container
    final containers = thermalContainers;
    for (var i = 0; i < containers.length; i++) {
      for (var j = i + 1; j < containers.length; j++) {
        containers[i].exchangeEnergyWith(containers[j], dt);
      }
    }

    // 4) burners → objects / air
    for (final burner in burners) {
      final onTop = <ThermalContainer>[];
      for (final c in containers) {
        if (burner.inContactWith(c.bounds)) onTop.add(c);
      }
      if (onTop.isNotEmpty) {
        for (final c in onTop) {
          if (c.temperature > EfacConstants.waterFreezingPointTemperature) {
            final delta = burner.energyDeltaForObject(
              dt,
              objectEnergyAboveMin: c.energyAboveMinimum,
            );
            c.changeEnergy(delta);
          }
        }
      } else {
        burner.energyDeltaForAir(dt); // air energy no-op
      }
    }

    // 5) containers ↔ air (skip immersed blocks)
    for (final c in containers) {
      if (_isImmersedInBeaker(c)) continue;
      if (c is ThermalBlock) {
        air.exchangeWithBlock(c, dt);
      } else if (c is Beaker) {
        air.exchangeEnergyWithContainer(
          getTemperature: () => c.temperature,
          changeContainerEnergy: c.changeEnergy,
          containerCategory: c.category,
          contactLength: c.width,
          getEnergyBeyondMaxTemperature: c.energyBeyondMaxTemperature,
          dt: dt,
        );
      }
    }

    // 6) wander + element step
    chunkSystem.step(dt);
    air.stepChunks(dt);
      for (final c in containers) {
      c.step(dt);
    }

    // 7) emit thermal chunks from heating burners into air when nothing on top
    _maybeEmitBurnerChunks(dt);
  }

  void _maybeEmitBurnerChunks(double dt) {
    for (final burner in burners) {
      if (burner.heatCoolLevel <= 0) continue;
      var occupied = false;
      for (final c in thermalContainers) {
        if (burner.inContactWith(c.bounds)) {
          occupied = true;
          break;
        }
      }
      if (occupied) continue;
      // Spawn occasional rising chunk — rate tied to heat level.
      if (burner.heatCoolLevel * dt > 0.02) {
        final c = chunkSystem.createThermal(burner.bounds.center);
        chunkSystem.wanderTo(
          c,
          Offset(burner.position.dx, EfacConstants.introScreenEnergyChunkMaxTravelHeight),
          xMin: burner.position.dx - Burner.sideLength / 3,
          xMax: burner.position.dx + Burner.sideLength / 3,
          wanderAngleVariation: 0.15 * 3.141592653589793,
        );
        air.energyChunks.add(c);
      }
    }
  }

  bool _isImmersedInBeaker(ThermalContainer c) {
    if (c is! ThermalBlock) return false;
    for (final beaker in beakers) {
      if (beaker.thermalContactArea.intersects(c.bounds)) return true;
    }
    return false;
  }

  /// PhET fallToSurface — EFACIntroModel.ts:731-856
  void fallToSurface(ThermalContainer element, double dt) {
    var minY = 0.0;
    final spots = [..._groundSpotX]
      ..sort((a, b) =>
          (a - element.position.dx).abs().compareTo((b - element.position.dx).abs()));

    double? destX;
    HorizontalSurface? destSurface;
    final half = spaceBetweenGroundSpotCenters / 2;

    for (final spotX in spots) {
      if (destX != null || destSurface != null) break;

      final inSpot = <ThermalContainer>[];
      for (final other in thermalContainers) {
        if (identical(other, element)) continue;
        if ((other.position.dx - spotX).abs() <= half &&
            other.position.dy <= element.position.dy) {
          inSpot.add(other);
        }
      }

      // Burner top surfaces at this spot
      HorizontalSurface? burnerSurface;
      for (final burner in burners) {
        if ((burner.position.dx - spotX).abs() <= half &&
            burner.topSurface.y <= element.position.dy + 1e-6) {
          burnerSurface = burner.topSurface;
        }
      }

      if (inSpot.isNotEmpty) {
        final beakerInSpot = inSpot.any((e) => e is Beaker);
        if (beakerInSpot && element is Beaker) continue;

        HorizontalSurface? best;
        for (final e in inSpot) {
          final top = e.topSurface;
          if (top == null) continue;
          if (best == null || top.y > best.y) best = top;
        }
        if (burnerSurface != null &&
            (best == null || burnerSurface.y >= best.y)) {
          best = burnerSurface;
        }
        destSurface = best;
      } else if (burnerSurface != null) {
        destSurface = burnerSurface;
      } else {
        destX = spotX;
      }
    }

    destX ??= element.position.dx;

    if (destSurface != null) {
      minY = destSurface.y;
      element.position = Offset(destSurface.x, element.position.dy);
    } else {
      element.position = Offset(destX, element.position.dy);
    }

    final v = element.verticalVelocity + fallAcceleration * dt;
    var proposedY = element.position.dy + v * dt;
    if (proposedY < minY) {
      proposedY = minY;
      element.verticalVelocity = 0;
      if (destSurface != null) {
        element.supportingSurface = destSurface;
        destSurface.elementOnSurface = element;
      }
    } else {
      element.verticalVelocity = v;
    }
    element.position = Offset(element.position.dx, proposedY);
  }

  void setHeatCoolLevel(Burner burner, double level) {
    final clamped = level.clamp(-1.0, 1.0);
    if (linkedHeaters) {
      leftBurner.heatCoolLevel = clamped;
      rightBurner.heatCoolLevel = clamped;
    } else {
      burner.heatCoolLevel = clamped;
    }
    notifyListeners();
  }

  void setEnergyChunksVisible(bool value) {
    energyChunksVisible = value;
    notifyListeners();
  }

  void setLinkedHeaters(bool value) {
    linkedHeaters = value;
    if (value) rightBurner.heatCoolLevel = leftBurner.heatCoolLevel;
    notifyListeners();
  }

  void setPlaying(bool value) {
    isPlaying = value;
    notifyListeners();
  }

  void setTimeSpeed(EfacTimeSpeed speed) {
    timeSpeed = speed;
    notifyListeners();
  }

  void moveBlock(ThermalBlock block, Offset modelPos) {
    block.userControlled = true;
    block.supportingSurface = null;
    block.position = Offset(modelPos.dx, modelPos.dy < 0 ? 0 : modelPos.dy);
    EfacIntroZOrder.applyBlockZIndices(blocks);
    notifyListeners();
  }

  void endBlockDrag(ThermalBlock block) {
    block.userControlled = false;
    EfacIntroZOrder.applyBlockZIndices(blocks);
    notifyListeners();
  }

  void moveBeaker(Beaker beaker, Offset modelPos) {
    beaker.userControlled = true;
    beaker.supportingSurface = null;
    beaker.position = Offset(modelPos.dx, modelPos.dy < 0 ? 0 : modelPos.dy);
    // Beaker front-order is derived from centerY at render time (PhET listener).
    notifyListeners();
  }

  void endBeakerDrag(Beaker beaker) {
    beaker.userControlled = false;
    notifyListeners();
  }

  void moveThermometer(StickyThermometer t, Offset modelPos) {
    t.userControlled = true;
    t.stopFollowing();
    t.active = true;
    t.position = modelPos;
    notifyListeners();
  }

  void endThermometerDrag(StickyThermometer t) {
    t.userControlled = false;
    // Sticky attach: highest zIndex block, else beaker fluid.
    final tip = t.position;
    final sorted = [...blocks]..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    ThermalBlock? stickBlock;
    for (final b in sorted) {
      if (b.projectedShape.containsPoint(tip)) stickBlock = b;
    }
    if (stickBlock != null) {
      t.startFollowingBlock(stickBlock);
    } else {
      for (final beaker in beakers) {
        if (beaker.thermalContactArea.containsPoint(tip)) {
          t.startFollowingBeaker(beaker);
          break;
        }
      }
    }
    // Return to storage if near storage area (view checks; model: far left idle)
    notifyListeners();
  }

  void returnThermometerToStorage(StickyThermometer t, int index) {
    t.reset(thermometerStoragePositions[index]);
    notifyListeners();
  }

  void reset() {
    energyChunksVisible = false;
    linkedHeaters = false;
    isPlaying = true;
    timeSpeed = EfacTimeSpeed.normal;
    air.reset();
    chunkSystem.clear();
    leftBurner.reset();
    rightBurner.reset();
    for (final b in blocks) {
      b.reset(home: _homePositions[b.id]!);
      chunkSystem.seedForEnergy(b.bounds.center, b.energy, b.energyChunks);
    }
    for (final b in beakers) {
      b.reset(home: _homePositions[b.id]!);
      chunkSystem.seedForEnergy(
        b.thermalContactArea.center,
        b.energy,
        b.energyChunks,
      );
    }
    for (var i = 0; i < thermometers.length; i++) {
      thermometers[i].reset(thermometerStoragePositions[i]);
    }
    notifyListeners();
  }
}
