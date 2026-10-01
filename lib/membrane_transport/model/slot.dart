import 'membrane_transport_model.dart';
import 'proteins/create_transport_protein.dart';
import 'proteins/transport_protein.dart';
import 'transport_protein_type.dart';

/// Membrane slot that can hold one transport protein — PhET `Slot.ts`.
class Slot {
  Slot({
    required this.model,
    required this.position,
  });

  final MembraneTransportModel model;
  final double position;

  TransportProtein? transportProtein;

  TransportProteinType? get transportProteinType => transportProtein?.type;

  bool get isFilled => transportProtein != null;

  void setTransportProteinType(TransportProteinType? type) {
    transportProtein?.clear(this);
    transportProtein?.dispose();
    transportProtein = type == null
        ? null
        : createTransportProtein(model, type, position);
  }

  void reset() {
    transportProtein?.dispose();
    transportProtein = null;
  }
}
