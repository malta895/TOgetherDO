import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseConfig {
  static FirebaseStorage? _firebaseStorageInstance;

  static FirebaseFirestore? _firebaseFirestoreInstance;

  static void initialize({
    required FirebaseFirestore firebaseFirestore,
    required FirebaseStorage firebaseStorage,
  }) {
    if (_firebaseFirestoreInstance != null) {
      throw StateError("DatabaseConfig is already initialized!");
    }

    // initialize only if not null
    _firebaseFirestoreInstance ??= firebaseFirestore;
    _firebaseStorageInstance ??= firebaseStorage;
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
}
