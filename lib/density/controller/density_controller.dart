import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../density_constants.dart';
import '../interaction/pointer_drag.dart';
import '../model/compare_state.dart';
import '../model/density_block.dart';
import '../model/density_material.dart';
import '../model/density_vec.dart';
import '../model/intro_state.dart';
import '../model/mystery_state.dart';
import '../render/density_mvt.dart';
import '../render/density_render_data.dart';
import '../solver/buoyancy_world.dart';
import '../solver/density_relation.dart';

enum DensityScreenId { intro, compare, mystery }

class DensityController extends ChangeNotifier {
  DensityController({math.Random? random})
    : intro = IntroState.initial(),
      compare = CompareState.initial(),
      mystery = MysteryState.initial(random: random ?? math.Random());

  IntroState intro;
  CompareState compare;
  MysteryState mystery;
  DensityScreenId screen = DensityScreenId.intro;

  String? grabbedId;
  DensityVec? grabOffset;
  DensityVec? pointerWorld;
  double fluidSurfaceY = fluidSurfaceYFromVolume(
    DensityConstants.desiredStartingPoolVolume,
  );
  double scaleKg = 0;

  List<DensityBlock> get visibleBlocks {
    switch (screen) {
      case DensityScreenId.intro:
        return [
          intro.blockA,
          if (intro.blockB.visible) intro.blockB,
        ];
      case DensityScreenId.compare:
        return compare.visibleBlocks;
      case DensityScreenId.mystery:
        return mystery.visibleBlocks;
    }
  }

  void selectScreen(DensityScreenId next) {
    _release();
    screen = next;
    notifyListeners();
  }

  void step(double dt) {
    final result = BuoyancyWorld.step(
      blocks: visibleBlocks,
      dt: dt,
      grabbedId: grabbedId,
      pointerWorld: pointerWorld,
      measureScale: screen == DensityScreenId.mystery,
    );
    fluidSurfaceY = result.fluidSurfaceY;
    scaleKg = result.scaleKg;
    _writeBlocks(result.blocks);
    notifyListeners();
  }

  void pointerDown(Offset screen, DensityMvt mvt) {
    final hit = PointerDrag.hitTest(
      blocks: visibleBlocks,
      mvt: mvt,
      screen: screen,
    );
    if (hit == null) return;
    grabbedId = hit.blockId;
    grabOffset = DensityVec(hit.localOffset.dx, hit.localOffset.dy);
    _replaceBlock(hit.blockId, PointerDrag.beginGrab);
    final world = mvt.toWorld(screen);
    pointerWorld = DensityVec(
      world.x - grabOffset!.x,
      world.y - grabOffset!.y,
    );
    notifyListeners();
  }

  void pointerMove(Offset screen, DensityMvt mvt) {
    if (grabbedId == null || grabOffset == null) return;
    final world = mvt.toWorld(screen);
    pointerWorld = DensityVec(
      world.x - grabOffset!.x,
      world.y - grabOffset!.y,
    );
    notifyListeners();
  }

  void pointerUp() {
    _release();
    notifyListeners();
  }

  void setIntroMode(TwoBlockMode mode) {
    intro = intro.withMode(mode);
    notifyListeners();
  }

  void setIntroMaterial(String blockId, DensityMaterialId material) {
    _mapIntro(
      blockId,
      (b) => DensityRelation.setMaterial(b, material),
    );
  }

  void setIntroMass(String blockId, double mass) {
    _mapIntro(blockId, (b) => DensityRelation.setMass(b, mass));
  }

  void setIntroVolumeLiters(String blockId, double liters) {
    final snapped = (liters * 2).round() / 2;
    _mapIntro(
      blockId,
      (b) => DensityRelation.setVolume(
        b,
        DensityConstants.cubicMetersFromLiters(snapped),
      ),
    );
  }

  void resetIntro() {
    _release();
    intro = IntroState.initial();
    notifyListeners();
  }

  void setCompareSet(CompareBlockSet set) {
    _release();
    compare = compare.withBlockSet(set);
    notifyListeners();
  }

  void setCompareLockedMass(double mass) {
    compare = compare.withLockedMass(mass);
    notifyListeners();
  }

  void setCompareLockedVolumeLiters(double liters) {
    compare = compare.withLockedVolume(
      DensityConstants.cubicMetersFromLiters(liters),
    );
    notifyListeners();
  }

