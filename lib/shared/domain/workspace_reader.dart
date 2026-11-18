/// Counts across the entire directory, independent of search/filter state.
/// No revenue projection until a real revenue register exists.
final class WorkspaceOverview {
  const WorkspaceOverview({
    required this.totalOutlets,
    required this.activeOutlets,
  });
  final int totalOutlets, activeOutlets;
  int get inactiveOutlets => totalOutlets - activeOutlets;
}

abstract interface class WorkspaceReader {
  Stream<WorkspaceOverview> watchOverview();
}
