import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/theme.dart';

import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static final String routeName = "/settings_ui";
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _lightTheme = true;

  //Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void onThemeChanged(bool value, ThemeChanger themeChanger) async {
    (value)
        ? themeChanger.setCurrentTheme(ThemeChanger.darkTheme)
        : themeChanger.setCurrentTheme(ThemeChanger.lightTheme);

    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  Future<bool> setTheme(ThemeChanger themeChanger) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool value = _prefs.getBool('darkMode') ?? false;
    print("Value in settings");
    print(value);
    /*(value)
        ? themeChanger.setCurrentTheme(ThemeChanger.darkTheme)
        : themeChanger.setCurrentTheme(ThemeChanger.lightTheme);*/

    return value;
  }

  /* @override
  void initState() {
    super.initState();
    _lightTheme = _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('counter') ?? 0);
    });
  } */

  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);

    /*setTheme(themeChanger).then((value) {
      _lightTheme = value;
      print("Light theme dentro funzione");
      print(_lightTheme);
    });*/

    return FutureBuilder(
        future: setTheme(themeChanger),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            _lightTheme = snapshot.data!;
          }
          return Scaffold(
              appBar: AppBar(title: Text('Settings UI')),
              drawer: ListAppNavDrawer(SettingsScreen.routeName),
              body: Column(children: [
                Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      //                   <--- left side
                      color: Colors.grey,
                      width: 0.8,
                    ))),
                    child: ListTile(
                        title: Text(
                          "Dark theme",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).accentColor),
                        ),
                        subtitle: Text("Toggle light or dark theme",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        trailing: Switch(
                            value: _lightTheme,
                            onChanged: (bool value) {
                              setState(() {
                                _lightTheme = value;
                              });
                              onThemeChanged(value, themeChanger);
                            }))),
                Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      //                   <--- left side
                      color: Colors.grey,
                      width: 0.8,
                    ))),
                    child: ListTile(
                        title: Text(
                          "Sync contacts",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).accentColor),
                        ),
                        subtitle: Text("Synchronize your contacts",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        trailing: IconButton(
                            icon: const Icon(Icons.sync_outlined),
                            onPressed: () {
                              print("Sync pushed");
                            }))),
                Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      //                   <--- left side
                      color: Colors.grey,
                      width: 0.8,
                    ))),
                    child: ListTile(
                        title: Text(
                          "Allow Notifications",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).accentColor),
                        ),
                        subtitle: Text(
                            "Allow or disallow notifications for the app",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        trailing: Switch(
                            value: _lightTheme, onChanged: (bool value) {}))),
              ]));
        });
  }

  /* Scaffold(
        appBar: AppBar(title: Text('Settings UI')),
        drawer: ListAppNavDrawer(SettingsScreen.routeName),
        body: Padding(
          padding: EdgeInsets.only(top: 10),
          child: SettingsList(
            sections: [
              SettingsSection(title: 'General', tiles: [
                SettingsTile(
                  title: 'Sync contacts',
                  leading: Icon(Icons.sync_outlined),
                  onPressed: (BuildContext context) {},
                )
              ]),
              SettingsSection(
                title: 'Personalization',
                tiles: [
                  SettingsTile.switchTile(
                    title: 'Dark theme',
                    leading: Icon(Icons.dark_mode_outlined),
                    switchValue: _lightTheme,
                    onToggle: (bool value) {
                      setState(() {
                        _lightTheme = value;
                      });
                      onThemeChanged(value, themeChanger);
                    },
                  ),
                ],
              ),
            ],
          ),
        )); */
}
