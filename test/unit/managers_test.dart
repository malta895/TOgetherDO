import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'managers_test.mocks.dart';

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult<T> extends Mock
    implements HttpsCallableResult<T> {}

@GenerateMocks([FirebaseFunctions])
void main() {
  final fakeFirebaseFirestore = FakeFirebaseFirestore();
  final fakeFirebaseStorage = MockFirebaseStorage();
  final fakeFirebaseFunctions = MockFirebaseFunctions();
  final fakeHttpsCallable = MockHttpsCallable();
  final fakeHttpsCallableResult = MockHttpsCallableResult();

  ManagerConfig.initialize(
    firebaseStorage: fakeFirebaseStorage,
    firebaseFirestore: fakeFirebaseFirestore,
    firebaseFunctions: fakeFirebaseFunctions,
  );

  group('Test usermanager', () {
    final testUser = ListAppUser(
      databaseId: '123prova',
      username: 'johndoe',
      email: 'doe@email.com',
      firstName: "John",
      lastName: "Doe",
    );

    ListAppUserManager.instance.saveToFirestore(testUser);

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
        when(fakeFirebaseFunctions.httpsCallable(
          'getUserByEmail-getUserByEmail',
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 30),
          ),
        )).thenReturn(fakeHttpsCallable);

        when(fakeHttpsCallableResult.data()).thenAnswer((_) async => testUser);

        final user =
            await ListAppUserManager.instance.getByEmail('doe@email.com');
        expect(
          user?.databaseId,
          '123prova',
        );

        final wrongUser =
            await ListAppUserManager.instance.getByEmail('random');
        expect(wrongUser, null);
      },
      skip: 'Find a way to mock the cloud functions properly', // TODO fix this
    );

    test('test getByUsername', () async {
      final user = await ListAppUserManager.instance.getByUsername('johndoe');
      expect(
        user?.databaseId,
        '123prova',
      );

      final wrongUser =
          await ListAppUserManager.instance.getByUsername('random');
      expect(wrongUser, null);
    });
  });
}
