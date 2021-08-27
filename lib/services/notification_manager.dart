import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/services/database_manager.dart';
import 'package:mobile_applications/services/list_manager.dart';
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
    try {
      final queryResult = await this
          .firebaseCollection
          .where('userToId', isEqualTo: userUid!)
          .get();

      var docs = queryResult.docs;

      switch (orderBy) {
        case 'createdAt':
          docs.sort((a, b) {
            return b.data()!.createdAt.compareTo(a.data()!.createdAt);
          });
          break;
      }

      // find and inject the values not already objects in database
      return Future.wait(
        docs.map(
          (e) async {
            final notification = e.data()!;

            final userFrom = await ListAppUserManager.instance
                .getByUid(notification.userFromId);

            final userTo = await ListAppUserManager.instance
                .getByUid(notification.userToId);

            notification.userFrom = userFrom;
            notification.userTo = userTo;

            switch (notification.notificationType) {
              case NotificationType.friendship:
                // NOTE nothing to inject here for now
                return notification as FriendshipNotification;
              case NotificationType.listInvite:
                final listInviteNotification =
                    notification as ListInviteNotification;
                listInviteNotification.list =
                    await ListAppListManager.instanceForUser(userFrom!)
                        .getByUid(listInviteNotification.listId);
                return listInviteNotification;
            }
          },
        ),
      );
    } on CheckedFromJsonException catch (e) {
      print(e);
      return [];
    }
  }

  Future<bool> acceptNotification(String notificationId) async {
    await firebaseCollection
        .doc(notificationId)
        .update({"status": "accepted", "isRead": true});
    return true;
  }

  Future<bool> rejectNotification(String notificationId) async {
    await firebaseCollection
        .doc(notificationId)
        .update({"status": "rejected", "isRead": true});
    return true;
  }

  Stream<int> getUnreadNotificationCountStream(String userId) async* {
    final snapshotStream = firebaseCollection
        .where("isRead", isEqualTo: false)
        .where("userToId", isEqualTo: userId)
        .snapshots();

    await for (final querySnapshot in snapshotStream) yield querySnapshot.size;
  }
}
