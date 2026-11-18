/// Stable identifiers are owned by a future adapter, not by the UI.
final class Outlet {
  const Outlet({required this.id, required this.name, required this.isActive});

  final String id;
  final String name;
  final bool isActive;
}
