import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/models/friendship.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/user_manager.dart';

class ListAppFriendshipManager with ChangeNotifier {
  static ListAppFriendshipManager _instance =
      ListAppFriendshipManager._privateConstructor();

  ListAppFriendshipManager._privateConstructor();

  static ListAppFriendshipManager get instance => _instance;

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  final _friendshipsCollection = FirebaseFirestore.instance
      .collection(ListAppFriendship.collectionName)
      .withConverter<ListAppFriendship>(
          fromFirestore: (snapshots, _) =>
              ListAppFriendship.fromJson(snapshots.data()!),
          toFirestore: (friendship, _) => friendship.toJson());

  Future<List<ListAppUser?>> getFriendsFromByUid(String uid) async {
    final queryResultFrom = await _friendshipsCollection
        .where('userFrom', isEqualTo: uid)
        .where('requestAccepted', isEqualTo: true)
        .get();

    return Future.wait(queryResultFrom.docs.map((element) async {
      return await ListAppUserManager.instance
          .getUserByUid((element.data().userTo));
    }));
  }

  Future<List<ListAppUser?>> getFriendsToByUid(String uid) async {
    final queryResultTo = await _friendshipsCollection
        .where('userTo', isEqualTo: uid)
        .where('requestAccepted', isEqualTo: true)
        .get();

    return Future.wait(queryResultTo.docs.map((element) async {
      return await ListAppUserManager.instance
          .getUserByUid((element.data().userFrom));
    }));
  }

  Future<ListAppFriendship?> getFriendshipById(String id) async {
    final queryResult = await _friendshipsCollection.doc(id).get();

    return queryResult.data();
  }

  Future<bool> addFriendByEmail(String email, String userFrom) async {
    try {
      ListAppUser? userTo =
          await ListAppUserManager.instance.getUserByEmail(email);
      if (userTo != null) {
        final newFriendship = ListAppFriendship(
            userFrom: userFrom,
            userTo: userTo.databaseId,
            requestAccepted: false);

        await _friendshipsCollection.add(newFriendship);
      }
    } on StateError catch (_) {
      return false;
    }

    return true;

    /*await ListAppUserManager.instance
        .getUserByEmail(email)
        .then((userTo) async {
      if (userTo != null) {
        final newFriendship = ListAppFriendship(
            userFrom: userFrom,
            userTo: userTo.databaseId,
            requestAccepted: false);

        await _friendshipsCollection.add(newFriendship);
        return true;
      }
    }).catchError((onError) {
      print(onError);
    });

    return false;*/
  }

  Future<bool> addFriendByUsername(String username, String userFrom) async {
    try {
      ListAppUser? userTo =
          await ListAppUserManager.instance.getUserByUsername(username);
      if (userTo != null) {
        final newFriendship = ListAppFriendship(
            userFrom: userFrom,
            userTo: userTo.databaseId,
            requestAccepted: false);

        await _friendshipsCollection.add(newFriendship);
      }
    } on TypeError catch (_) {
      return false;
    }

    return true;
  }
}
