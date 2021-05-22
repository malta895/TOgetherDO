import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:mobile_applications/ui/app_drawer.dart';
import 'package:mobile_applications/ui/new_list.dart';
import 'package:mobile_applications/models/user.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsList createState() => _FriendsList();
}

class _FriendsList extends State<FriendsList> {
  final String title = 'Friends';
  // the current destination selected in the Drawer
  final int _drawerSelectedDestination = 2;

  //TODO fetch actual data from backend

  final User _user =
      User("Luca", "Maltagliati", "luca.malta@mail.com", "malta");

  Widget _buildListItems(BuildContext context) {
    _user.addFriendship(
      Friendship(
          User("Lorenzo", "Amici", "lorenzo.amici@mail.com",
              "lorenzo.amici@mail.com"),
          true),
    ); // TODO remove when data are fetched from backend
    return ListView.builder(
      itemCount: _user.friendships.length,
      itemBuilder: (context, i) {
        return _buildRow(context, _user.friendships.elementAt(i).user);
      },
    );
  }

  Widget _buildRow(BuildContext context, User friend) {
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
        drawer: ListAppDrawer(),
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
