import '../model/intro_model.dart';
import 'collision_lab_controller.dart';

class IntroController extends CollisionLabController {
  IntroController() : super(IntroModel());

  IntroModel get introModel => model as IntroModel;
}
