@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:strata/core/database/storage_problem.dart';
import 'package:strata/core/database/strata_database.dart';
import 'package:strata/features/outlets/data/sqlite_outlet_repository.dart';
import 'package:strata/features/outlets/domain/outlet_repository.dart';
import 'package:strata/shared/application/overview_provider.dart';
import 'package:strata/shared/data/workspace_providers.dart';

import 'support/test_database.dart';

const all = (search: '', filter: OutletFilter.all);
OutletDetails details(String code, String name, [String? note]) =>
    OutletDetails(outletCode: code, name: name, description: note);

void main() {
  late StrataDatabase db;
  late SqliteOutletRepository repo;
  setUp(() {
    db = memoryDatabase();
    repo = SqliteOutletRepository(db);
  });
  tearDown(() => db.close());

  test(
    'fresh SQLite initializes empty with version and foreign keys enabled',
    () async {
      await db.initialize();
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        2,
      );
      expect(
        (await db.customSelect('PRAGMA foreign_keys').getSingle())
            .data
            .values
            .single,
        1,
      );
      expect(await repo.watchDirectory(all).first, isEmpty);
      expect((await repo.watchOverview().first).totalOutlets, 0);
    },
  );
  test(
    'create, read and edit retain identity, status and creation time',
    () async {
      final id = await repo.create(details(' A1 ', ' North ', ' Site '));
      final first = (await repo.watchDirectory(all).first).single;
      expect(
        [
          first.id,
          first.outletCode,
          first.name,
          first.description,
          first.isActive,
        ],
        [id, 'A1', 'North', 'Site', true],
      );
      expect(first.createdAt.isUtc, true);
      expect(first.updatedAt, first.createdAt);
      await repo.setActive(id, false);
      await repo.edit(id, details('A2', 'جنوب', '  '));
      final next = (await repo.watchDirectory(all).first).single;
      expect(
        [
          next.id,
          next.outletCode,
          next.name,
          next.description,
          next.isActive,
          next.createdAt,
        ],
        [id, 'A2', 'جنوب', null, false, first.createdAt],
      );
      expect(next.updatedAt.isBefore(first.updatedAt), false);
    },
  );
  test(
    'required, duplicate create/edit, no-op own code and database constraints',
    () async {
      expect(() => details('  ', 'North'), throwsA(OutletProblem.missingCode));
      expect(() => details('A', ' \t '), throwsA(OutletProblem.missingName));
      final a = await repo.create(details('A', 'First'));
      await repo.setActive(a, false);
      await expectLater(
        repo.create(details(' a ', 'Second')),
        throwsA(OutletProblem.duplicateCode),
      );
      final b = await repo.create(details('B', 'Second'));
      await expectLater(
        repo.edit(b, details('A', 'Changed')),
        throwsA(OutletProblem.duplicateCode),
      );
      await repo.edit(b, details('b', 'Second'));
      expect((await repo.watchDirectory(all).first).map((o) => o.name), [
        'First',
        'Second',
      ]);
      await expectLater(
        db.customStatement("UPDATE outlets SET name = ' '"),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(
        repo.setActive('missing', true),
        throwsA(OutletProblem.notFound),
      );
    },
  );
  test(
    'search name and code literally, including Arabic and wildcard characters',
    () async {
      await repo.create(details('M%_1', 'فرع المنيا'));
      await repo.create(details('MAIN', 'Cairo'));
      for (final (query, code) in [
        ('منيا', 'M%_1'),
        ('%_', 'M%_1'),
        (' aiR ', 'MAIN'),
        ('ain', 'MAIN'),
      ]) {
        expect(
          (await repo.watchDirectory((
            search: query,
            filter: OutletFilter.all,
          )).first).single.outletCode,
          code,
        );
      }
      expect(
        await repo.watchDirectory((
          search: 'missing',
          filter: OutletFilter.all,
        )).first,
        isEmpty,
      );
    },
  );
  test('activate and deactivate filter without deleting history', () async {
    final id = await repo.create(details('X', 'Station'));
    const active = (search: '', filter: OutletFilter.active),
        inactive = (search: '', filter: OutletFilter.inactive);
    await repo.setActive(id, false);
    expect(await repo.watchDirectory(active).first, isEmpty);
    expect((await repo.watchDirectory(inactive).first).single.id, id);
    await repo.setActive(id, true);
    expect((await repo.watchDirectory(active).first).single.id, id);
    expect(await repo.watchDirectory(inactive).first, isEmpty);
  });
  test(
    'dashboard provider emits committed total/active/inactive counts without refresh',
    () async {
      final container = ProviderContainer.test(
        overrides: [outletRepositoryProvider.overrideWith((ref) => repo)],
      );
      final changes = StreamController<(int, int, int)>();
      final subscription = container.listen(overviewProvider, (_, next) {
        if (next.asData case final data?) {
          final o = data.value;
          changes.add((o.totalOutlets, o.activeOutlets, o.inactiveOutlets));
        }
      });
      final iterator = StreamIterator(changes.stream);
      Future<void> next((int, int, int) expected) async {
        expect(await iterator.moveNext(), true);
        expect(iterator.current, expected);
      }

      try {
        await next((0, 0, 0));
        final id = await repo.create(details('A', 'One'));
        await next((1, 1, 0));
        await repo.create(details('B', 'Two'));
        await next((2, 2, 0));
        await repo.setActive(id, false);
        await next((2, 1, 1));
        await repo.setActive(id, true);
        await next((2, 2, 0));
      } finally {
        subscription.close();
        await iterator.cancel();
        await changes.close();
      }
    },
  );

  group('disposable on-disk storage', () {
    late Directory temp;
    late File file;
    setUp(() async {
      temp = await Directory.systemTemp.createTemp('strata-test-');
      file = File('${temp.path}/strata.sqlite');
    });
    tearDown(() => temp.delete(recursive: true));
    test(
      'independent native background connections survive close and reopen',
      () async {
        final first = StrataDatabase(NativeDatabase.createInBackground(file));
        late String id;
        try {
          final writer = SqliteOutletRepository(first);
          id = await writer.create(details('LOCAL', 'Minya'));
          await writer.setActive(id, false);
        } finally {
          await first.close();
        }
        final second = StrataDatabase(NativeDatabase.createInBackground(file));
        try {
          await second.initialize();
          final row = (await SqliteOutletRepository(
            second,
          ).watchDirectory(all).first).single;
          expect([row.id, row.name, row.isActive], [id, 'Minya', false]);
        } finally {
          await second.close();
        }
      },
    );
    test(
      'v1 fixture upgrades to v2 without changing any existing outlet fields',
      () async {
        final old = sqlite3.open(file.path);
        try {
          old.execute(
            '''CREATE TABLE outlets (id TEXT NOT NULL PRIMARY KEY, outlet_code TEXT NOT NULL COLLATE NOCASE UNIQUE CHECK(length(trim(outlet_code)) > 0 AND outlet_code = trim(outlet_code)), name TEXT NOT NULL CHECK(length(trim(name)) > 0), description TEXT, is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0,1)), created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)''',
          );
          old.execute(
            "INSERT INTO outlets VALUES ('keep', 'V1', 'Original', 'old', 0, 10, 20)",
          );
          old.execute('PRAGMA user_version = 1');
        } finally {
          old.close();
        }
        final upgraded = StrataDatabase(NativeDatabase(file));
        try {
          await upgraded.initialize();
        } finally {
          await upgraded.close();
        }
        final inspect = sqlite3.open(file.path);
        try {
          expect(inspect.userVersion, 2);
          expect(inspect.select('SELECT * FROM outlets').single.values, [
            'keep',
            'V1',
            'Original',
            'old',
            0,
            10,
            20,
          ]);
          expect(
            inspect.select(
              "SELECT name FROM sqlite_master WHERE name = 'outlets_directory'",
            ),
            hasLength(1),
          );
        } finally {
          inspect.close();
        }
      },
    );
    test(
      'future schema rejected; original version and data untouched',
      () async {
        final future = sqlite3.open(file.path);
        future.execute('CREATE TABLE future_table (value TEXT)');
        future.execute("INSERT INTO future_table VALUES ('keep')");
        future.userVersion = 99;
        future.close();
        final unsupported = StrataDatabase(NativeDatabase(file));
        try {
          await expectLater(
            unsupported.initialize(),
            throwsA(StorageProblem.incompatible),
          );
        } finally {
          await unsupported.close();
        }
        final inspect = sqlite3.open(file.path);
        try {
          expect(inspect.userVersion, 99);
          expect(
            inspect.select('SELECT value FROM future_table').single['value'],
            'keep',
          );
        } finally {
          inspect.close();
        }
      },
    );
    test(
      'corrupt bytes fail closed, without deletion or replacement',
      () async {
        final bytes = List<int>.filled(600, 0x43);
        await file.writeAsBytes(bytes);
        final broken = StrataDatabase(NativeDatabase(file));
        try {
          await expectLater(
            broken.initialize(),
            throwsA(isA<SqliteException>()),
          );
        } finally {
          await broken.close();
        }
        expect(await file.readAsBytes(), bytes);
      },
    );
  });
}
