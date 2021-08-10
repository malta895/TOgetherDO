import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/exception.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/database_manager.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/utils.dart' show ManagerUtils;

class ListAppUserManager extends DatabaseManager<ListAppUser>
    with ChangeNotifier {
  static ListAppUserManager _instance =
      ListAppUserManager._privateConstructor();

  ListAppUserManager._privateConstructor()
      : super(ManagerConfig.firebaseFirestoreInstance
            .collection(ListAppUser.collectionName)
            .withConverter<ListAppUser?>(
                fromFirestore: (snapshots, _) {
                  final snapshotsData = snapshots.data();
                  if (snapshotsData == null) return null;
                  return ListAppUser.fromJson(snapshotsData);
                },
                toFirestore: (user, _) => user!.toJson()));

  static ListAppUserManager get instance => _instance;

  final _firebaseStorageInstance = ManagerConfig.firebaseStorage;

  final _firebaseFunctions = ManagerConfig.firebaseFunctions;

  Future<void> changeProfilePicture(
    ListAppUser user,
    XFile imageFile,
  ) async {
    final imageRef =
        _firebaseStorageInstance.ref('pro-pic-user-' + user.databaseId!);

    await imageRef.putData(await imageFile.readAsBytes());

    final profilePictureURL = await imageRef.getDownloadURL();
    await this
        .firebaseCollection
        .doc(user.databaseId)
        .update({'profilePictureURL': profilePictureURL});

    // set the new image to the user
    user.profilePictureURL = profilePictureURL;
  }

  Future<ListAppUser?> getByEmail(String email) async {
    try {
      final callable = _firebaseFunctions.httpsCallable(
        'getUserByEmail-getUserByEmail',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );

      final result = await callable(email);

      return result.data<ListAppUser?>();
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<ListAppUser?> getByUsername(String username) async {
    try {
      final queryResult =
          await firebaseCollection.where('username', isEqualTo: username).get();

      return ManagerUtils.nullOrSingleData(queryResult);
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      return null;
    }
  }

  ///Returns `true` if the given username is already present on database. Unauthenticated method, since anyone can see if an username exists before choosing it
  Future<bool> usernameExists(String username) async {
    try {
      final queryResult =
          await firebaseCollection.where('username', isEqualTo: username).get();
      return queryResult.size == 1;
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      return true; // even if the model could not be retrieved, the username exists
    }
  }

  /// Checks if the username is not null or empty and if it is not a duplicate
  /// return an according exception in the case
  Future<void> validateUsername(String? username) async {
    if (username == null || username.isEmpty) {
      throw ListAppException('The username is empty');
    }
    if (await usernameExists(username)) {
      throw ListAppException('The username is already taken');
    }
  }

  /// Updates the username on firestore. Returns `false` on failure
  Future<void> updateUsername(String username, String? userId) async {
    if (userId == null) throw ListAppException('No user is logged in.');

    if (await usernameExists(username)) {
      throw ListAppException('The username is already taken');
    }

    try {
      await this.firebaseCollection.doc(userId).update({'username': username});
      notifyListeners();
    } on FirebaseException catch (e) {
      print(e.message);
      throw ListAppException('An error occurred. Please try again later.');
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      throw ListAppException('An error occurred. Please try again later.');
    }
  }
}
