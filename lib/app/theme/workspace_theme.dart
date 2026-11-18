import 'package:material_ui/material_ui.dart';

abstract final class WorkspaceTheme {
  static const navy = Color(0xFF111D32);
  static const blue = Color(0xFF435FE4);

  static ThemeData create(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: blue, brightness: brightness)
        .copyWith(
          primary: dark ? const Color(0xFFB0BFFF) : const Color(0xFF3E59CF),
          surface: dark ? const Color(0xFF1A2538) : Colors.white,
          onSurface: dark ? const Color(0xFFF0F3FC) : const Color(0xFF16243B),
          onSurfaceVariant: dark
              ? const Color(0xFFAFBCD0)
              : const Color(0xFF5E6D82),
          outlineVariant: dark
              ? const Color(0xFF344158)
              : const Color(0xFFE0E5EE),
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Manrope',
      fontFamilyFallback: const ['Noto Sans Arabic'],
      scaffoldBackgroundColor: dark
          ? const Color(0xFF111A29)
          : const Color(0xFFF5F7FB),
      dividerColor: scheme.outlineVariant,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
    );
  }
}

extension WorkspaceColors on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

enum Accent {
  blue(Color(0xFF405DDA), Color(0xFFEBEEFF), Color(0xFFB5C3FF)),
  teal(Color(0xFF087C72), Color(0xFFE1F5F0), Color(0xFF85DDC9)),
  violet(Color(0xFF8051C3), Color(0xFFF2EBFC), Color(0xFFD3B5FF));

  const Accent(this.ink, this.wash, this.lightInk);
  final Color ink;
  final Color wash;
  final Color lightInk;
  Color foreground(BuildContext context) => context.isDark ? lightInk : ink;
  Color background(BuildContext context) => context.isDark
      ? Color.alphaBlend(ink.withValues(alpha: 0.24), context.colors.surface)
      : wash;
}
