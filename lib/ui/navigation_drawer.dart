import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/ui/friends.dart';
import 'package:mobile_applications/ui/home_lists.dart';
import 'package:mobile_applications/ui/login/login_screen.dart';
import 'package:mobile_applications/ui/profile.dart';
import 'package:mobile_applications/ui/settings_ui.dart';
import 'package:provider/provider.dart';

class ListAppNavDrawerStateInfo with ChangeNotifier {
  static final Map<String, int> destinationsRouteNamesAndIndexes = {
    ListHomePage.routeName: 0,
    SettingsScreen.routeName: 1,
    FriendsPage.routeName: 2,
  };

  int? _currentDrawerIndex = 0;

  int? get currentDrawerIndex => _currentDrawerIndex;

  set currentDrawerIndex(int? drawerIndex) {
    _currentDrawerIndex = drawerIndex;
    notifyListeners();
  }
}

class ListAppNavDrawer extends StatelessWidget {
  final String _currentRouteName;
  ListAppNavDrawer(this._currentRouteName);

  final Map<String, int> _destinationsRouteNamesAndIndexes = {
    ListHomePage.routeName: 0,
    SettingsScreen.routeName: 1,
    FriendsPage.routeName: 2,
  };

  ListTile _generateMenuItem(
      {required Icon icon,
      required BuildContext context,
      required String title,
      required int? currentDrawerIndex,
      required String destinationRouteName,
      bool pushReplacement = false,
      void Function()? onTap}) {
    return ListTile(
        leading: icon,
        title: Text(title),
        selected: _destinationsRouteNamesAndIndexes[destinationRouteName]
                ?.compareTo(currentDrawerIndex ?? -1) ==
            0,
        onTap: () {
          onTap?.call();

          Navigator.of(context).pop();

          Provider.of<ListAppNavDrawerStateInfo>(context, listen: false)
                  .currentDrawerIndex =
              _destinationsRouteNamesAndIndexes[destinationRouteName];

          if (_currentRouteName == destinationRouteName) return;

          if (pushReplacement) {
            Navigator.pushReplacementNamed(context, destinationRouteName);
          } else {
            Navigator.pushNamed(context, destinationRouteName);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    int? currentDrawerIndex =
        Provider.of<ListAppNavDrawerStateInfo>(context).currentDrawerIndex ??
            _destinationsRouteNamesAndIndexes[_currentRouteName];

    print("build " + currentDrawerIndex.toString());

    return Drawer(
      child: ListView(
        children: <Widget>[
          InkWell(
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              )
            },
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor),
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
                          color: Theme.of(context).primaryColor,
                          fontSize: 20.0),
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
          _generateMenuItem(
            icon: Icon(Icons.list),
            context: context,
            currentDrawerIndex: currentDrawerIndex,
            title: "My Lists",
            destinationRouteName: ListHomePage.routeName,
          ),
          _generateMenuItem(
            icon: Icon(Icons.settings),
            context: context,
            currentDrawerIndex: currentDrawerIndex,
            title: "Settings",
            destinationRouteName: SettingsScreen.routeName,
          ),
          _generateMenuItem(
            icon: Icon(Icons.people),
            context: context,
            currentDrawerIndex: currentDrawerIndex,
            title: "Friends",
            destinationRouteName: FriendsPage.routeName,
          ),
          _generateMenuItem(
              icon: Icon(Icons.logout),
              context: context,
              title: "Logout",
              currentDrawerIndex: currentDrawerIndex,
              destinationRouteName: LoginScreen.routeName,
              pushReplacement: true,
              onTap: () => context.read<ListAppAuthProvider>().logout()),
        ],
      ),
    );
  }
}
