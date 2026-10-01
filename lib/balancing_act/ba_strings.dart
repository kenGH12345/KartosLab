/// English strings from `balancing-act-strings_en.json` + Vegas.
abstract final class BaStrings {
  static const String title = 'Balancing Act';
  static const String subtitle = 'Intro · Balance Lab · Game';
  static const String screenIntro = 'Intro';
  static const String screenBalanceLab = 'Balance Lab';
  static const String screenGame = 'Game';

  static const String show = 'Show';
  static const String massLabels = 'Mass Labels';
  static const String forcesFromObjects = 'Forces from Objects';
  static const String level = 'Level';
  static const String position = 'Position';
  static const String none = 'None';
  static const String rulers = 'Rulers';
  static const String marks = 'Marks';
  static const String kg = 'kg';
  static const String meters = 'meters';
  static const String bricks = 'Bricks';
  static const String people = 'People';
  static const String mysteryObjects = 'Mystery Objects';
  static const String unknownMassLabel = '?';

  static const String selectLevel = 'Select Level';
  static const String startOver = 'Start Over';
  static const String check = 'Check';
  static const String next = 'Next';
  static const String tryAgain = 'Try Again';
  static const String showAnswer = 'Show Answer';
  static const String balanceMe = 'Balance Me!';
  static const String whatIsTheMass = 'What is the mass?';
  static const String whatWillHappen = 'What will happen?';
  static const String continueLabel = 'Continue';
  static const String score = 'Score';

  static String massLabel(double kg) {
    final v = kg == kg.roundToDouble() ? kg.toInt().toString() : kg.toString();
    return '$v $kgUnit';
  }

  static const String kgUnit = 'kg';

  static String challengeBanner(
          int level1Based, int challenge1Based, int total) =>
      'Level $level1Based, Challenge $challenge1Based of $total';
}
