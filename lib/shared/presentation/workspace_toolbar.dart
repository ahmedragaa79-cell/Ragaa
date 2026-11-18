import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/localization/localization.dart';
import '../../app/router/destination.dart';
import '../../app/theme/workspace_theme.dart';
import '../../features/settings/application/preferences_controller.dart';

class WorkspaceToolbar extends ConsumerWidget {
  const WorkspaceToolbar({
    super.key,
    required this.current,
    required this.showMenu,
  });
  final Destination current;
  final bool showMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final english = Localizations.localeOf(context).languageCode == 'en';
    final controller = ref.read(preferencesProvider.notifier);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.outlineVariant),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, box) => ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 62),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: showMenu ? 8 : 28,
              vertical: 6,
            ),
            child: Row(
              children: [
                if (showMenu)
                  IconButton(
                    key: const ValueKey('open-drawer'),
                    tooltip: l.openNavigation,
                    icon: const Icon(Icons.menu_rounded, size: 21),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  )
                else
                  Icon(
                    Icons.grid_view_rounded,
                    size: 16,
                    color: context.colors.onSurfaceVariant,
                  ),
                if (box.maxWidth >= 540) ...[
                  const SizedBox(width: 10),
                  Text(
                    l.workspace,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    current.label(l),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
                PopupMenuButton<Locale>(
                  key: const ValueKey('toolbar-language'),
                  tooltip: l.language,
                  position: PopupMenuPosition.under,
                  initialValue: Locale(english ? 'en' : 'ar'),
                  onSelected: controller.setLocale,
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: const Locale('en'),
                      child: Text(l.englishName),
                    ),
                    PopupMenuItem(
                      value: const Locale('ar'),
                      child: Text(l.arabicName),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 9,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language_rounded,
                          color: context.colors.onSurfaceVariant,
                          size: 17,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          english ? l.englishName : l.arabicName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 15),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 19,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: context.colors.outlineVariant,
                ),
                IconButton(
                  key: const ValueKey('toolbar-theme'),
                  tooltip: context.isDark ? l.switchLight : l.switchDark,
                  onPressed: () => controller.setTheme(
                    context.isDark ? ThemeMode.light : ThemeMode.dark,
                  ),
                  icon: Icon(
                    context.isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    size: 19,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
