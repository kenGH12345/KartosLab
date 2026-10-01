import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/controller/view_properties.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/measure_model.dart';
import 'package:kratos/energy_skate_park/model/track_set_model.dart';

class MeasureController extends EspController {
  MeasureController()
      : super(
          MeasureModel(),
          view: EspViewProperties()
            ..barGraphVisible = false
            ..speedVisible = true
            ..referenceHeightVisible = true,
        );

  MeasureModel get measureModel => model as MeasureModel;

  void setScene(TrackScene scene) {
    measureModel.setScene(scene);
    notifyListeners();
  }

  void setPathVisible(bool v) {
    measureModel.pathVisible = v;
    if (!v) measureModel.clearEnergyData();
    notifyListeners();
  }

  void setSensorProbe(EspVec pos) {
    measureModel.sensorProbePosition = EspVec(
      pos.x,
      pos.y.clamp(0.0, EspConstants.referenceHeightMax + 2),
    );
    notifyListeners();
  }

  @override
  void setReferenceHeight(double h) {
    measureModel.setReferenceHeight(h);
    notifyListeners();
  }

  @override
  void setStopwatchVisible(bool v) {
    measureModel.stopwatchVisible = v;
    notifyListeners();
  }

  @override
  void resetStopwatch() {
    measureModel.resetStopwatch();
    notifyListeners();
  }
}
