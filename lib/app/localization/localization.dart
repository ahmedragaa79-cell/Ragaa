import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../shared/domain/revenue.dart';
import 'generated/app_localizations.dart';

extension WorkspaceLocalization on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  WorkspaceFormats get formats =>
      WorkspaceFormats(Localizations.localeOf(this));
}

/// Always use the active interface locale (not the process default). Use the
/// Egyptian Arabic CLDR symbols for Arabic-Indic digits and decimal grouping.
final class WorkspaceFormats {
  WorkspaceFormats(Locale locale)
    : tag = locale.languageCode == 'ar' ? 'ar_EG' : 'en';

  final String tag;

  String count(int value) => NumberFormat.decimalPattern(tag).format(value);
  String index(int value) => NumberFormat('00', tag).format(value);
  String date(DateTime day) => DateFormat.yMMMEd(tag).format(day);

  String amount(LedgerAmount value) {
    // Split the signed integer, rather than divide it through a binary double.
    final digits = value.units.abs().toString().padLeft(
      value.decimalPlaces + 1,
      '0',
    );
    final point = digits.length - value.decimalPlaces;
    final format = NumberFormat.decimalPattern(tag);
    final sign = value.units < 0 ? format.symbols.MINUS_SIGN : '';
    final whole = format.format(int.parse(digits.substring(0, point)));
    if (value.decimalPlaces == 0) return '$sign$whole';
    final fraction = NumberFormat(
      '0' * value.decimalPlaces,
      tag,
    ).format(int.parse(digits.substring(point)));
    return '$sign$whole${format.symbols.DECIMAL_SEP}$fraction';
  }
}
