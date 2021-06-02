import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  static final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.cyan[700],
      accentColor: Colors.pinkAccent[400],
      appBarTheme: AppBarTheme(
        centerTitle: true,
      ));

  static final ThemeData lightTheme = ThemeData(
      primaryColor: Colors.cyan[700],
      accentColor: Colors.pinkAccent[700],
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
