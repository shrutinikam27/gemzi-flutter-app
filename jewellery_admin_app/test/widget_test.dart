// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('Admin App Login Screen Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify LoginPage loads with correct title.
    expect(find.text('Admin Login'), findsOneWidget);
    expect(
        find.text('Login to manage your jewellery business'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
