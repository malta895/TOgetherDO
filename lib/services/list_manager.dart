import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/database_manager.dart';
import 'package:mobile_applications/services/item_manager.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/services/utils.dart';

class ListAppListManager extends DatabaseManager<ListAppList> {
  static Query? _collectionGroup;
  static Query<ListAppList>? _collectionGroupConverted;
  final String _userUid;

  static Query getCollectionGroup() {
    _collectionGroup ??=
        FirebaseFirestore.instance.collectionGroup(ListAppList.collectionName);
    return _collectionGroup!;
  }

  static Query<ListAppList> getCollectionGroupConverted() {
    _collectionGroupConverted ??= FirebaseFirestore.instance
        .collectionGroup(ListAppList.collectionName)
        .withConverter<ListAppList>(
            fromFirestore: (snapshots, _) =>
                ListAppList.fromJson(snapshots.data()!),
            toFirestore: (list, _) => list.toJson());
    return _collectionGroupConverted!;
  }

  static final Map<String, ListAppListManager> _cachedInstances = {};

  ListAppListManager._privateConstructor(this._userUid)
      : super(FirebaseFirestore.instance
            .collection(ListAppUser.collectionName)
            .doc(_userUid)
            .collection(ListAppList.collectionName)
            .withConverter<ListAppList>(
                fromFirestore: (snapshots, _) =>
                    ListAppList.fromJson(snapshots.data()!),
                toFirestore: (list, _) => list.toJson()));

  static ListAppListManager instanceForUser(ListAppUser user) =>
      instanceForUserUid(user.databaseId!);
  static ListAppListManager instanceForUserUid(String userUid) {
    if (_cachedInstances.containsKey(userUid)) {
      return _cachedInstances[userUid]!;
    }

    ListAppListManager newInstance =
        ListAppListManager._privateConstructor(userUid);

    _cachedInstances[userUid] = newInstance;

    return newInstance;
  }

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  /// Get all the lists the user is in, as owner or as member
  Future<List<ListAppList>> getUserLists(ListAppUser user,
      {String? orderBy}) async {
    // the owned lists are already in this instance of the manager
    final queryResultOwnedLists = await this.firebaseCollection.get();

    final queryResultMemberLists = await getCollectionGroupConverted()
        .where('members', arrayContains: user.databaseId)
        .get();

    final combinedQueryResult =
        queryResultMemberLists.docs.followedBy(queryResultOwnedLists.docs);

    // TODO remove lists that the user hasn't already accepted
    // probabilmente basta non mettere in members finchè non si accetta
    // LEVA FOREACH
    // notEqualTo con indice
    // FALLO IN USER MANAGERRRR
    // awaitedLists.forEach((element) async {
    //   final notificationQuery = await _notificationsCollection
    //       .where('notificationType', isEqualTo: "listInvite")
    //       .where('listId', isEqualTo: element.databaseId)
    //       .where('userId', isEqualTo: _userUid)
    //       .where('status', whereIn: ["undefined", "rejected"]).get();
    //   if (notificationQuery.docs.length == 0) {
    //     awaitedLists
    //         .removeWhere((list) => list.databaseId == element.databaseId);
    //   }
    // });

    final listAppLists = combinedQueryResult
        .where((element) => ManagerUtils.doesElementConvertFromJson(element))
        .map((listDocumentSnapshot) async {
      final ListAppList listAppList = listDocumentSnapshot.data();

      // inject creator
      listAppList.creator =
          await ListAppUserManager.instance.getByUid(listAppList.creatorUid!);

      // inject users
      listAppList.members.forEach((memberUserUid) async {
        final listAppUser =
            await ListAppUserManager.instance.getByUid(memberUserUid!);

        if (listAppUser != null) listAppList.membersAsUsers.add(listAppUser);
      });

      //inject items
      // TODO we can remove it if we fetch them at need
      listAppList.items = await ListAppItemManager.instanceForList(
              listDocumentSnapshot.id, listAppList.creatorUid!)
          .getItems();

      return listAppList;
    }).toList();

    final awaitedLists = await Future.wait(listAppLists);

    switch (orderBy) {
      case 'createdAt':
        awaitedLists.sort((a, b) {
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
    }

    return awaitedLists;
  }

  Future<bool?> addMemberToList(String lid, String uid) async {
    this
        .firebaseCollection
        .doc(lid)
        .update({
          "members": FieldValue.arrayUnion([uid])
        })
        .then((value) => true)
        .catchError((e) => false);
  }

  Future<bool?> removeMemberFromList(String lid, String uid) async {
    this
        .firebaseCollection
        .doc(lid)
        .update({
          "members": FieldValue.arrayRemove([uid])
        })
        .then((value) => true)
        .catchError((e) => false);
  }

  Future<bool> leaveList(String ownerUid, ListAppList list) async {
    try {
      final ownerListCollectionRef = FirebaseFirestore.instance
          .collection(ListAppUser.collectionName)
          .doc(ownerUid)
          .collection(ListAppList.collectionName);

      final queryResultDocRef = ownerListCollectionRef.doc(list.databaseId);

      final queryResult = await queryResultDocRef.get();

      final membersUids = queryResult.get('members');

      if (membersUids.remove(_userUid)) {
        queryResultDocRef.update({'members': membersUids});
        return true;
      }
      return false;
    } on CheckedFromJsonException catch (_) {
      return false;
    }
  }
}
