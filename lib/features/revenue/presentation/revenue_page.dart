import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../app/router/destination.dart';
import '../../../app/theme/workspace_theme.dart';
import '../../../shared/presentation/module_page.dart';

class RevenuePage extends StatelessWidget {
  const RevenuePage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ModulePage(
      title: l.revenueEntry,
      description: l.revenueDescription,
      panelTitle: l.revenueRegister,
      emptyTitle: l.noRevenue,
      emptyDescription: l.emptyRevenue,
      icon: Destination.revenue.icon,
      accent: Accent.teal,
      capabilities: [
        (
          icon: Icons.timelapse_rounded,
          title: l.shiftEntries,
          description: l.shiftEntriesHint,
        ),
        (
          icon: Icons.calculate_outlined,
          title: l.dailyTotals,
          description: l.dailyTotalsHint,
        ),
      ],
    );
  }
}
