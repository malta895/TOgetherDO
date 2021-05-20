import 'package:firebase_auth/firebase_auth.dart';

///A wrapper of FirebaseAuth, that provides a better interface to the login ui
///It is a Singleton, get it with [ListAppAuth.instance]
class ListAppAuthenticator {
  // This class is a singleton
  ListAppAuthenticator._privateConstructor();

  static final ListAppAuthenticator _instance =
      ListAppAuthenticator._privateConstructor();

  static ListAppAuthenticator get instance => _instance;

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// returns the current logged in user, null if no one is loggedIn
  User? get loggedInUser {
    return _firebaseAuth.currentUser;
  }

  bool isSomeoneLoggedIn() {
    return loggedInUser != null;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  //every method returns null when successfull

  Future<String?>? signupWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      // see https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/createUserWithEmailAndPassword.html
      print(e.code);
      switch (e.code) {
        case 'email-already-in-use':
          return "An user with this email address already exists.\n"
              "Please login or proceed to password recovery.";
        case 'invalid-email':
          return "The provided email address is not valid.";
        case 'weak-password':
          return "The password is too weak. Please provide a stronger one.";
        case 'operation-not-allowed':
          return "We are sorry but we do not accept new user creation at the moment. Please try again later.";
        default:
          return "Unknown error.";
      }
    }
  }

  Future<String?>? loginViaEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      print(e.code);

      // see https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithEmailAndPassword.html for the error codes
      switch (e.code) {
        //for security reasons, treat these cases as if they were the same
        case 'user-not-found':
        case 'wrong-password':
          return "Wrong credentials, please check and try again.";

        case 'invalid-email':
          return "The email address is not valid, please check and try again.";

        case 'user-disabled':
          return "Your user account has been disabled!";
        default:
          return 'Unknown error!';
      }
    }
  }
}
