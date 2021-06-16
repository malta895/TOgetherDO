import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_applications/models/user.dart';

class ListAppUserManager {
  static ListAppUserManager _instance =
      ListAppUserManager._privateConstructor();

  ListAppUserManager._privateConstructor();

  static ListAppUserManager get instance => _instance;

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  final _usersCollection = FirebaseFirestore.instance
      .collection(ListAppUser.collectionName)
      .withConverter<ListAppUser>(
          fromFirestore: (snapshots, _) =>
              ListAppUser.fromJson(snapshots.data()!),
          toFirestore: (user, _) => user.toJson());

  Future<ListAppUser?> getUserByEmail(String email) async {
    final queryResult =
        await _usersCollection.where('email', isEqualTo: email).get();

    return queryResult.docs.single.data();
  }
}
