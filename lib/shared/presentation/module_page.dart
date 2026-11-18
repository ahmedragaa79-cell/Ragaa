import 'package:material_ui/material_ui.dart';

import '../../app/localization/localization.dart';
import '../../app/theme/workspace_theme.dart';
import '../../core/widgets/surface.dart';
import 'page_layout.dart';

typedef Capability = ({IconData icon, String title, String description});

/// A real destination, not a simulated CRUD/export screen. Descriptive
/// capability cards are intentionally not buttons until the workflows exist.
class ModulePage extends StatelessWidget {
  const ModulePage({
    super.key,
    required this.title,
    required this.description,
    required this.panelTitle,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.icon,
    required this.accent,
    required this.capabilities,
  });
  final String title, description, panelTitle, emptyTitle, emptyDescription;
  final IconData icon;
  final Accent accent;
  final List<Capability> capabilities;

  @override
  Widget build(BuildContext context) => WorkspacePage(
    eyebrow: context.l10n.moduleEyebrow,
    title: title,
    description: description,
    children: [
      SurfacePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 17),
              child: Text(
                panelTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.background(context),
                        width: 2,
                      ),
                    ),
                    child: AccentIcon(icon, accent, size: 52),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    emptyTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Text(
                      emptyDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 26),
      Text(
        context.l10n.plannedCapabilities,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      AdaptiveRow(
        minWidth: 580,
        children: [
          for (final capability in capabilities)
            SurfacePanel(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AccentIcon(capability.icon, accent, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capability.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            capability.description,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.6,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ],
  );
}
