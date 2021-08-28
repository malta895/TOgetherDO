import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/friends_page.dart';
import 'package:mobile_applications/ui/lists_page.dart';
import 'package:mobile_applications/ui/login/login_screen.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/notification_page.dart';
import 'package:mobile_applications/ui/settings_page.dart';
import 'package:mobile_applications/ui/theme.dart';
import 'package:provider/provider.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  FlutterAppBadger.updateBadgeCount(1);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  ManagerConfig.initialize(
    firebaseFirestore: FirebaseFirestore.instance,
    firebaseStorage: FirebaseStorage.instance,
    firebaseFunctions: FirebaseFunctions.instanceFor(region: 'europe-west6'),
    firebaseMessaging: FirebaseMessaging.instance,
  );

  FirebaseMessaging.onBackgroundMessage(_messageHandler);

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
  final _materialAppKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final consumer = Consumer<ThemeChanger>(
        builder: (context, ThemeChanger notifier, child) {
      return StreamBuilder<User?>(
          initialData: context.read<ListAppAuthProvider>().loggedInUser,
          stream: context.read<ListAppAuthProvider>().authState,
          builder: (context, snapshot) {
            return MaterialApp(
              navigatorKey: _materialAppKey,
              debugShowCheckedModeBanner: false,
              initialRoute: snapshot.hasData
                  ? ListsPage.routeName
                  : LoginScreen.routeName,
              theme: notifier.darkThemeBool ? lightTheme : darkTheme,
              routes: {
                LoginScreen.routeName: (context) => LoginScreen(),
                ListsPage.routeName: (context) => const ListsPage(),
                FriendsPage.routeName: (context) => const FriendsPage(),
                SettingsScreen.routeName: (context) => SettingsScreen(),
                NotificationPage.routeName: (context) =>
                    const NotificationPage(),
              },
            );
          });
    });

    // when the app is closed the notification is shown
    ManagerConfig.firebaseMessaging
        ?.getInitialMessage()
        .then((RemoteMessage? message) {
      Future.doWhile(() {
        final materialAppCurrentState = _materialAppKey.currentState;
        if (message == null || message.notification == null) return false;
        if (materialAppCurrentState == null) return true;
        Navigator.of(materialAppCurrentState.context)
            .pushNamed(NotificationPage.routeName);
        return false;
      });
    });

    // when we open the app from a notification show the notifications page directly
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        Future.doWhile(() {
          final materialAppCurrentState = _materialAppKey.currentState;
          if (message.notification == null) return false;
          if (materialAppCurrentState == null) return true;
          Navigator.of(materialAppCurrentState.context)
              .pushNamed(NotificationPage.routeName);
          return false;
        });
      },
    );
    return consumer;
  }
}
