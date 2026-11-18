import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../app/router/destination.dart';
import '../../../app/theme/workspace_theme.dart';
import '../../../shared/presentation/module_page.dart';

class OutletsPage extends StatelessWidget {
  const OutletsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ModulePage(
      title: l.outletManagement,
      description: l.outletsDescription,
      panelTitle: l.outletDirectory,
      emptyTitle: l.noOutlets,
      emptyDescription: l.emptyOutlets,
      icon: Destination.outlets.icon,
      accent: Accent.blue,
      capabilities: [
        (
          icon: Icons.storefront_outlined,
          title: l.outletProfiles,
          description: l.outletProfilesHint,
        ),
        (
          icon: Icons.toggle_on_outlined,
          title: l.outletAvailability,
          description: l.outletAvailabilityHint,
        ),
      ],
    );
  }
}
