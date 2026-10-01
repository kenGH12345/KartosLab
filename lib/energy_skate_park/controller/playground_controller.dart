import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/controller/view_properties.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/control_point.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/playground_model.dart';
import 'package:kratos/energy_skate_park/model/track.dart';

class PlaygroundController extends EspController {
  PlaygroundController()
      : super(
          PlaygroundModel(),
          view: EspViewProperties()..barGraphVisible = true,
        );

  PlaygroundModel get playgroundModel => model as PlaygroundModel;

  Track? _dragTrack;
  ControlPoint? _dragCp;

  /// Selected CP for split/delete UI (ControlPointUI.ts).
  Track? selectedTrack;
  int? selectedControlPointIndex;

  void addTrack() {
    final n = playgroundModel.getNumberOfControlPoints();
    if (n >= EspConstants.maxNumberControlPoints) return;
    playgroundModel.createDraggableTrack();
    clearSelection();
    tryJoinTracks();
    notifyListeners();
  }

  void clearTracks() {
    playgroundModel.clearTracks();
    _dragTrack = null;
    _dragCp = null;
    clearSelection();
    notifyListeners();
  }

  void clearSelection() {
    selectedTrack = null;
    selectedControlPointIndex = null;
  }

  void selectControlPoint(Track track, int index) {
    if (!playgroundModel.tracks.contains(track)) return;
    if (index < 0 || index >= track.controlPoints.length) return;
    selectedTrack = track;
    selectedControlPointIndex = index;
    notifyListeners();
  }

  /// Pick nearest CP and select it (tap / long-press without drag).
  bool selectNearestControlPoint(EspVec modelPos) {
    final hit = _findNearestCp(modelPos);
    if (hit == null) {
      clearSelection();
      notifyListeners();
      return false;
    }
    selectControlPoint(hit.$1, hit.$2);
    return true;
  }

  void tryJoinTracks() {
    final list = List.of(playgroundModel.tracks);
    for (var i = 0; i < list.length; i++) {
      for (var j = i + 1; j < list.length; j++) {
        final joined = playgroundModel.joinTracks(list[i], list[j]);
        if (joined != null) {
          notifyListeners();
          return;
        }
      }
    }
  }

  (Track, int)? _findNearestCp(EspVec modelPos) {
    Track? bestTrack;
    var bestIndex = -1;
    var bestD2 = EspConstants.controlPointPickRadius *
        EspConstants.controlPointPickRadius;

    for (final track in playgroundModel.tracks) {
      if (!track.configurable) continue;
      for (var i = 0; i < track.controlPoints.length; i++) {
        final cp = track.controlPoints[i];
        if (!cp.interactive) continue;
        final dx = cp.x - modelPos.x;
        final dy = cp.y - modelPos.y;
        final d2 = dx * dx + dy * dy;
        if (d2 <= bestD2) {
          bestD2 = d2;
          bestTrack = track;
          bestIndex = i;
        }
      }
    }
    if (bestTrack == null || bestIndex < 0) return null;
    return (bestTrack, bestIndex);
  }

  /// Begin dragging a control point (model meters pick).
  bool beginControlPointDrag(EspVec modelPos) {
    final hit = _findNearestCp(modelPos);
    if (hit == null) return false;
    final track = hit.$1;
    final index = hit.$2;
    final cp = track.controlPoints[index];
    _dragTrack = track;
    _dragCp = cp;
    cp.dragging = true;
    selectedTrack = track;
    selectedControlPointIndex = index;
    notifyListeners();
    return true;
  }

  void dragControlPoint(EspVec modelPos) {
    final cp = _dragCp;
    final track = _dragTrack;
    if (cp == null || track == null) return;
    cp.x = modelPos.x;
    cp.y = modelPos.y.clamp(0.0, 8.0);
    track.updateLinSpace();
    track.updateSplines();
    notifyListeners();
  }

  void endControlPointDrag() {
    final cp = _dragCp;
    if (cp != null) cp.dragging = false;
    _dragCp = null;
    _dragTrack = null;
    tryJoinTracks();
    // Refresh selection indices after possible join (tracks replaced).
    if (selectedTrack != null &&
        !playgroundModel.tracks.contains(selectedTrack)) {
      clearSelection();
    }
    notifyListeners();
  }

  /// Split selected interior CP — EnergySkateParkModel.splitControlPoint.
  bool splitSelectedControlPoint() {
    final track = selectedTrack;
    final index = selectedControlPointIndex;
    if (track == null || index == null) return false;
    final angle = playgroundModel.modelAngleAtControlPoint(track, index);
    final ok = playgroundModel.splitControlPoint(track, index, angle);
    if (ok) clearSelection();
    notifyListeners();
    return ok;
  }

  /// Long-press split shortcut on nearest CP.
  bool splitAt(EspVec modelPos) {
    final hit = _findNearestCp(modelPos);
    if (hit == null) return false;
    final track = hit.$1;
    final index = hit.$2;
    if (index <= 0 || index >= track.controlPoints.length - 1) return false;
    final angle = playgroundModel.modelAngleAtControlPoint(track, index);
    final ok = playgroundModel.splitControlPoint(track, index, angle);
    if (ok) clearSelection();
    notifyListeners();
    return ok;
  }

  bool deleteSelectedControlPoint() {
    final track = selectedTrack;
    final index = selectedControlPointIndex;
    if (track == null || index == null) return false;
    final ok = playgroundModel.deleteControlPoint(track, index);
    if (ok) clearSelection();
    notifyListeners();
    return ok;
  }

  bool get canSplitSelected {
    final track = selectedTrack;
    final index = selectedControlPointIndex;
    if (track == null || index == null) return false;
    if (!track.splittable) return false;
    if (index <= 0 || index >= track.controlPoints.length - 1) return false;
    return playgroundModel.canCutTrackControlPoint();
  }

  bool get canDeleteSelected {
    final track = selectedTrack;
    final index = selectedControlPointIndex;
    if (track == null || index == null) return false;
    return true;
  }

  @override
  void setReferenceHeight(double h) {
    playgroundModel.skater.referenceHeight = h.clamp(
      EspConstants.referenceHeightMin,
      EspConstants.referenceHeightMax,
    );
    playgroundModel.skater.updateEnergy();
    notifyListeners();
  }

  @override
  void reset() {
    clearSelection();
    super.reset();
  }
}
