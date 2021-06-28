import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/list_item.dart';
import 'package:mobile_applications/models/user.dart';

/// The item manager. This is not a singleton as a new instance is created for each subcollection
class ListAppItemManager {
  final _itemCollectionRef;
  final String listUid;
  final String userUid;

  //cache the instances to avoid creating new ones every time we operate on the same list
  static final Map<String, ListAppItemManager> _cachedInstances = {};

  ListAppItemManager._privateConstructor(this.listUid, this.userUid)
      : _itemCollectionRef = FirebaseFirestore.instance
            .collection(ListAppUser.collectionName)
            .doc(userUid)
            .collection(ListAppList.collectionName)
            .doc(listUid)
            .collection(BaseItem.collectionName)
            .withConverter<BaseItem>(
                fromFirestore: (snapshots, _) =>
                    BaseItem.fromJson(snapshots.data()!),
                toFirestore: (instance, _) => instance.toJson());

  static ListAppItemManager instanceForList(String listUid, String userUid) {
    if (_cachedInstances.containsKey(listUid)) {
      return _cachedInstances[listUid]!;
    }

    ListAppItemManager newInstance =
        ListAppItemManager._privateConstructor(listUid, userUid);

    _cachedInstances[listUid] = newInstance;

    return newInstance;
  }

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  Future<BaseItem?> getItemByUid(String uid) async {
    final queryResult = await _itemCollectionRef.doc(uid).get();
    return queryResult.data();
  }

  Future<void> saveInstance(BaseItem item) async {
    if (item.databaseId != null) {
      await _itemCollectionRef.doc(item.databaseId).set(item);
      return;
    }
    await _itemCollectionRef.doc().set(item);
  }
}
