import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_cloud_functions_mock/firebase_cloud_functions_mock.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:mobile_applications/models/exception.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:test/test.dart';

void main() {
  final fakeFirebaseFirestore = FakeFirebaseFirestore();
  final fakeFirebaseStorage = MockFirebaseStorage();
  final fakeFirebaseFunctions = MockCloudFunctions();

  ManagerConfig.initialize(
    firebaseStorage: fakeFirebaseStorage,
    firebaseFirestore: fakeFirebaseFirestore,
    firebaseFunctions: fakeFirebaseFunctions,
  );

  void createTestUser() {
    final testUser = ListAppUser(
      databaseId: '123prova',
      username: 'johndoe',
      email: 'doe@email.com',
      firstName: "John",
      lastName: "Doe",
    );

    ListAppUserManager.instance.saveToFirestore(testUser);
  }

  createTestUser();

  group('Test usermanager', () {
    test('test getByUid', () async {
      final user = await ListAppUserManager.instance.getByUid('123prova');
      expect(
        user?.username,
        'johndoe',
      );

      final wrongUser = await ListAppUserManager.instance.getByUid('random');
      expect(wrongUser, null);
    });

    test(
      'test getByEmail',
      () async {
        final testUser = {
          "databaseId": '123prova',
          "createdAt": 1625751035020,
          "displayName": "John Doe",
          "email": "doe@email.com",
          "firstName": "John",
          "friends": [],
          "isNew": false,
          "lastName": "Doe",
          "notificationTokens": [],
          "phoneNumber": null,
          "profilePictureURL": null,
          "username": "johndoe1",
        };

        fakeFirebaseFunctions.mockResult(
            functionName: 'getUserByEmail-getUserByEmail',
            json: jsonEncode(testUser),
            parameters: {"email": "doe@email.com"});

        final user =
            await ListAppUserManager.instance.getByEmail('doe@email.com');
        expect(
          user?.databaseId,
          '123prova',
        );

        final wrongUser =
            await ListAppUserManager.instance.getByEmail('random');

        expect(wrongUser, null);

        fakeFirebaseFirestore.clearPersistence();
      },
    );

    test('getByUsername', () async {
      final user = await ListAppUserManager.instance.getByUsername('johndoe');
      expect(
        user?.databaseId,
        '123prova',
      );

      final wrongUser =
          await ListAppUserManager.instance.getByUsername('random');
      expect(wrongUser, null);

      // bad user, without required attributes
      fakeFirebaseFirestore
          .collection('users')
          .doc('bad_user')
          .set({'bad': 'bad', 'username': 'bad'});

      final badUser = await ListAppUserManager.instance.getByUsername('bad');

      expect(badUser, null);

      await fakeFirebaseFirestore.collection('users').doc('bad_user').delete();
    });

    test('usernameExists', () async {
      final trueResult =
          await ListAppUserManager.instance.usernameExists('johndoe');
      expect(trueResult, true);

      final falseResult =
          await ListAppUserManager.instance.usernameExists('johndoe1');

      expect(falseResult, false);
    });

    test('validateUsername', () async {
      try {
        await ListAppUserManager.instance.validateUsername('johndoe');
        fail('Expected a ListAppException to be thrown');
      } on ListAppException catch (e) {
        expect(e.message, 'The username is already taken');
      }

      try {
        await ListAppUserManager.instance.validateUsername('');
        fail('Expected a ListAppException to be thrown');
      } on ListAppException catch (e) {
        expect(e.message, 'The username is empty');
      }
    });
  });
}
