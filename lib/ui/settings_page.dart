import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = "/settings_ui";
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

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
        appBar: AppBar(title: const Text('Settings')),
        drawer: const ListAppNavDrawer(routeName: SettingsScreen.routeName),
        body: Column(children: [
          Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                //                   <--- left side
                color: Colors.grey,
                width: 0.8,
              ))),
              child: ListTile(
                  title: Text(
                    "Dark theme",
                    key: const Key("text"),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).accentColor),
                  ),
                  subtitle: const Text("Toggle light or dark theme",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  trailing: Consumer<ThemeChanger>(
                    builder: (context, notifier, child) => Switch(
                        key: const Key("theme setting"),
                        value: !notifier.darkThemeBool,
                        onChanged: (bool value) {
                          notifier.toggleTheme();
                        }),
                  ))),
/*          Container(
              decoration: const BoxDecoration(
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
                  subtitle: const Text("Synchronize your contacts",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  trailing: IconButton(
                      icon: const Icon(Icons.sync_outlined),
                      onPressed: () {
                        print("Sync pushed");
                      }))), */
          Container(
              decoration: const BoxDecoration(
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
                subtitle: const Text(
                    "Allow or disallow notifications for the app",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                onTap: () => {AppSettings.openNotificationSettings()},
              )),
        ]));
  }
}
