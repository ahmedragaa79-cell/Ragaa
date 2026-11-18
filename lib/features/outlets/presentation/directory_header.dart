import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../app/theme/workspace_theme.dart';
import '../../../core/widgets/surface.dart';
import '../../../shared/domain/workspace_reader.dart';
import '../domain/outlet_repository.dart';

class DirectoryCounts extends StatelessWidget {
  const DirectoryCounts(this.overview, {super.key});
  final WorkspaceOverview overview;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      (
        l.totalOutlets,
        overview.totalOutlets,
        Icons.storefront_outlined,
        Accent.blue,
      ),
      (
        l.activeOutlets,
        overview.activeOutlets,
        Icons.check_circle_outline,
        Accent.teal,
      ),
      (
        l.inactiveOutlets,
        overview.inactiveOutlets,
        Icons.pause_circle_outline,
        Accent.violet,
      ),
    ];
    return LayoutBuilder(
      builder: (context, size) {
        final wide = size.maxWidth >= 600;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (label, count, icon, accent) in items)
              SizedBox(
                width: size.maxWidth < 270
                    ? size.maxWidth
                    : (size.maxWidth - 20) / 3,
                child: SurfacePanel(
                  child: Padding(
                    padding: EdgeInsets.all(wide ? 16 : 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (wide) ...[
                              AccentIcon(icon, accent, size: 32),
                              const SizedBox(width: 12),
                            ],
                            Flexible(
                              child: Text(
                                context.formats.count(count),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: accent.foreground(context),
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class DirectoryControls extends StatelessWidget {
  const DirectoryControls({
    super.key,
    required this.search,
    required this.onSearch,
    required this.filter,
    required this.onFilter,
  });
  final TextEditingController search;
  final ValueChanged<String> onSearch;
  final OutletFilter filter;
  final ValueChanged<OutletFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(l.directoryListLabel, color: context.colors.onSurfaceVariant),
          const SizedBox(height: 4),
          Semantics(
            header: true,
            child: Text(
              l.outletDirectory,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('directory-search'),
            controller: search,
            onChanged: onSearch,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: l.searchOutlets,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l.clearSearch,
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        search.clear();
                        onSearch('');
                      },
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 2,
            children: [
              for (final (value, label) in [
                (OutletFilter.all, l.filterAll),
                (OutletFilter.active, l.active),
                (OutletFilter.inactive, l.inactive),
              ])
                ChoiceChip(
                  key: ValueKey('filter-${value.name}'),
                  label: Text(label),
                  selected: value == filter,
                  onSelected: (_) => onFilter(value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
