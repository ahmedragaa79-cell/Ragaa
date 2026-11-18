import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import 'storage_problem.dart';

QueryExecutor openLocalConnection() => DatabaseConnection.delayed(_open());

Future<DatabaseConnection> _open() async {
  const name = 'strata';
  final probe = await WasmDatabase.probe(
    databaseName: name,
    sqlite3Uri: Uri.base.resolve('sqlite/sqlite3.wasm'),
    driftWorkerUri: Uri.base.resolve('sqlite/drift_worker.js'),
  );
  final existing = probe.existingDatabases
      .where((db) => db.$2 == name)
      .map((db) => db.$1)
      .toSet();
  // Never open an empty substitute if an existing store is inaccessible, or
  // choose arbitrarily between two stores. No in-memory / unsafe fallbacks.
  if (existing.length <= 1) {
    for (final storage in const [
      WasmStorageImplementation.opfsShared,
      WasmStorageImplementation.opfsLocks,
      WasmStorageImplementation.sharedIndexedDb,
    ]) {
      if (probe.availableStorages.contains(storage) &&
          (existing.isEmpty || existing.contains(storage.storageApi))) {
        return probe.open(storage, name);
      }
    }
  }
  throw StorageProblem.noDurableBrowserStorage;
}
