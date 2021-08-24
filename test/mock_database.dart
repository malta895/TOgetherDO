import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/theme.dart';
import 'package:provider/provider.dart';

class TestUtils {
  static bool _isDatabaseSet = false;
  static final FakeFirebaseFirestore _fakeFirebaseFirestore =
      FakeFirebaseFirestore();

  static Widget createScreen({required Widget screen}) {
    final mockUser = MockUser(
      uid: 'user1_id',
      email: "john@doe.com",
      displayName: 'John Doe',
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChanger>(
          create: (_) => ThemeChanger(),
        ),
        ChangeNotifierProvider<ListAppNavDrawerStateInfo>(
          create: (_) => ListAppNavDrawerStateInfo(),
        ),
        ChangeNotifierProvider(
          create: (_) => ListAppAuthProvider(
            MockFirebaseAuth(
              signedIn: true,
              mockUser: mockUser,
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ListAppUserManager.instance),
      ],
      child: MaterialApp(home: screen),
    );
  }

  /// create an instance of a mock database with pre-filled data and returns the FakeFirebaseFirestore instance
  static FirebaseFirestore createMockDatabase() {
    if (_isDatabaseSet) return _fakeFirebaseFirestore;
    _isDatabaseSet = true;

    // the logged in user
    final user1 = {
      "databaseId": 'user1_id',
      "createdAt": 1625751035020,
      "displayName": "John Doe",
      "email": "john@doe.com",
      "firstName": "John",
      "friends": <String, bool>{"user2_id": true, "johndoe2": true},
      "isNew": false,
      "lastName": "Doe",
      "notificationTokens": [],
      "phoneNumber": null,
      "profilePictureURL": null,
      "username": "johndoe1",
    };

    final user2 = {
      "databaseId": 'user2_id',
      "createdAt": 1625751035020,
      "displayName": "John Doe",
      "email": "john@doe.com",
      "firstName": "John",
      "friends": <String, bool>{},
      "isNew": false,
      "lastName": "DoeSecond",
      "notificationTokens": [],
      "phoneNumber": null,
      "profilePictureURL": null,
      "username": "johndoe2",
    };
    // add a new user to be added as friend
    final user3 = {
      "databaseId": 'user3_id',
      "createdAt": 1625751035020,
      "displayName": "John DoeFriend",
      "email": "john@friend.com",
      "firstName": "John",
      "friends": <String, bool>{},
      "isNew": false,
      "lastName": "DoeFriend",
      "notificationTokens": [],
      "phoneNumber": null,
      "profilePictureURL": null,
      "username": "johndoe3",
    };

    final user4 = {
      "databaseId": 'user4_id',
      "createdAt": 1625751035020,
      "displayName": "John DoeFriend4",
      "email": "john@friend.com",
      "firstName": "John",
      "friends": <String, bool>{},
      "isNew": false,
      "lastName": "DoeFriend4",
      "notificationTokens": [],
      "phoneNumber": null,
      "profilePictureURL": null,
      "username": "johndoe4",
    };

    final list1 = {
      "createdAt": 1626005532227,
      "creatorUid": "user1_id",
      "databaseId": "list1_id",
      "items": [],
      "description": "Lista numero 1",
      "expiryDate": null,
      "listType": "public",
      "members": <String, bool>{"user2_id": true},
      "name": "Nuova lista",
    };

    final list2 = {
      "createdAt": 1625160623927,
      "creatorUid": "user2_id",
      "databaseId": "list2_id",
      "items": [],
      "description": "Lista numero 2",
      "expiryDate": null,
      "listType": "public",
      "members": <String, bool>{"user1_id": true},
      "name": "Fare la spesa",
    };

    final item1 = {
      "createdAt": 1625838181902,
      "creatorUid": "lGmqaAgJZqVIdqXt3GmQFNC9E3D3",
      "databaseId": "item1_id",
      "description": null,
      "itemType": "simple",
      "maxQuantity": 1,
      "name": "prova",
      "quantityPerMember": 1,
    };

    _fakeFirebaseFirestore
        .collection('users')
        .doc(user1["databaseId"] as String)
        .set(user1);

    _fakeFirebaseFirestore
        .collection('users')
        .doc(user3["databaseId"] as String)
        .set(user3);

    _fakeFirebaseFirestore
        .collection('users')
        .doc(user4["databaseId"] as String)
        .set(user4);

    _fakeFirebaseFirestore
        .collection('users')
        .doc(user1["databaseId"] as String)
        .collection('lists')
        .doc(list1['databaseId'] as String)
          ..set(list1)
          ..collection('items').doc(item1["databaseId"] as String).set(item1);

    _fakeFirebaseFirestore
        .collection('users')
        .doc(user2["databaseId"] as String)
        .set(user2);

    _fakeFirebaseFirestore
        .collection('users')
        .doc(user2["databaseId"] as String)
        .collection('lists')
        .doc(list2['databaseId'] as String)
        .set(list2);

    return _fakeFirebaseFirestore;
  }
}
