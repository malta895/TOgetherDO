import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class ListAppAuthenticator {
  ListAppAuthenticator._privateConstructor();

  static final ListAppAuthenticator _instance =
      ListAppAuthenticator._privateConstructor();

  static ListAppAuthenticator get instance => _instance;
}
