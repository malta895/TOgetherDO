import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class MockDatabase {
  /// create an instance of a mock database with pre-filled data and returns the FakeFirebaseFirestore instance
  static FirebaseFirestore createMockDatabase() {
    final fakeFirebaseFirestore = FakeFirebaseFirestore();

    // the logged in user
    final user1 = {
      "databaseId": 'user1_id',
      "createdAt": 1625751035020,
      "displayName": "John Doe",
      "email": "john@doe.com",
      "firstName": "John",
      "friends": [],
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
      "friends": [],
      "isNew": false,
      "lastName": "Doe",
      "notificationTokens": [],
      "phoneNumber": null,
      "profilePictureURL": null,
      "username": "johndoe2",
    };

    final list1 = {
      "createdAt": 1626005532227,
      "creatorUid": "user1_id",
      "databaseId": "list1_id",
      "items": [],
      "description": "Lista numero 1",
      "expiryDate": null,
      "listType": "public",
      "members": ["user2_id"],
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
      "members": ["user1_id"],
      "name": "Fare la spesa",
    };

    fakeFirebaseFirestore
        .collection('users')
        .doc(user1["databaseId"] as String)
        .set(user1);

    fakeFirebaseFirestore
        .collection('users')
        .doc(user1["databaseId"] as String)
        .collection('lists')
        .doc(list1['databaseId'] as String)
        .set(list1);

    fakeFirebaseFirestore
        .collection('users')
        .doc(user2["databaseId"] as String)
        .set(user2);

    fakeFirebaseFirestore
        .collection('users')
        .doc(user2["databaseId"] as String)
        .collection('lists')
        .doc(list2['databaseId'] as String)
        .set(list2);

    return fakeFirebaseFirestore;
  }
}
