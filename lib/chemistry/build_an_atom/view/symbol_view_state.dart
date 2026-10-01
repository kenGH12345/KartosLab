/// Symbol Screen view-only properties (accordion expand flags).
library;

import 'package:flutter/foundation.dart';

import '../model/baa_model.dart';

/// Symbol accordion state for Symbol Screen.
///
/// Appearance / electron-model flags live on [AtomViewState] (shared play area).
class SymbolViewState extends ChangeNotifier {
  SymbolViewState(this.model);

  final BAAModel model;

  /// Symbol accordion — sun AccordionBox default expanded.
  bool symbolExpanded = true;

  void setSymbolExpanded(bool v) {
    if (symbolExpanded == v) return;
    symbolExpanded = v;
    notifyListeners();
  }

  void reset() {
    symbolExpanded = true;
    notifyListeners();
  }
}
