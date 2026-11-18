import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../application/workspace_preferences.dart';

/// One versioned document for the small device preferences. A successful
/// write saves both choices together. This is never the business database.
final class LocalPreferenceStore implements PreferenceStore {
  static const _key = 'strata.preferences.v1';
  late final _store = SharedPreferencesAsync();

  @override
  Future<WorkspacePreferences> load() async {
    final raw = await _store.getString(_key);
    if (raw == null) return const WorkspacePreferences();
    final data = jsonDecode(raw);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid preferences');
    }
    return WorkspacePreferences.decode(
      data['locale'] is String ? data['locale'] as String : null,
      data['theme'] is String ? data['theme'] as String : null,
    );
  }

  @override
  Future<void> save(WorkspacePreferences values) => _store.setString(
    _key,
    jsonEncode({
      'locale': values.locale?.languageCode,
      'theme': values.themeMode.name,
    }),
  );
}
