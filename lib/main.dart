import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './ui/home_lists.dart';
import './ui/theme.dart';
import 'package:mobile_applications/ui/home_lists.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  ThemeData _darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.cyan[700],
      accentColor: Colors.pinkAccent,
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
      builder: (_) => ThemeChanger(_lightTheme),
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
