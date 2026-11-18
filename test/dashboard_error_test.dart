import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strata/shared/domain/workspace_reader.dart';

import 'support/app_harness.dart';

class _InterruptedReader implements WorkspaceReader {
  bool first = true;
  @override
  Stream<WorkspaceOverview> watchOverview() async* {
    if (first) {
      first = false;
      throw StateError('Unavailable');
    }
    yield const WorkspaceOverview(totalOutlets: 0, activeOutlets: 0);
  }
}

void main() {
  testWidgets('a read failure is not shown as zero revenue; retry recovers', (
    tester,
  ) async {
    setViewport(tester, const Size(1150, 800));
    await launch(tester, MemoryPreferenceStore(), reader: _InterruptedReader());
    expect(
      find.text('The workspace summary could not be loaded.'),
      findsOneWidget,
    );
    expect(find.text('0.00'), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Not available yet'), findsOneWidget);
  });
}
