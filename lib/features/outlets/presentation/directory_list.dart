import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/localization/localization.dart';
import '../../../app/theme/workspace_theme.dart';
import '../../../core/widgets/surface.dart';
import '../../../shared/domain/outlet.dart';
import '../domain/outlet_repository.dart';
import 'outlet_editor.dart';
import 'status_action.dart';

class EmptyDirectory extends StatelessWidget {
  const EmptyDirectory({super.key, required this.total, required this.query});
  final int total;
  final DirectoryQuery query;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final (title, hint, icon) = switch ((
      total,
      query.search.trim(),
      query.filter,
    )) {
      (0, _, _) => (l.noOutlets, l.emptyOutlets, Icons.storefront_outlined),
      (_, final term, _) when term.isNotEmpty => (
        l.noSearchResults,
        l.noSearchHint,
        Icons.search_off,
      ),
      (_, _, OutletFilter.active) => (
        l.noActive,
        l.noActiveHint,
        Icons.check_circle_outline,
      ),
      (_, _, OutletFilter.inactive) => (
        l.noInactive,
        l.noInactiveHint,
        Icons.pause_circle_outline,
      ),
      _ => (l.noOutlets, l.emptyOutlets, Icons.storefront_outlined),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
      child: Column(
        children: [
          AccentIcon(icon, Accent.blue, size: 47),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              title,
              style: titleStyle?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class DirectoryList extends StatelessWidget {
  const DirectoryList(this.outlets, {super.key});
  final List<Outlet> outlets;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return LayoutBuilder(
      builder: (context, size) {
        final wide = size.maxWidth >= 740;
        return Column(
          children: [
            if (wide)
              ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  child: _Columns(
                    code: Text(l.outletCode),
                    profile: Text(l.outletName),
                    status: Text(l.statusLabel),
                    created: Text(l.createdLabel),
                    actions: Text(l.actionsLabel, textAlign: TextAlign.end),
                  ),
                ),
              ),
            for (final outlet in outlets) ...[
              _OutletRow(key: ValueKey(outlet.id), outlet: outlet, wide: wide),
              const Divider(height: 1),
            ],
          ],
        );
      },
    );
  }
}

class _OutletRow extends ConsumerWidget {
  const _OutletRow({super.key, required this.outlet, required this.wide});
  final Outlet outlet;
  final bool wide;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final profile = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(outlet.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        if (outlet.description case final d?)
          Text(
            d,
            style: TextStyle(
              fontSize: 12,
              color: context.colors.onSurfaceVariant,
            ),
          ),
      ],
    );
    final code = Text(
      outlet.outletCode,
      style: TextStyle(
        color: context.colors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
    final active = outlet.isActive,
        accent = active ? Accent.teal : Accent.violet;
    final status = Align(
      alignment: AlignmentDirectional.centerStart,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.background(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
          child: Text(
            active ? l.active : l.inactive,
            style: TextStyle(
              color: accent.foreground(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
    final date = context.formats.date(outlet.createdAt.toLocal());
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: ValueKey('edit-${outlet.id}'),
          tooltip: l.editOutlet,
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => editOutlet(context, outlet),
        ),
        IconButton(
          key: ValueKey('status-${outlet.id}'),
          tooltip: active ? l.deactivateOutlet : l.activateOutlet,
          icon: Icon(
            active ? Icons.pause_circle_outline : Icons.play_circle_outline,
          ),
          onPressed: () => changeOutletStatus(context, ref, outlet),
        ),
      ],
    );
    if (wide) {
      return _Columns(
        code: code,
        profile: profile,
        status: status,
        created: Text(date, style: const TextStyle(fontSize: 12)),
        actions: actions,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Row(
            children: [
              Expanded(child: code),
              const SizedBox(width: 6),
              status,
            ],
          ),
          profile,
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l.createdLabel}\n$date',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              actions,
            ],
          ),
        ],
      ),
    );
  }
}

class _Columns extends StatelessWidget {
  const _Columns({
    required this.code,
    required this.profile,
    required this.status,
    required this.created,
    required this.actions,
  });
  final Widget code, profile, status, created, actions;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    child: Row(
      spacing: 12,
      children: [
        Expanded(flex: 3, child: code),
        Expanded(flex: 6, child: profile),
        Expanded(flex: 3, child: status),
        Expanded(flex: 4, child: created),
        SizedBox(width: 96, child: actions),
      ],
    ),
  );
}
