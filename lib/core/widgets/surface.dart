import 'package:material_ui/material_ui.dart';

import '../../app/theme/workspace_theme.dart';

class SurfacePanel extends StatelessWidget {
  const SurfacePanel({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.colors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: onTap == null ? child : InkWell(onTap: onTap, child: child),
    );
  }
}

class AccentIcon extends StatelessWidget {
  const AccentIcon(this.icon, this.accent, {super.key, this.size = 42});

  final IconData icon;
  final Accent accent;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: accent.background(context),
      borderRadius: BorderRadius.circular(size * .27),
    ),
    child: Icon(icon, size: size * .54, color: accent.foreground(context)),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color, this.rule = false});
  final String text;
  final Color? color;
  final bool rule;

  @override
  Widget build(BuildContext context) {
    final ink = color ?? context.colors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rule) ...[
          Container(width: 17, height: 2, color: ink),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: ink,
              fontSize: 10,
              height: 1.5,
              fontWeight: FontWeight.w800,
              letterSpacing: Directionality.of(context) == TextDirection.rtl
                  ? 0
                  : 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
