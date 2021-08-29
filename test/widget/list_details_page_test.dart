import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cloud_functions_mock/firebase_cloud_functions_mock.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/services/item_manager.dart';
import 'package:mobile_applications/services/list_manager.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/ui/lists_page.dart';
import 'package:mobile_applications/ui/new_item_page.dart';
import 'package:numberpicker/numberpicker.dart';

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

  group('Public List Page Widget Tests - User is creator of the list', () {
    testWidgets(
      'Testing graphic elements',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list1_id")));
        await tester.pumpAndSettle();

        // the name of the list should be shown
        expect(find.text("Nuova lista"), findsOneWidget);

        //the description of the list should be shown
        expect(find.text("Lista numero 1"), findsOneWidget);

        //the username of the creator of the list should be shown
        expect(find.text("johndoe1"), findsOneWidget);

        //since I can add new members, I should see the add new item button
        expect(find.text("Add new list item..."), findsOneWidget);

        //I have to see the item of the list
        expect(find.text("prova"), findsOneWidget);
        expect(find.text("multiFulfillmentMember"), findsOneWidget);
        //expect(find.byType(Checkbox), findsOneWidget);

        final checkboxFinder = find.byType(Checkbox);

        var checkbox = tester.firstWidget(checkboxFinder) as Checkbox;
        expect(checkbox.value, false);

        //I have to see the members of the list
        await tester.tap(find.text("MEMBERS"));
        await tester.pumpAndSettle();

        expect(find.text("Add new member..."), findsOneWidget);
        expect(find.text("John Doe"), findsWidgets);
      },
    );

    testWidgets(
      'Testing add new item button',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list1_id")));
        await tester.pumpAndSettle();

        //click on add new item
        await tester.tap(find.text("Add new list item..."));
        await tester.pumpAndSettle();

        expect(find.byType(NewItemPage), findsOneWidget);
      },
    );

    testWidgets(
      'Testing add new member button',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list1_id")));
        await tester.pumpAndSettle();

        await tester.tap(find.text("MEMBERS"));
        await tester.pumpAndSettle();

        //click on add new member
        await tester.tap(find.text("Add new member..."));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);

        //await tester.tap(find.byWidget(Icon(Icons.person_add_alt_rounded)));
        await tester.tap(find.ancestor(
            of: find.byIcon(Icons.person_add_alt_rounded),
            matching:
                find.byWidgetPredicate((widget) => widget is IconButton)));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Add new member..."));
        await tester.pumpAndSettle();
        expect(
            find.textContaining(
                "You don't have any friend left to add to this list"),
            findsOneWidget);
      },
    );

    testWidgets(
      'Testing delete member button',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list1_id")));
        await tester.pumpAndSettle();

        await tester.tap(find.text("MEMBERS"));
        await tester.pumpAndSettle();

        //click on add new member
        await tester.tap(find.byIcon(Icons.person_remove_alt_1_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
            find.text(
                "Are you sure you want to remove John Doe from this list?"),
            findsOneWidget);

        await tester.tap(find.text("REMOVE"));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.person_remove_alt_1_rounded), findsNothing);
      },
    );

    testWidgets(
      'Testing details of an item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list1_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.text("prova"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text("Item details"), findsOneWidget);
        expect(find.text("item1 description"), findsOneWidget);
        expect(
            find.ancestor(
                of: find.text("John Doe"),
                matching: find.byWidgetPredicate((widget) => widget is Card)),
            findsOneWidget);
        expect(find.text("DELETE"), findsOneWidget);
        expect(find.text("There is no link for this item"), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsWidgets);
      },
    );

    testWidgets(
      'Update of an item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list1_id")));
        await tester.pumpAndSettle();

        await tester.tap(find.text("prova"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.tap(find.byIcon(Icons.edit).first);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNWidgets(2));
        expect(find.text("prova"), findsNWidgets(3));
        await tester.enterText(find.byType(TextField).first, "prova 1");
        await tester.pumpAndSettle();

        await tester.tap(find.text("OK"));
        await tester.pumpAndSettle();

        expect(find.text("prova"), findsNothing);
        expect(find.text("prova 1"), findsOneWidget);

        await tester.tap(find.text("prova 1"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.tap(find.byIcon(Icons.edit).at(1));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNWidgets(2));
        expect(find.text("item1 description"), findsNWidgets(2));
        await tester.enterText(
            find.byType(TextField).first, "item1 new description");
        await tester.pumpAndSettle();

        await tester.tap(find.text("OK"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("prova 1"));
        await tester.pumpAndSettle();
        expect(find.text("item1 description"), findsNothing);
        expect(find.text("item1 new description"), findsOneWidget);
      },
    );

    testWidgets(
      'Testing completion of a simple item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list1_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        final checkboxFinder = find.byType(Checkbox);

        var checkbox = tester.firstWidget(checkboxFinder) as Checkbox;
        expect(checkbox.value, true);
      },
    );

    testWidgets(
      'Testing completion of a multiFulfillmentMember item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list1_id")));
        await tester.pumpAndSettle();

        final item =
            await ListAppItemManager.instanceForList("list1_id", "user1_id")
                .getByUid("item3_id");

        await ListAppItemManager.instanceForList("list1_id", "user1_id")
            .fulfillItem("user1_id", "list1_id", item!, 2);
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(ListsPage), findsOneWidget);
        //click again on list1
        await tester.tap(find.byKey(const Key("list1_id")));
        await tester.pumpAndSettle();

        expect(find.text("2 / 6"), findsOneWidget);
      },
    );

    testWidgets(
      'Testing delete list button',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list1_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.byIcon(Icons.more_vert).first);
        await tester.pumpAndSettle();

        expect(find.text("Delete list"), findsOneWidget);

        await tester.tap(find.text("Delete list"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.tap(find.text("DELETE"));
        await tester.pumpAndSettle();

        expect(find.byType(ListsPage), findsOneWidget);
      },
    );
  });

  group('Public List Page Widget Tests - User is member of the list', () {
    testWidgets(
      'Testing graphic elements',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list2_id")));
        await tester.pumpAndSettle();

        // the name of the list should be shown
        expect(find.text("Famiglia"), findsOneWidget);

        //the description of the list should be shown
        expect(find.text("Lista numero 2"), findsOneWidget);

        //the username of the creator of the list should be shown
        expect(find.text("johndoe2"), findsOneWidget);

        //since I can add new members, I should see the add new item button
        expect(find.text("Add new list item..."), findsOneWidget);

        //I have to see the item of the list
        expect(find.text("multiFulfillment"), findsOneWidget);
        //expect(find.byType(Checkbox), findsOneWidget);

        final checkboxFinder = find.byType(Checkbox);

        var checkbox = tester.firstWidget(checkboxFinder) as Checkbox;
        expect(checkbox.value, false);

        //I have to see the members of the list
        await tester.tap(find.text("MEMBERS"));
        await tester.pumpAndSettle();

        expect(find.text("Add new member..."), findsNothing);
        expect(find.text("John Doe"), findsWidgets);
      },
    );

    testWidgets(
      'Testing details of an item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list2_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.text("multiFulfillment"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text("Item details"), findsOneWidget);
        expect(find.text("item2 description"), findsOneWidget);
        expect(
            find.ancestor(
                of: find.text("John DoeSecond"),
                matching: find.byWidgetPredicate((widget) => widget is Card)),
            findsOneWidget);
        expect(find.text("DELETE"), findsNothing);
        expect(find.text("There is no link for this item"), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsNothing);
      },
    );

    testWidgets(
      'Testing completion of an item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list2_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        final checkboxFinder = find.byType(Checkbox);

        var checkbox = tester.firstWidget(checkboxFinder) as Checkbox;
        expect(checkbox.value, true);
        expect(find.text("1 / 3"), findsOneWidget);

        await tester.tap(find.text("1 / 3"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
            find.ancestor(
                of: find.text("John Doe"),
                matching:
                    find.byWidgetPredicate((widget) => widget is AlertDialog)),
            findsOneWidget);
      },
    );

    testWidgets(
      'Testing leave list button',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list2_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.byIcon(Icons.more_vert).first);
        await tester.pumpAndSettle();

        expect(find.text("Leave list"), findsOneWidget);

        await tester.tap(find.text("Leave list"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.tap(find.text("LEAVE"));
        await tester.pumpAndSettle();

        expect(find.byType(ListsPage), findsOneWidget);
      },
    );
  });

  group('Private Saved List Page Widget Tests - User is creator of the list',
      () {
    testWidgets(
      'Testing graphic elements',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list3_id")));
        await tester.pumpAndSettle();

        // the name of the list should be shown
        expect(find.text("Regali"), findsOneWidget);

        //the description of the list should be shown
        expect(find.text("Lista numero 3"), findsOneWidget);

        //the username of the creator of the list should be shown
        expect(find.text("johndoe1"), findsOneWidget);

        //since I can add new members, I should see the add new item button
        expect(find.text("Add new list item..."), findsNothing);

        //I have to see the item of the list
        expect(find.text("prova"), findsOneWidget);
        //expect(find.byType(Checkbox), findsOneWidget);

        expect(find.byType(Checkbox), findsNothing);
      },
    );

    testWidgets(
      'Testing details of an item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list3_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.text("prova"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text("Item details"), findsOneWidget);
        expect(find.text("item1 description"), findsOneWidget);
        expect(
            find.ancestor(
                of: find.text("John Doe"),
                matching: find.byWidgetPredicate((widget) => widget is Card)),
            findsOneWidget);
        expect(find.text("You can no longer delete this item"), findsOneWidget);
        expect(find.text("There is no link for this item"), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsNothing);
      },
    );

    testWidgets(
      'Testing delete list button',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list3_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.byIcon(Icons.more_vert).first);
        await tester.pumpAndSettle();

        expect(find.text("Delete list"), findsOneWidget);

        await tester.tap(find.text("Delete list"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.tap(find.text("DELETE"));
        await tester.pumpAndSettle();

        expect(find.byType(ListsPage), findsOneWidget);
      },
    );
  });

  group('Private Saved Page Widget Tests - User is member of the list', () {
    testWidgets(
      'Testing graphic elements',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list4_id")));
        await tester.pumpAndSettle();

        // the name of the list should be shown
        expect(find.text("Natale"), findsOneWidget);

        //the description of the list should be shown
        expect(find.text("Lista numero 4"), findsOneWidget);

        //the username of the creator of the list should be shown
        expect(find.text("johndoe2"), findsOneWidget);

        //since I can add new members, I should see the add new item button
        expect(find.text("Add new list item..."), findsNothing);

        //I have to see the item of the list
        expect(find.text("multiFulfillment"), findsOneWidget);
        //expect(find.byType(Checkbox), findsOneWidget);

        final checkboxFinder = find.byType(Checkbox);

        var checkbox = tester.firstWidget(checkboxFinder) as Checkbox;
        expect(checkbox.value, false);

        //I have to see the members of the list
        await tester.tap(find.text("MEMBERS"));
        await tester.pumpAndSettle();

        expect(find.text("Add new member..."), findsNothing);
        expect(find.text("John Doe"), findsWidgets);
      },
    );

    testWidgets(
      'Testing details of an item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list4_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.text("multiFulfillment"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text("Item details"), findsOneWidget);
        expect(find.text("item2 description"), findsOneWidget);
        expect(
            find.ancestor(
                of: find.text("John DoeSecond"),
                matching: find.byWidgetPredicate((widget) => widget is Card)),
            findsOneWidget);
        expect(
            find.text("Only the creator can delete the item"), findsOneWidget);
        expect(find.text("There is no link for this item"), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsNothing);
      },
    );

    testWidgets(
      'Testing completion of an item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list4_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        final checkboxFinder = find.byType(Checkbox);

        var checkbox = tester.firstWidget(checkboxFinder) as Checkbox;
        expect(checkbox.value, true);
      },
    );
  });

  group('Private Draft List Page Widget Tests - User is creator of the list',
      () {
    testWidgets(
      'Testing graphic elements',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list5_id")));
        await tester.pumpAndSettle();

        // the name of the list should be shown
        expect(find.text("Natale"), findsOneWidget);

        //the description of the list should be shown
        expect(find.text("Lista numero 5"), findsOneWidget);

        //since I can add new members, I should see the add new item button
        expect(find.text("Add new list item..."), findsOneWidget);

        //I have to see the item of the list
        expect(find.text("prova"), findsOneWidget);
        //expect(find.byType(Checkbox), findsOneWidget);

        expect(find.byType(Checkbox), findsNothing);
        expect(find.byIcon(Icons.edit), findsOneWidget);
      },
    );

    testWidgets(
      'Testing details of an item',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list5_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.text("prova"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text("Item details"), findsOneWidget);
        expect(find.text("item1 description"), findsOneWidget);
        expect(
            find.ancestor(
                of: find.text("John Doe"),
                matching: find.byWidgetPredicate((widget) => widget is Card)),
            findsOneWidget);
        expect(find.text("DELETE"), findsOneWidget);
        expect(find.text("There is no link for this item"), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsWidgets);
      },
    );

    testWidgets(
      'Testing save list button',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        //click on list1
        await tester.tap(find.byKey(const Key("list5_id")));
        await tester.pumpAndSettle();

        //complete an item
        await tester.tap(find.byIcon(Icons.more_vert).first);
        await tester.pumpAndSettle();

        expect(find.text("Save list"), findsOneWidget);

        await tester.tap(find.text("Save list"));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.tap(find.text("OK"));
        await tester.pumpAndSettle();

        expect(find.byType(ListsPage), findsOneWidget);
        expect(
            await ListAppListManager.instanceForUserUid("user1_id")
                .getByUid("list5_id")
                .then((value) => value!.listStatus == ListStatus.saved),
            isTrue);
      },
    );
  });
}
