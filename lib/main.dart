import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile_applications/ui/notification_page.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/friends.dart';
import 'package:mobile_applications/ui/lists_page.dart';
import 'package:mobile_applications/ui/login/login_screen.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/settings_ui.dart';
import 'package:mobile_applications/ui/theme.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  // NOTE this stuff comes from login example, not sure if it is needed
  // SystemChrome.setSystemUIOverlayStyle(
  //     SystemUiOverlayStyle(
  //     systemNavigationBarColor:
  //         SystemUiOverlayStyle.dark.systemNavigationBarColor,
  //   ),
  // )
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(_MultiProviderApp());
}

class _MultiProviderApp extends StatelessWidget {
  /// Use MultiProvider once to add every provider we need to have in our app
  MultiProvider _appWithProviders(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChanger>(
          create: (_) => ThemeChanger(),
        ),
        ChangeNotifierProvider<ListAppNavDrawerStateInfo>(
          create: (_) => ListAppNavDrawerStateInfo(),
        ),
        ChangeNotifierProvider(
            create: (_) => ListAppAuthProvider(FirebaseAuth.instance)),
        ChangeNotifierProvider(create: (_) => ListAppUserManager.instance),
      ],
      child: _MaterialAppWithTheme(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _appWithProviders(context);
  }
}

class _MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeChanger>(
        builder: (context, ThemeChanger notifier, child) {
      return StreamBuilder<User?>(
        initialData: context.read<ListAppAuthProvider>().loggedInUser,
        stream: context.read<ListAppAuthProvider>().authState,
        builder: (context, snapshot) {
          return MaterialApp(
              initialRoute: snapshot.hasData
                  ? ListsPage.routeName
                  : LoginScreen.routeName,
              theme: notifier.darkThemeBool ? lightTheme : darkTheme,
              routes: {
                LoginScreen.routeName: (context) => LoginScreen(),
                ListsPage.routeName: (context) => ListsPage(),
                FriendsPage.routeName: (context) => FriendsPage(),
                SettingsScreen.routeName: (context) => SettingsScreen(),
              });
        },
      );
    });
  }
}
