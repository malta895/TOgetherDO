import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'app_drawer.dart';
import 'theme.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  final String title = 'Settings';
  // the current destination selected in the Drawer
  int _selectedDestination = 1;
  bool _darkMode = false;

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

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  //Loading counter value on start
  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = (prefs.getBool('darkMode') ?? false);
    });
  }

  //Incrementing counter after click
  _setDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = !(prefs.getBool('darkMode') ?? false);
      prefs.setBool('darkMode', _darkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: app_drawer(_selectedDestination, selectDestination, context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: Colors.grey,
                width: 0.8,
              ))),
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                value: _darkMode,
                onChanged: (bool value) {
                  if (value) {
                    _themeChanger.setTheme(_darkTheme);
                  } else {
                    _themeChanger.setTheme(_lightTheme);
                  }
                  _setDarkMode();
                },
                secondary: const Icon(Icons.bedtime),
              ))
        ],
      ),
    );
  }

  /* Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // leading: Icon(Icons.menu), // not needed, automatically added by Drawer
            title: Text(title)),
        drawer: a_drawer(_selectedDestination, selectDestination, context),
        body: Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: SettingsList(
              sections: [
                SettingsSection(
                  title: 'General',
                  tiles: [
                    SettingsTile(
                      title: 'Language',
                      subtitle: 'English',
                      leading: Icon(Icons.language),
                      onPressed: (BuildContext context) {},
                    ),
                    SettingsTile.switchTile(
                      title: 'Use fingerprint',
                      leading: Icon(Icons.fingerprint),
                      switchValue: true,
                      onToggle: (bool value) {},
                    ),
                  ],
                ),
              ],
            )));
  } */

  void selectDestination(int index, route) {
    // Changes the state of the navigation drawer
    setState(() {
      _selectedDestination = index;
      Navigator.push(context, route);
    });
  }
}
