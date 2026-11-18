import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../app/theme/workspace_theme.dart';
import '../../../core/widgets/surface.dart';
import '../../../shared/domain/revenue.dart';
import '../../../shared/domain/workspace_reader.dart';

class SnapshotPanel extends StatelessWidget {
  const SnapshotPanel({super.key, required this.overview});
  final WorkspaceOverview overview;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SurfacePanel(
      child: Padding(
        padding: const EdgeInsets.all(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.snapshot,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.35,
                    ),
                  ),
                ),
                Icon(
                  Icons.donut_small_outlined,
                  size: 18,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 13),
            _Metric(
              Icons.storefront_outlined,
              Accent.blue,
              l.activeOutlets,
              overview.activeOutlets,
            ),
            Divider(height: 16, color: context.colors.outlineVariant),
            _Metric(
              Icons.receipt_long_outlined,
              Accent.teal,
              l.revenueRecords,
              overview.revenueRecords,
            ),
            Divider(height: 16, color: context.colors.outlineVariant),
            _Metric(
              Icons.timelapse_rounded,
              Accent.violet,
              l.shiftsPerDay,
              RevenueShift.values.length,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.accent, this.label, this.value);
  final IconData icon;
  final Accent accent;
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      AccentIcon(icon, accent, size: 31),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: context.colors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        context.formats.count(value),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    ],
  );
}
