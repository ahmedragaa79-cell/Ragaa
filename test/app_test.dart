import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strata/shared/presentation/workspace_sidebar.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets(
    'desktop starts in LTR with an empty ledger and navigable modules',
    (tester) async {
      setViewport(tester, const Size(1320, 900));
      await launch(tester, MemoryPreferenceStore());
      final total = find.text('Total revenue');
      expect(total, findsOneWidget);
      expect(find.text('0.00'), findsOneWidget);
      expect(Directionality.of(tester.element(total)), TextDirection.ltr);
      expect(
        tester.getCenter(find.byType(WorkspaceSidebar)).dx,
        lessThan(tester.getCenter(total).dx),
      );
      await tapKey(tester, 'module-outlets');
      expect(find.text('No outlets yet'), findsOneWidget);
      await tapKey(tester, 'nav-revenue');
      expect(find.text('No revenue entries yet'), findsOneWidget);
      await tapKey(tester, 'nav-reports');
      expect(find.text('No reports yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'switching language mirrors the current screen; preferences survive a fresh app',
    (tester) async {
      setViewport(tester, const Size(1280, 900));
      final store = MemoryPreferenceStore();
      await launch(tester, store);
      await tapKey(tester, 'nav-settings');
      await tapKey(tester, 'language-ar');
      final title = find.text('لغة العرض');
      expect(title, findsOneWidget);
      expect(Directionality.of(tester.element(title)), TextDirection.rtl);
      expect(
        tester.getCenter(find.byType(WorkspaceSidebar)).dx,
        greaterThan(1000),
      );
      await tapKey(tester, 'theme-dark');
      expect(Theme.of(tester.element(title)).brightness, Brightness.dark);
      expect(store.saved.locale, const Locale('ar'));
      expect(store.saved.themeMode, ThemeMode.dark);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await launch(tester, store);
      final total = find.text('إجمالي الإيرادات');
      expect(total, findsOneWidget);
      expect(find.text('٠٫٠٠'), findsOneWidget);
      expect(find.text('٢'), findsOneWidget);
      expect(Theme.of(tester.element(total)).brightness, Brightness.dark);
      await tapKey(tester, 'toolbar-language');
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(
        Directionality.of(tester.element(find.text('Total revenue'))),
        TextDirection.ltr,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('narrow Arabic device uses an RTL drawer without overflowing', (
    tester,
  ) async {
    setViewport(tester, const Size(360, 780));
    tester.binding.platformDispatcher.localesTestValue = [
      const Locale('ar', 'EG'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
    await launch(tester, MemoryPreferenceStore());
    final total = find.text('إجمالي الإيرادات');
    expect(Directionality.of(tester.element(total)), TextDirection.rtl);
    expect(find.byKey(const ValueKey('nav-reports')), findsNothing);
    await tapKey(tester, 'open-drawer');
    await tapKey(tester, 'nav-reports');
    expect(find.text('مركز التقارير'), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-reports')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a failed preference write warns without undoing the current language',
    (tester) async {
      setViewport(tester, const Size(1180, 800));
      final store = MemoryPreferenceStore()..rejectWrites = true;
      await launch(tester, store);
      await tapKey(tester, 'nav-settings');
      await tapKey(tester, 'language-ar');
      expect(find.textContaining('تعذّر الوصول'), findsOneWidget);
      expect(find.text('لغة العرض'), findsOneWidget);
      expect(store.saved.locale, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
