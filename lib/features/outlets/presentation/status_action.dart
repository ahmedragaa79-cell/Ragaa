import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../shared/data/workspace_providers.dart';
import '../../../shared/domain/outlet.dart';
import '../domain/outlet_repository.dart';

Future<void> changeOutletStatus(
  BuildContext context,
  WidgetRef ref,
  Outlet outlet,
) async {
  final activating = !outlet.isActive;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l = context.l10n;
      return AlertDialog(
        scrollable: true,
        title: Text(
          activating
              ? l.confirmActivate(outlet.name)
              : l.confirmDeactivate(outlet.name),
        ),
        content: Text(activating ? l.activateHint : l.deactivateHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancelAction),
          ),
          FilledButton(
            key: const ValueKey('confirm-status'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(activating ? l.activateOutlet : l.deactivateOutlet),
          ),
        ],
      );
    },
  );
  if (confirmed != true || !context.mounted) return;
  // The originating row may disappear from a filtered list after the write.
  final messenger = ScaffoldMessenger.of(context);
  final l = context.l10n;
  String message;
  try {
    final repo = await ref.read(outletRepositoryProvider.future);
    await repo.setActive(outlet.id, activating);
    message = activating ? l.outletActivated : l.outletDeactivated;
  } on OutletProblem catch (error) {
    message = error == OutletProblem.notFound
        ? l.outletNotFound
        : l.outletWriteFailed;
  } catch (_) {
    message = l.outletWriteFailed;
  }
  if (messenger.mounted) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
