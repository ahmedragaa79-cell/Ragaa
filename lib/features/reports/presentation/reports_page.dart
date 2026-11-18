import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../app/router/destination.dart';
import '../../../app/theme/workspace_theme.dart';
import '../../../shared/presentation/module_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ModulePage(
      title: l.reports,
      description: l.reportsDescription,
      panelTitle: l.reportCenter,
      emptyTitle: l.noReports,
      emptyDescription: l.emptyReports,
      icon: Destination.reports.icon,
      accent: Accent.violet,
      capabilities: [
        (
          icon: Icons.filter_alt_outlined,
          title: l.reportFilters,
          description: l.reportFiltersHint,
        ),
        (
          icon: Icons.file_download_outlined,
          title: l.reportExports,
          description: l.reportExportsHint,
        ),
      ],
    );
  }
}
