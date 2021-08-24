import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/models/friendship.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/database_manager.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/notification_manager.dart';
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

  Future<bool> _addFriend(
    ListAppUser userFrom,
    String userToId,
    FriendshipRequestMethod friendshipRequestMethod,
  ) async {
    try {
      final newFriendship = ListAppFriendship(
        userFrom: userFrom.databaseId!,
        userTo: userToId,
        requestAccepted: false,
        requestedBy: friendshipRequestMethod,
      );

      await saveToFirestore(newFriendship);

      final newNotification = FriendshipNotification(
        userFrom: userFrom.databaseId!,
        userId: userToId,
        friendshipId: newFriendship.databaseId!,
      );

      await ListAppNotificationManager.instance
          .saveToFirestore(newNotification);

      // add a new friend with pending request
      userFrom.friends[userToId] = false;
      await ListAppUserManager.instance.saveToFirestore(userFrom);

      return true;
    } on StateError catch (_) {
      return false;
    }
  }

  Future<bool> addFriendByEmail(
    String email,
    ListAppUser userFrom,
  ) async {
    ListAppUser? userTo = await ListAppUserManager.instance.getByEmail(email);
    if (userTo != null) {
      return _addFriend(
        userFrom,
        userTo.databaseId!,
        FriendshipRequestMethod.email,
      );
    } else
      return false;
  }

  Future<bool> addFriendByUsername(
    String username,
    ListAppUser userFrom,
  ) async {
    try {
      ListAppUser? userTo =
          await ListAppUserManager.instance.getByUsername(username);
      if (userTo != null) {
        return _addFriend(
          userFrom,
          userTo.databaseId!,
          FriendshipRequestMethod.username,
        );
      } else
        return false;
    } on TypeError catch (_) {
      return false;
    }
  }
}
