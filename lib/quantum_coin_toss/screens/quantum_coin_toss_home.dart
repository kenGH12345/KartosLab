import 'package:flutter/material.dart';

import '../coins/coins_screen.dart';

/// KartosLab home entry for PhET Quantum Coin Toss (Coins screen).
class QuantumCoinTossHome extends StatelessWidget {
  const QuantumCoinTossHome({super.key});

  static const String title = '量子抛硬币';
  static const String subtitle = 'Classical · Quantum Coin';
  static const Color accentColor = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return const CoinsScreen();
  }
}

/// Alias for callers expecting `QuantumCoinTossScreen`.
typedef QuantumCoinTossScreen = QuantumCoinTossHome;
