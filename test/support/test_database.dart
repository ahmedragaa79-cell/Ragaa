import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:strata/core/database/strata_database.dart';

/// Never invoke path_provider or open the installed app's database in tests.
StrataDatabase memoryDatabase() => StrataDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);
