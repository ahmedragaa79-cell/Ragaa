import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../app/router/destination.dart';
import '../../../app/theme/workspace_theme.dart';
import '../../../core/widgets/surface.dart';
import '../../../shared/presentation/page_layout.dart';

class ModuleCards extends StatelessWidget {
  const ModuleCards({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AdaptiveRow(
      children: [
        _ModuleCard(
          Destination.outlets,
          Accent.blue,
          l.outletManagement,
          l.outletsCardDescription,
          l.openOutlets,
        ),
        _ModuleCard(
          Destination.revenue,
          Accent.teal,
          l.revenueEntry,
          l.revenueCardDescription,
          l.openRevenue,
        ),
        _ModuleCard(
          Destination.reports,
          Accent.violet,
          l.reports,
          l.reportsCardDescription,
          l.openReports,
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard(
    this.page,
    this.accent,
    this.title,
    this.description,
    this.action,
  );
  final Destination page;
  final Accent accent;
  final String title, description, action;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: SurfacePanel(
      key: ValueKey('module-${page.name}'),
      onTap: () => context.go(page.path),
      child: Padding(
        padding: const EdgeInsets.all(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AccentIcon(page.icon, accent),
                    Text(
                      context.formats.index(page.index),
                      style: TextStyle(
                        color: context.colors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .8,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.45,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 17),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      action,
                      style: TextStyle(
                        color: accent.foreground(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: accent.foreground(context),
                    size: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
