import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'list_view_page.dart';
import 'app_drawer.dart';
import 'new_list.dart';
import 'models/alist.dart';

class ListHomePage extends StatefulWidget {
  @override
  _ListHomePage createState() => _ListHomePage();
}

class _ListHomePage extends State<ListHomePage> {
  final String title = 'ListApp';
  // the current destination selected in the Drawer
  int _selectedDestination = 0;

  //TODO fetch actual data from backend
  final List<AList> _aLists = [
    AList(1, "First list", "Description of the first list"),
    AList(2, "Second list", "Description of the second list"),
    AList(3, "USA trip", "From NY to San Francisco"),
    AList(4, "Christmas presents", "Christmas 2020"),
  ];

  Widget _buildListItems(BuildContext context) {
    return ListView.builder(
      itemCount: _aLists.length,
      itemBuilder: (context, i) {
        return _buildRow(context, _aLists[i]);
      },
    );
  }

  Widget _buildRow(BuildContext context, AList aList) {
    return ListTile(
      title: Text(
        aList.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(aList.description),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => ListViewRoute(aList)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.amber,
          appBarTheme: AppBarTheme(
            centerTitle: true,
          )),
      title: title,
      home: Scaffold(
        appBar: AppBar(
          // leading: Icon(Icons.menu), // not needed, automatically added by Drawer
          title: Text(title),
          actions: [
            Icon(Icons.search),
          ],
        ),
        drawer: a_drawer(_selectedDestination, selectDestination),
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
        ),
      ),
    );
  }

  void selectDestination(int index) {
    // Changes the state of the navigation drawer
    setState(() {
      _selectedDestination = index;
    });
  }
}
