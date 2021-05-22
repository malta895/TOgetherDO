import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/ui/home_lists.dart';

import 'package:mobile_applications/ui/login/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile_applications/ui/theme.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // NOTE this stuff comes from login example, not sure if it is needed
  // SystemChrome.setSystemUIOverlayStyle(
  //     SystemUiOverlayStyle(
  //     systemNavigationBarColor:
  //         SystemUiOverlayStyle.dark.systemNavigationBarColor,
  //   ),
  // );
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(ListApp());
}

class ListApp extends StatelessWidget {

  /// Use MultiProvider once to add every provider we need to have in our app
  MultiProvider _appWithProviders() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChanger>(
          create: (_) => ThemeChanger(ThemeChanger.lightTheme),
        ),
        Provider<ListAppAuthProvider>(
            create: (_) => ListAppAuthProvider(FirebaseAuth.instance)),
        StreamProvider(
          create: (context) => context.read<ListAppAuthProvider>().authState,
          //initially no user is logged in
          initialData: null,
        )
      ],
      child: MaterialAppWithTheme(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _appWithProviders();
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);

    /// The User instance watched from firebase
    final firebaseUser = context.watch<User?>();

    return MaterialApp(
        initialRoute: firebaseUser == null
            ? ListHomePage.routeName
            : LoginScreen.routeName,
        theme: themeChanger.currentTheme,
        routes: {
          LoginScreen.routeName: (context) => LoginScreen(),
          ListHomePage.routeName: (context) => ListHomePage()
        });
  }
}
