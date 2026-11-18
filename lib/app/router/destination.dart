import 'package:material_ui/material_ui.dart';

import '../localization/generated/app_localizations.dart';

enum Destination {
  dashboard('/', Icons.space_dashboard_outlined),
  outlets('/outlets', Icons.storefront_outlined),
  revenue('/revenue', Icons.account_balance_wallet_outlined),
  reports('/reports', Icons.insert_chart_outlined_rounded),
  settings('/settings', Icons.tune_rounded);

  const Destination(this.path, this.icon);
  final String path;
  final IconData icon;
  String label(AppLocalizations l) => switch (this) {
    dashboard => l.dashboard,
    outlets => l.outlets,
    revenue => l.revenueEntry,
    reports => l.reports,
    settings => l.settings,
  };

  static Destination forPath(String path) => values.firstWhere(
    (section) => section.path == path,
    orElse: () => dashboard,
  );
}
