import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/database_manager.dart';
import 'package:mobile_applications/services/item_manager.dart';
import 'package:mobile_applications/services/user_manager.dart';

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

  final _notificationsCollection = FirebaseFirestore.instance
      .collection(ListAppNotification.collectionName)
      .withConverter<ListAppNotification>(
          fromFirestore: (snapshots, _) =>
              ListAppNotification.fromJson(snapshots.data()!),
          toFirestore: (notification, _) => notification.toJson());

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  @override
  Future<void> saveToFirestore(ListAppList list) async {
    final _docRef = this.firebaseCollection.doc(list.databaseId);
    list.databaseId = _docRef.id;
    await _docRef.set(list);
  }

  @override
  Future<ListAppList?> getByUid(String uid) {
    return getListById(uid);
  }

  Future<List<ListAppList>> getLists({String? orderBy}) async {
    final queryResult = await this.firebaseCollection.get();

    var docs = queryResult.docs;

    bool isBadListPresent = false;

    final listsInjectedWithData = docs.map((e) async {
      try {
        final list = e.data();
        list.databaseId = e.id;
        final creatorUid = list.creatorUid;
        if (creatorUid != null) {
          list.creator = await ListAppUserManager.instance.getByUid(creatorUid);
        }

        list.items =
            await ListAppItemManager.instanceForList(e.id, list.creatorUid!)
                .getItems();
        return list;
      } on CheckedFromJsonException catch (e) {
        print(e.message);
        // if the list could not be retrieved just put a value that will be removed later
        // unfortunately we can't skip values with map()
        isBadListPresent = true;
        return ListAppList(name: 'null');
      }
    }).toList();

    var awaitedLists = await Future.wait(listsInjectedWithData);

    // remove bad lists
    if (isBadListPresent)
      awaitedLists.removeWhere((element) => element.databaseId == null);

    // remove lists that the user hasn't already accepted
    // LEVA FOREACH
    // notEqualTo con indice
    // FALLO IN USER MANAGERRRR
    awaitedLists.forEach((element) async {
      final notificationQuery = await _notificationsCollection
          .where('notificationType', isEqualTo: "listInvite")
          .where('listId', isEqualTo: element.databaseId)
          .where('userId', isEqualTo: _userUid)
          .where('status', whereIn: ["undefined", "rejected"]).get();
      if (notificationQuery.docs.length == 0) {
        awaitedLists
            .removeWhere((list) => list.databaseId == element.databaseId);
      }
    });

    print(awaitedLists.length);

    awaitedLists.forEach((element) {
      print(element.name);
    });

    switch (orderBy) {
      case 'createdAt':
        awaitedLists.sort((a, b) {
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
    }

    return awaitedLists.toList();
  }

  Future<ListAppList?> getListById(String id) async {
    final queryresult = await this.firebaseCollection.doc(id).get();
    return queryresult.data();
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
