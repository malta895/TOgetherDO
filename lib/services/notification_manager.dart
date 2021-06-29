import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/models/user.dart';

class ListAppNotificationManager with ChangeNotifier {
  static ListAppNotificationManager _instance =
      ListAppNotificationManager._privateConstructor();

  ListAppNotificationManager._privateConstructor();

  static ListAppNotificationManager get instance => _instance;

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  static final Map<String, ListAppNotificationManager> _cachedInstances = {};

  final _notificationsCollection = FirebaseFirestore.instance
      .collection(ListAppNotification.collectionName)
      .withConverter<ListAppNotification>(
          fromFirestore: (snapshots, _) =>
              ListAppNotification.fromJson(snapshots.data()!),
          toFirestore: (notification, _) => notification.toJson());

  static ListAppNotificationManager instanceForUser(ListAppUser user) =>
      instanceForUserUid(user.databaseId);
  static ListAppNotificationManager instanceForUserUid(String userUid) {
    if (_cachedInstances.containsKey(userUid)) {
      return _cachedInstances[userUid]!;
    }
    ListAppNotificationManager newInstance =
        ListAppNotificationManager._privateConstructor();

    _cachedInstances[userUid] = newInstance;

    return newInstance;
  }

  Future<List<ListAppNotification>> getNotificationsByUid(String uid) async {
    final queryResult =
        await _notificationsCollection.where('userId', isEqualTo: uid).get();

    print("FUORI getNotificatoinsByUid");

    return Future.wait(queryResult.docs.map((e) async {
      final list = e.data();
      print("getNotificatoinsByUid");
      print(list.databaseId);
      list.databaseId = e.id;
      return list;
    }));
  }

  /*Future<List<ListAppFriendship?>> getNotificationsByUid(String uid) async {
    final queryResult =
        await _notificationsCollection.where('userId', isEqualTo: uid).get();

    print("getNotificationsByUid");

    return Future.wait(queryResult.docs.map((element) async {
      return await ListAppFriendshipManager.instance
          .getFriendshipById((element.data().objectId!));
    }));*/

  /*return Future.wait(queryResult.docs.map((e) async {
      final notification = e.data();
      notification.databaseId = e.id;
      ListAppFriendship? friendship = await ListAppFriendshipManager.instance
            .getFriendshipById(notification.databaseId!);
        return friendship;

      /* return Future.wait(queryResult.docs.map((e) async {
      final notification = e.data();
      notification.databaseId = e.id;
      if (notification.notificationType == "friendship") {
        ListAppFriendship? friendship = await ListAppFriendshipManager.instance
            .getFriendshipById(notification.databaseId!);

            
      }
      return notification; */
    }));
  }*/
}
