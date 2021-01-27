import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_lists.dart';
import 'theme.dart';
import 'settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  ThemeData _darkTheme = ThemeData(
      primaryColor: Colors.cyan[700],
      accentColor: Colors.pinkAccent[700],
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        centerTitle: true,
      ));

  ThemeData _lightTheme = ThemeData(
      primaryColor: Colors.cyan[700],
      accentColor: Colors.pinkAccent[700],
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        centerTitle: true,
      ));
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      builder: (_) => ThemeChanger(_darkTheme),
      child: new MaterialAppWithTheme(),
    ); // TODO switch to login page
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      home: ListHomePage(),
      theme: theme.getTheme(),
    );
  }
}
