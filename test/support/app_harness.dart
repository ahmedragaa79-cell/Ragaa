import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strata/app/app.dart';
import 'package:strata/features/settings/application/preferences_controller.dart';
import 'package:strata/features/settings/application/workspace_preferences.dart';
import 'package:strata/shared/data/empty_workspace_reader.dart';
import 'package:strata/shared/domain/workspace_reader.dart';

class MemoryPreferenceStore implements PreferenceStore {
  WorkspacePreferences saved = const WorkspacePreferences();
  bool rejectReads = false, rejectWrites = false;

  @override
  Future<WorkspacePreferences> load() async {
    if (rejectReads) throw StateError('read failed');
    return saved;
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    if (rejectWrites) throw StateError('write failed');
    saved = saved.withLocale(locale);
  }

  @override
  Future<void> saveTheme(ThemeMode theme) async {
    if (rejectWrites) throw StateError('write failed');
    saved = saved.withTheme(theme);
  }
}

void setViewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> launch(
  WidgetTester tester,
  MemoryPreferenceStore store, {
  WorkspaceReader? reader,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferenceStoreProvider.overrideWithValue(store),
        initialPreferencesProvider.overrideWithValue(
          await restorePreferences(store),
        ),
        if (reader != null) workspaceReaderProvider.overrideWithValue(reader),
      ],
      child: const StrataApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}
