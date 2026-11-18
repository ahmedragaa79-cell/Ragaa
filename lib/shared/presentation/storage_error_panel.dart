import 'package:material_ui/material_ui.dart';

import '../../app/localization/localization.dart';
import '../../core/database/storage_problem.dart';
import '../../core/widgets/surface.dart';

class StorageErrorPanel extends StatelessWidget {
  const StorageErrorPanel({
    super.key,
    required this.heading,
    required this.error,
    required this.onRetry,
  });
  final String heading;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final detail = switch (error) {
      StorageProblem.corrupt => l.corruptStorage,
      StorageProblem.incompatible => l.incompatibleStorage,
      StorageProblem.noDurableBrowserStorage => l.browserStorageUnavailable,
      _ => l.storageReadHint,
    };
    return SurfacePanel(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.storage_outlined),
            const SizedBox(height: 10),
            Semantics(
              liveRegion: true,
              child: Text(
                heading,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 5),
            Text(detail, textAlign: TextAlign.center),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l.retry),
            ),
          ],
        ),
      ),
    );
  }
}
