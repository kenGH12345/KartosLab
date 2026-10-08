import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/localization_format.dart';

/// Chemistry terminology (`chemistry.*`).
///
/// Shared physics terms prefer [PhysicsL10n] / [FluidsL10n] / [QuantumL10n]
/// (mass, pressure, volume, energy, photon, wavelength…).
class ChemistryL10n {
  const ChemistryL10n(this.locale);

  final KartosLocale locale;

  static const Map<String, Map<KartosLocale, String>> _table = {
    'chemistry.atom': {KartosLocale.zhCN: '原子', KartosLocale.en: 'Atom'},
    'chemistry.element': {KartosLocale.zhCN: '元素', KartosLocale.en: 'Element'},
    'chemistry.molecule': {KartosLocale.zhCN: '分子', KartosLocale.en: 'Molecule'},
    'chemistry.compound': {KartosLocale.zhCN: '化合物', KartosLocale.en: 'Compound'},
    'chemistry.ion': {KartosLocale.zhCN: '离子', KartosLocale.en: 'Ion'},
    'chemistry.cation': {KartosLocale.zhCN: '阳离子', KartosLocale.en: 'Cation'},
    'chemistry.anion': {KartosLocale.zhCN: '阴离子', KartosLocale.en: 'Anion'},
    'chemistry.proton': {KartosLocale.zhCN: '质子', KartosLocale.en: 'Proton'},
    'chemistry.neutron': {KartosLocale.zhCN: '中子', KartosLocale.en: 'Neutron'},
    'chemistry.electron': {KartosLocale.zhCN: '电子', KartosLocale.en: 'Electron'},
    'chemistry.nucleus': {KartosLocale.zhCN: '原子核', KartosLocale.en: 'Nucleus'},
    'chemistry.atomicNumber': {
      KartosLocale.zhCN: '原子序数',
      KartosLocale.en: 'Atomic Number',
    },
    'chemistry.massNumber': {
      KartosLocale.zhCN: '质量数',
      KartosLocale.en: 'Mass Number',
    },
    'chemistry.isotope': {KartosLocale.zhCN: '同位素', KartosLocale.en: 'Isotope'},
    'chemistry.symbol': {KartosLocale.zhCN: '符号', KartosLocale.en: 'Symbol'},
    'chemistry.bond': {KartosLocale.zhCN: '化学键', KartosLocale.en: 'Bond'},
    'chemistry.ionicBond': {KartosLocale.zhCN: '离子键', KartosLocale.en: 'Ionic Bond'},
    'chemistry.covalentBond': {
      KartosLocale.zhCN: '共价键',
      KartosLocale.en: 'Covalent Bond',
    },
    'chemistry.electronegativity': {
      KartosLocale.zhCN: '电负性',
      KartosLocale.en: 'Electronegativity',
    },
    'chemistry.lonePair': {
      KartosLocale.zhCN: '孤对电子',
      KartosLocale.en: 'Lone Pair',
    },
    'chemistry.bonding': {KartosLocale.zhCN: '成键', KartosLocale.en: 'Bonding'},
    'chemistry.molecularGeometry': {
      KartosLocale.zhCN: '分子构型',
      KartosLocale.en: 'Molecule Geometry',
    },
    'chemistry.electronGeometry': {
      KartosLocale.zhCN: '电子构型',
      KartosLocale.en: 'Electron Geometry',
    },
    'chemistry.solution': {KartosLocale.zhCN: '溶液', KartosLocale.en: 'Solution'},
    'chemistry.solute': {KartosLocale.zhCN: '溶质', KartosLocale.en: 'Solute'},
    'chemistry.solvent': {KartosLocale.zhCN: '溶剂', KartosLocale.en: 'Solvent'},
    'chemistry.concentration': {
      KartosLocale.zhCN: '浓度',
      KartosLocale.en: 'Concentration',
    },
    'chemistry.molarity': {
      KartosLocale.zhCN: '摩尔浓度',
      KartosLocale.en: 'Molarity',
    },
    'chemistry.acid': {KartosLocale.zhCN: '酸', KartosLocale.en: 'Acid'},
    'chemistry.base': {KartosLocale.zhCN: '碱', KartosLocale.en: 'Base'},
    'chemistry.neutral': {KartosLocale.zhCN: '中性', KartosLocale.en: 'Neutral'},
    'chemistry.ph': {KartosLocale.zhCN: 'pH', KartosLocale.en: 'pH'},
    'chemistry.macro': {KartosLocale.zhCN: '宏观', KartosLocale.en: 'Macro'},
    'chemistry.micro': {KartosLocale.zhCN: '微观', KartosLocale.en: 'Micro'},
    'chemistry.mySolution': {
      KartosLocale.zhCN: '我的溶液',
      KartosLocale.en: 'My Solution',
    },
    'chemistry.reactant': {KartosLocale.zhCN: '反应物', KartosLocale.en: 'Reactant'},
    'chemistry.product': {KartosLocale.zhCN: '生成物', KartosLocale.en: 'Product'},
    'chemistry.leftover': {KartosLocale.zhCN: '剩余物', KartosLocale.en: 'Leftover'},
    'chemistry.reactants': {
      KartosLocale.zhCN: '反应物',
      KartosLocale.en: 'Reactants',
    },
    'chemistry.products': {
      KartosLocale.zhCN: '生成物',
      KartosLocale.en: 'Products',
    },
    'chemistry.leftovers': {
      KartosLocale.zhCN: '剩余物',
      KartosLocale.en: 'Leftovers',
    },
    'chemistry.coefficient': {
      KartosLocale.zhCN: '系数',
      KartosLocale.en: 'Coefficient',
    },
    'chemistry.balanced': {
      KartosLocale.zhCN: '已配平',
      KartosLocale.en: 'Balanced',
    },
    'chemistry.notBalanced': {
      KartosLocale.zhCN: '未配平',
      KartosLocale.en: 'Not balanced',
    },
    'chemistry.simplified': {
      KartosLocale.zhCN: '已约简',
      KartosLocale.en: 'Simplified',
    },
    'chemistry.notSimplified': {
      KartosLocale.zhCN: '未约简',
      KartosLocale.en: 'Not simplified',
    },
    'chemistry.reaction': {KartosLocale.zhCN: '反应', KartosLocale.en: 'Reaction'},
    'chemistry.solid': {KartosLocale.zhCN: '固体', KartosLocale.en: 'Solid'},
    'chemistry.liquid': {KartosLocale.zhCN: '液体', KartosLocale.en: 'Liquid'},
    'chemistry.gas': {KartosLocale.zhCN: '气体', KartosLocale.en: 'Gas'},
    'chemistry.heat': {KartosLocale.zhCN: '加热', KartosLocale.en: 'Heat'},
    'chemistry.cool': {KartosLocale.zhCN: '冷却', KartosLocale.en: 'Cool'},
    'chemistry.water': {KartosLocale.zhCN: '水', KartosLocale.en: 'Water'},
    'chemistry.partialCharges': {
      KartosLocale.zhCN: '部分电荷',
      KartosLocale.en: 'Partial Charges',
    },
    'chemistry.bondDipole': {
      KartosLocale.zhCN: '键偶极',
      KartosLocale.en: 'Bond Dipole',
    },
    'chemistry.molecularDipole': {
      KartosLocale.zhCN: '分子偶极',
      KartosLocale.en: 'Molecular Dipole',
    },
  };

