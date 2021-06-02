import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/friends.dart';
import 'package:mobile_applications/ui/home_lists.dart';

import 'package:mobile_applications/ui/login/login_screen.dart';
import 'package:mobile_applications/ui/settings_page.dart';
import 'package:mobile_applications/ui/settings_ui.dart';
import 'package:provider/provider.dart';
import 'package:mobile_applications/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  SharedPreferences.setMockInitialValues({"darkTheme": true});

  runApp(ListApp());
}

class ListApp extends StatelessWidget {
  /// Use MultiProvider once to add every provider we need to have in our app
  MultiProvider _appWithProviders(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChanger>(
          create: (_) => ThemeChanger(ThemeChanger.lightTheme),
        ),
        ChangeNotifierProvider<ListAppNavDrawerStateInfo>(
          create: (_) => ListAppNavDrawerStateInfo(),
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
    return _appWithProviders(context);
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  Future<ThemeData> setTheme(ThemeChanger themeChanger) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool value = _prefs.getBool('darkMode') ?? false;
    print("Value tema");
    print(value);
    ThemeData currentTheme =
        value ? ThemeChanger.darkTheme : ThemeChanger.lightTheme;
    return currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);

    ThemeData _currentTheme = themeChanger.currentTheme;

    /// The User instance watched from firebase
    final firebaseUser = context.watch<User?>();

    setTheme(themeChanger).then((value) {
      _currentTheme = value;
    });

    return MaterialApp(
        initialRoute: firebaseUser == null
            ? LoginScreen.routeName
            : ListHomePage.routeName,
        theme: _currentTheme,
        routes: {
          LoginScreen.routeName: (context) => LoginScreen(),
          ListHomePage.routeName: (context) => ListHomePage(),
          SettingsPage.routeName: (context) => SettingsPage(),
          FriendsPage.routeName: (context) => FriendsPage(),
          SettingsScreen.routeName: (context) => SettingsScreen()
        });
  }
}
