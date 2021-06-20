import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_applications/models/exception.dart';
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

  User _getCurrentUser() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw ListAppException("No user is currently logged in!");
    }

    return currentUser;
  }

  /// persists an instance of an user on firestore. If not given the uid is generated automatically
  Future<void> persistInstance(ListAppUser user, [String? uid]) async {
    if (uid == null) {
      await _usersCollection.add(user);
    } else {
      await _usersCollection.doc(uid).set(user);
    }
  }

  Future<ListAppUser?> getUserByEmail(String email) async {
    final queryResult =
        await _usersCollection.where('email', isEqualTo: email).get();

    return queryResult.docs.single.data();
  }

  Future<ListAppUser?> getUserByUid(String uid) async {
    final queryResult = await _usersCollection.doc(uid).get();

    return queryResult.data();
  }

  ///Returns `true` if the given username is already present on database. Unauthenticated method, sice anyone can see if an username exists before choosing it
  Future<bool> usernameExists(String username) async {
    final queryResult =
        await _usersCollection.where('username', isEqualTo: username).get();
    return queryResult.size == 1;
  }

  ///Updates the username on firestore. Returns `false` on failure
  Future<bool> updateUsername(
    String username,
  ) async {
    if (await usernameExists(username)) {
      return false;
    }

    try {
      await _usersCollection
          .doc(_getCurrentUser().uid)
          .update({'username': username});

      //TODO set current ListAppUser
      return true;
    } on FirebaseException catch (e) {
      print(e.message);
      return false;
    }
  }

  Future<ListAppUser> createNewListAppUser(ListAppUser user) async {
    return user;
  }
}
