import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/friendship.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/friendship_manager.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/new_friends.dart';
import 'package:mobile_applications/ui/notification_badge.dart';
import 'package:mobile_applications/ui/notification_page.dart';

class FriendsPage extends StatefulWidget {
  static final String routeName = "/friends";

  @override
  _FriendsList createState() => _FriendsList();
}

class _FriendsList extends State<FriendsPage> {
  final String title = 'Friends';

  //TODO fetch actual data from backend
  final ListAppUser _user = ListAppUser(
      databaseId: "shdopjf",
      firstName: "Luca",
      lastName: "Maltagliati",
      email: "luca.malta@mail.com",
      username: "malta",
      friends: {
        ListAppUser(
            databaseId: 'sdifasp',
            firstName: "Lorenzo",
            lastName: "Amici",
            email: "lorenzo.amici@mail.com",
            username: "lorenzo.amici@mail.com"),
      });

  Widget _buildListItems(BuildContext context) {
    final Future<List<ListAppUser?>> friendsFrom = ListAppFriendshipManager
        .instance
        .getFriendsFromByUid("9LUBLCszUrU4mukuRWhHFS2iexL2");

    final Future<List<ListAppUser?>> friendsTo = ListAppFriendshipManager
        .instance
        .getFriendsToByUid("9LUBLCszUrU4mukuRWhHFS2iexL2");

    return FutureBuilder(
        future: Future.wait([friendsFrom, friendsTo]),
        builder: (BuildContext context,
            AsyncSnapshot<List<List<ListAppUser?>>> snapshot) {
          if (snapshot.hasData) {
            final allFriends = snapshot.data![0] + snapshot.data![1];
            return ListView.builder(
              itemCount: snapshot.data![0].length + snapshot.data![1].length,
              itemBuilder: (context, i) {
                return _buildRow(context, allFriends[i]!);
              },
            );
          } else {
            return Container();
          }
        });

    /*return ListView.builder(
      itemCount: _user.friends.length,
      itemBuilder: (context, i) {
        return _buildRow(context, friendsFrom.elementAt(i));
      },
    );*/
  }

  Widget _buildRow(BuildContext context, ListAppUser friend) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
          title: Text(
            friend.fullName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(friend.email),
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
          title: Text(title),
          actions: [NotificationBadge()],
        ),
        drawer: ListAppNavDrawer(FriendsPage.routeName),
        body: _buildListItems(context),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewFriendPage()),
            )
          },
          icon: Icon(Icons.add),
          label: Text('ADD FRIEND'),
        ));
  }
}
