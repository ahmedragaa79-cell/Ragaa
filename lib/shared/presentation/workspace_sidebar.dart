import 'package:material_ui/material_ui.dart';

import '../../app/localization/localization.dart';
import '../../app/router/destination.dart';
import '../../app/theme/workspace_theme.dart';
import '../../core/widgets/surface.dart';
import 'brand_mark.dart';

class WorkspaceSidebar extends StatelessWidget {
  const WorkspaceSidebar({
    super.key,
    required this.current,
    required this.onSelect,
  });
  final Destination current;
  final ValueChanged<Destination> onSelect;
  static const width = 230.0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Material(
      color: WorkspaceTheme.navy,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 28,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 7),
                    child: Row(
                      children: [
                        const BrandMark(),
                        const SizedBox(width: 11),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.appName,
                                style: const TextStyle(
                                  fontSize: 25,
                                  height: 1.08,
                                  letterSpacing: -.9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Eyebrow(
                                l.brandTagline,
                                color: const Color(0xFFB1BDD2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 37),
                  _NavGroup(l.navigationGroup),
                  for (final item in Destination.values.where(
                    (i) => i != Destination.settings,
                  ))
                    _NavItem(item, current, onSelect),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 17),
                    child: Divider(color: Color(0xFF2B374C), height: 1),
                  ),
                  _NavGroup(l.preferenceGroup),
                  _NavItem(Destination.settings, current, onSelect),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2B374C), height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 35,
                    height: 37,
                    decoration: BoxDecoration(
                      color: const Color(0xFF23314A),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.dns_outlined,
                      color: Color(0xFFC2D3F0),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.localWorkspace,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          l.thisDevice,
                          style: const TextStyle(
                            color: Color(0xFFA7B5CA),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavGroup extends StatelessWidget {
  const _NavGroup(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 10),
    child: Eyebrow(label, color: const Color(0xFF96A8C4)),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.item, this.current, this.onSelect);
  final Destination item, current;
  final ValueChanged<Destination> onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = item == current;
    final ink = selected ? Colors.white : const Color(0xFFC3CDDD);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? const Color(0xFF405CD9) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            key: ValueKey('nav-${item.name}'),
            onTap: () => onSelect(item),
            borderRadius: BorderRadius.circular(9),
            hoverColor: Colors.white.withValues(alpha: .07),
            focusColor: Colors.white.withValues(alpha: .12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Icon(item.icon, size: 20, color: ink),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label(context.l10n),
                      style: TextStyle(
                        color: ink,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFBBCAFF),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