  void setCompareLockedDensity(double density) {
    compare = compare.withLockedDensity(density);
    notifyListeners();
  }

  void resetCompare() {
    _release();
    compare = CompareState.initial();
    notifyListeners();
  }

  void setMysterySet(MysteryBlockSet set) {
    _release();
    mystery = mystery.withBlockSet(set);
    notifyListeners();
  }

  void refreshMysteryRandom() {
    mystery = mystery.refreshRandom(math.Random());
    notifyListeners();
  }

  void setMysteryTableExpanded(bool expanded) {
    mystery = mystery.copyWith(tableExpanded: expanded);
    notifyListeners();
  }

  void resetMystery() {
    _release();
    mystery = MysteryState.initial();
    notifyListeners();
  }

  DensityRenderData renderData(DensityMvt mvt) {
    final showMass = screen != DensityScreenId.mystery || mystery.massLabelsVisible;
    return DensityRenderData(
      mvt: mvt,
      fluidSurfaceY: fluidSurfaceY,
      scale: screen == DensityScreenId.mystery
          ? DensityScaleView(
              position: BuoyancyWorld.scalePosition,
              massKg: scaleKg,
            )
          : null,
      cubes: [
        for (final b in visibleBlocks)
          DensityCubeView(
            id: b.id,
            tag: b.tag,
            center: b.position,
            volume: b.volume,
            color: DensityMaterialLooks.colorFor(b),
            massKg: DensityRelation.massOf(b),
            showMassLabel: showMass,
            materialId: b.materialId,
            colorArgb: b.colorArgb,
            grabbed: b.id == grabbedId,
          ),
      ],
    );
  }

  void _mapIntro(String id, DensityBlock Function(DensityBlock) fn) {
    if (id == intro.blockA.id) {
      intro = intro.copyWith(blockA: fn(intro.blockA));
    } else if (id == intro.blockB.id) {
      intro = intro.copyWith(blockB: fn(intro.blockB));
    }
    notifyListeners();
  }

  void _replaceBlock(String id, DensityBlock Function(DensityBlock) fn) {
    switch (screen) {
      case DensityScreenId.intro:
        _mapIntro(id, fn);
      case DensityScreenId.compare:
        compare = compare.copyWith(
          sameMassBlocks: _mapList(compare.sameMassBlocks, id, fn),
          sameVolumeBlocks: _mapList(compare.sameVolumeBlocks, id, fn),
          sameDensityBlocks: _mapList(compare.sameDensityBlocks, id, fn),
        );
        notifyListeners();
      case DensityScreenId.mystery:
        mystery = mystery.copyWith(
          set1: _mapList(mystery.set1, id, fn),
          set2: _mapList(mystery.set2, id, fn),
          set3: _mapList(mystery.set3, id, fn),
          randomBlocks: _mapList(mystery.randomBlocks, id, fn),
        );
        notifyListeners();
    }
  }

  void _writeBlocks(List<DensityBlock> next) {
    switch (screen) {
      case DensityScreenId.intro:
        DensityBlock a = intro.blockA;
        DensityBlock b = intro.blockB;
        for (final n in next) {
          if (n.id == a.id) a = n;
          if (n.id == b.id) b = n;
        }
        intro = intro.copyWith(blockA: a, blockB: b);
      case DensityScreenId.compare:
        compare = compare.copyWith(
          sameMassBlocks: _merge(compare.sameMassBlocks, next),
          sameVolumeBlocks: _merge(compare.sameVolumeBlocks, next),
          sameDensityBlocks: _merge(compare.sameDensityBlocks, next),
        );
      case DensityScreenId.mystery:
        mystery = mystery.copyWith(
          set1: _merge(mystery.set1, next),
          set2: _merge(mystery.set2, next),
          set3: _merge(mystery.set3, next),
          randomBlocks: _merge(mystery.randomBlocks, next),
        );
    }
  }

  List<DensityBlock> _mapList(
    List<DensityBlock> list,
    String id,
    DensityBlock Function(DensityBlock) fn,
  ) {
    return [for (final b in list) b.id == id ? fn(b) : b];
  }

  List<DensityBlock> _merge(List<DensityBlock> current, List<DensityBlock> next) {
    final byId = {for (final b in next) b.id: b};
    return [for (final b in current) byId[b.id] ?? b];
  }

  void _release() {
    grabbedId = null;
    grabOffset = null;
    pointerWorld = null;
  }
}
