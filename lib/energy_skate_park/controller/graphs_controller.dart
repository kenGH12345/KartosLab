import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/controller/view_properties.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/graphs_model.dart';
import 'package:kratos/energy_skate_park/model/track_set_model.dart';

class GraphsController extends EspController {
  GraphsController()
      : super(
          GraphsModel(),
          view: EspViewProperties()..barGraphVisible = false,
        );

  GraphsModel get graphsModel => model as GraphsModel;

  void setScene(TrackScene scene) {
    graphsModel.setScene(scene);
    notifyListeners();
  }

  void setIndependentVariable(GraphIndependentVariable v) {
    graphsModel.independentVariable = v;
    graphsModel.clearEnergyData();
    notifyListeners();
  }

  void setKineticVisible(bool v) {
    graphsModel.kineticVisible = v;
    notifyListeners();
  }

  void setPotentialVisible(bool v) {
    graphsModel.potentialVisible = v;
    notifyListeners();
  }

  void setThermalVisible(bool v) {
    graphsModel.thermalVisible = v;
    notifyListeners();
  }

  void setTotalVisible(bool v) {
    graphsModel.totalVisible = v;
    notifyListeners();
  }

  void clearEnergyData() {
    graphsModel.clearEnergyData();
    notifyListeners();
  }

  void setEnergyGraphZoomIndex(int i) {
    graphsModel.energyGraphZoomIndex =
        i.clamp(0, EspConstants.plotRanges.length - 1);
    notifyListeners();
  }

  void setEnergyGraphExpanded(bool v) {
    graphsModel.energyGraphExpanded = v;
    notifyListeners();
  }

  void setCursorSampleIndex(int? i) {
    if (i == null) {
      graphsModel.cursorSampleIndex = null;
    } else if (graphsModel.dataSamples.isEmpty) {
      graphsModel.cursorSampleIndex = null;
    } else {
      graphsModel.cursorSampleIndex =
          i.clamp(0, graphsModel.dataSamples.length - 1);
    }
    notifyListeners();
  }

  /// Pick nearest sample by independent-variable axis value (model units).
  void setCursorFromIndependentValue(double xVal) {
    final samples = graphsModel.dataSamples;
    if (samples.isEmpty) return;
    var best = 0;
    var bestD = double.infinity;
    for (var i = 0; i < samples.length; i++) {
      final s = samples[i];
      final v = graphsModel.independentVariable ==
              GraphIndependentVariable.time
          ? s.time
          : s.positionX + EspConstants.positionPlotOffset;
      final d = (v - xVal).abs();
      if (d < bestD) {
        bestD = d;
        best = i;
      }
    }
    graphsModel.cursorSampleIndex = best;
    notifyListeners();
  }
}
