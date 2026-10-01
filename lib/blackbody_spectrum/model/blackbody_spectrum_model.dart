import 'package:flutter/foundation.dart';

import '../blackbody_spectrum_constants.dart';
import 'blackbody_body_model.dart';

/// Root model — PhET `BlackbodySpectrumModel` equivalent.
///
/// Holds 3 BlackbodyBodyModel instances + 3 visibility flags + max wavelength.
///
/// [来源: phet/js/blackbody-spectrum/model/BlackbodySpectrumModel.js:16-87]
class BlackbodySpectrumModel extends ChangeNotifier {
  BlackbodySpectrumModel() {
    mainBody = BlackbodyBodyModel(BlackbodySpectrumConstants.sunTemperature);
    savedBodyOne = BlackbodyBodyModel(null);
    savedBodyTwo = BlackbodyBodyModel(null);
  }

  late BlackbodyBodyModel mainBody;
  late BlackbodyBodyModel savedBodyOne;
  late BlackbodyBodyModel savedBodyTwo;

  /// [来源: BlackbodySpectrumModel.js:25-27] graphValuesVisibleProperty, initial false
  bool graphValuesVisible = false;

  /// [来源: BlackbodySpectrumModel.js:28-30] intensityVisibleProperty, initial false
  bool intensityVisible = false;

  /// [来源: BlackbodySpectrumModel.js:31-33] labelsVisibleProperty, initial false
  bool labelsVisible = false;

  /// [来源: BlackbodySpectrumModel.js:35-36] wavelengthMax = 3000
  double wavelengthMax = BlackbodySpectrumConstants.defaultHorizontalZoom;

  /// Horizontal zoom value (same as wavelengthMax).
  double get horizontalZoom => wavelengthMax;

  /// Vertical zoom value.
  double verticalZoom = BlackbodySpectrumConstants.defaultVerticalZoom;

  /// Lightweight paint tick for temperature drag updates.
  final ValueNotifier<int> paintEpoch = ValueNotifier<int>(0);

  /// Temperature of the main body.
  /// [来源: BlackbodySpectrumModel.js:21-22]
  double get temperature => mainBody.temperature!;
  set temperature(double value) {
    final clamped = value.clamp(
      BlackbodySpectrumConstants.minTemperature,
      BlackbodySpectrumConstants.maxTemperature,
    );
    if (mainBody.temperature == clamped) return;
    mainBody.temperature = clamped;
    paintEpoch.value++;
    notifyListeners();
  }

  void setGraphValuesVisible(bool v) {
    if (graphValuesVisible == v) return;
    graphValuesVisible = v;
    notifyListeners();
  }

  void setIntensityVisible(bool v) {
    if (intensityVisible == v) return;
    intensityVisible = v;
    notifyListeners();
  }

  void setLabelsVisible(bool v) {
    if (labelsVisible == v) return;
    labelsVisible = v;
    notifyListeners();
  }

  /// Save main body temperature to the saved queue (FIFO, max 2).
  /// [来源: BlackbodySpectrumModel.js:74-77]
  void saveMainBody() {
    savedBodyTwo.temperature = savedBodyOne.temperature;
    savedBodyOne.temperature = mainBody.temperature;
    notifyListeners();
  }

  /// Clear all saved graphs.
  /// [来源: BlackbodySpectrumModel.js:83-86]
  void clearSavedGraphs() {
    savedBodyOne.temperature = null;
    savedBodyTwo.temperature = null;
    notifyListeners();
  }

  /// Zoom horizontal axis.
  /// [来源: ZoomableAxesView.js:373-378, 384-389]
  void zoomHorizontalIn() {
    final newZoom = (wavelengthMax / BlackbodySpectrumConstants.horizontalZoomScale)
        .clamp(
          BlackbodySpectrumConstants.minHorizontalZoom,
          BlackbodySpectrumConstants.maxHorizontalZoom,
        );
    if (wavelengthMax == newZoom) return;
    wavelengthMax = newZoom;
    notifyListeners();
  }

  void zoomHorizontalOut() {
    final newZoom = (wavelengthMax * BlackbodySpectrumConstants.horizontalZoomScale)
        .clamp(
          BlackbodySpectrumConstants.minHorizontalZoom,
          BlackbodySpectrumConstants.maxHorizontalZoom,
        );
    if (wavelengthMax == newZoom) return;
    wavelengthMax = newZoom;
    notifyListeners();
  }

  /// Zoom vertical axis.
  /// [来源: ZoomableAxesView.js:395-400, 406-411]
  void zoomVerticalIn() {
    final newZoom = (verticalZoom / BlackbodySpectrumConstants.verticalZoomScale)
        .clamp(
          BlackbodySpectrumConstants.minVerticalZoom,
          BlackbodySpectrumConstants.maxVerticalZoom,
        );
    if (verticalZoom == newZoom) return;
    verticalZoom = newZoom;
    notifyListeners();
  }

  void zoomVerticalOut() {
    final newZoom = (verticalZoom * BlackbodySpectrumConstants.verticalZoomScale)
        .clamp(
          BlackbodySpectrumConstants.minVerticalZoom,
          BlackbodySpectrumConstants.maxVerticalZoom,
        );
    if (verticalZoom == newZoom) return;
    verticalZoom = newZoom;
    notifyListeners();
  }

  /// Reset everything to defaults.
  /// [来源: BlackbodySpectrumModel.js:62-68]
  void reset() {
    mainBody.temperature = BlackbodySpectrumConstants.sunTemperature;
    savedBodyOne.temperature = null;
    savedBodyTwo.temperature = null;
    graphValuesVisible = false;
    intensityVisible = false;
    labelsVisible = false;
    wavelengthMax = BlackbodySpectrumConstants.defaultHorizontalZoom;
    verticalZoom = BlackbodySpectrumConstants.defaultVerticalZoom;
    paintEpoch.value++;
    notifyListeners();
  }

  @override
  void dispose() {
    paintEpoch.dispose();
    super.dispose();
  }
}
