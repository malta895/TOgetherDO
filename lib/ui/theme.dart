import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.cyan[900],
    accentColor: Colors.pinkAccent[400],
    textTheme: TextTheme(
      headline1: TextStyle(
          fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
    ));

ThemeData lightTheme = ThemeData(
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

class ThemeChanger extends ChangeNotifier {
  final String key = "darkTheme";
  SharedPreferences? _prefs;
  late bool _darkThemeBool = true;

  bool get darkThemeBool => _darkThemeBool;

  ThemeChanger() {
    _darkThemeBool = true;
    _loadFromPrefs();
  }

  toggleTheme() {
    _darkThemeBool = !_darkThemeBool;
    notifyListeners();
    _saveToPrefs();
  }

  _initPrefs() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _darkThemeBool = _prefs?.getBool(key) ?? false;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _prefs?.setBool(key, _darkThemeBool);
  }

  /*ThemeData _currentTheme;

  ThemeChanger(this._currentTheme);

  ThemeData get currentTheme => _currentTheme;

  setCurrentTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }*/
}
