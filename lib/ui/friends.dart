import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/new_list.dart';
import 'package:mobile_applications/models/user.dart';

class FriendsPage extends StatefulWidget {
  static final String routeName = "/friends";

  @override
  _FriendsList createState() => _FriendsList();
}

class _FriendsList extends State<FriendsPage> {
  final String title = 'Friends';

  //TODO fetch actual data from backend
  final ListAppUser _user = ListAppUser(
      firstName: "Luca",
      lastName: "Maltagliati",
      email: "luca.malta@mail.com",
      username: "malta",
      friends: {
        ListAppUser(
            firstName: "Lorenzo",
            lastName: "Amici",
            email: "lorenzo.amici@mail.com",
            username: "lorenzo.amici@mail.com"),
      });

  Widget _buildListItems(BuildContext context) {
    return ListView.builder(
      itemCount: _user.friends.length,
      itemBuilder: (context, i) {
        return _buildRow(context, _user.friends.elementAt(i));
      },
    );
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
          actions: [
            Icon(Icons.search),
          ],
        ),
        drawer: ListAppNavDrawer(FriendsPage.routeName),
        body: _buildListItems(context),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewList()),
            )
          },
          icon: Icon(Icons.add),
          label: Text('NEW LIST'),
        ));
  }
}
