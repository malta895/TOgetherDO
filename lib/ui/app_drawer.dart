import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/ui/friends.dart';
import 'package:mobile_applications/ui/home_lists.dart';
import 'package:mobile_applications/ui/login/login_screen.dart';
import 'package:mobile_applications/ui/profile.dart';
import 'package:mobile_applications/ui/settings_ui.dart';
import 'package:provider/provider.dart';

class ListAppDrawerStateInfo with ChangeNotifier {
  int _currentDrawerIndex = 0;

  int get currentDrawerIndex => _currentDrawerIndex;

  set currentDrawerIndex(int drawerIndex) {
    print(_currentDrawerIndex);
    print(drawerIndex);
    _currentDrawerIndex = drawerIndex;
    notifyListeners();
  }
}

class ListAppDrawer extends StatelessWidget {
  final String _currentRouteName;
  ListAppDrawer(this._currentRouteName);

  final Map<String, int> _destinationsRouteNamesAndIndexes = {
    ListHomePage.routeName: 0,
    SettingsScreen.routeName: 1,
    FriendsPage.routeName: 2,
    LoginScreen.routeName: 3
  };

  /// helper function to change the state and the current page when selecting a new destination in the drawer
  void _selectDestination(
      {required int index,
      required BuildContext context,
      required String destinationRouteName,
      bool pushReplacement = false}) {
    Navigator.of(context).pop();

    Provider.of<ListAppDrawerStateInfo>(context, listen: false)
        .currentDrawerIndex = index;

    if (_currentRouteName == destinationRouteName) return;

    if (pushReplacement) {
      Navigator.pushReplacementNamed(context, destinationRouteName);
    } else {
      Navigator.pushNamed(context, destinationRouteName);
    }
  }

  ListTile _generateMenuItem(
      {required Icon icon,
      required BuildContext context,
      required String title,
      required String destinationRouteName,
      bool pushReplacement = false,
      void Function()? callback}) {
    return ListTile(
        leading: icon,
        title: Text(title),
        selected: Provider.of<ListAppDrawerStateInfo>(context, listen: false)
                .currentDrawerIndex ==
            _destinationsRouteNamesAndIndexes[_currentRouteName],
        onTap: () {
          callback?.call();

          Navigator.of(context).pop();

          Provider.of<ListAppDrawerStateInfo>(context, listen: false)
                  .currentDrawerIndex =
              _destinationsRouteNamesAndIndexes[destinationRouteName]!;

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
    int currentDrawerIndex =
        Provider.of<ListAppDrawerStateInfo>(context).currentDrawerIndex;

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
            title: "My Lists",
            destinationRouteName: ListHomePage.routeName,
          ),
          _generateMenuItem(
            icon: Icon(Icons.settings),
            context: context,
            title: "Settings",
            destinationRouteName: SettingsScreen.routeName,
          ),
          _generateMenuItem(
            icon: Icon(Icons.people),
            context: context,
            title: "Friends",
            destinationRouteName: FriendsPage.routeName,
          ),
          _generateMenuItem(
              icon: Icon(Icons.logout),
              context: context,
              title: "Logout",
              destinationRouteName: LoginScreen.routeName,
              pushReplacement: true,
              callback: () => context.read<ListAppAuthProvider>().logout()),
        ],
      ),
    );
  }
}
