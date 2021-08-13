import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/services/database_manager.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/user_manager.dart';

class ListAppNotificationManager extends DatabaseManager<ListAppNotification> {
  static ListAppNotificationManager _instance =
      ListAppNotificationManager._privateConstructor();

  ListAppNotificationManager._privateConstructor()
      : super(ManagerConfig.firebaseFirestoreInstance
            .collection(ListAppNotification.collectionName)
            .withConverter<ListAppNotification?>(
                fromFirestore: (snapshots, _) {
                  final snapshotsData = snapshots.data();
                  if (snapshotsData == null) return null;
                  return ListAppNotification.fromJson(snapshotsData);
                },
                toFirestore: (notification, _) => notification!.toJson()));

  static ListAppNotificationManager get instance => _instance;

  final FirebaseFirestore firestoreInstance =
      ManagerConfig.firebaseFirestoreInstance;

  Future<List<ListAppNotification>> getNotificationsByUserId(
      String? userUid, String? orderBy) async {
    final queryResult = await this
        .firebaseCollection
        .where('userId', isEqualTo: userUid!)
        .get();

    var docs = queryResult.docs;

    switch (orderBy) {
      case 'createdAt':
        docs.sort((a, b) {
          return b.data()!.createdAt.compareTo(a.data()!.createdAt);
        });
        break;
    }

    return Future.wait(docs.map((e) async {
      final notification = e.data()!;
      print("STATUS");
      print(notification.status);
      final sender =
          await ListAppUserManager.instance.getByUid(notification.userFrom);

      notification.databaseId = e.id;
      notification.sender = sender;
      return notification;
    }));
  }

  Future<bool> acceptNotification(String id) async {
    await this.firebaseCollection.doc(id).update({"status": "accepted"});
    return true;
  }

  Future<bool> rejectNotification(String id) async {
    await this.firebaseCollection.doc(id).update({"status": "rejected"});
    return true;
  }

  Future<int> getUnansweredNotifications(String uid, String orderBy) async {
    try {
      var cont = 0;
      print("Inizio getunanswered");
      var notificationList = await getNotificationsByUserId(uid, orderBy);

      for (var item in notificationList) {
        if (item.status == NotificationStatus.pending) {
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
        await this.firebaseCollection.where('userId', isEqualTo: uid).get();

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
