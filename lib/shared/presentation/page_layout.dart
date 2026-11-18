import 'package:material_ui/material_ui.dart';

import '../../app/theme/workspace_theme.dart';
import '../../core/widgets/surface.dart';

/// Shared content gutter and header rhythm across all five destinations.
class WorkspacePage extends StatelessWidget {
  const WorkspacePage({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.trailing,
    required this.children,
  });

  final String eyebrow, title, description;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final compact = box.maxWidth < 650;
      final header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(eyebrow, rule: true),
          const SizedBox(height: 6),
          Semantics(
            header: true,
            child: Text(
              title,
              style: TextStyle(
                fontSize: compact ? 30 : 35,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
                height: 1.3,
                color: context.colors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: context.colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      );
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 18 : 30,
          vertical: compact ? 21 : 27,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1380),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!compact && trailing != null)
                  Row(
                    children: [
                      Expanded(child: header),
                      const SizedBox(width: 14),
                      trailing!,
                    ],
                  )
                else ...[
                  header,
                  if (trailing != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: trailing!,
                    ),
                  ],
                ],
                const SizedBox(height: 23),
                ...children,
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Equal-height columns on wide canvases; natural-height cards on mobile.
class AdaptiveRow extends StatelessWidget {
  const AdaptiveRow({
    super.key,
    required this.children,
    this.minWidth = 700,
    this.flex,
    this.gap = 16,
  });
  final List<Widget> children;
  final double minWidth, gap;
  final List<int>? flex;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      if (box.maxWidth < minWidth) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: children,
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: [
            for (var i = 0; i < children.length; i++)
              Expanded(flex: flex?[i] ?? 1, child: children[i]),
          ],
        ),
      );
    },
  );
}
