import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/base_model.dart';
import 'package:mobile_applications/services/manager_config.dart';

/// The database manager. Contains common methods for convenience
abstract class DatabaseManager<T extends BaseModel> {
  final CollectionReference<T?> firebaseCollection;

  final FirebaseFirestore firestoreInstance;

  DatabaseManager(this.firebaseCollection)
      : firestoreInstance = ManagerConfig.firebaseFirestoreInstance;

  /// Saves the instance to firestore, overwriting it if already exists
  Future<void> saveToFirestore(T instance) async {
    final docRef = firebaseCollection.doc(instance.databaseId);
    instance.databaseId = docRef.id;
    // TODO put also createdAt (?)
    await docRef.set(instance);
  }

  /// deletes the instance from firestore
  Future<void> deleteInstance(T instance) async {
    if (instance.databaseId != null) {
      await this.firebaseCollection.doc(instance.databaseId).delete();
    }
  }

  /// Gets an instance from the database by Uid
  Future<T?> getByUid(String uid, {throwJsonException: false}) async {
    try {
      final queryResult = await firebaseCollection.doc(uid).get();
      return queryResult.data();
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      if (throwJsonException) rethrow;
      return null;
    }
  }
}
