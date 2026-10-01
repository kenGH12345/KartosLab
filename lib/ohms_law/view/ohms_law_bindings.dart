import 'package:flutter/foundation.dart';

import '../model/ohms_law_model.dart';

/// View-layer [ChangeNotifier] over frozen [OhmsLawModel] properties.
///
/// Does not modify Model; only relays Property notifications for rebuilds.
class OhmsLawBindings extends ChangeNotifier {
  OhmsLawBindings(this.model) {
    _onNumber = (_) => notifyListeners();
    _onUnits = (_) => notifyListeners();
    model.voltageProperty.addListener(_onNumber);
    model.resistanceProperty.addListener(_onNumber);
    model.currentProperty.addListener(_onNumber);
    model.currentUnitsProperty.addListener(_onUnits);
  }

  final OhmsLawModel model;

  late final void Function(double) _onNumber;
  late final void Function(dynamic) _onUnits;

  @override
  void dispose() {
    model.voltageProperty.removeListener(_onNumber);
    model.resistanceProperty.removeListener(_onNumber);
    model.currentProperty.removeListener(_onNumber);
    model.currentUnitsProperty.removeListener(_onUnits);
    super.dispose();
  }
}
