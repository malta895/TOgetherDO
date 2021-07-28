import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'utils_test.mocks.dart';

@GenerateMocks([FirebaseFunctions])
void main() {
  test('Test DatabaseConfig', () {
    // trying to access configs before initialization results in an error
    expect(() => ManagerConfig.firebaseFirestoreInstance, throwsStateError);
    expect(() => ManagerConfig.firebaseStorage, throwsStateError);
    expect(() => ManagerConfig.firebaseFunctions, throwsStateError);

    final fakeFirebaseFirestore = FakeFirebaseFirestore();
    final fakeFirebaseStorage = MockFirebaseStorage();
    final fakeFirebaseFunctions = MockFirebaseFunctions();

    // initialize configs
    ManagerConfig.initialize(
      firebaseFirestore: fakeFirebaseFirestore,
      firebaseStorage: fakeFirebaseStorage,
      firebaseFunctions: fakeFirebaseFunctions,
    );

    // no error should be thrown now
    expect(ManagerConfig.firebaseFirestoreInstance, fakeFirebaseFirestore);
    expect(ManagerConfig.firebaseStorage, fakeFirebaseStorage);
    expect(ManagerConfig.firebaseFunctions, fakeFirebaseFunctions);

    // reinitializing config results in an error
    expect(
        () => ManagerConfig.initialize(
              firebaseFirestore: FakeFirebaseFirestore(),
              firebaseStorage: MockFirebaseStorage(),
              firebaseFunctions: MockFirebaseFunctions(),
            ),
        throwsStateError);
  });
}
