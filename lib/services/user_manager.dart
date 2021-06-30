import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  final _usersCollection = FirebaseFirestore.instance
      .collection(ListAppUser.collectionName)
      .withConverter<ListAppUser>(
          fromFirestore: (snapshots, _) =>
              ListAppUser.fromJson(snapshots.data()!),
          toFirestore: (user, _) => user.toJson());

  /// saves an instance of an user on firestore. If not given the uid is generated automatically
  Future<void> saveInstance(ListAppUser user) async {
    await _usersCollection.doc(user.databaseId).set(user);
  }

  Future<ListAppUser?> getUserByEmail(String email) async {
    final queryResult =
        await _usersCollection.where('email', isEqualTo: email).get();

    return queryResult.docs.single.data();
  }

  Future<ListAppUser?> getUserByUsername(String username) async {
    final queryResult =
        await _usersCollection.where('username', isEqualTo: username).get();

    return queryResult.docs.single.data();
  }

  Future<ListAppUser?> getUserByUid(String uid) async {
    final queryResult = await _usersCollection.doc(uid).get();

    return queryResult.data();
  }

  ///Returns `true` if the given username is already present on database. Unauthenticated method, since anyone can see if an username exists before choosing it
  Future<bool> usernameExists(String username) async {
    final queryResult =
        await _usersCollection.where('username', isEqualTo: username).get();
    return queryResult.size == 1;
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
      // TODO update also anywhere else the username is used
      notifyListeners();
    } on FirebaseException catch (e) {
      print(e.message);
      throw ListAppException('An error occurred. Please try again later.');
    }
  }

  ///Gets the lists in wich the given user is in
  Future<List<ListAppList>> getLists(ListAppUser listAppUser) async {
    try {
      final queryResult = await ListAppListManager.getCollectionGroup()
          .where('members', arrayContains: listAppUser.username)
          .get();

      final participantLists = queryResult.docs.map((e) {
        final list = e.data();
        list.databaseId = e.id;
        return list;
      });

      final ownedLists =
          await ListAppListManager.instanceForUser(listAppUser).getLists();

      return participantLists.followedBy(ownedLists).toList();
    } on FirebaseException catch (e) {
      print(e.toString());
      throw ListAppException(e.message.toString());
    } on CheckedFromJsonException catch (e) {
      print(e);
      throw ListAppException(e.message.toString());
    }
  }
}
