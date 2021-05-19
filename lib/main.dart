import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_applications/ui/login/login_page.dart';
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

  // TODO conditionally show login page or home lists page, if the user is logged in or not
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

  ChangeNotifierProvider<ThemeChanger> _appWithThemeBuilder() {
    return ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(_lightTheme),
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
            // TODO replace with something better, maybe create a common error/waiting widget and populate with the according message
            return Text(
                "An error has occurred while connecting to the server.");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return _appWithThemeBuilder();
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
      // home: ListHomePage(),
      // TODO anziche mostrare direttamente la pagina di login inserire un meccanismo per controllare
      // se l'utente è già loggato e rimandarlo alla home page nel caso
      home: LoginPage(),
      theme: theme.getTheme(),
    );
  }
}
