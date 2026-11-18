import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:strata/app/localization/localization.dart';
import 'package:strata/shared/domain/revenue.dart';

void main() {
  setUpAll(initializeDateFormatting);
  final english = WorkspaceFormats(const Locale('en'));
  final arabic = WorkspaceFormats(const Locale('ar'));
  test('amounts preserve scale and use the active locale, without a presumed currency', () {
    const value = LedgerAmount(123456, decimalPlaces: 2);
    expect(english.amount(value), '1,234.56');
    expect(arabic.amount(value), '١٬٢٣٤٫٥٦');
    expect(english.amount(const LedgerAmount(-3, decimalPlaces: 3)), '-0.003');
    expect(english.amount(const LedgerAmount(42, decimalPlaces: 0)), '42');
    expect(arabic.count(12), '١٢');
  });
  test('dates use localized month names, order and digits', () {
    final day = DateTime(2026, 11, 18);
    expect(english.date(day), allOf(contains('Nov'), contains('2026')));
    expect(arabic.date(day), allOf(contains('نوفمبر'), contains('٢٠٢٦')));
  });
}
