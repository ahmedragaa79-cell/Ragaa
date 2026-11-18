// Opt-in documentation captures, not platform-dependent assertions in the
// default test suite. Run with --update-goldens (see README).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strata/features/settings/application/workspace_preferences.dart';

import '../support/app_harness.dart';

void main() {
  for (final (code, mode) in [
    ('en', ThemeMode.light),
    ('ar', ThemeMode.dark),
  ]) {
    testWidgets('capture the real $code dashboard', (tester) async {
      setViewport(tester, const Size(1320, 880));
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await tester.runAsync(icons.load);
      final store = MemoryPreferenceStore()
        ..saved = WorkspacePreferences(locale: Locale(code), themeMode: mode);
      await launch(tester, store);
      final context = tester.element(find.byType(Scaffold));
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/art/ledger-study.webp'),
          context,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('../../docs/previews/dashboard-$code.png'),
      );
    });
  }
}
