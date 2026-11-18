@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strata/features/settings/data/local_preference_store.dart';

void main() {
  test(
    'the web plugin restores choices through a fresh storage adapter',
    () async {
      // The test runner owns its isolated browser origin; no business storage.
      final store = LocalPreferenceStore();
      await store.saveLocale(const Locale('ar'));
      await store.saveTheme(ThemeMode.dark);
      final restored = await LocalPreferenceStore().load();
      expect(restored.locale, const Locale('ar'));
      expect(restored.themeMode, ThemeMode.dark);
    },
  );
}
