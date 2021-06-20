import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_applications/models/exception.dart';
import 'package:mobile_applications/models/user.dart';

import 'package:mobile_applications/services/user_manager.dart';

///A wrapper of FirebaseAuth, that provides a better interface to the login ui
///It is used with a Provider, get it with Provider.of(context).read<ListAppAuthProvider>()
class ListAppAuthProvider {
  ListAppAuthProvider(this.firebaseAuth);

  final FirebaseAuth firebaseAuth;
  ListAppUser? _loggedInListAppUser;

  /// returns the current logged in user, null if no one is loggedIn
  User? get loggedInUser {
    return firebaseAuth.currentUser;
  }

  /// returns the ListAppUser instance of the current logged in user
  ListAppUser get loggedInListAppUser {
    if (loggedInUser == null) {
      _loggedInListAppUser = null;
      throw ListAppException("No logged in user!");
    }
    return _loggedInListAppUser!;
  }

  Stream<User?> get authState => firebaseAuth.idTokenChanges();

  Future<bool> isSomeoneLoggedIn() => authState.isEmpty;

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  ///sets the current list app user retrieving the data from database
  ///if not present, it also creates it
  Future<void> _createListAppUser() async {
    final currentUser = loggedInUser;
    if (currentUser == null) {
      throw ListAppException("No user is logged in");
    }

    ListAppUser? listAppUser =
        await ListAppUserManager.instance.getUserByUid(currentUser.uid);

    if (listAppUser == null) {
      listAppUser = ListAppUser(
        email: currentUser.email!,
        databaseId: currentUser.uid,
        displayName: currentUser.displayName,
        phoneNumber: currentUser.phoneNumber,
        profilePictureURL: currentUser.photoURL,
      );

      await ListAppUserManager.instance
          .persistInstance(listAppUser, currentUser.uid);
    }
    _loggedInListAppUser = listAppUser;
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
      log(userCredential.toString());

      _createListAppUser();

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

      log(userCredential.toString());
      print(userCredential);

      _createListAppUser();

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

      log(userCredential.toString());

      _createListAppUser();

      return null;
    } on FirebaseAuthException catch (e) {
      log(e.message ?? 'null error message');
      return _switchErrorCode(e.code);
    } on PlatformException catch (e) {
      // this happens when something is wrong in Firebase configuration, such as tokens
      // treated as an internal application error
      print(e.toString());
      log(e.message.toString());
      return """
This login method is not available at the moment. Please try another one.
Sorry for the inconvenience""";
    }
  }

  Future<String?>? loginViaFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      final loginAccessToken = loginResult.accessToken;

      if (loginAccessToken == null) {
        return "Error while trying to obtain credentials";
      }

      final facebookAuthCredential =
          FacebookAuthProvider.credential(loginAccessToken.token);

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(facebookAuthCredential);
      log(userCredential.toString());

      _createListAppUser();
    } on FirebaseAuthException catch (e) {
      return _switchErrorCode(e.code);
    }
  }
}
