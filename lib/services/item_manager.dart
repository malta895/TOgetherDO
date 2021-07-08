import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/list_item.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/database_manager.dart';

/// The item manager. This is not a singleton as a new instance is created for each subcollection
class ListAppItemManager extends DatabaseManager<BaseItem> {
  final String listUid;
  final String userUid;
  //cache the instances to avoid creating new ones every time we operate on the same list
  static final Map<String, ListAppItemManager> _cachedInstances = {};

  ListAppItemManager._privateConstructor(this.listUid, this.userUid)
      : super(FirebaseFirestore.instance
            .collection(ListAppUser.collectionName)
            .doc(userUid)
            .collection(ListAppList.collectionName)
            .doc(listUid)
            .collection(BaseItem.collectionName)
            .withConverter<BaseItem>(
                fromFirestore: (snapshots, _) =>
                    BaseItem.fromJson(snapshots.data()!),
                toFirestore: (instance, _) => instance.toJson()));

  static ListAppItemManager instanceForList(String listUid, String userUid) {
    if (_cachedInstances.containsKey(listUid)) {
      return _cachedInstances[listUid]!;
    }

    ListAppItemManager newInstance =
        ListAppItemManager._privateConstructor(listUid, userUid);

    _cachedInstances[listUid] = newInstance;

    return newInstance;
  }

  Future<BaseItem?> getItemByUid(String uid) async {
    try {
      final queryResult = await this.firebaseCollection.doc(uid).get();
      return queryResult.data();
    } on CheckedFromJsonException catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<BaseItem>> getItems() async {
    final queryResult = await this.firebaseCollection.get();

    return queryResult.docs.map((e) {
      return e.data();
    }).toList();
  }

  Future<bool> listItemNameExists(String name) async {
    final queryResult =
        await this.firebaseCollection.where("name", isEqualTo: name).get();
    return queryResult.docs.isNotEmpty;
  }
}
