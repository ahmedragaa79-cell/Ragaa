import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strata/core/database/storage_problem.dart';

import 'support/app_harness.dart';
import 'support/test_database.dart';

Future<void> field(WidgetTester t, String key, String value) async {
  await t.enterText(find.byKey(ValueKey(key)), value);
  await t.pumpAndSettle();
}

Future<void> action(WidgetTester t, String tooltip) async {
  final target = find.byTooltip(tooltip).first;
  await t.ensureVisible(target);
  await t.tap(target);
  await t.pumpAndSettle();
}

Future<void> cancel(WidgetTester t) async {
  await t.tap(find.text('Cancel'));
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
    'desktop create/edit, required and duplicate errors, cancel, dashboard and status',
    (t) async {
      setViewport(t, const Size(1280, 960));
      await launch(t, MemoryPreferenceStore());
      await tapKey(t, 'nav-outlets');
      expect(find.text('No outlets yet'), findsOneWidget);
      await tapKey(t, 'add-outlet');
      await tapKey(t, 'save-outlet');
      expect(find.text('Enter an outlet code.'), findsOneWidget);
      expect(find.text('Enter an outlet name.'), findsOneWidget);
      await field(t, 'outlet-code', 'M-01');
      await field(t, 'outlet-name', 'Central');
      await field(t, 'outlet-description', 'Ground floor');
      await tapKey(t, 'save-outlet');
      expect(find.text('Central'), findsOneWidget);
      expect(find.text('Ground floor'), findsOneWidget);
      expect(find.text('Outlet added.'), findsOneWidget);
      await tapKey(t, 'add-outlet');
      await field(t, 'outlet-code', 'm-01');
      await field(t, 'outlet-name', 'Duplicate');
      await tapKey(t, 'save-outlet');
      expect(
        find.text('This code already belongs to an outlet. Choose another.'),
        findsOneWidget,
      );
      await cancel(t);
      await action(t, 'Edit outlet');
      await field(t, 'outlet-name', 'Discarded');
      await cancel(t);
      expect(find.text('Central'), findsOneWidget);
      await action(t, 'Edit outlet');
      await field(t, 'outlet-name', 'East');
      await tapKey(t, 'save-outlet');
      expect(find.text('East'), findsOneWidget);
      await tapKey(t, 'filter-inactive');
      expect(find.text('No inactive outlets'), findsOneWidget);
      await tapKey(t, 'filter-all');
      await action(t, 'Deactivate outlet');
      await cancel(t);
      expect(find.byTooltip('Deactivate outlet'), findsOneWidget);
      await action(t, 'Deactivate outlet');
      await tapKey(t, 'confirm-status');
      await tapKey(t, 'filter-active');
      expect(find.text('No active outlets'), findsOneWidget);
      await tapKey(t, 'nav-dashboard');
      expect(find.text('Not available yet'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(2));
      expect(find.text('0'), findsOneWidget);
      await tapKey(t, 'nav-outlets');
      await tapKey(t, 'filter-inactive');
      await action(t, 'Activate outlet');
      await tapKey(t, 'confirm-status');
      expect(find.text('No inactive outlets'), findsOneWidget);
      await tapKey(t, 'filter-all');
      await field(t, 'directory-search', 'unmatched');
      expect(find.text('No matching outlets'), findsOneWidget);
      await action(t, 'Clear search');
      expect(find.text('East'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'compact directory keeps query and filter on live RTL/dark switch; Arabic form and feedback',
    (t) async {
      setViewport(t, const Size(375, 840));
      await launch(t, MemoryPreferenceStore());
      await tapKey(t, 'open-drawer');
      await tapKey(t, 'nav-outlets');
      await field(t, 'directory-search', 'فرع');
      await tapKey(t, 'filter-active');
      await tapKey(t, 'toolbar-language');
      await t.tap(find.text('العربية'));
      await t.pumpAndSettle();
      await tapKey(t, 'toolbar-theme');
      final title = find.text('دليل المنافذ');
      expect(Directionality.of(t.element(title)), TextDirection.rtl);
      expect(Theme.of(t.element(title)).brightness, Brightness.dark);
      expect(
        t
            .widget<TextField>(find.byKey(const ValueKey('directory-search')))
            .controller!
            .text,
        'فرع',
      );
      expect(
        t
            .widget<ChoiceChip>(find.byKey(const ValueKey('filter-active')))
            .selected,
        true,
      );
      await tapKey(t, 'add-outlet');
      await tapKey(t, 'save-outlet');
      expect(find.text('أدخل رمز المنفذ.'), findsOneWidget);
      expect(find.text('أدخل اسم المنفذ.'), findsOneWidget);
      await field(t, 'outlet-code', 'م١');
      await field(t, 'outlet-name', 'فرع المنيا');
      await tapKey(t, 'save-outlet');
      expect(find.text('تمت إضافة المنفذ.'), findsOneWidget);
      expect(find.text('فرع المنيا'), findsOneWidget);
      await action(t, 'إيقاف المنفذ');
      expect(find.text('هل تريد إيقاف «فرع المنيا»؟'), findsOneWidget);
      await tapKey(t, 'confirm-status');
      await tapKey(t, 'filter-inactive');
      expect(find.text('فرع المنيا'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'unavailable storage disables writes and retry opens a fresh connection',
    (t) async {
      setViewport(t, const Size(1200, 900));
      var available = false;
      await launch(
        t,
        MemoryPreferenceStore(),
        database: () {
          if (!available) throw StorageProblem.noDurableBrowserStorage;
          return memoryDatabase();
        },
      );
      await tapKey(t, 'nav-outlets');
      expect(
        find.text('The outlet directory could not be loaded.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Reliable storage is unavailable'),
        findsOneWidget,
      );
      expect(
        t
            .widget<FilledButton>(find.byKey(const ValueKey('add-outlet')))
            .onPressed,
        isNull,
      );
      available = true;
      await t.tap(find.text('Try again'));
      await t.pumpAndSettle();
      expect(find.text('No outlets yet'), findsOneWidget);
    },
  );
}
