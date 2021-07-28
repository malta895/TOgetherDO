import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:mobile_applications/services/database_config.dart';
import 'package:test/test.dart';

void main() {
  test('Test DatabaseConfig', () {
    // trying to access configs before initialization results in an error
    expect(() => DatabaseConfig.firebaseFirestoreInstance, throwsStateError);
    expect(() => DatabaseConfig.firebaseStorage, throwsStateError);

    final fakeFirebaseFirestore = FakeFirebaseFirestore();
    final fakeFirebaseStorage = MockFirebaseStorage();

    // initialize configs
    DatabaseConfig.initialize(
      firebaseFirestore: fakeFirebaseFirestore,
      firebaseStorage: fakeFirebaseStorage,
    );

    // no error should be thrown now
    expect(DatabaseConfig.firebaseFirestoreInstance, fakeFirebaseFirestore);
    expect(DatabaseConfig.firebaseStorage, fakeFirebaseStorage);

    // reinitializing config results in an error
    expect(
        () => DatabaseConfig.initialize(
              firebaseFirestore: FakeFirebaseFirestore(),
              firebaseStorage: MockFirebaseStorage(),
            ),
        throwsStateError);
  });
}
