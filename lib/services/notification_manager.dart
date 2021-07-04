import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/services/user_manager.dart';

class ListAppNotificationManager with ChangeNotifier {
  static ListAppNotificationManager _instance =
      ListAppNotificationManager._privateConstructor();

  ListAppNotificationManager._privateConstructor();

  static ListAppNotificationManager get instance => _instance;

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  final _notificationsCollection = FirebaseFirestore.instance
      .collection(ListAppNotification.collectionName)
      .withConverter<ListAppNotification>(
          fromFirestore: (snapshots, _) =>
              ListAppNotification.fromJson(snapshots.data()!),
          toFirestore: (notification, _) => notification.toJson());

  Future<List<ListAppNotification>> getNotificationsByUid(
      String uid, String? orderBy) async {
    final queryResult =
        await _notificationsCollection.where('userId', isEqualTo: uid).get();

    var docs = queryResult.docs;

    switch (orderBy) {
      case 'createdAt':
        docs.sort((a, b) {
          return b.data().createdAt!.compareTo(a.data().createdAt as int);
        });
        break;
    }

    return Future.wait(docs.map((e) async {
      final notification = e.data();
      print("STATUS");
      print(notification.status);
      final sender =
          await ListAppUserManager.instance.getUserByUid(notification.userFrom);

      notification.databaseId = e.id;
      notification.sender = sender;
      return notification;
    }));
  }

  Future<bool> acceptNotification(String id) async {
    await _notificationsCollection.doc(id).update({"status": "accepted"});
    return true;
  }

  Future<bool> rejectNotification(String id) async {
    await _notificationsCollection.doc(id).update({"status": "rejected"});
    return true;
  }

  Future<int> getUnansweredNotifications(String uid, String orderBy) async {
    try {
      var cont = 0;
      print("Inizio getunanswered");
      var notificationList = await getNotificationsByUid(uid, orderBy);

      for (var item in notificationList) {
        if (item.status == NotificationStatus.undefined) {
          cont++;
        }
      }

      /*notificationList.map((e) {
      if (e.status == NotificationStatus.undefined) {
        print("una undefined trovata");
        cont++;
      }
    });*/

      return cont;
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      return 0;
    }
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
