/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/user.dart';

class ListAppItemManager {
  static ListAppItemManager _instance =
      ListAppItemManager._privateConstructor();

  ListAppItemManager._privateConstructor();

  static ListAppItemManager get instance => _instance;

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  final _itemCollection = FirebaseFirestore.instance
      .collection(ListAppList.collectionName)
      .withConverter<ListAppList>(
          fromFirestore: (snapshots, _) =>
              ListAppList.fromJson(snapshots.data()!),
          toFirestore: (user, _) => user.toJson());

  /*Future<ListAppList?> getUserByEmail(String email) async {
    final queryResult =
        await _itemCollection.where('email', isEqualTo: email).get();

    return queryResult.docs.single.data();
  }*/

  Future<ListAppItem?> getItemByList(ListAppList list) async {
    // TODO verify it works
    final queryResult = await _itemCollection
        .where('name', isEqualTo: name)
        .where('users', arrayContains: user.databaseId)
        .get();

    return queryResult.docs.single.data();
  }
}
 */