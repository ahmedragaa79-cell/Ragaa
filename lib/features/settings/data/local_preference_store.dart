import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../application/workspace_preferences.dart';

/// Preferences only. Never use this key-value store for business records.
final class LocalPreferenceStore implements PreferenceStore {
  static const _language = 'strata.preferences.language.v1';
  static const _appearance = 'strata.preferences.appearance.v1';

  // Lazily initialize so a missing platform implementation can be handled by
  // the same error boundary as a failed read or write.
  late final _store = SharedPreferencesAsync();

  @override
  Future<WorkspacePreferences> load() async {
    final data = await _store.getAll(allowList: {_language, _appearance});
    return WorkspacePreferences.decode(
      data[_language] is String ? data[_language] as String : null,
      data[_appearance] is String ? data[_appearance] as String : null,
    );
  }

  @override
  Future<void> saveLocale(Locale locale) =>
      _store.setString(_language, locale.languageCode);

  @override
  Future<void> saveTheme(ThemeMode theme) =>
      _store.setString(_appearance, theme.name);
}
