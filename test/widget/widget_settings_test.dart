import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_applications/services/manager_config.dart';

import '../mock_database.dart';
import '../unit/managers_test.dart';
import '../unit/managers_test.mocks.dart';

void main() {
  // initialize here cause it could be useful in tests
  FirebaseFirestore fakeFirebaseFirestore;
  setUpAll(() {
    fakeFirebaseFirestore = TestUtils.createMockDatabase();
    final fakeFirebaseStorage = MockFirebaseStorage();
    final fakeFirebaseFunctions = MockFirebaseFunctions();
    final fakeHttpsCallable = MockHttpsCallableResult();
    final fakeHttpsCallableResult = MockHttpsCallableResult();

    ManagerConfig.initialize(
      firebaseStorage: fakeFirebaseStorage,
      firebaseFirestore: fakeFirebaseFirestore,
      firebaseFunctions: fakeFirebaseFunctions,
    );
  });

  //ThemeData currentTheme = lightTheme;
  group('Settings Page Widget Tests', () {
    testWidgets(
      'Testing if theme setting works',
      (tester) async {
        await tester.pumpWidget(TestUtils.createHomeScreen());
        await tester.tap(find.byKey(const Key("theme setting")));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        final textColorFinder = tester.widget<Text>(find.byType(Text));
        expect(textColorFinder.style!.color, Colors.pinkAccent[400]);
      },
      skip: true, // TODO fix this tests
    );
  });
}
