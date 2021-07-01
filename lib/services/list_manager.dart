import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/user.dart';

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

    switch (orderBy) {
      case 'createdAt':
        docs.sort((a, b) {
          return b.data().createdAt.compareTo(a.data().createdAt);
        });
        break;
    }

    return Future.wait(docs.map((e) async {
      final list = e.data();
      list.databaseId = e.id;
      return list;
    }));
  }

  Future<ListAppList?> getListById(String id) async {
    final queryresult = await _listCollectionRef.doc(id).get();

    return queryresult.data();
  }

  Future<void> deleteList(ListAppList list) async {
    if (list.databaseId != null) {
      await _listCollectionRef.doc(list.databaseId).delete();
    }
  }

  Future<bool> leaveList(String ownerUid, ListAppList list) async {
    final listCollectionRef = FirebaseFirestore.instance
        .collection(ListAppUser.collectionName)
        .doc(ownerUid)
        .collection(ListAppList.collectionName);

    final queryResultDocRef = listCollectionRef.doc(list.databaseId);

    final queryResult = await queryResultDocRef.get();

    var membersUids = queryResult.get('members');

    if (membersUids.remove(_userUid)) {
      queryResultDocRef.update({'members': membersUids});
      return true;
    }
    return false;
  }
}
