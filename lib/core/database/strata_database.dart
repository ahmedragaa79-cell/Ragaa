import 'package:drift/drift.dart';

import 'storage_problem.dart';

part 'strata_database.g.dart';

const _directoryIndex =
    'CREATE INDEX IF NOT EXISTS outlets_directory ON outlets (is_active, name COLLATE NOCASE, id)';

@DataClassName('OutletRow')
@TableIndex.sql(_directoryIndex)
class Outlets extends Table {
  TextColumn get id => text()();
  TextColumn get outletCode => text().customConstraint(
    'NOT NULL COLLATE NOCASE UNIQUE CHECK (length(trim(outlet_code)) > 0 AND outlet_code = trim(outlet_code))',
  )();
  TextColumn get name =>
      text().customConstraint('NOT NULL CHECK (length(trim(name)) > 0)')();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  // UTC epoch milliseconds: no locale or local time zone in the file format.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Outlets])
class StrataDatabase extends _$StrataDatabase {
  StrataDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => transaction(() async {
      final existing = await customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' LIMIT 1",
      ).get();
      if (existing.isNotEmpty) throw StorageProblem.incompatible;
      await m.createAll();
    }),
    onUpgrade: (m, from, to) async {
      if (from != 1 || to != 2) throw StorageProblem.incompatible;
      // v1 already has every business field. v2 adds only a search/filter
      // index; an interrupted upgrade can safely replay this step.
      await transaction(() => customStatement(_directoryIndex));
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      final check = await customSelect('PRAGMA quick_check(1)').getSingle();
      if (check.data.values.single != 'ok') throw StorageProblem.corrupt;
    },
  );

  /// Forces open, migration, integrity and column checks before serving UI.
  Future<void> initialize() async {
    await (select(outlets)..limit(0)).get();
  }
}
