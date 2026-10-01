/// A participant in a chemical reaction — `Substance.ts`.
class Substance {
  Substance({
    required int coefficient,
    required this.symbol,
    this.iconId,
    int quantity = 0,
  })  : _initialCoefficient = coefficient,
        _initialQuantity = quantity,
        _coefficient = coefficient,
        _quantity = quantity;

  final String symbol;
  String? iconId;

  final int _initialCoefficient;
  final int _initialQuantity;

  int _coefficient;
  int _quantity;

  void Function()? onChanged;

  int get coefficient => _coefficient;
  set coefficient(int value) {
    assert(value >= 0);
    if (_coefficient == value) return;
    _coefficient = value;
    onChanged?.call();
  }

  int get quantity => _quantity;
  set quantity(int value) {
    assert(value >= 0);
    if (_quantity == value) return;
    _quantity = value;
    onChanged?.call();
  }

  /// Shallow copy; observers are not copied.
  Substance clone({int? quantity}) {
    return Substance(
      coefficient: _coefficient,
      symbol: symbol,
      iconId: iconId,
      quantity: quantity ?? _quantity,
    );
  }

  bool equalsSubstance(Substance other) {
    return symbol == other.symbol &&
        _coefficient == other._coefficient &&
        iconId == other.iconId &&
        _quantity == other._quantity;
  }

  void reset() {
    _coefficient = _initialCoefficient;
    _quantity = _initialQuantity;
    onChanged?.call();
  }
}
