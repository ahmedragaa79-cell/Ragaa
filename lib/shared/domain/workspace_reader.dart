import 'outlet.dart';
import 'revenue.dart';

/// Projection for the dashboard. An adapter can aggregate without loading the
/// entire revenue history into presentation memory.
final class WorkspaceOverview {
  const WorkspaceOverview({
    required this.totalRevenue,
    required this.activeOutlets,
    required this.revenueRecords,
  });

  const WorkspaceOverview.empty()
    : totalRevenue = const LedgerAmount(0, decimalPlaces: 2),
      activeOutlets = 0,
      revenueRecords = 0;

  final LedgerAmount totalRevenue;
  final int activeOutlets;
  final int revenueRecords;
}

/// Storage boundary, deliberately read-only during initialization. A future
/// repository may read from local storage, a server, or a synchronized cache.
abstract interface class WorkspaceReader {
  Future<WorkspaceOverview> overview();
  Future<List<Outlet>> outlets();
  Future<List<RevenueRecord>> revenue(RevenueQuery query);
}
