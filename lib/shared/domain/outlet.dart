/// Identity and creation time never change, including across deactivation.
final class Outlet {
  const Outlet({
    required this.id,
    required this.outletCode,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id, outletCode, name;
  final String? description;
  final bool isActive;
  final DateTime createdAt, updatedAt;
}
