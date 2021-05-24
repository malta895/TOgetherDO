import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


///A wrapper of FirebaseAuth, that provides a better interface to the login ui
///It is used with a Provider, get it with Provider.of(context).read<ListAppAuthProvider>()
class ListAppAuthProvider {
  ListAppAuthProvider(this.firebaseAuth);

  final FirebaseAuth firebaseAuth;

  /// returns the current logged in user, null if no one is loggedIn
  User? get loggedInUser {
    return firebaseAuth.currentUser;
  }

  Stream<User?> get authState => firebaseAuth.idTokenChanges();

  Future<bool> isSomeoneLoggedIn() => authState.isEmpty;

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  String _switchErrorCode(String? errorCode) {
    // See https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
    // we cover only the possible errors in our app

    switch (errorCode) {
      //for security reasons, treat these cases as if they were the same
      case 'user-not-found':
      case 'wrong-password':
        return "Wrong credentials, please check and try again.";

      case 'invalid-email':
        return "The email address is not valid, please check and try again.";

      case 'user-disabled':
        return "Your user account has been disabled!";

      case 'account-exists-with-different-credential':
        //TODO handle by logging in with the existing account anyways
        return "This account was previously registered with an email address. Please login with email and password";
      case "invalid-credential":
        return "Error verifying credentials, please try again";

      default:
        return 'Unknown error!';
    }
  }

  //every method returns null when successfull

  Future<String?>? signupWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
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
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
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

  Future<String?>? loginViaGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
          scopes: <String>[
            'email',
            'https://www.googleapis.com/auth/contacts.readonly'
          ]).signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth == null) {
        return "Error while trying to obtain credentials";
      }

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      print(e);
      return _switchErrorCode(e.code);
    } on PlatformException catch (e) {
      // this happens when something is wrong in Firebase configuration, such as tokens
      // treated as an internal application error
      print(e.toString());
      return """
This login method is not available at the moment. Please try another one.
Sorry for the inconvenience""";
    }
  }

  Future<String?>? loginViaFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.accessToken == null) {
        return "Error while trying to obtain credentials";
      }

      final facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(facebookAuthCredential);
    } on FirebaseAuthException catch (e) {
      return _switchErrorCode(e.code);
    }
  }
}
