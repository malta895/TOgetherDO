import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/list_item.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/database_manager.dart';
import 'package:mobile_applications/services/manager_config.dart';

/// The item manager. This is not a singleton as a new instance is created for each subcollection
class ListAppItemManager extends DatabaseManager<BaseItem> {
  final String listUid;
  final String userUid;
  //cache the instances to avoid creating new ones every time we operate on the same list
  static final Map<String, ListAppItemManager> _cachedInstances = {};

  ListAppItemManager._privateConstructor(this.listUid, this.userUid)
      : super(ManagerConfig.firebaseFirestoreInstance
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

    final listWithNulls = queryResult.docs.map((e) {
      try {
        return e.data();
      } on CheckedFromJsonException catch (e) {
        print(e);
        return null;
      }
    }).toList();

    listWithNulls.removeWhere((element) => element == null);

    return listWithNulls.cast<BaseItem>();
  }

  Future<bool> listItemNameExists(String name) async {
    final queryResult =
        await this.firebaseCollection.where("name", isEqualTo: name).get();
    //print(queryResult.docs.first.data());
    return queryResult.docs.isNotEmpty;
  }

  Future<bool> fulfillItem(String uid, String itemId, int completions) async {
    final item = await this.firebaseCollection.doc(itemId).get();
    final usersCompletions1 = item.data()!.usersCompletions;
    if (usersCompletions1 != null) {
      usersCompletions1[uid] = completions;

      print(usersCompletions1);

      await this
          .firebaseCollection
          .doc(itemId)
          .update({'usersCompletions': usersCompletions1});

      return true;
    }

    return false;
  }

  /*Future<bool> checkCompletionsForItem(String itemId) async {
    final queryResult = await ManagerConfig.firebaseFirestoreInstance
        .collection(ListAppUser.collectionName)
        .doc(userUid)
        .collection(ListAppList.collectionName)
        .doc(listUid)
        .collection("completions")
        .where(itemId, isEqualTo: itemId)
        .get();

    print("COMPLETIONS");
    print(queryResult.docs.first.data());

    return queryResult.docs.isNotEmpty;
  }*/
}
