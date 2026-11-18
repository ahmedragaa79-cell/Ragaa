import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/localization/localization.dart';
import '../../app/router/destination.dart';
import '../../app/theme/workspace_theme.dart';
import '../../features/settings/application/preferences_controller.dart';
import 'workspace_sidebar.dart';
import 'workspace_toolbar.dart';

class WorkspaceShell extends ConsumerWidget {
  const WorkspaceShell({super.key, required this.current, required this.child});
  final Destination current;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final warning = ref.watch(
      preferencesProvider.select((s) => s.storageWarning),
    );
    return Scaffold(
      drawer: wide
          ? null
          : Drawer(
              width: WorkspaceSidebar.width + 18,
              child: Builder(
                builder: (drawerContext) => WorkspaceSidebar(
                  current: current,
                  onSelect: (page) {
                    Scaffold.of(drawerContext).closeDrawer();
                    context.go(page.path);
                  },
                ),
              ),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            SizedBox(
              width: WorkspaceSidebar.width,
              child: WorkspaceSidebar(
                current: current,
                onSelect: (page) => context.go(page.path),
              ),
            ),
          Expanded(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WorkspaceToolbar(current: current, showMenu: !wide),
                  if (warning)
                    Semantics(
                      liveRegion: true,
                      child: ColoredBox(
                        color: context.colors.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            context.l10n.storageWarning,
                            style: TextStyle(
                              color: context.colors.onErrorContainer,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
