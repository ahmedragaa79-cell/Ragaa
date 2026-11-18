/// A calendar day, not a transaction timestamp. The caller determines the
/// relevant business date; no device timezone conversion is performed here.
final class BusinessDay implements Comparable<BusinessDay> {
  BusinessDay.fromCalendar(DateTime date)
    : _calendar = DateTime.utc(date.year, date.month, date.day);

  final DateTime _calendar;

  @override
  bool operator ==(Object other) =>
      other is BusinessDay && _calendar == other._calendar;

  @override
  int get hashCode => _calendar.hashCode;

  int get year => _calendar.year;
  int get month => _calendar.month;
  int get day => _calendar.day;

  @override
  int compareTo(BusinessDay other) => _calendar.compareTo(other._calendar);
}

enum RevenueShift { first, second }

/// The natural uniqueness boundary for a future transactional write adapter.
typedef RevenueKey = ({String outletId, BusinessDay day, RevenueShift shift});

/// A scaled integer, not a floating-point ledger balance. The adapter supplies
/// precision; this foundation does not assign a currency or rounding policy.
final class LedgerAmount {
  const LedgerAmount(this.units, {required this.decimalPlaces})
    : assert(decimalPlaces >= 0);

  final int units;
  final int decimalPlaces;
}

final class RevenueRecord {
  const RevenueRecord({
    required this.id,
    required this.key,
    required this.amount,
    this.recordedByUserId,
  });

  final String id;
  final RevenueKey key;
  final LedgerAmount amount;
  final String? recordedByUserId;
}

/// An empty outlet selection means all outlets. Both date bounds are inclusive.
final class RevenueQuery {
  RevenueQuery({Set<String> outletIds = const {}, this.from, this.through})
    : outletIds = Set.unmodifiable(outletIds) {
    if (from != null && through != null && from!.compareTo(through!) > 0) {
      throw ArgumentError('The start of the range must not follow its end.');
    }
  }

  final Set<String> outletIds;
  final BusinessDay? from;
  final BusinessDay? through;
}
