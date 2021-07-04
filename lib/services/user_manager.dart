import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/exception.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/list_manager.dart';

class ListAppUserManager with ChangeNotifier {
  static ListAppUserManager _instance =
      ListAppUserManager._privateConstructor();

  ListAppUserManager._privateConstructor();

  static ListAppUserManager get instance => _instance;

  final _firebaseStorageInstance = firebase_storage.FirebaseStorage.instance;

  final _usersCollection = FirebaseFirestore.instance
      .collection(ListAppUser.collectionName)
      .withConverter<ListAppUser>(
          fromFirestore: (snapshots, _) {
            return ListAppUser.fromJson(snapshots.data()!);
          },
          toFirestore: (user, _) => user.toJson());

  Future<void> changeProfilePicture(
      ListAppUser user, PickedFile imageFile) async {
    final imageRef =
        _firebaseStorageInstance.ref('pro-pic-user-' + user.databaseId);

    await imageRef.putData(await imageFile.readAsBytes());

    final profilePictureURL = await imageRef.getDownloadURL();
    await _usersCollection
        .doc(user.databaseId)
        .update({'profilePictureURL': profilePictureURL});

    // set the new image to the user
    user.profilePictureURL = profilePictureURL;
  }

  /// saves an instance of an user on firestore. If not given the uid is generated automatically
  Future<void> saveInstance(ListAppUser user) async {
    await _usersCollection.doc(user.databaseId).set(user);
  }

  Future<ListAppUser?> getUserByEmail(String email) async {
    try {
      final queryResult =
          await _usersCollection.where('email', isEqualTo: email).get();

      return queryResult.docs.single.data();
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<ListAppUser?> getUserByUsername(String username) async {
    try {
      final queryResult =
          await _usersCollection.where('username', isEqualTo: username).get();

      return queryResult.docs.single.data();
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<ListAppUser?> getUserByUid(String uid) async {
    try {
      final queryResult = await _usersCollection.doc(uid).get();

      return queryResult.data();
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      return null;
    }
  }

  ///Returns `true` if the given username is already present on database. Unauthenticated method, since anyone can see if an username exists before choosing it
  Future<bool> usernameExists(String username) async {
    try {
      final queryResult =
          await _usersCollection.where('username', isEqualTo: username).get();
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

  ///Updates the username on firestore. Returns `false` on failure
  Future<void> updateUsername(String username, String? userId) async {
    if (userId == null) throw ListAppException('No user is logged in.');

    if (await usernameExists(username)) {
      throw ListAppException('The username is already taken');
    }

    try {
      await _usersCollection.doc(userId).update({'username': username});
      notifyListeners();
    } on FirebaseException catch (e) {
      print(e.message);
      throw ListAppException('An error occurred. Please try again later.');
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      throw ListAppException('An error occurred. Please try again later.');
    }
  }

  ///Gets the lists in wich the given user is in
  Future<List<ListAppList>> getLists(ListAppUser listAppUser,
      {String? orderBy}) async {
    try {
      final queryResult = await ListAppListManager.getCollectionGroupConverted()
          .where('members', arrayContains: listAppUser.databaseId)
          .get();

      final participantLists =
          await Future.wait(queryResult.docs.map((e) async {
        final listAppList = e.data();
        listAppList.databaseId = e.id;

        // replace the users id with the usernames
        final usernames = await Future.wait(listAppList.members.map((e) async {
          if (e == null) return null;
          final user = await getUserByUid(e);
          return user?.username;
        }));

        listAppList.members = usernames.toSet();

        if (listAppList.creatorUid == null) {
          print("The list ${listAppList.databaseId} has null creatorUid!");
        }
        listAppList.creator = await ListAppUserManager.instance
            .getUserByUid(listAppList.creatorUid!);

        return listAppList;
      }));

      final ownedLists = await ListAppListManager.instanceForUser(listAppUser)
          .getLists(orderBy: orderBy);

      final listAppLists = participantLists.followedBy(ownedLists).toList();

      switch (orderBy) {
        case 'createdAt':
          listAppLists.sort((a, b) {
            return b.createdAt.compareTo(a.createdAt);
          });
          break;
      }

      return listAppLists;
    } on FirebaseException catch (e) {
      print(e.toString());
      throw ListAppException(e.message.toString());
    }
  }
}
