import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../app/theme/workspace_theme.dart';
import '../../../core/widgets/surface.dart';
import '../../../shared/presentation/page_layout.dart';
import '../application/preferences_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final controller = ref.read(preferencesProvider.notifier);
    final theme = ref.watch(
      preferencesProvider.select((s) => s.values.themeMode),
    );
    final language = Localizations.localeOf(context).languageCode;
    return WorkspacePage(
      eyebrow: l.preferencesLabel,
      title: l.settings,
      description: l.settingsDescription,
      children: [
        _PreferencePanel(
          icon: Icons.translate_rounded,
          accent: Accent.blue,
          title: l.displayLanguage,
          description: l.languageHint,
          choices: [
            for (final code in ['en', 'ar'])
              ChoiceChip(
                key: ValueKey('language-$code'),
                label: Text(code == 'en' ? l.englishName : l.arabicName),
                selected: language == code,
                onSelected: (_) => controller.setLocale(Locale(code)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _PreferencePanel(
          icon: Icons.contrast_rounded,
          accent: Accent.violet,
          title: l.appearance,
          description: l.appearanceHint,
          choices: [
            for (final (mode, label) in [
              (ThemeMode.system, l.systemMode),
              (ThemeMode.light, l.lightMode),
              (ThemeMode.dark, l.darkMode),
            ])
              ChoiceChip(
                key: ValueKey('theme-${mode.name}'),
                label: Text(label),
                selected: theme == mode,
                onSelected: (_) => controller.setTheme(mode),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Icon(
              Icons.devices_outlined,
              size: 17,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                l.preferenceNote,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PreferencePanel extends StatelessWidget {
  const _PreferencePanel({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.choices,
  });
  final IconData icon;
  final Accent accent;
  final String title, description;
  final List<Widget> choices;
  @override
  Widget build(BuildContext context) => SurfacePanel(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccentIcon(icon, accent),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        color: context.colors.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Wrap(spacing: 9, runSpacing: 7, children: choices),
        ],
      ),
    ),
  );
}
