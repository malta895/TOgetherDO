import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'models/alist.dart';
import 'app_drawer.dart';
import 'new_list.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsList createState() => _FriendsList();
}

class _FriendsList extends State<FriendsList> {
  final String title = 'Friends';
  // the current destination selected in the Drawer
  int _selectedDestination = 2;

  //TODO fetch actual data from backend
  final List<FriendList> _friends = [
    FriendList("Lorenzo Amici", "lorenzo.amici@mail.com"),
    FriendList("Luca Maltagliati", "luca.malta@mail.com")
  ];

  Widget _buildListItems(BuildContext context) {
    return ListView.builder(
      itemCount: _friends.length,
      itemBuilder: (context, i) {
        return _buildRow(context, _friends[i]);
      },
    );
  }

  Widget _buildRow(BuildContext context, FriendList FList) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
          title: Text(
            FList.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(FList.email),
          onTap: () {
            print(FList.name);
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
        drawer: a_drawer(_selectedDestination, selectDestination, context),
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

  void selectDestination(int index, route) {
    // Changes the state of the navigation drawer
    setState(() {
      _selectedDestination = index;
      Navigator.push(context, route);
    });
  }
}
