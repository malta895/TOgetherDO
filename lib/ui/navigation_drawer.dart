import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
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

class ListAppNavDrawer extends StatelessWidget {
  final String routeName;
  const ListAppNavDrawer({required this.routeName});

  static const destinationsRouteNamesAndIndexes = {
    ListsPage.routeName: 0,
    SettingsScreen.routeName: 1,
    FriendsPage.routeName: 2,
    ProfilePage.routeName: null,
  };

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
        selected: destinationsRouteNamesAndIndexes[destinationRouteName]
                ?.compareTo(currentDrawerIndex ?? -1) ==
            0,
        onTap: () {
          onTap?.call();

          Navigator.of(context).pop();

          Provider.of<ListAppNavDrawerStateInfo>(context, listen: false)
                  .currentDrawerIndex =
              destinationsRouteNamesAndIndexes[destinationRouteName];

          if (routeName == destinationRouteName) return;

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
            destinationsRouteNamesAndIndexes[routeName];

    return Drawer(
      child: ListView(
        children: <Widget>[
          const _UserDetailsInkWell(),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          _buildMenuItem(
            icon: const Icon(Icons.list),
            context: context,
            currentDrawerIndex: currentDrawerIndex,
            title: "My Lists",
            destinationRouteName: ListsPage.routeName,
          ),
          _buildMenuItem(
            icon: const Icon(Icons.settings),
            context: context,
            currentDrawerIndex: currentDrawerIndex,
            title: "Settings",
            destinationRouteName: SettingsScreen.routeName,
          ),
          _buildMenuItem(
            icon: const Icon(Icons.people),
            context: context,
            currentDrawerIndex: currentDrawerIndex,
            title: "Friends",
            destinationRouteName: FriendsPage.routeName,
          ),
          _buildMenuItem(
              icon: const Icon(Icons.logout),
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

class _UserDetailsInkWell extends StatefulWidget {
  const _UserDetailsInkWell({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserDetailsInkWellState();
}

class _UserDetailsInkWellState extends State<_UserDetailsInkWell> {
  Stream<ListAppUser?>? _userStream;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('BUILD NAVIGATION DRAWER');

    _userStream = Provider.of<ListAppAuthProvider>(context)
        .getLoggedInListAppUserStream();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Provider.of<ListAppNavDrawerStateInfo>(context, listen: false)
                .currentDrawerIndex =
            ListAppNavDrawer
                .destinationsRouteNamesAndIndexes[ProfilePage.routeName];

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage()),
        );
      },
      child: DrawerHeader(
        margin: EdgeInsets.zero,
        decoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: StreamBuilder<ListAppUser?>(
            stream: _userStream,
            builder:
                (BuildContext context, AsyncSnapshot<ListAppUser?> snapshot) {
              ListAppUser? listAppUser;
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Container();
                case ConnectionState.active:
                case ConnectionState.done:
                  listAppUser = snapshot.data;
                  return Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CircleAvatar(
                          backgroundImage: () {
                            final String? photoURL =
                                listAppUser?.profilePictureURL;

                            if (photoURL != null) return NetworkImage(photoURL);

                            return const AssetImage(
                                "assets/sample-profile.png");
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
                        alignment:
                            Alignment.centerRight + const Alignment(0, .3),
                        child: Text(
                          listAppUser?.email ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  );
              }
            }),
      ),
    );
  }
}
