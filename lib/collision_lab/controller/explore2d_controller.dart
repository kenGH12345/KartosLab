import '../model/explore2d_model.dart';
import 'collision_lab_controller.dart';

class Explore2dController extends CollisionLabController {
  Explore2dController() : super(Explore2dModel());

  Explore2dModel get explore2dModel => model as Explore2dModel;
}
