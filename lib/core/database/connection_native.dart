import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openLocalConnection() => LazyDatabase(() async {
  final directory = Platform.isWindows
      ? _windowsLocalDirectory()
      : await getApplicationSupportDirectory();
  await directory.create(recursive: true);
  return NativeDatabase.createInBackground(
    File(p.join(directory.path, 'strata.sqlite')),
  );
});

Directory _windowsLocalDirectory() {
  final local = Platform.environment['LOCALAPPDATA'];
  if (local == null || !p.isAbsolute(local)) {
    throw StateError('Local application data directory unavailable');
  }
  return Directory(p.join(local, 'Strata'));
}
