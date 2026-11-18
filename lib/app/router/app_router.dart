import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/outlets/presentation/outlets_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../../features/revenue/presentation/revenue_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../shared/presentation/workspace_shell.dart';
import 'destination.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    onException: (context, state, router) =>
        router.go(Destination.dashboard.path),
    routes: [
      ShellRoute(
        builder: (context, state, child) => WorkspaceShell(
          current: Destination.forPath(state.uri.path),
          child: child,
        ),
        routes: [
          for (final page in Destination.values)
            GoRoute(
              path: page.path,
              pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: switch (page) {
                  Destination.dashboard => const DashboardPage(),
                  Destination.outlets => const OutletsPage(),
                  Destination.revenue => const RevenuePage(),
                  Destination.reports => const ReportsPage(),
                  Destination.settings => const SettingsPage(),
                },
              ),
            ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
