import '../particle_mode.dart';
import '../solute_type.dart';
import 'transport_protein.dart';

class LeakageChannel extends TransportProtein {
  LeakageChannel({
    required super.model,
    required super.type,
    required super.position,
  }) : super(initialState: 'open', openStates: const ['open']);

  @override
  bool isAvailableForPassiveTransport(
    SoluteType soluteType,
    MembraneSide location,
  ) {
    return !hasSolutesMovingTowardOrThrough() &&
        model.checkGradientForCrossing(soluteType, location);
  }
}
