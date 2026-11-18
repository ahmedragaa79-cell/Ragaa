import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/common.dart';

import '../../core/database/connection.dart';
import '../../core/database/storage_problem.dart';
import '../../core/database/strata_database.dart';
import '../../features/outlets/data/sqlite_outlet_repository.dart';
import '../../features/outlets/domain/outlet_repository.dart';
import '../domain/workspace_reader.dart';

final databaseFactoryProvider = Provider<StrataDatabase Function()>(
  (ref) =>
      () => StrataDatabase(openLocalConnection()),
);

final outletRepositoryProvider = FutureProvider<OutletRepository>((ref) async {
  final db = ref.watch(databaseFactoryProvider)();
  ref.onDispose(db.close);
  try {
    await db.initialize();
  } on SqliteException catch (error) {
    // SQLITE_CORRUPT / SQLITE_NOTADB. Never show paths, SQL, or stored values.
    if (error.resultCode == 11 || error.resultCode == 26)
      throw StorageProblem.corrupt;
    rethrow;
  }
  return SqliteOutletRepository(db);
}, retry: (count, error) => null);

final workspaceReaderProvider = Provider<Future<WorkspaceReader>>(
  (ref) => ref.watch(outletRepositoryProvider.future),
);
