import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/settings/application/preferences_controller.dart';
import 'features/settings/data/local_preference_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LocalPreferenceStore();
  final initial = await restorePreferences(store);
  runApp(
    ProviderScope(
      overrides: [
        preferenceStoreProvider.overrideWithValue(store),
        initialPreferencesProvider.overrideWithValue(initial),
      ],
      child: const StrataApp(),
    ),
  );
}
