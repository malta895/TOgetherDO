import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:mobile_applications/ui/list_view_page.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/new_list.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/ui/notifications.dart';

class ListHomePage extends StatefulWidget {
  static final String routeName = "/home";
  static final String humanReadableName = "My Lists";

  @override
  _ListHomePage createState() => _ListHomePage();
}

class _ListHomePage extends State<ListHomePage> {
  final String title = 'ListApp';

  //TODO fetch actual data from backend
  final List<ListAppList> _aLists = [
    ListAppList(
        name: "First list", description: "Description of the first list"),
    ListAppList(
        name: "Second list", description: "Description of the second list"),
    ListAppList(name: "USA trip", description: "From NY to San Francisco"),
    ListAppList(name: "Christmas presents", description: "Christmas 2020"),
  ];

  /*@override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences sharedPrefs =
        await SharedPreferencesManager.getSharedPreferencesInstance();
    setState(() {
      myEmailController.text = (sharedPrefs.getString(SharedPreferencesManager.emailKey) ?? "");
      _isNotification = (sharedPrefs.getBool(SharedPreferencesManager.notificationKey) ??false);
      myTotalItemController.text = (sharedPrefs.getInt(SharedPreferencesManager.totalItems) ?? 0).toString();
    });
  }*/

  Widget _buildListItems(BuildContext context) {
    return ListView.builder(
      itemCount: _aLists.length,
      itemBuilder: (context, i) {
        return _buildRow(context, _aLists[i]);
      },
    );
  }

  Widget _buildRow(BuildContext context, ListAppList aList) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          //                   <--- left side
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
          key: Key("Item tile"),
          title: Text(
            aList.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(aList.description ?? ''),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ListViewRoute(aList)),
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                )
              },
              //onPressed: () => print("ciao"),
            ),
          ],
        ),
        drawer: ListAppNavDrawer(ListHomePage.routeName),
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
