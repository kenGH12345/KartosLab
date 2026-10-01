import 'package:kratos/energy_skate_park/model/track_set_model.dart';

/// EnergySkateParkFullTrackSetModel — all four premade tracks.
class FullTrackSetModel extends TrackSetModel {
  FullTrackSetModel({
    super.defaultSaveSamples = false,
    super.tracksConfigurable = false,
    super.saveSampleInterval,
    super.maxNumberOfSamples,
  }) : super(
          trackScenes: const [
            TrackScene.parabola,
            TrackScene.ramp,
            TrackScene.doubleWell,
            TrackScene.loop,
          ],
        );
}
