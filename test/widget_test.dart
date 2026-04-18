// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_app/main.dart';

void main() {
  testWidgets('RateMate auth and review flow', (WidgetTester tester) async {
    await tester.pumpWidget(const RateMateApp());

    // Initial auth screen
    expect(find.text('RateMate Login'), findsOneWidget);

    // Switch to registration.
    await tester.tap(find.text("Don't have an account? Sign up"));
    await tester.pumpAndSettle();
    expect(find.text('RateMate Sign Up'), findsOneWidget);

    // Fill registration form.
    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(
      find.byType(TextField).at(1),
      'testuser@example.com',
    );
    await tester.enterText(find.byType(TextField).at(2), 'testpass');
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    // Should be logged in and show home screen.
    expect(find.textContaining('Welcome,'), findsOneWidget);
    expect(find.text('RateMate Home'), findsOneWidget);

    // Select a target user (seeded Bob Smith or Alice etc.)
    await tester.tap(find.text('Bob Smith').first);
    await tester.pumpAndSettle();

    // On profile, submit anonymous review.
    expect(find.text('Submit anonymous review'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Great friend!');
    await tester.tap(find.text('Submit Review'));
    await tester.pumpAndSettle();

    // Confirm success message and review appears.
    expect(find.text('Review submitted anonymously!'), findsOneWidget);
    expect(find.text('Great friend!'), findsOneWidget);
  });
}
