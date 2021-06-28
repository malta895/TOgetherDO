import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/ui/friends.dart';
import 'package:mobile_applications/ui/lists_page.dart';
import 'package:mobile_applications/ui/login/login_screen.dart';
import 'package:mobile_applications/ui/profile.dart';
import 'package:mobile_applications/ui/settings_ui.dart';
import 'package:provider/provider.dart';

class ListAppNavDrawerStateInfo with ChangeNotifier {
  int? _currentDrawerIndex = 0;

  int? get currentDrawerIndex => _currentDrawerIndex;

  set currentDrawerIndex(int? drawerIndex) {
    _currentDrawerIndex = drawerIndex;
    notifyListeners();
  }
}

class ListAppNavDrawer extends StatefulWidget {
  final String currentRouteName;
  ListAppNavDrawer(this.currentRouteName);

  @override
  _ListAppNavDrawerState createState() => _ListAppNavDrawerState();
}

class _ListAppNavDrawerState extends State<ListAppNavDrawer> {
  Future<ListAppUser?>? _userFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _userFuture =
        Provider.of<ListAppAuthProvider>(context).getLoggedInListAppUser();
  }

  final Map<String, int?> _destinationsRouteNamesAndIndexes = {
    ListsPage.routeName: 0,
    SettingsScreen.routeName: 1,
    FriendsPage.routeName: 2,
    ProfilePage.routeName: null,
  };

  Widget _buildUserDetailsInkWell(BuildContext context) {
    return FutureBuilder<ListAppUser?>(
        future: _userFuture,
        builder: (BuildContext context, AsyncSnapshot<ListAppUser?> snapshot) {
          ListAppUser? listAppUser = snapshot.data;

          return InkWell(
            onTap: () {
              Provider.of<ListAppNavDrawerStateInfo>(context, listen: false)
                      .currentDrawerIndex =
                  _destinationsRouteNamesAndIndexes[ProfilePage.routeName];

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              );
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
                      backgroundImage: () {
                        final String? photoURL =
                            listAppUser?.profilePictureURL;

                        if (photoURL != null) return NetworkImage(photoURL);

                        return AssetImage("assets/sample-profile.png");
                      }() as ImageProvider,
                      radius: 40.0,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      listAppUser?.fullName ?? "",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20.0),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight + Alignment(0, .3),
                    child: Text(
                      listAppUser?.email ?? '',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  ListTile _buildMenuItem(
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

          if (widget.currentRouteName == destinationRouteName) return;

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
            _destinationsRouteNamesAndIndexes[widget.currentRouteName];

    return Drawer(
      child: ListView(
        children: <Widget>[
          //TODO choose which DrawerHeader we should use
          //_buildUserAccountsDrawerHeader(context),
          _buildUserDetailsInkWell(context),
          Divider(
            height: 1,
            thickness: 1,
          ),
          _buildMenuItem(
            icon: Icon(Icons.list),
            context: context,
            currentDrawerIndex: currentDrawerIndex,
            title: "My Lists",
            destinationRouteName: ListsPage.routeName,
          ),
          _buildMenuItem(
            icon: Icon(Icons.settings),
            context: context,
            currentDrawerIndex: currentDrawerIndex,
            title: "Settings",
            destinationRouteName: SettingsScreen.routeName,
          ),
          _buildMenuItem(
            icon: Icon(Icons.people),
            context: context,
            currentDrawerIndex: currentDrawerIndex,
            title: "Friends",
            destinationRouteName: FriendsPage.routeName,
          ),
          _buildMenuItem(
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
