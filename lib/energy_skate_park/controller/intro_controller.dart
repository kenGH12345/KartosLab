import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/controller/view_properties.dart';
import 'package:kratos/energy_skate_park/model/intro_model.dart';
import 'package:kratos/energy_skate_park/model/track_set_model.dart';

class IntroController extends EspController {
  IntroController()
      : super(
          IntroModel(),
          view: EspViewProperties()..barGraphVisible = true,
        );

  IntroModel get introModel => model as IntroModel;

  void setScene(TrackScene scene) {
    introModel.setScene(scene);
    notifyListeners();
  }
}
