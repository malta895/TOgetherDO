import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/user.dart';

class ListAppListManager {
  static ListAppListManager _instance =
      ListAppListManager._privateConstructor();

  ListAppListManager._privateConstructor();

  static ListAppListManager get instance => _instance;

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  final _usersCollection = FirebaseFirestore.instance
      .collection(ListAppList.collectionName)
      .withConverter<ListAppList>(
          fromFirestore: (snapshots, _) =>
              ListAppList.fromJson(snapshots.data()!),
          toFirestore: (user, _) => user.toJson());

  Future<ListAppList?> getUserByEmail(String email) async {
    final queryResult =
        await _usersCollection.where('email', isEqualTo: email).get();

    return queryResult.docs.single.data();
  }

  Future<ListAppList?> getListByNameAndUser(
      ListAppUser user, String name) async {
    // TODO verify it works
    final queryResult = await _usersCollection
        .where('name', isEqualTo: name)
        .where('users', arrayContains: user.databaseId)
        .get();

    return queryResult.docs.single.data();
  }
}
