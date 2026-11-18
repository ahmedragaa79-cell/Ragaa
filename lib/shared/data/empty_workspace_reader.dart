import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/outlet.dart';
import '../domain/revenue.dart';
import '../domain/workspace_reader.dart';

final workspaceReaderProvider = Provider<WorkspaceReader>(
  (ref) => const EmptyWorkspaceReader(),
);

/// No database, seeded outlets, synthetic totals, or pretend writes.
final class EmptyWorkspaceReader implements WorkspaceReader {
  const EmptyWorkspaceReader();

  @override
  Future<WorkspaceOverview> overview() async => const WorkspaceOverview.empty();

  @override
  Future<List<Outlet>> outlets() async => const [];

  @override
  Future<List<RevenueRecord>> revenue(RevenueQuery query) async => const [];
}
