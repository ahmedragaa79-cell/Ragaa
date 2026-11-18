import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/local_preference_store.dart';
import 'workspace_preferences.dart';

final preferenceStoreProvider = Provider<PreferenceStore>(
  (ref) => LocalPreferenceStore(),
);

/// Supplied before the first frame, so the saved language never flashes back
/// to the system language. A blocked preference backend does not block launch.
typedef PreferenceSnapshot = ({
  WorkspacePreferences values,
  bool storageWarning,
});

Future<PreferenceSnapshot> restorePreferences(PreferenceStore store) async {
  try {
    return (values: await store.load(), storageWarning: false);
  } catch (_) {
    return (values: const WorkspacePreferences(), storageWarning: true);
  }
}

final initialPreferencesProvider = Provider<PreferenceSnapshot>(
  (ref) => (values: const WorkspacePreferences(), storageWarning: false),
);
final preferencesProvider =
    NotifierProvider<PreferencesController, PreferenceSnapshot>(
      PreferencesController.new,
    );

class PreferencesController extends Notifier<PreferenceSnapshot> {
  Future<void> _writes = Future.value();

  @override
  PreferenceSnapshot build() => ref.watch(initialPreferencesProvider);

  Future<void> setLocale(Locale locale) {
    final store = ref.read(preferenceStoreProvider);
    return _update(
      state.values.withLocale(locale),
      () => store.saveLocale(locale),
    );
  }

  Future<void> setTheme(ThemeMode theme) {
    final store = ref.read(preferenceStoreProvider);
    return _update(state.values.withTheme(theme), () => store.saveTheme(theme));
  }

  Future<void> _update(
    WorkspacePreferences values,
    Future<void> Function() persist,
  ) {
    // Apply immediately; serialize writes so quick successive choices restore
    // in the same order after restart. Keep the session usable on failure.
    state = (values: values, storageWarning: state.storageWarning);
    _writes = _writes.then((_) async {
      try {
        await persist();
      } catch (_) {
        if (ref.mounted) state = (values: state.values, storageWarning: true);
      }
    });
    return _writes;
  }
}
