import 'package:flutter/material.dart';
import 'package:mobile_applications/services/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static final String routeName = "/settings_ui";
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

/*class _SettingsScreenState extends State<SettingsScreen> {
  bool _lightTheme = true;

  /*void onThemeChanged(bool value, ThemeChanger themeChanger) async {
    (value)
        ? themeChanger.setCurrentTheme(ThemeChanger.darkTheme)
        : themeChanger.setCurrentTheme(ThemeChanger.lightTheme);

    var prefs = await SharedPreferencesManager.getSharedPreferencesInstance();
    await prefs.setBool('darkMode', value);
  }*/

  Future<bool> setTheme() async {
    SharedPreferences _prefs =
        await SharedPreferencesManager.getSharedPreferencesInstance();
    bool value = _prefs.getBool('darkMode') ?? false;

    return value;
  }

  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);

    setTheme().then((value) {
      _lightTheme = value;
    });

    return FutureBuilder(
        future: setTheme(),
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
                        trailing:
                            Switch(value: true, onChanged: (bool value) {}))),
              ]));
        });
  }
}*/

class _SettingsScreenState extends State<SettingsScreen> {
  Future<PermissionStatus> provaNotifiche() async {
    Permission.camera.request();
    return Permission.notification.status;
  }

  @override
  Widget build(BuildContext context) {
    provaNotifiche().then((value) {
      print(value);
    });
    return Scaffold(
        appBar: AppBar(title: Text('Settings')),
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
                  trailing: Consumer<ThemeChanger>(
                    builder: (context, notifier, child) => Switch(
                        key: Key("theme setting"),
                        value: !notifier.darkThemeBool,
                        onChanged: (bool value) {
                          notifier.toggleTheme();
                        }),
                  ))),
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
                  "Manage Notifications",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).accentColor),
                ),
                subtitle: Text("Allow or disallow notifications for the app",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                onTap: () => {AppSettings.openNotificationSettings()},
              )),
        ]));
  }
}
