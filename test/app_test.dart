import 'package:flutter_test/flutter_test.dart';
import 'package:strata/main.dart';

void main() {
  testWidgets('initializes the workspace', (tester) async {
    await tester.pumpWidget(const StrataApp());
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