  String _t(String key) {
    final row = _table[key];
    if (row == null) {
      assert(false, 'Missing localization key: $key');
      return key;
    }
    return locFormat(row[locale] ?? row[KartosLocale.zhCN] ?? key);
  }

  static Iterable<String> get keys => _table.keys;

  String get atom => _t('chemistry.atom');
  String get element => _t('chemistry.element');
  String get molecule => _t('chemistry.molecule');
  String get compound => _t('chemistry.compound');
  String get ion => _t('chemistry.ion');
  String get cation => _t('chemistry.cation');
  String get anion => _t('chemistry.anion');
  String get proton => _t('chemistry.proton');
  String get neutron => _t('chemistry.neutron');
  String get electron => _t('chemistry.electron');
  String get nucleus => _t('chemistry.nucleus');
  String get atomicNumber => _t('chemistry.atomicNumber');
  String get massNumber => _t('chemistry.massNumber');
  String get isotope => _t('chemistry.isotope');
  String get symbol => _t('chemistry.symbol');
  String get bond => _t('chemistry.bond');
  String get ionicBond => _t('chemistry.ionicBond');
  String get covalentBond => _t('chemistry.covalentBond');
  String get electronegativity => _t('chemistry.electronegativity');
  String get lonePair => _t('chemistry.lonePair');
  String get bonding => _t('chemistry.bonding');
  String get molecularGeometry => _t('chemistry.molecularGeometry');
  String get electronGeometry => _t('chemistry.electronGeometry');
  String get solution => _t('chemistry.solution');
  String get solute => _t('chemistry.solute');
  String get solvent => _t('chemistry.solvent');
  String get concentration => _t('chemistry.concentration');
  String get molarity => _t('chemistry.molarity');
  String get acid => _t('chemistry.acid');
  String get base => _t('chemistry.base');
  String get neutral => _t('chemistry.neutral');
  String get ph => _t('chemistry.ph');
  String get macro => _t('chemistry.macro');
  String get micro => _t('chemistry.micro');
  String get mySolution => _t('chemistry.mySolution');
  String get reactant => _t('chemistry.reactant');
  String get product => _t('chemistry.product');
  String get leftover => _t('chemistry.leftover');
  String get reactants => _t('chemistry.reactants');
  String get products => _t('chemistry.products');
  String get leftovers => _t('chemistry.leftovers');
  String get coefficient => _t('chemistry.coefficient');
  String get balanced => _t('chemistry.balanced');
  String get notBalanced => _t('chemistry.notBalanced');
  String get simplified => _t('chemistry.simplified');
  String get notSimplified => _t('chemistry.notSimplified');
  String get reaction => _t('chemistry.reaction');
  String get solid => _t('chemistry.solid');
  String get liquid => _t('chemistry.liquid');
  String get gas => _t('chemistry.gas');
  String get heat => _t('chemistry.heat');
  String get cool => _t('chemistry.cool');
  String get water => _t('chemistry.water');
  String get partialCharges => _t('chemistry.partialCharges');
  String get bondDipole => _t('chemistry.bondDipole');
  String get molecularDipole => _t('chemistry.molecularDipole');
}
