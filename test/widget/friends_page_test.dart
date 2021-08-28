import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cloud_functions_mock/firebase_cloud_functions_mock.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/friends_page.dart';

import '../mock_database.dart';

void main() {
  // initialize here cause it could be useful in tests
  late final FirebaseFirestore fakeFirebaseFirestore;
  late final fakeFirebaseFunctions;

  setUpAll(() async {
    fakeFirebaseFirestore = TestUtils.createMockDatabase();
    final fakeFirebaseStorage = MockFirebaseStorage();
    fakeFirebaseFunctions = MockCloudFunctions();

    ManagerConfig.initialize(
      firebaseStorage: fakeFirebaseStorage,
      firebaseFirestore: fakeFirebaseFirestore,
      firebaseFunctions: fakeFirebaseFunctions,
    );
  });

  group('Test friends page', () {
    testWidgets('Accepted friends should be shown', (tester) async {
      await tester
          .pumpWidget(TestUtils.createScreen(screen: const FriendsPage()));
      await tester.pumpAndSettle();

      expect(
        find.textContaining("You don't have any friends."),
        findsNothing,
      );

      expect(find.text("johndoe2"), findsOneWidget);
      expect(find.text("John DoeSecond"), findsOneWidget);
      expect(find.text("Accepted"), findsNWidgets(2));
    });

    testWidgets(
      'Add a new friend by username and by email',
      (tester) async {
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const FriendsPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'johndoe4');
        await tester.tap(find.byKey(const Key("add_friend_button")));
        await tester.pumpAndSettle();

        // we have the pending friend in the database
        expect(
            (await ListAppUserManager.instance.getByUid('user1_id'))!
                .friends['user4_id'],
            false);
        expect(find.text('johndoe4'), findsOneWidget);
        expect(find.textContaining('pending'), findsOneWidget);

        // add the email
        fakeFirebaseFunctions.mockResult(
          functionName: 'getUserByEmail-getUserByEmail',
          json: jsonEncode({
            "databaseId": 'user5_id',
            "createdAt": 1625751035020,
            "displayName": "John DoeFriend5",
            "email": "john@friend.com",
            "firstName": "John",
            "friends": <String, bool>{},
            "isNew": false,
            "lastName": "DoeFriend5",
            "notificationTokens": [],
            "phoneNumber": null,
            "profilePictureURL": null,
            "username": "johndoe5",
          }),
          parameters: {"email": "john@friend5.com"},
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'john@friend5.com');
        await tester.tap(find.byKey(const Key("add_friend_button")));
        await tester.pumpAndSettle();

        // we have the pending friend in the database
        expect(
            (await ListAppUserManager.instance.getByUid('user1_id'))!
                .friends['user5_id'],
            false);
        expect(find.text('johndoe5'), findsOneWidget);
        expect(find.textContaining('pending'), findsNWidgets(2));
      },
    );
  });
  testWidgets(
    'Cannot add themselves/already friends',
    (tester) async {
      await tester
          .pumpWidget(TestUtils.createScreen(screen: const FriendsPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'johndoe2');
      await tester.tap(find.byKey(const Key("add_friend_button")));
      await tester.pumpAndSettle();

      // unfortunately we cannot test the text of the toast, but we can ensure the dialog is still there
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'johndoe1');
      await tester.tap(find.byKey(const Key("add_friend_button")));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    },
  );

  testWidgets('Pending friendship should be shown', (tester) async {
    // add a pending friend to the database
    final user1 = await ListAppUserManager.instance.getByUid("user1_id");
    user1!.friends = <String, bool>{
      "user2_id": true,
      "johndoe2": true,
      'user3_id': false,
    };
    ListAppUserManager.instance.saveToFirestore(user1);
    await tester
        .pumpWidget(TestUtils.createScreen(screen: const FriendsPage()));
    await tester.pumpAndSettle();

    expect(find.text("johndoe3"), findsOneWidget);
    expect(find.text("John DoeFriend"), findsOneWidget);
    expect(find.text("Request pending"), findsOneWidget);
  });

  testWidgets('Test Friend removal', (tester) async {
    // add a pending friend to the database
    await tester
        .pumpWidget(TestUtils.createScreen(screen: const FriendsPage()));
    await tester.pumpAndSettle();

    expect(
      find.textContaining("You don't have any friends."),
      findsNothing,
    );

    expect(find.text("johndoe2"), findsOneWidget);
    expect(find.text("John DoeSecond"), findsOneWidget);
    expect(find.text("Accepted"), findsOneWidget);

    await tester.drag(
      find.byKey(const Key("dismissible_friend_user2_id")),
      const Offset(500.0, .0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == "CONFIRM"));
    await tester.pumpAndSettle();

    final user1 = await ListAppUserManager.instance.getByUid("user1_id");
    expect(user1!.friends.containsKey("user2_id"), false);
    final user2 = await ListAppUserManager.instance.getByUid("user2_id");
    expect(user2!.friends.containsKey("user1_id"), false);

    expect(find.text("johndoe2"), findsNothing);
    expect(find.text("John DoeSecond"), findsNothing);
    expect(find.text("Accepted"), findsNothing);
  });

  testWidgets('No friends implies a message on screen', (tester) async {
    // remove all friends
    final user1 = await ListAppUserManager.instance.getByUid("user1_id");
    user1!.friends = <String, bool>{};
    ListAppUserManager.instance.saveToFirestore(user1);

    await tester
        .pumpWidget(TestUtils.createScreen(screen: const FriendsPage()));
    await tester.pumpAndSettle();

    expect(find.textContaining("johndoe"), findsNothing);
    expect(find.text("John DoeFriend"), findsNothing);
    expect(find.text("Request pending"), findsNothing);
    expect(find.textContaining("You don't have any friends."), findsOneWidget);
  });
}
