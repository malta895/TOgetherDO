import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:settings_ui/settings_ui.dart';

import 'app_drawer.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  final String title = 'Settings';
  // the current destination selected in the Drawer
  int _selectedDestination = 1;
  bool switchValue = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // leading: Icon(Icons.menu), // not needed, automatically added by Drawer
          title: Text(title),
          actions: [
            Icon(Icons.search),
          ],
        ),
        drawer: a_drawer(_selectedDestination, selectDestination, context),
        body: Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: SettingsList(
              sections: [
                SettingsSection(
                  title: 'Section',
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
  }

  void selectDestination(int index, route) {
    // Changes the state of the navigation drawer
    setState(() {
      _selectedDestination = index;
      Navigator.push(context, route);
    });
  }
}
