import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/user.dart';

class ListAppListManager {
  static ListAppListManager _instance =
      ListAppListManager._privateConstructor();

  ListAppListManager._privateConstructor();

  static ListAppListManager get instance => _instance;

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  final _listCollectionRef = FirebaseFirestore.instance
      .collection(ListAppList.collectionName)
      .withConverter<ListAppList>(
          fromFirestore: (snapshots, _) =>
              ListAppList.fromJson(snapshots.data()!),
          toFirestore: (list, _) => list.toJson());

  Future<ListAppList?> getListByNameAndUser(
      ListAppUser user, String name) async {
    final queryResult = await _listCollectionRef
        .where('name', isEqualTo: name)
        .where('users', arrayContains: user.databaseId)
        .get();

    return queryResult.docs.single.data();
  }

  Future<void> saveInstance(ListAppList list) async {
    if (list.databaseId != null) {
      await _listCollectionRef.doc(list.databaseId).set(list);
    }
    await _listCollectionRef.add(list);
  }
}
