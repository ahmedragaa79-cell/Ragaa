import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strata/features/settings/application/preferences_controller.dart';
import 'package:strata/features/settings/application/workspace_preferences.dart';
import 'package:strata/shared/data/empty_workspace_reader.dart';
import 'package:strata/shared/domain/revenue.dart';

import 'support/app_harness.dart';

void main() {
  test('the production adapter contains no outlets or revenue rows', () async {
    const store = EmptyWorkspaceReader();
    expect(await store.outlets(), isEmpty);
    expect(await store.revenue(RevenueQuery()), isEmpty);
    final overview = await store.overview();
    expect(overview.revenueRecords, 0);
    expect(overview.activeOutlets, 0);
    expect(overview.totalRevenue.units, 0);
  });
  test(
    'query bounds are inclusive calendar days; selected IDs are immutable',
    () {
      final start = BusinessDay.fromCalendar(DateTime(2026, 11, 18, 23));
      final same = BusinessDay.fromCalendar(DateTime.utc(2026, 11, 18));
      final end = BusinessDay.fromCalendar(DateTime(2026, 11, 19));
      expect(start, same);
      expect(
        (outletId: 'test', day: start, shift: RevenueShift.first),
        (outletId: 'test', day: same, shift: RevenueShift.first),
      );
      final ids = {'one'};
      final query = RevenueQuery(from: start, through: same, outletIds: ids);
      ids.add('two');
      expect(query.outletIds, {'one'});
      expect(
        () => RevenueQuery(from: end, through: start),
        throwsArgumentError,
      );
    },
  );
  test(
    'corrupt values and unreadable preferences never prevent startup',
    () async {
      final invalid = WorkspacePreferences.decode('invalid', 'outdated');
      expect(invalid.locale, isNull);
      expect(invalid.themeMode, ThemeMode.system);
      final initial = await restorePreferences(
        MemoryPreferenceStore()..rejectReads = true,
      );
      expect(initial.storageWarning, isTrue);
      expect(initial.values.themeMode, ThemeMode.system);
    },
  );
  test('rapid preference changes restore the last choice', () async {
    final store = MemoryPreferenceStore();
    final container = ProviderContainer.test(
      overrides: [preferenceStoreProvider.overrideWithValue(store)],
    );
    final controller = container.read(preferencesProvider.notifier);
    await Future.wait([
      controller.setLocale(const Locale('ar')),
      controller.setTheme(ThemeMode.dark),
      controller.setLocale(const Locale('en')),
    ]);
    expect(store.saved.locale, const Locale('en'));
    expect(store.saved.themeMode, ThemeMode.dark);
  });
}
