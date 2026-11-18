import 'package:material_ui/material_ui.dart';

/// A null locale follows the system. Invalid/obsolete stored values safely
/// fall back to the system instead of breaking startup.
final class WorkspacePreferences {
  const WorkspacePreferences({this.locale, this.themeMode = ThemeMode.system});

  factory WorkspacePreferences.decode(String? language, String? appearance) {
    return WorkspacePreferences(
      locale: switch (language) {
        'ar' => const Locale('ar'),
        'en' => const Locale('en'),
        _ => null,
      },
      themeMode: switch (appearance) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
    );
  }

  final Locale? locale;
  final ThemeMode themeMode;

  WorkspacePreferences withLocale(Locale value) =>
      WorkspacePreferences(locale: value, themeMode: themeMode);

  WorkspacePreferences withTheme(ThemeMode value) =>
      WorkspacePreferences(locale: locale, themeMode: value);
}

abstract interface class PreferenceStore {
  Future<WorkspacePreferences> load();
  Future<void> saveLocale(Locale locale);
  Future<void> saveTheme(ThemeMode theme);
}
