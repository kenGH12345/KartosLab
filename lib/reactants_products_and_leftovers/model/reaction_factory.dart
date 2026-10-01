import '../rpal_symbols.dart';
import 'reaction.dart';
import 'substance.dart';

Substance _s(int c, String symbol, String icon) =>
    Substance(coefficient: c, symbol: symbol, iconId: icon);

/// Factory functions — `ReactionFactory.ts` (full game pools).
class ReactionFactory {
  ReactionFactory._();

  static Reaction makeWater({String? name}) => Reaction(
        name: name ?? 'Make Water',
        reactants: [_s(2, RpalSymbols.h2, 'H2'), _s(1, RpalSymbols.o2, 'O2')],
        products: [_s(2, RpalSymbols.h2o, 'H2O')],
      );

  static Reaction makeAmmonia({String? name}) => Reaction(
        name: name ?? 'Make Ammonia',
        reactants: [_s(1, RpalSymbols.n2, 'N2'), _s(3, RpalSymbols.h2, 'H2')],
        products: [_s(2, RpalSymbols.nh3, 'NH3')],
      );

  static Reaction combustMethane({String? name}) => Reaction(
        name: name ?? 'Combust Methane',
        reactants: [_s(1, RpalSymbols.ch4, 'CH4'), _s(2, RpalSymbols.o2, 'O2')],
        products: [
          _s(1, RpalSymbols.co2, 'CO2'),
          _s(2, RpalSymbols.h2o, 'H2O'),
        ],
      );

  static Reaction reactionH2F2To2HF() => Reaction(
        reactants: [_s(1, RpalSymbols.h2, 'H2'), _s(1, RpalSymbols.f2, 'F2')],
        products: [_s(2, RpalSymbols.hf, 'HF')],
      );

  static Reaction reactionH2Cl2To2HCl() => Reaction(
        reactants: [_s(1, RpalSymbols.h2, 'H2'), _s(1, RpalSymbols.cl2, 'Cl2')],
        products: [_s(2, RpalSymbols.hcl, 'HCl')],
      );

  static Reaction reactionCO2H2ToCH3OH() => Reaction(
        reactants: [_s(1, RpalSymbols.co, 'CO'), _s(2, RpalSymbols.h2, 'H2')],
        products: [_s(1, RpalSymbols.ch3oh, 'CH3OH')],
      );

  static Reaction reactionCH2OH2ToCH3OH() => Reaction(
        reactants: [_s(1, RpalSymbols.ch2o, 'CH2O'), _s(1, RpalSymbols.h2, 'H2')],
        products: [_s(1, RpalSymbols.ch3oh, 'CH3OH')],
      );

  static Reaction reactionC2H4H2ToC2H6() => Reaction(
        reactants: [
          _s(1, RpalSymbols.c2h4, 'C2H4'),
          _s(1, RpalSymbols.h2, 'H2'),
        ],
        products: [_s(1, RpalSymbols.c2h6, 'C2H6')],
      );

  static Reaction reactionC2H22H2ToC2H6() => Reaction(
        reactants: [
          _s(1, RpalSymbols.c2h2, 'C2H2'),
          _s(2, RpalSymbols.h2, 'H2'),
        ],
        products: [_s(1, RpalSymbols.c2h6, 'C2H6')],
      );

  static Reaction reactionCO2ToCO2() => Reaction(
        reactants: [_s(1, RpalSymbols.c, 'C'), _s(1, RpalSymbols.o2, 'O2')],
        products: [_s(1, RpalSymbols.co2, 'CO2')],
      );

  static Reaction reaction2CO2To2CO() => Reaction(
        reactants: [_s(2, RpalSymbols.c, 'C'), _s(1, RpalSymbols.o2, 'O2')],
        products: [_s(2, RpalSymbols.co, 'CO')],
      );

  static Reaction reaction2COO2To2CO2() => Reaction(
        reactants: [_s(2, RpalSymbols.co, 'CO'), _s(1, RpalSymbols.o2, 'O2')],
        products: [_s(2, RpalSymbols.co2, 'CO2')],
      );

  static Reaction reactionCCO2To2CO() => Reaction(
        reactants: [_s(1, RpalSymbols.c, 'C'), _s(1, RpalSymbols.co2, 'CO2')],
        products: [_s(2, RpalSymbols.co, 'CO')],
      );

  static Reaction reactionC2SToCS2() => Reaction(
        reactants: [_s(1, RpalSymbols.c, 'C'), _s(2, RpalSymbols.s, 'S')],
        products: [_s(1, RpalSymbols.cs2, 'CS2')],
      );

  static Reaction reactionN2O2To2NO() => Reaction(
        reactants: [_s(1, RpalSymbols.n2, 'N2'), _s(1, RpalSymbols.o2, 'O2')],
        products: [_s(2, RpalSymbols.no, 'NO')],
      );

  static Reaction reaction2NOO2To2NO2() => Reaction(
        reactants: [_s(2, RpalSymbols.no, 'NO'), _s(1, RpalSymbols.o2, 'O2')],
        products: [_s(2, RpalSymbols.no2, 'NO2')],
      );

