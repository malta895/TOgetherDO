import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_applications/models/user.dart';

import 'package:mobile_applications/services/user_manager.dart';

///A wrapper of FirebaseAuth, that provides a better interface to the login ui
///It is used with a Provider, get it with Provider.of(context).read<ListAppAuthProvider>()
class ListAppAuthProvider with ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  ListAppUser? _loggedInListAppUser;

  /// returns the current logged in user, null if no one is loggedIn
  User? get loggedInUser {
    return firebaseAuth.currentUser;
  }

  /// returns the ListAppUser instance of the current logged in user
  ListAppUser? get loggedInListAppUser {
    return _loggedInListAppUser;
  }

  Future<ListAppUser?> getLoggedInListAppUser() async {
    final user = loggedInUser;
    if (user == null) return null;
    await _createListAppUser(user);
    return _loggedInListAppUser;
  }

  static int _initializationCounter = 0;

  ListAppAuthProvider(this.firebaseAuth) {
    // Subscribe to login/logout events
    firebaseAuth.idTokenChanges().listen((User? user) async {
      if (user == null) {
        _loggedInListAppUser = null;
      } else {
        await _createListAppUser(user);
      }
      notifyListeners();
    });

    _initializationCounter++;
    print('AuthProvider initialized $_initializationCounter times.');

    // Subscribe to user changes, e.g. username change
    ListAppUserManager.instance.addListener(() async {
      final uid = _loggedInListAppUser?.databaseId;
      if (uid != null) {
        _loggedInListAppUser =
            await ListAppUserManager.instance.getUserByUid(uid);
      }
    });
  }

  Stream<User?> get authState {
    return firebaseAuth.idTokenChanges();
  }

  Future<bool> isSomeoneLoggedIn() => authState.isEmpty;

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  ///sets the current list app user retrieving the data from database
  ///if not present, it also creates it
  Future<void> _createListAppUser(User firebaseUser) async {
    ListAppUser? listAppUser =
        await ListAppUserManager.instance.getUserByUid(firebaseUser.uid);

    if (listAppUser == null) {

      final notificationToken = await FirebaseMessaging.instance.getToken();

      listAppUser = ListAppUser(
        isNew: true,
        email: firebaseUser.email!,
        databaseId: firebaseUser.uid,
        displayName: firebaseUser.displayName,
        phoneNumber: firebaseUser.phoneNumber,
        profilePictureURL: firebaseUser.photoURL,
        notificationTokens: notificationToken == null ? {} : {notificationToken},
      );

      await ListAppUserManager.instance.saveInstance(listAppUser);
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
    } on FirebaseAuthException catch (e) {
      return _switchErrorCode(e.code);
    }
  }
}
