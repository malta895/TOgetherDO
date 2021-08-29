import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cloud_functions_mock/firebase_cloud_functions_mock.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/ui/lists_page.dart';

import '../mock_database.dart';

void main() {
  // initialize here cause it could be useful in tests
  FirebaseFirestore fakeFirebaseFirestore;
  setUpAll(() {
    fakeFirebaseFirestore = TestUtils.createMockDatabase();
    final fakeFirebaseStorage = MockFirebaseStorage();
    final fakeFirebaseFunctions = MockCloudFunctions();

    ManagerConfig.initialize(
      firebaseStorage: fakeFirebaseStorage,
      firebaseFirestore: fakeFirebaseFirestore,
      firebaseFunctions: fakeFirebaseFunctions,
    );
  });

  group('Profile Page Widget Tests', () {
    testWidgets(
      'Profile page shoud show up and show the user\'s information',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        await tester.dragFrom(
            tester.getTopLeft(find.byType(MaterialApp)), Offset(300, 0));
        await tester.pumpAndSettle();

        await tester.tap(find.text("John Doe"));
        await tester.pumpAndSettle();

        expect(find.text("John Doe"), findsOneWidget);

        expect(find.text("Username"), findsOneWidget);
        expect(find.text("johndoe1"), findsOneWidget);

        expect(find.text("First name"), findsOneWidget);
        expect(find.text("John"), findsOneWidget);

        expect(find.text("Last name"), findsOneWidget);
        expect(find.text("Doe"), findsOneWidget);

        expect(find.text("Email"), findsOneWidget);
        expect(find.text("john@doe.com"), findsOneWidget);

        expect(find.byIcon(Icons.create), findsNWidgets(3));
        expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
      },
    );

    testWidgets(
      'Testing of update user\'s information',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        await tester.dragFrom(
            tester.getTopLeft(find.byType(MaterialApp)), Offset(300, 0));
        await tester.pumpAndSettle();

        await tester.tap(find.text("John Doe"));
        await tester.pumpAndSettle();

        //username
        await tester.tap(find.byIcon(Icons.create).first);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text("johndoe1"), findsNWidgets(2));
        await tester.enterText(find.byType(TextField).first, "johndoe10");
        await tester.pumpAndSettle();

        await tester.tap(find.text("OK"));
        await tester.pumpAndSettle();

        expect(find.text("johndoe1"), findsNothing);
        expect(find.text("johndoe10"), findsOneWidget);

        //first name
        await tester.tap(find.byIcon(Icons.create).at(1));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text("John"), findsNWidgets(2));
        await tester.enterText(find.byType(TextField).first, "Johnny");
        await tester.pumpAndSettle();

        await tester.tap(find.text("OK"));
        await tester.pumpAndSettle();

        expect(find.text("John"), findsNothing);
        expect(find.text("Johnny Doe"), findsOneWidget);
        expect(find.text("Johnny"), findsOneWidget);

        //first name
        await tester.tap(find.byIcon(Icons.create).at(2));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text("Doe"), findsNWidgets(2));
        await tester.enterText(find.byType(TextField).first, "Donny");
        await tester.pumpAndSettle();

        await tester.tap(find.text("OK"));
        await tester.pumpAndSettle();

        expect(find.text("Dow"), findsNothing);
        expect(find.text("Johnny Donny"), findsOneWidget);
        expect(find.text("Donny"), findsOneWidget);
      },
    );
  });
}
