import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  static final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.cyan[700],
      accentColor: Colors.pinkAccent[400],
      textTheme: TextTheme(
        headline1: TextStyle(
            fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
      ));

  static final ThemeData lightTheme = ThemeData(
      primaryColor: Colors.cyan[700],
      accentColor: Colors.pinkAccent[700],
      textTheme: TextTheme(
        headline1: TextStyle(
            fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      errorColor: Colors.black,
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        centerTitle: true,
      ));

  ThemeData _currentTheme;

  ThemeChanger(this._currentTheme);

  ThemeData get currentTheme => _currentTheme;

  setCurrentTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