  static Reaction reaction2N2O2To2N2O() => Reaction(
        reactants: [_s(2, RpalSymbols.n2, 'N2'), _s(1, RpalSymbols.o2, 'O2')],
        products: [_s(2, RpalSymbols.n2o, 'N2O')],
      );

  static Reaction reactionP46H2To4PH3() => Reaction(
        reactants: [_s(1, RpalSymbols.p4, 'P4'), _s(6, RpalSymbols.h2, 'H2')],
        products: [_s(4, RpalSymbols.ph3, 'PH3')],
      );

  static Reaction reactionP46F2To4PF3() => Reaction(
        reactants: [_s(1, RpalSymbols.p4, 'P4'), _s(6, RpalSymbols.f2, 'F2')],
        products: [_s(4, RpalSymbols.pf3, 'PF3')],
      );

  static Reaction reactionP46Cl2To4PCl3() => Reaction(
        reactants: [_s(1, RpalSymbols.p4, 'P4'), _s(6, RpalSymbols.cl2, 'Cl2')],
        products: [_s(4, RpalSymbols.pcl3, 'PCl3')],
      );

  static Reaction reactionPCl3Cl2ToPCl5() => Reaction(
        reactants: [
          _s(1, RpalSymbols.pcl3, 'PCl3'),
          _s(1, RpalSymbols.cl2, 'Cl2'),
        ],
        products: [_s(1, RpalSymbols.pcl5, 'PCl5')],
      );

  static Reaction reaction2SO2O2To2SO3() => Reaction(
        reactants: [
          _s(2, RpalSymbols.so2, 'SO2'),
          _s(1, RpalSymbols.o2, 'O2'),
        ],
        products: [_s(2, RpalSymbols.so3, 'SO3')],
      );

  // Two-product
  static Reaction reaction2C2H2OToCH4CO2() => Reaction(
        reactants: [
          _s(2, RpalSymbols.c, 'C'),
          _s(2, RpalSymbols.h2o, 'H2O'),
        ],
        products: [
          _s(1, RpalSymbols.ch4, 'CH4'),
          _s(1, RpalSymbols.co2, 'CO2'),
        ],
      );

  static Reaction reactionCH4H2OTo3H2CO() => Reaction(
        reactants: [
          _s(1, RpalSymbols.ch4, 'CH4'),
          _s(1, RpalSymbols.h2o, 'H2O'),
        ],
        products: [
          _s(3, RpalSymbols.h2, 'H2'),
          _s(1, RpalSymbols.co, 'CO'),
        ],
      );

  static Reaction reaction2C2H67O2() => Reaction(
        reactants: [
          _s(2, RpalSymbols.c2h6, 'C2H6'),
          _s(7, RpalSymbols.o2, 'O2'),
        ],
        products: [
          _s(4, RpalSymbols.co2, 'CO2'),
          _s(6, RpalSymbols.h2o, 'H2O'),
        ],
      );

  static Reaction reactionC2H43O2() => Reaction(
        reactants: [
          _s(1, RpalSymbols.c2h4, 'C2H4'),
          _s(3, RpalSymbols.o2, 'O2'),
        ],
        products: [
          _s(2, RpalSymbols.co2, 'CO2'),
          _s(2, RpalSymbols.h2o, 'H2O'),
        ],
      );

  static Reaction reaction2C2H25O2() => Reaction(
        reactants: [
          _s(2, RpalSymbols.c2h2, 'C2H2'),
          _s(5, RpalSymbols.o2, 'O2'),
        ],
        products: [
          _s(4, RpalSymbols.co2, 'CO2'),
          _s(2, RpalSymbols.h2o, 'H2O'),
        ],
      );

  static Reaction reactionC2H5OH3O2() => Reaction(
        reactants: [
          _s(1, RpalSymbols.c2h5Oh, 'C2H5OH'),
          _s(3, RpalSymbols.o2, 'O2'),
        ],
        products: [
          _s(2, RpalSymbols.co2, 'CO2'),
          _s(3, RpalSymbols.h2o, 'H2O'),
        ],
      );

  static Reaction reactionC2H6Cl2ToProducts() => Reaction(
        reactants: [
          _s(1, RpalSymbols.c2h6, 'C2H6'),
          _s(1, RpalSymbols.cl2, 'Cl2'),
        ],
        products: [
          _s(1, RpalSymbols.c2h5Cl, 'C2H5Cl'),
          _s(1, RpalSymbols.hcl, 'HCl'),
        ],
      );

  static Reaction reactionCH44S() => Reaction(
        reactants: [_s(1, RpalSymbols.ch4, 'CH4'), _s(4, RpalSymbols.s, 'S')],
        products: [
          _s(1, RpalSymbols.cs2, 'CS2'),
          _s(2, RpalSymbols.h2s, 'H2S'),
        ],
      );

