import 'dart:math' as math;

import 'package:kratos/energy_skate_park/model/skater_image_set.dart';

import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/view_properties.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/esp_model.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/measure_model.dart';
import 'package:kratos/energy_skate_park/model/track.dart';

/// Shared controller: clock commands + skater drag (ChangeNotifier).
class EspController extends ChangeNotifier {
  EspController(this.model, {EspViewProperties? view})
      : view = view ?? EspViewProperties();

  final EspModel model;
  final EspViewProperties view;

  /// ToolboxPanel global bounds for return-to-toolbox (EnergySkateParkScreenView.ts).
  final GlobalKey toolboxPanelKey = GlobalKey();

  bool draggingSkater = false;
  bool? _wasPausedBeforeDrag;

  bool get isPlaying => !model.paused;

  void tick(double wallDt) {
    if (model.paused) return;
    model.step(wallDt);
    notifyListeners();
  }

  void playPause() {
    model.paused = !model.paused;
    notifyListeners();
  }

  void play() {
    model.paused = false;
    notifyListeners();
  }

  void pause() {
    model.paused = true;
    notifyListeners();
  }

  void stepForward() {
    if (!model.paused) return;
    model.manualStep();
    notifyListeners();
  }

  void setSlow(bool slow) {
    model.slow = slow;
    notifyListeners();
  }

  void setFriction(double v) {
    model.friction = v.clamp(EspConstants.minFriction, EspConstants.maxFriction);
    notifyListeners();
  }

  void setGravityMagnitude(double g) {
    model.gravityMagnitude = g;
    notifyListeners();
  }

  void setMass(double m) {
    model.skater.mass = m.clamp(20.0, 100.0);
    model.skater.updateEnergy();
    notifyListeners();
  }

  void setStickingToTrack(bool v) {
    model.isStickingToTrack = v;
    notifyListeners();
  }

  void setPieChartVisible(bool v) {
    view.pieChartVisible = v;
    notifyListeners();
  }

  void setBarGraphVisible(bool v) {
    view.barGraphVisible = v;
    notifyListeners();
  }

  void setSpeedVisible(bool v) {
    view.speedVisible = v;
    notifyListeners();
  }

  void setGridVisible(bool v) {
    view.gridVisible = v;
    notifyListeners();
  }

  void setReferenceHeightVisible(bool v) {
    // ReferenceHeightLine.ts:120-124 — reset height when toggling visibility.
    if (!v) {
      setReferenceHeight(0);
    }
    view.referenceHeightVisible = v;
    notifyListeners();
  }

  void setReferenceHeight(double h) {
    final model = this.model;
    if (model is MeasureModel) {
      model.setReferenceHeight(h);
    } else {
      model.skater.referenceHeight = h.clamp(
        EspConstants.referenceHeightMin,
        EspConstants.referenceHeightMax,
      );
      model.skater.updateEnergy();
    }
    notifyListeners();
  }

  void setStopwatchVisible(bool v) {
    if (!v && model.stopwatchVisible) {
      model.tools.onStopwatchHidden();
    }
    model.stopwatchVisible = v;
    notifyListeners();
  }

  /// EnergySkateParkScreenView.ts — instant hide, no animation/snap.
  void returnStopwatchToToolbox() {
    if (!model.stopwatchVisible) return;
    model.tools.onStopwatchHidden();
    model.stopwatchVisible = false;
    notifyListeners();
  }

  void returnMeasuringTapeToToolbox() {
    if (!model.measuringTapeVisible) return;
    model.measuringTapeVisible = false;
    notifyListeners();
  }

  Rect? get toolboxGlobalBounds {
    final ctx = toolboxPanelKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    return origin & box.size;
  }

  bool intersectsToolbox(Rect toolGlobalBounds) {
    final tb = toolboxGlobalBounds;
    if (tb == null) return false;
    return tb.overlaps(toolGlobalBounds);
  }

  void placeStopwatchFromToolbox(Offset viewTopLeft, Size playAreaSize) {
    model.tools.placeStopwatchAtView(viewTopLeft, playAreaSize);
    notifyListeners();
  }

  void dragStopwatch(Offset viewPos, Size playAreaSize) {
    model.tools.dragStopwatchTo(viewPos, playAreaSize);
    notifyListeners();
  }

  void resetStopwatch() {
    model.resetStopwatch();
    notifyListeners();
  }

