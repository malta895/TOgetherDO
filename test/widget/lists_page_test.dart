import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cloud_functions_mock/firebase_cloud_functions_mock.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/ui/lists_details_page/list_details_page.dart';
import 'package:mobile_applications/ui/lists_page.dart';
import 'package:mobile_applications/ui/new_list_page.dart';

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

  group('Home Page Widget Tests', () {
    testWidgets(
      'ListView should show up and show the lists in the database',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        // the owned list should be shown
        expect(find.text("Nuova lista"), findsOneWidget);

        //the list in which the user is member should be shown
        expect(find.text("Famiglia"), findsOneWidget);

        expect(find.byKey(const Key('list1_id')), findsOneWidget);

        await tester.pumpAndSettle();

        // the owner of the list should see Me as creator
        expect(find.textContaining('unknown\n'), findsNothing);
        expect(find.textContaining("johndoe1\n"), findsNothing);
        expect(find.textContaining("Me\n"), findsNWidgets(3));

        // we should see the name of the creator if we are not the list creator
        expect(find.textContaining("johndoe2\n"), findsNWidgets(2));

        // test number of elements
        expect(find.textContaining("0 elements"), findsNothing);
        expect(find.textContaining("1 element"), findsNWidgets(4));
      },
    );

    testWidgets('Tap on list should show list details', (tester) async {
      await tester
          .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
      await tester.pumpAndSettle();
      // the key of the list is the database id of the list
      await tester.tap(find.byKey(const Key("list1_id")));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // we should be in the list details page, and not anymore in lists page
      expect(find.byType(ListDetailsPage), findsOneWidget);
      expect(find.byType(ListsPage), findsNothing);

      // we should find the description and title of the list
      expect(find.text("Nuova lista"), findsOneWidget);
      expect(find.text("Lista numero 1"), findsOneWidget);
    });

    testWidgets(
      'Testing tap on "New List" button',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // we should be in the create list page, and not anymore in lists page
        expect(find.byType(NewListPage), findsOneWidget);
        expect(find.byType(ListsPage), findsNothing);
      },
    );

    testWidgets(
      'Delete lists',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        await tester.drag(
          find.byKey(const Key("dismissible_list1_id")),
          const Offset(500.0, .0),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining(
              "Are you sure you wish to delete the Nuova lista list?"),
          findsOneWidget,
        );

        await tester.tap(find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == "DELETE"));
        await tester.pumpAndSettle();

        // the deleted list is not there anymore
        expect(find.text("Nuova lista"), findsNothing);
        // the other lists are still there
        expect(find.text("Famiglia"), findsOneWidget);

        await tester.drag(
          find.byKey(const Key("dismissible_list2_id")),
          const Offset(500.0, .0),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining(
              "Are you sure you wish to leave the Famiglia list?"),
          findsOneWidget,
        );

        await tester.tap(find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == "LEAVE"));
        await tester.pumpAndSettle();

        // the other list has been left, shouldn't be there anymore
        expect(find.text("Famiglia"), findsNothing);

        await tester.drag(
          find.byKey(const Key("dismissible_list4_id")),
          const Offset(500.0, .0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == "LEAVE"));
        await tester.pumpAndSettle();

        await tester.drag(
          find.byKey(const Key("dismissible_list3_id")),
          const Offset(500.0, .0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == "DELETE"));
        await tester.pumpAndSettle();

        await tester.drag(
          find.byKey(const Key("dismissible_list5_id")),
          const Offset(500.0, .0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == "DELETE"));
        await tester.pumpAndSettle();

        // we should see the no list message
        expect(
            find.textContaining("You don't have any lists."), findsOneWidget);
      },
    );

    // TODO add other tests (drawer, notifications, ...)
  });
}
