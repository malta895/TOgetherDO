import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/list_item.dart';

/// The item manager. This is not a singleton as a new instance is created for each subcollection
class ListAppItemManager {
  final _itemCollectionRef;

  ListAppItemManager.fromListUid(String listUid)
      : _itemCollectionRef = FirebaseFirestore.instance
            .collection(ListAppList.collectionName)
            .doc(listUid)
            .collection(BaseItem.collectionName)
            .withConverter<BaseItem>(
                fromFirestore: (snapshots, _) =>
                    BaseItem.fromJson(snapshots.data()!),
                toFirestore: (instance, _) => instance.toJson());

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  Future<BaseItem?> getItemByUid(String uid) async {
    final queryResult = await _itemCollectionRef.doc(uid).get();
    return queryResult.data();
  }

  Future<void> saveInstance(BaseItem item) async {
    if (item.databaseId != null) {
      await _itemCollectionRef.doc(item.databaseId).set(item);
    }
    await _itemCollectionRef.doc().set(item);
  }
}
