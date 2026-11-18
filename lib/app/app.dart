import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../features/settings/application/preferences_controller.dart';
import 'localization/generated/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/workspace_theme.dart';

class StrataApp extends ConsumerWidget {
  const StrataApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider.select((s) => s.values));
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      locale: prefs.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      theme: WorkspaceTheme.create(Brightness.light),
      darkTheme: WorkspaceTheme.create(Brightness.dark),
      themeMode: prefs.themeMode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
