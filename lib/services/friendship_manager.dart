import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/models/friendship.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/database_manager.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/services/utils.dart';

class ListAppFriendshipManager extends DatabaseManager<ListAppFriendship>
    with ChangeNotifier {
  static ListAppFriendshipManager _instance =
      ListAppFriendshipManager._privateConstructor();

  ListAppFriendshipManager._privateConstructor()
      : super(ManagerConfig.firebaseFirestoreInstance
            .collection(ListAppFriendship.collectionName)
            .withConverter<ListAppFriendship?>(
                fromFirestore: (snapshots, _) {
                  final snapshotsData = snapshots.data();
                  return snapshotsData == null
                      ? null
                      : ListAppFriendship.fromJson(snapshotsData);
                },
                toFirestore: (friendship, _) => friendship!.toJson()));

  static ListAppFriendshipManager get instance => _instance;

  final FirebaseFirestore firestoreInstance =
      ManagerConfig.firebaseFirestoreInstance;

  Future<List<ListAppUser?>> getFriendsFromByUid(String uid) async {
    final queryResultFrom = await this
        .firebaseCollection
        .where('userFrom', isEqualTo: uid)
        .where('requestAccepted', isEqualTo: true)
        .get();

    return Future.wait(queryResultFrom.docs
        .where((element) => ManagerUtils.doesElementConvertFromJson(element))
        .map((element) async {
      return await ListAppUserManager.instance
          .getByUid((element.data()!.userTo));
    }));
  }

  Future<List<ListAppUser?>> getFriendsToByUid(String uid) async {
    final queryResultTo = await this
        .firebaseCollection
        .where('userTo', isEqualTo: uid)
        .where('requestAccepted', isEqualTo: true)
        .get();

    return Future.wait(queryResultTo.docs.map((element) async {
      return await ListAppUserManager.instance
          .getByUid((element.data()!.userFrom));
    }));
  }

  Future<bool> addFriendByEmail(String email, String? userFromUid) async {
    try {
      ListAppUser? userTo = await ListAppUserManager.instance.getByEmail(email);
      if (userTo != null) {
        final newFriendship = ListAppFriendship(
          userFrom: userFromUid!,
          userTo: userTo.databaseId!,
          requestAccepted: false,
          requestedBy: FriendshipRequestMethod.email,
        );

        await saveToFirestore(newFriendship);
      }
    } on StateError catch (_) {
      return false;
    }

    return true;
  }

  Future<bool> addFriendByUsername(String username, String userFrom) async {
    try {
      ListAppUser? userTo =
          await ListAppUserManager.instance.getByUsername(username);
      if (userTo != null) {
        final newFriendship = ListAppFriendship(
          userFrom: userFrom,
          userTo: userTo.databaseId!,
          requestAccepted: false,
          requestedBy: FriendshipRequestMethod.username,
        );

        await saveToFirestore(newFriendship);
      }
    } on TypeError catch (_) {
      return false;
    }

    return true;
  }
}
