import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/ui/friends.dart';
import 'package:mobile_applications/ui/home_lists.dart';
import 'package:mobile_applications/ui/login_page.dart';
import 'package:mobile_applications/ui/profile.dart';
import 'package:mobile_applications/ui/settings_ui.dart';

Drawer appDrawer(_selectedDestination, selectDestination, context) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        InkWell(
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            )
          },
          child: DrawerHeader(
            margin: EdgeInsets.zero,
            decoration:
                BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/sample-profile.png"),
                    radius: 40.0,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'John Reed',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 20.0),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight + Alignment(0, .3),
                  child: Text(
                    'john.reed@mail.com',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
        ),
        ListTile(
          leading: Icon(Icons.list),
          title: Text('My Lists'),
          selected: _selectedDestination == 0,
          onTap: () => selectDestination(
              index: 0,
              route: MaterialPageRoute(builder: (context) => ListHomePage())),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          selected: _selectedDestination == 1,
          onTap: () => selectDestination(
              1, MaterialPageRoute(builder: (context) => SettingsScreen())),
        ),
        ListTile(
          leading: Icon(Icons.people),
          title: Text('Friends'),
          selected: _selectedDestination == 2,
          onTap: () => selectDestination(
              index: 2,
              route: MaterialPageRoute(builder: (context) => FriendsList())),
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
          selected: _selectedDestination == 2,
          onTap: () => selectDestination(
            index: 3,
            route: MaterialPageRoute(builder: (context) => LoginWidget()),
            pushReplacement:
                true, // cannot go back into application when we logout
          ), // TODO Perform logout logic too
        ),
      ],
    ),
  );
}
