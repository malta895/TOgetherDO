import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/user_manager.dart';

class ListAppListManager {
  final CollectionReference<ListAppList> _listCollectionRef;
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
      : _listCollectionRef = FirebaseFirestore.instance
            .collection(ListAppUser.collectionName)
            .doc(_userUid)
            .collection(ListAppList.collectionName)
            .withConverter<ListAppList>(
                fromFirestore: (snapshots, _) =>
                    ListAppList.fromJson(snapshots.data()!),
                toFirestore: (list, _) => list.toJson());

  static ListAppListManager instanceForUser(ListAppUser user) =>
      instanceForUserUid(user.databaseId);
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

  Future<void> saveInstance(ListAppList list) async {
    if (list.databaseId != null) {
      await _listCollectionRef.doc(list.databaseId).set(list);
      return;
    }
    await _listCollectionRef.add(list);
  }

  Future<List<ListAppList>> getLists({String? orderBy}) async {
    final queryResult = await _listCollectionRef.get();

    var docs = queryResult.docs;

    final listsInjectedWithData = docs.map((e) async {
      try {
        final list = e.data();
        list.databaseId = e.id;
        final creatorUid = list.creatorUid;
        if (creatorUid != null) {
          list.creator =
              await ListAppUserManager.instance.getUserByUid(creatorUid);
        }
        return list;
      } on CheckedFromJsonException catch (e) {
        print(e.message);
        // if the list could not be retrieved just put a value that will be removed later
        return ListAppList(name: 'null');
      }
    });

    var awaitedLists = await Future.wait(listsInjectedWithData);

    // remove bad lists
    awaitedLists.removeWhere((element) => element.databaseId == null);

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
    final queryresult = await _listCollectionRef.doc(id).get();

    return queryresult.data();
  }

  Future<bool?> addMemberToList(String lid, String uid) async {
    final queryResult = await _listCollectionRef.doc(lid).update({
      "members": FieldValue.arrayUnion([uid])
    });
  }

  Future<void> deleteList(ListAppList list) async {
    if (list.databaseId != null) {
      await _listCollectionRef.doc(list.databaseId).delete();
    }
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
    } on CheckedFromJsonException catch (e) {
      return false;
    }
  }
}
