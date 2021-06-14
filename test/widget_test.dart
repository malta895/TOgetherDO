// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_applications/main.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:mobile_applications/ui/home_lists.dart';

import 'mock.dart';

void main() {

    // TestWidgetsFlutterBinding.ensureInitialized(); Gets called in setupFirebaseAuthMocks()
  setupFirebaseAuthMocks();

  setUpAll(() async {
          WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('Check title', (WidgetTester tester) async {
      print("initialize");

    print("oshagf");
    // Build our app and trigger a frame.
    await tester.pumpWidget(ListHomePage());
    print("fhasof");

    final titleFinder = find.text('Login');

    // Verify that our counter starts at 0.
    expect(titleFinder, findsOneWidget);
  });
}
