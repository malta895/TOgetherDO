import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/new_friends_page.dart';
import 'package:mobile_applications/ui/notification_badge.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  static const String routeName = "/friends";

  const FriendsPage();

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsPage> {
  static const String title = 'Friends';

  late final Future<List<ListAppUser>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _friendsFuture = _fetchFriends();
  }

  Future<List<ListAppUser>> _fetchFriends() async {
    final loggedInListAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();
    if (loggedInListAppUser == null) return [];
    return ListAppUserManager.instance.getFriends(loggedInListAppUser);
  }

  Widget _buildListItems(BuildContext context) {
    return FutureBuilder<List<ListAppUser>>(
        future: _friendsFuture,
        builder: (BuildContext context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return Container();
            case ConnectionState.done:
              final friends = snapshot.data!;
              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, i) {
                  return _buildRow(context, friends[i]);
                },
              );
          }
        });
  }

  Widget _buildRow(BuildContext context, ListAppUser friend) {
    return Container(
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
          title: Text(
            friend.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(friend.username ?? ''),
          onTap: () {
            print(friend.fullName);
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Icon(Icons.menu), // not needed, automatically added by Drawer
        title: const Text(title),
        actions: [NotificationBadge()],
      ),
      drawer: const ListAppNavDrawer(routeName: FriendsPage.routeName),
      body: _buildListItems(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewFriendPage()),
          )
        },
        icon: const Icon(Icons.add),
        label: const Text('ADD FRIEND'),
      ),
    );
  }
}
