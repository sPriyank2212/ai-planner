import 'package:flutter_test/flutter_test.dart';
import 'package:ai_planner/main.dart';

void main() {
  testWidgets('App loads and shows tasks screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AIPlannerApp());

    // Allow async initialization (SharedPreferences) to complete.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('My Tasks'), findsOneWidget);
  });
}