  /// Stopwatch.ts — visibility false → stop + time 0.
  void onStopwatchDragEnd(Rect globalBounds) {
    if (intersectsToolbox(globalBounds)) {
      returnStopwatchToToolbox();
    }
  }

  /// MeasuringTapeNode baseDragEnded — base bounds only.
  void onMeasuringTapeBaseDragEnd(Rect globalBaseBounds) {
    if (intersectsToolbox(globalBaseBounds)) {
      returnMeasuringTapeToToolbox();
    }
  }

  void setMeasuringTapeVisible(bool v) {
    model.measuringTapeVisible = v;
    if (v && model.measuringTapeDistance < 1e-6) {
      model.tools.resetMeasuringTape();
    }
    notifyListeners();
  }

  void placeMeasuringTapeFromToolbox(EspVec modelBase) {
    model.tools.placeMeasuringTapeAt(modelBase);
    notifyListeners();
  }

  void setMeasuringTapeBase(EspVec pos) {
    model.measuringTapeBase = model.tools.clampTapePoint(pos);
    notifyListeners();
  }

  void setMeasuringTapeTip(EspVec pos) {
    model.measuringTapeTip = model.tools.clampTapePoint(pos);
    notifyListeners();
  }

  /// Move both endpoints preserving model offset (body drag).
  void translateMeasuringTape(EspVec deltaModel) {
    model.measuringTapeBase =
        model.tools.clampTapePoint(model.measuringTapeBase + deltaModel);
    model.measuringTapeTip =
        model.tools.clampTapePoint(model.measuringTapeTip + deltaModel);
    notifyListeners();
  }

  void setSelectedSkater(int index) {
    view.selectedSkaterIndex =
        index.clamp(0, SkaterImageSet.count - 1);
    notifyListeners();
  }

  void returnSkater() {
    model.skater.returnToStartingPosition();
    notifyListeners();
  }

  void reset() {
    model.reset();
    view.reset();
    draggingSkater = false;
    _wasPausedBeforeDrag = null;
    notifyListeners();
  }

  /// Begin skater drag — pause while userControlled.
  void beginSkaterDrag() {
    if (draggingSkater) return;
    draggingSkater = true;
    _wasPausedBeforeDrag = model.paused;
    model.paused = true;
    model.skater.userControlled = true;
    model.skater.velocityX = 0;
    model.skater.velocityY = 0;
    model.skater.parametricSpeed = 0;
    notifyListeners();
  }

  /// Project to track if within 0.5 m (SkaterNode.ts).
  void dragSkater(EspVec modelPos) {
    if (!draggingSkater) beginSkaterDrag();

    final physical = model.getPhysicalTracks();
    Track? bestTrack;
    var bestDist = EspConstants.skaterTrackSnapDistance;
    var bestU = 0.0;
    EspVec? bestPoint;

    for (final track in physical) {
      final closest = track.getClosestPositionAndParameter(modelPos);
      final d = math.sqrt(closest.distance);
      if (d < bestDist) {
        bestDist = d;
        bestTrack = track;
        bestU = closest.parametricPosition;
        bestPoint = closest.point;
      }
    }

    if (bestTrack != null && bestPoint != null) {
      model.skater.track = bestTrack;
      model.skater.parametricPosition = bestU;
      model.skater.positionX = bestPoint.x;
      model.skater.positionY = bestPoint.y;
      model.skater.angle = bestTrack.getViewAngleAt(bestU);
      model.skater.isOnTopSideOfTrack = true;
    } else {
      model.skater.track = null;
      model.skater.positionX = modelPos.x;
      model.skater.positionY = math.max(0, modelPos.y);
      model.skater.angle = 0;
    }
    model.skater.velocityX = 0;
    model.skater.velocityY = 0;
    model.skater.parametricSpeed = 0;
    model.skater.updateEnergy();
    notifyListeners();
  }

  /// End drag — record starting pose (SkaterNode release).
  void endSkaterDrag() {
    if (!draggingSkater) return;
    draggingSkater = false;
    final skater = model.skater;
    skater.userControlled = false;
    skater.startingPositionX = skater.positionX;
    skater.startingPositionY = skater.positionY;
    skater.startingU = skater.parametricPosition;
    skater.startingUp = skater.isOnTopSideOfTrack;
    skater.startingTrack = skater.track;
    skater.startingAngle = skater.angle;
    skater.updateEnergy();

    final restore = _wasPausedBeforeDrag;
    _wasPausedBeforeDrag = null;
    if (restore != null) {
      model.paused = restore;
    }
    notifyListeners();
  }
}
