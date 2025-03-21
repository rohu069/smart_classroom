import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample_classroom/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(SmartLearningApp());

    // Check if '0' is initially displayed
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Check if counter increments to '1'
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