  static Reaction reactionCS23O2() => Reaction(
        reactants: [
          _s(1, RpalSymbols.cs2, 'CS2'),
          _s(3, RpalSymbols.o2, 'O2'),
        ],
        products: [
          _s(1, RpalSymbols.co2, 'CO2'),
          _s(2, RpalSymbols.so2, 'SO2'),
        ],
      );

  static Reaction reaction4NH33O2() => Reaction(
        reactants: [
          _s(4, RpalSymbols.nh3, 'NH3'),
          _s(3, RpalSymbols.o2, 'O2'),
        ],
        products: [
          _s(2, RpalSymbols.n2, 'N2'),
          _s(6, RpalSymbols.h2o, 'H2O'),
        ],
      );

  static Reaction reaction4NH35O2() => Reaction(
        reactants: [
          _s(4, RpalSymbols.nh3, 'NH3'),
          _s(5, RpalSymbols.o2, 'O2'),
        ],
        products: [
          _s(4, RpalSymbols.no, 'NO'),
          _s(6, RpalSymbols.h2o, 'H2O'),
        ],
      );

  static Reaction reaction4NH37O2() => Reaction(
        reactants: [
          _s(4, RpalSymbols.nh3, 'NH3'),
          _s(7, RpalSymbols.o2, 'O2'),
        ],
        products: [
          _s(4, RpalSymbols.no2, 'NO2'),
          _s(6, RpalSymbols.h2o, 'H2O'),
        ],
      );

  static Reaction reaction4NH36NO() => Reaction(
        reactants: [
          _s(4, RpalSymbols.nh3, 'NH3'),
          _s(6, RpalSymbols.no, 'NO'),
        ],
        products: [
          _s(5, RpalSymbols.n2, 'N2'),
          _s(6, RpalSymbols.h2o, 'H2O'),
        ],
      );

  static Reaction reactionSO22H2() => Reaction(
        reactants: [
          _s(1, RpalSymbols.so2, 'SO2'),
          _s(2, RpalSymbols.h2, 'H2'),
        ],
        products: [
          _s(1, RpalSymbols.s, 'S'),
          _s(2, RpalSymbols.h2o, 'H2O'),
        ],
      );

  static Reaction reactionSO23H2() => Reaction(
        reactants: [
          _s(1, RpalSymbols.so2, 'SO2'),
          _s(3, RpalSymbols.h2, 'H2'),
        ],
        products: [
          _s(1, RpalSymbols.h2s, 'H2S'),
          _s(2, RpalSymbols.h2o, 'H2O'),
        ],
      );

  static Reaction reaction2F2H2O() => Reaction(
        reactants: [
          _s(2, RpalSymbols.f2, 'F2'),
          _s(1, RpalSymbols.h2o, 'H2O'),
        ],
        products: [
          _s(1, RpalSymbols.of2, 'OF2'),
          _s(2, RpalSymbols.hf, 'HF'),
        ],
      );

  static Reaction reactionOF2H2O() => Reaction(
        reactants: [
          _s(1, RpalSymbols.of2, 'OF2'),
          _s(1, RpalSymbols.h2o, 'H2O'),
        ],
        products: [
          _s(1, RpalSymbols.o2, 'O2'),
          _s(2, RpalSymbols.hf, 'HF'),
        ],
      );

  /// Level 2 pool — 21 one-product reactions (`ChallengeFactory.ts`).
  static List<Reaction Function()> get level2Pool => [
        reactionPCl3Cl2ToPCl5,
        makeWater,
        reactionH2F2To2HF,
        reactionH2Cl2To2HCl,
        reactionCO2H2ToCH3OH,
        reactionCH2OH2ToCH3OH,
        reactionC2H4H2ToC2H6,
        reactionC2H22H2ToC2H6,
        reactionCO2ToCO2,
        reaction2CO2To2CO,
        reaction2COO2To2CO2,
        reactionCCO2To2CO,
        reactionC2SToCS2,
        makeAmmonia,
        reactionN2O2To2NO,
        reaction2NOO2To2NO2,
        reaction2N2O2To2N2O,
        reactionP46H2To4PH3,
        reactionP46F2To4PF3,
        reactionP46Cl2To4PCl3,
        reaction2SO2O2To2SO3,
      ];

  /// Level 3 pool — 18 two-product reactions.
  static List<Reaction Function()> get level3Pool => [
        reactionC2H5OH3O2,
        reaction2C2H2OToCH4CO2,
        reactionCH4H2OTo3H2CO,
        combustMethane,
        reaction2C2H67O2,
        reactionC2H43O2,
        reaction2C2H25O2,
        reactionC2H6Cl2ToProducts,
        reactionCH44S,
        reactionCS23O2,
        reaction4NH33O2,
        reaction4NH35O2,
        reaction4NH37O2,
        reaction4NH36NO,
        reactionSO22H2,
        reactionSO23H2,
        reaction2F2H2O,
        reactionOF2H2O,
      ];

  static List<Reaction Function()> get level1Pool =>
      [...level2Pool, ...level3Pool];

  static List<List<Reaction Function()>> get pools =>
      [level1Pool, level2Pool, level3Pool];
}
