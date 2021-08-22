import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cloud_functions_mock/firebase_cloud_functions_mock.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/ui/friends_page.dart';

import '../mock_database.dart';

void main() {
  // initialize here cause it could be useful in tests
  late final FirebaseFirestore fakeFirebaseFirestore;
  late final fakeFirebaseFunctions;

  setUpAll(() {
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
    testWidgets('All friends should be shown', (tester) async {
      await tester
          .pumpWidget(TestUtils.createScreen(screen: const FriendsPage()));
      await tester.pumpAndSettle();

      expect(find.text("johndoe2"), findsOneWidget);
      expect(find.text("John DoeSecond"), findsOneWidget);
    });

    testWidgets(
      'Add a new friend by username and by email',
      (tester) async {
        // add a new user to be added as friend
        final user3 = {
          "databaseId": 'user3_id',
          "createdAt": 1625751035020,
          "displayName": "John DoeFriend",
          "email": "john@friend.com",
          "firstName": "John",
          "friends": [],
          "isNew": false,
          "lastName": "DoeFriend",
          "notificationTokens": [],
          "phoneNumber": null,
          "profilePictureURL": null,
          "username": "johndoe3",
        };
        fakeFirebaseFirestore
            .collection('users')
            .doc(user3["databaseId"] as String)
            .set(user3);

        await tester
            .pumpWidget(TestUtils.createScreen(screen: const FriendsPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'johndoe3');
        await tester.tap(find.byKey(const Key("add_friend_button")));
        await tester.pumpAndSettle();

        var queryResult = await fakeFirebaseFirestore
            .collection('friendships')
            .where('userFrom', isEqualTo: 'user1_id')
            .where('userTo', isEqualTo: 'user3_id')
            .get();

        // the database should contain the new friendship
        expect(queryResult.docs.length, 1);
        final friendship = queryResult.docs.first;
        expect(friendship["requestAccepted"], false);
        expect(friendship["requestedBy"], "username");

        await fakeFirebaseFirestore
            .collection('friendships')
            .doc(queryResult.docs.first.id)
            .delete();

        // add the email
        fakeFirebaseFunctions.mockResult(
          functionName: 'getUserByEmail-getUserByEmail',
          json: jsonEncode(user3),
          parameters: {"email": "john@friend.com"},
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'john@friend.com');
        await tester.tap(find.byKey(const Key("add_friend_button")));
        await tester.pumpAndSettle();

        queryResult = await fakeFirebaseFirestore
            .collection('friendships')
            .where('userFrom', isEqualTo: 'user1_id')
            .where('userTo', isEqualTo: 'user3_id')
            .get();

        // the database should contain the new friendship
        expect(queryResult.docs.length, 1);
        final friendship2 = queryResult.docs.first;
        expect(friendship2["requestAccepted"], false);
        expect(friendship2["requestedBy"], "email");
      },
      skip: true, // TODO remove when add to friends is completed
    );
  });
}
