import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/friendship_manager.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/new_friends_page.dart';
import 'package:mobile_applications/ui/notification_badge.dart';

class FriendsPage extends StatefulWidget {
  static const String routeName = "/friends";

  const FriendsPage();

  @override
  _FriendsList createState() => _FriendsList();
}

class _FriendsList extends State<FriendsPage> {
  static const String title = 'Friends';

  late final Future<List<ListAppUser?>> _friendsFrom;
  late final Future<List<ListAppUser?>> _friendsTo;

  @override
  void initState() {
    super.initState();
    // TODO remove hardcoded value
    _friendsFrom = ListAppFriendshipManager.instance
        .getFriendsFromByUid("9LUBLCszUrU4mukuRWhHFS2iexL2");

    // TODO remove hardcoded value
    _friendsTo = ListAppFriendshipManager.instance
        .getFriendsToByUid("9LUBLCszUrU4mukuRWhHFS2iexL2");
  }

  Widget _buildListItems(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([_friendsFrom, _friendsTo]),
        builder: (BuildContext context,
            AsyncSnapshot<List<List<ListAppUser?>>> snapshot) {
          if (snapshot.hasData) {
            final friendsFrom = snapshot.data![0];
            final friendsTo = snapshot.data![1];

            final allFriends = friendsFrom.followedBy(friendsTo).toList();
            return ListView.builder(
              itemCount: friendsFrom.length + friendsTo.length,
              itemBuilder: (context, i) {
                return _buildRow(context, allFriends[i]!);
              },
            );
          } else {
            return Container();
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
