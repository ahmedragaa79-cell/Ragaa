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

  Future<void> setLocale(Locale locale) =>
      _update(state.values.withLocale(locale));

  Future<void> setTheme(ThemeMode theme) =>
      _update(state.values.withTheme(theme));

  Future<void> _update(WorkspacePreferences values) {
    final store = ref.read(preferenceStoreProvider);
    // Apply immediately; serialize whole snapshots so the last choice wins,
    // even after a transient storage failure or rapid successive changes.
    state = (values: values, storageWarning: state.storageWarning);
    _writes = _writes.then((_) async {
      var failed = false;
      try {
        await store.save(values);
      } catch (_) {
        failed = true;
      }
      if (ref.mounted && state.storageWarning != failed) {
        state = (values: state.values, storageWarning: failed);
      }
    });
    return _writes;
  }
}
