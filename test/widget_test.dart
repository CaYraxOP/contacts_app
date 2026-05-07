// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:contacts_app/main.dart';

void main() {
  testWidgets('App boots and shows shell', (WidgetTester tester) async {
    Get.testMode = true;
    await tester.pumpWidget(const ContactsApp());

    // Splash renders immediately.
    expect(find.text('Contacts'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // After the splash delay, we navigate to Home.
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('Contacts'), findsWidgets);
  });
}
