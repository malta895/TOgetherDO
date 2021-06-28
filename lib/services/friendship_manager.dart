import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/models/exception.dart';
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
}
