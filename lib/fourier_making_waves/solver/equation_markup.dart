import '../model/domain.dart';
import '../model/equation_form.dart';
import '../model/series_type.dart';

/// Presentation markup for Discrete equations. PhET `EquationMarkup.ts`
///
/// Does **not** affect Fourier sampling — display only.
class EquationMarkup {
  EquationMarkup._();

  static const String hidden = '';

  /// General form with symbolic order n and amplitude Aₙ.
  static String getGeneralFormMarkup(
    Domain domain,
    SeriesType seriesType,
    EquationForm equationForm,
  ) {
    return getSpecificFormMarkup(
      domain,
      seriesType,
      equationForm,
      'n',
      'Aₙ',
    );
  }

  static String getSpecificFormMarkup(
    Domain domain,
    SeriesType seriesType,
    EquationForm equationForm,
    Object order,
    Object amplitude,
  ) {
    switch (domain) {
      case Domain.space:
        return _space(seriesType, equationForm, order, amplitude);
      case Domain.time:
        return _time(seriesType, equationForm, order, amplitude);
      case Domain.spaceAndTime:
        return _spaceAndTime(seriesType, equationForm, order, amplitude);
    }
  }

  static String getFunctionOfMarkup(Domain domain) {
    switch (domain) {
      case Domain.space:
        return 'F(x)';
      case Domain.time:
        return 'F(t)';
      case Domain.spaceAndTime:
        return 'F(x,t)';
    }
  }

  static String _sinCos(SeriesType seriesType) =>
      seriesType == SeriesType.sin ? 'sin' : 'cos';

  static String _space(
    SeriesType seriesType,
    EquationForm form,
    Object order,
    Object amplitude,
  ) {
    final sc = _sinCos(seriesType);
    switch (form) {
      case EquationForm.wavelength:
        return '$amplitude $sc( 2πx / λ_$order )';
      case EquationForm.spatialWaveNumber:
        return '$amplitude $sc( k_$order x )';
      case EquationForm.mode:
        return '$amplitude $sc( 2π $order x / L )';
      default:
        return hidden;
    }
  }

  static String _time(
    SeriesType seriesType,
    EquationForm form,
    Object order,
    Object amplitude,
  ) {
    final sc = _sinCos(seriesType);
    switch (form) {
      case EquationForm.frequency:
        return '$amplitude $sc( 2π f_$order t )';
      case EquationForm.period:
        return '$amplitude $sc( 2π t / T_$order )';
      case EquationForm.angularWaveNumber:
        return '$amplitude $sc( ω_$order t )';
      case EquationForm.mode:
        return '$amplitude $sc( 2π $order t / T )';
      default:
        return hidden;
    }
  }

  static String _spaceAndTime(
    SeriesType seriesType,
    EquationForm form,
    Object order,
    Object amplitude,
  ) {
    final sc = _sinCos(seriesType);
    switch (form) {
      case EquationForm.wavelengthAndPeriod:
        return '$amplitude $sc( 2π(x/λ_$order − t/T_$order) )';
      case EquationForm.spatialAndAngular:
        return '$amplitude $sc( k_$order x − ω_$order t )';
      case EquationForm.mode:
        return '$amplitude $sc( 2π $order (x/L − t/T) )';
      default:
        return hidden;
    }
  }

  /// Forms valid for [domain] (excluding [EquationForm.hidden] always available).
  static List<EquationForm> formsForDomain(Domain domain) {
    switch (domain) {
      case Domain.space:
        return const [
          EquationForm.hidden,
          EquationForm.mode,
          EquationForm.wavelength,
          EquationForm.spatialWaveNumber,
        ];
      case Domain.time:
        return const [
          EquationForm.hidden,
          EquationForm.mode,
          EquationForm.frequency,
          EquationForm.period,
          EquationForm.angularWaveNumber,
        ];
      case Domain.spaceAndTime:
        return const [
          EquationForm.hidden,
          EquationForm.mode,
          EquationForm.wavelengthAndPeriod,
          EquationForm.spatialAndAngular,
        ];
    }
  }
}
