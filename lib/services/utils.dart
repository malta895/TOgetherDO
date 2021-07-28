import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class ManagerUtils {
  /// returns false if an error occurs during the conversion from json of the given element
  static bool doesElementConvertFromJson(
      QueryDocumentSnapshot queryDocumentSnapshot,
      {bool? throwError}) {
    try {
      queryDocumentSnapshot.data();
      return true;
    } on CheckedFromJsonException catch (e) {
      if (throwError == true) rethrow;
      log(e.message ?? 'Unknown checked from json exception');
      return false;
    }
  }

  static T? nullOrSingleData<T>(QuerySnapshot<T?> querySnapshot) =>
      querySnapshot.docs.isEmpty ? null : querySnapshot.docs.single.data();
}
