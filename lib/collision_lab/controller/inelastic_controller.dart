import '../model/inelastic_model.dart';
import 'collision_lab_controller.dart';

class InelasticController extends CollisionLabController {
  InelasticController() : super(InelasticModel());

  InelasticModel get inelasticModel => model as InelasticModel;
}
