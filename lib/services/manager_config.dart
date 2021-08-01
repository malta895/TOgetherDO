import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ManagerConfig {
  static FirebaseStorage? _firebaseStorageInstance;
  static FirebaseFirestore? _firebaseFirestoreInstance;
  static FirebaseFunctions? _firebaseFunctions;

  static void initialize({
    required FirebaseFirestore firebaseFirestore,
    required FirebaseStorage firebaseStorage,
    required FirebaseFunctions firebaseFunctions,
  }) {
    if (_firebaseFirestoreInstance != null) {
      throw StateError("DatabaseConfig is already initialized!");
    }

    // initialize only if not null
    _firebaseFirestoreInstance ??= firebaseFirestore;
    _firebaseStorageInstance ??= firebaseStorage;
    _firebaseFunctions ??= firebaseFunctions;
  }

  static FirebaseFirestore get firebaseFirestoreInstance {
    if (_firebaseFirestoreInstance == null) {
      throw StateError("DatabaseConfig must be initialized with initialize().");
    }
    return _firebaseFirestoreInstance!;
  }

  static FirebaseStorage get firebaseStorage {
    if (_firebaseStorageInstance == null) {
      throw StateError("DatabaseConfig must be initialized with initialize()");
    }
    return _firebaseStorageInstance!;
  }

  static FirebaseFunctions get firebaseFunctions {
    if (_firebaseFunctions == null) {
      throw StateError("DatabaseConfig must be initialized with initialize()");
    }
    return _firebaseFunctions!;
  }
}
