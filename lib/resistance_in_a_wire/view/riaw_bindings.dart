import 'package:flutter/foundation.dart';

import '../model/resistance_in_a_wire_model.dart';

/// View-layer [ChangeNotifier] over frozen [ResistanceInAWireModel].
///
/// Does not modify Model; only relays Property notifications for rebuilds.
class ResistanceInAWireBindings extends ChangeNotifier {
  ResistanceInAWireBindings(this.model) {
    _onNumber = (_) => notifyListeners();
    model.resistivityProperty.addListener(_onNumber);
    model.lengthProperty.addListener(_onNumber);
    model.areaProperty.addListener(_onNumber);
    model.resistanceProperty.addListener(_onNumber);
  }

  final ResistanceInAWireModel model;

  late final void Function(double) _onNumber;

  @override
  void dispose() {
    model.resistivityProperty.removeListener(_onNumber);
    model.lengthProperty.removeListener(_onNumber);
    model.areaProperty.removeListener(_onNumber);
    model.resistanceProperty.removeListener(_onNumber);
    super.dispose();
  }
}
