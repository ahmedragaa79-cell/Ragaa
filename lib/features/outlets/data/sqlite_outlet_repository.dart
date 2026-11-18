import 'package:drift/drift.dart';
import 'package:sqlite3/common.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/strata_database.dart';
import '../../../shared/domain/outlet.dart';
import '../../../shared/domain/workspace_reader.dart';
import '../domain/outlet_repository.dart';

final class SqliteOutletRepository implements OutletRepository {
  SqliteOutletRepository(this._db);
  final StrataDatabase _db;

  @override
  Stream<List<Outlet>> watchDirectory(DirectoryQuery query) {
    final rows = _db.select(_db.outlets);
    if (query.filter != OutletFilter.all) {
      rows.where((o) => o.isActive.equals(query.filter == OutletFilter.active));
    }
    final term = query.search.trim();
    if (term.isNotEmpty) {
      // Literal substring, not a user-supplied SQL pattern.
      final escaped = term
          .replaceAll('!', '!!')
          .replaceAll('%', '!%')
          .replaceAll('_', '!_');
      rows.where(
        (o) =>
            o.name.like('%$escaped%', escapeChar: '!') |
            o.outletCode.like('%$escaped%', escapeChar: '!'),
      );
    }
    rows.orderBy([
      (o) => OrderingTerm.asc(o.name.collate(Collate.noCase)),
      (o) => OrderingTerm.asc(o.id),
    ]);
    return rows
        .map(
          (o) => Outlet(
            id: o.id,
            outletCode: o.outletCode,
            name: o.name,
            description: o.description,
            isActive: o.isActive,
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              o.createdAt,
              isUtc: true,
            ),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(
              o.updatedAt,
              isUtc: true,
            ),
          ),
        )
        .watch();
  }

  @override
  Stream<WorkspaceOverview> watchOverview() {
    final table = _db.outlets;
    final total = table.id.count(),
        active = table.id.count(filter: table.isActive);
    return (_db.selectOnly(table)..addColumns([total, active]))
        .map(
          (row) => WorkspaceOverview(
            totalOutlets: row.read(total)!,
            activeOutlets: row.read(active)!,
          ),
        )
        .watchSingle();
  }

  int get _now => DateTime.now().millisecondsSinceEpoch;

  @override
  Future<String> create(OutletDetails details) => _withUniqueCode(() async {
    final id = const Uuid().v4(), stamp = _now;
    await _db
        .into(_db.outlets)
        .insert(
          OutletsCompanion.insert(
            id: id,
            outletCode: details.outletCode,
            name: details.name,
            description: Value(details.description),
            createdAt: stamp,
            updatedAt: stamp,
          ),
        );
    return id;
  });

  @override
  Future<void> edit(String id, OutletDetails details) => _withUniqueCode(
    () => _update(
      id,
      OutletsCompanion(
        outletCode: Value(details.outletCode),
        name: Value(details.name),
        description: Value(details.description),
        updatedAt: Value(_now),
      ),
    ),
  );

  @override
  Future<void> setActive(String id, bool active) => _update(
    id,
    OutletsCompanion(isActive: Value(active), updatedAt: Value(_now)),
  );

  Future<void> _update(String id, OutletsCompanion changes) async {
    final affected = await (_db.update(
      _db.outlets,
    )..where((o) => o.id.equals(id))).write(changes);
    if (affected != 1) throw OutletProblem.notFound;
  }

  // SQLite is the authority, even for concurrent writes: no check-then-insert
  // race. The only UNIQUE (not PRIMARY KEY) constraint is outlet_code.
  Future<T> _withUniqueCode<T>(Future<T> Function() write) async {
    try {
      return await write();
    } on SqliteException catch (error) {
      if (error.extendedResultCode == 2067) throw OutletProblem.duplicateCode;
      rethrow;
    }
  }
}
