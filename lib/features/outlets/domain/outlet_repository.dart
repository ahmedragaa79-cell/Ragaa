import '../../../shared/domain/outlet.dart';
import '../../../shared/domain/workspace_reader.dart';

enum OutletFilter { all, active, inactive }

typedef DirectoryQuery = ({String search, OutletFilter filter});

enum OutletProblem implements Exception {
  missingCode,
  missingName,
  duplicateCode,
  notFound,
}

/// A form is never allowed to supply/overwrite the ID, timestamps or status.
final class OutletDetails {
  OutletDetails({
    required String outletCode,
    required String name,
    String? description,
  }) : outletCode = outletCode.trim(),
       name = name.trim(),
       description = description == null || description.trim().isEmpty
           ? null
           : description.trim() {
    if (this.outletCode.isEmpty) throw OutletProblem.missingCode;
    if (this.name.isEmpty) throw OutletProblem.missingName;
  }
  final String outletCode, name;
  final String? description;
}

abstract interface class OutletRepository implements WorkspaceReader {
  Stream<List<Outlet>> watchDirectory(DirectoryQuery query);
  Future<String> create(OutletDetails details);
  Future<void> edit(String id, OutletDetails details);
  Future<void> setActive(String id, bool active);
}
