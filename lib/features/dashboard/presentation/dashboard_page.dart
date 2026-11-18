import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../app/theme/workspace_theme.dart';
import '../../../core/widgets/surface.dart';
import '../../../shared/presentation/page_layout.dart';
import '../application/overview_provider.dart';
import 'module_cards.dart';
import 'revenue_summary.dart';
import 'snapshot_panel.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return WorkspacePage(
      eyebrow: l.consoleLabel,
      title: l.dashboard,
      description: l.dashboardDescription,
      trailing: SurfacePanel(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                context.formats.date(DateTime.now()),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      children: [
        ref
            .watch(overviewProvider)
            .when(
              data: (o) => AdaptiveRow(
                flex: const [8, 5],
                minWidth: 680,
                children: [
                  RevenueSummary(total: o.totalRevenue),
                  SnapshotPanel(overview: o),
                ],
              ),
              loading: () => const SizedBox(
                height: 218,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => SurfacePanel(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(l.overviewUnavailable),
                      TextButton(
                        onPressed: () => ref.invalidate(overviewProvider),
                        child: Text(l.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        const SizedBox(height: 27),
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l.quickAccess,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.65,
                  ),
                ),
              ),
            ),
            Flexible(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Eyebrow(
                  l.modulesLabel,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        const ModuleCards(),
        const SizedBox(height: 20),
        const _ShiftGuide(),
      ],
    );
  }
}

class _ShiftGuide extends StatelessWidget {
  const _ShiftGuide();
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final label = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(l.shiftStructure, color: context.colors.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          l.shiftOverview,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          l.shiftGuide,
          style: TextStyle(
            color: context.colors.onSurfaceVariant,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
    final shifts = Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _ShiftBadge(l.firstShift, Accent.blue),
        _ShiftBadge(l.secondShift, Accent.violet),
      ],
    );
    return SurfacePanel(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, box) => box.maxWidth < 670
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [label, const SizedBox(height: 12), shifts],
                )
              : Row(
                  children: [
                    Expanded(child: label),
                    const SizedBox(width: 12),
                    shifts,
                  ],
                ),
        ),
      ),
    );
  }
}

class _ShiftBadge extends StatelessWidget {
  const _ShiftBadge(this.title, this.accent);
  final String title;
  final Accent accent;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: accent.background(context),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: accent.foreground(context),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: TextStyle(
            color: accent.foreground(context),
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}
