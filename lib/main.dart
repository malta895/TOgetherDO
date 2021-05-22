import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/ui/home_lists.dart';
import 'package:mobile_applications/ui/login/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile_applications/ui/theme.dart';

import 'package:firebase_core/firebase_core.dart';

void main() {
  // NOTE this stuff comes from login example, not sure if it is needed
  // SystemChrome.setSystemUIOverlayStyle(
  //     SystemUiOverlayStyle(
  //     systemNavigationBarColor:
  //         SystemUiOverlayStyle.dark.systemNavigationBarColor,
  //   ),
  // );
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ListApp());
}

class ListApp extends StatelessWidget {
  // initialize Firebase application
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  final ThemeData _darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.cyan[700],
      accentColor: Colors.pinkAccent,
      appBarTheme: AppBarTheme(
        centerTitle: true,
      ));

  final ThemeData _lightTheme = ThemeData(
      primaryColor: Colors.cyan[700],
      accentColor: Colors.pinkAccent[700],
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        centerTitle: true,
      ));

  /// Use MultiProvider once to add every provider we need to have in our app
  MultiProvider _appWithProviders() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChanger>(
          create: (_) => ThemeChanger(_lightTheme),
        ),
      ],
      child: MaterialAppWithTheme(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Initialize Flutter Fire (firebase)
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // FIXME create a proper error page
            return Text(
                "An error has occurred while connecting to the server.");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return _appWithProviders();
          }

          return Text("loading"); //TODO replace with something better
        });
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
        initialRoute: ListAppAuth.instance.isSomeoneLoggedIn()
            ? ListHomePage.routeName
            : LoginScreen.routeName,
        theme: theme.getTheme(),
        routes: {
          LoginScreen.routeName: (context) => LoginScreen(),
          ListHomePage.routeName: (context) => ListHomePage()
        });
  }
}
