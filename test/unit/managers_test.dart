import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/database_config.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:test/test.dart';

void main() {
  final fakeFirebaseFirestore = FakeFirebaseFirestore();
  final fakeFirebaseStorage = MockFirebaseStorage();
  DatabaseConfig.initialize(
    firebaseStorage: fakeFirebaseStorage,
    firebaseFirestore: fakeFirebaseFirestore,
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
    });
  });
}
