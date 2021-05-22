import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/ui/mixins/stateful_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'app_drawer.dart';
import 'theme.dart';

class SettingsPage extends StatefulWidget {
  static final String routeName = "/settings";
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  final String title = 'Settings';
  bool _darkMode = false;

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
      drawer: ListAppDrawer(),
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
                    _themeChanger.currentTheme = ThemeChanger.darkTheme;
                  } else {
                    _themeChanger.currentTheme = ThemeChanger.darkTheme;
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
        drawer: ListAppDrawer(),
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

}
