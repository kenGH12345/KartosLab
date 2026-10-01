import 'package:kratos/energy_skate_park/model/premade_tracks.dart';
import 'package:kratos/energy_skate_park/model/save_sample_model.dart';
import 'package:kratos/energy_skate_park/model/track.dart';

/// Premade track scene identifiers (PremadeTracks.TrackTypes).
enum TrackScene { parabola, ramp, doubleWell, loop }

/// EnergySkateParkTrackSetModel.ts — sceneProperty + updateActiveTrack.
class TrackSetModel extends SaveSampleModel {
  TrackSetModel({
    required this.trackScenes,
    super.saveSampleInterval,
    super.sampleFadeDecay,
    super.maxNumberOfSamples,
    super.defaultSaveSamples,
    this.tracksConfigurable = false,
  }) : scene = trackScenes.first,
        super(tracks: _buildTracks(trackScenes, tracksConfigurable)) {
    updateActiveTrack(scene);
  }

  final List<TrackScene> trackScenes;
  final bool tracksConfigurable;
  TrackScene scene;

  static List<Track> _buildTracks(
    List<TrackScene> scenes,
    bool configurable,
  ) {
    return [
      for (final s in scenes) _createForScene(s, configurable: configurable),
    ];
  }

  static Track _createForScene(TrackScene scene, {bool configurable = false}) {
    switch (scene) {
      case TrackScene.parabola:
        return PremadeTracks.createParabola(physical: false);
      case TrackScene.ramp:
        return PremadeTracks.createTrack(
          PremadeTracks.createRampControlPoints(),
          physical: false,
          slopeToGround: true,
        );
      case TrackScene.doubleWell:
        return PremadeTracks.createDoubleWell(physical: false);
      case TrackScene.loop:
        return PremadeTracks.createLoop(physical: false);
    }
  }

  /// When scene changes: only matching track is physical; skater detaches.
  void updateActiveTrack(TrackScene trackType) {
    scene = trackType;
    final sceneIndex = trackScenes.indexOf(trackType);
    for (var i = 0; i < tracks.length; i++) {
      tracks[i].physical = (i == sceneIndex);
    }
    skater.track = null;
    skater.parametricSpeed = 0;
    skater.velocityX = 0;
    skater.velocityY = 0;
    skater.positionX = 3.5;
    skater.positionY = 0;
    skater.angle = 0;
    skater.thermalEnergy = 0;
    skater.updateEnergy();
    clearEnergyData();
  }

  void setScene(TrackScene trackType) {
    if (!trackScenes.contains(trackType)) return;
    if (scene == trackType) return;
    updateActiveTrack(trackType);
  }

  Track? get activeTrack {
    for (final t in tracks) {
      if (t.physical) return t;
    }
    return null;
  }

  @override
  void reset() {
    super.reset();
    scene = trackScenes.first;
    updateActiveTrack(scene);
    pathVisible = defaultSaveSamples;
    preventSampleSave = false;
  }
}
