import '../model/explore1d_model.dart';
import 'collision_lab_controller.dart';

class Explore1dController extends CollisionLabController {
  Explore1dController() : super(Explore1dModel());

  Explore1dModel get explore1dModel => model as Explore1dModel;
}
