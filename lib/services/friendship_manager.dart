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

    /*final List<ListAppUser> friendsFromList = [];

    /* queryResultFrom.docs.map((e) async {
      await ListAppUserManager.instance
          .getUserByUid((e.data().userTo))
          .then((value) {
        friendsFromList.add(value!);
      });
    }); */
    queryResultFrom.docs.forEach((element) async {
      final value = await ListAppUserManager.instance
          .getUserByUid((element.data().userTo));

      print("USER");
      print(value!.displayName);
      print("USER");

      friendsFromList.add(value!);
    });

    queryResultFrom.docs.map((e) async {
      final value =
          await ListAppUserManager.instance.getUserByUid((e.data().userTo));

      friendsFromList.add(value!);
    });
*/
    //return friendsFromList;
  }

  Future<List<ListAppFriendship>?> getFriendsToByUid(String uid) async {
    final queryResultTo = await _friendshipsCollection
        .where('userTo', isEqualTo: uid)
        .where('accepted', isEqualTo: true)
        .get();
    final List<ListAppFriendship> friendsToList = [];

    queryResultTo.docs.map((e) => friendsToList.add(e.data()));

    return friendsToList;
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
    } on StateError catch (e) {
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
    } on TypeError catch (e) {
      return false;
    }

    return true;
  }
}
