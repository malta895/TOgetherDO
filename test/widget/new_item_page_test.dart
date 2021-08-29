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

  group('New Item Page Widget Tests', () {
    testWidgets(
      'Testing graphic elements',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list2
        await tester.tap(find.byKey(const Key("list2_id")));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Add new list item..."));
        await tester.pumpAndSettle();

        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text("Enter the item title"), findsOneWidget);
        expect(find.text("Simple item"), findsOneWidget);
        expect(find.text("Multiple instance item"), findsOneWidget);
        expect(find.text("Multiple People item"), findsOneWidget);
        expect(find.text("Submit"), findsOneWidget);
      },
    );

    testWidgets(
      'Creation of a simple item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list2
        await tester.tap(find.byKey(const Key("list2_id")));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Add new list item..."));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Simple item"));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), "new simple item");
        await tester.pumpAndSettle();
        await tester.tap(find.text("Submit"));
        await tester.pumpAndSettle();

        expect(find.text("new simple item"), findsOneWidget);
      },
    );

    testWidgets(
      'Creation of a multiple instance item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list2
        await tester.tap(find.byKey(const Key("list2_id")));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Add new list item..."));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Multiple instance item"));
        await tester.pumpAndSettle();

        expect(find.text("Number of items: "), findsNWidgets(2));
        expect(find.byIcon(Icons.remove), findsNWidgets(3));
        expect(find.byIcon(Icons.add), findsNWidgets(3));

        await tester.enterText(
            find.byType(TextFormField), "new multiple instance item");
        await tester.pumpAndSettle();
        await tester.tap(find.text("Submit"));
        await tester.pumpAndSettle();

        expect(find.text("new multiple instance item"), findsOneWidget);
      },
    );

    testWidgets(
      'Creation of a multiple people item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list2
        await tester.tap(find.byKey(const Key("list2_id")));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Add new list item..."));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Multiple People item"));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.byType(TextFormField), "new multiple people item");
        await tester.pumpAndSettle();
        await tester.tap(find.text("Submit"));
        await tester.pumpAndSettle();

        expect(find.text("new multiple people item"), findsOneWidget);
      },
    );
  });
}
