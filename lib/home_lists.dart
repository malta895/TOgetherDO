import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'list_view_page.dart';
import 'list_item.dart';

//TODO fetch actual data from backend
final List<ListItem> items = [
  MessageItem("First list", "Description of the first list"),
  MessageItem("Second list", "Description of the second list"),
  MessageItem("USA trip", "From NY to San Francisco"),
  MessageItem("Christmas presents", "Christmas 2020"),
];

class ListHomePage extends StatefulWidget {
  @override
  _ListHomePage createState() => _ListHomePage();
}

class _ListHomePage extends State<ListHomePage> {
  final String title = 'Home Page - ListApp';
  // the current destination selected in the Drawer
  int _selectedDestination = 0;

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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  // TODO put little profile here?
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: Stack(children: <Widget>[
                    Positioned(
                        bottom: 12.0,
                        left: 16.0,
                        child: Text("Flutter Step-by-Step",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500))),
                  ])),
              Divider(
                height: 1,
                thickness: 1,
              ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text('My Lists'),
                selected: _selectedDestination == 0,
                onTap: () => selectDestination(0),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                selected: _selectedDestination == 1,
                onTap: () => selectDestination(1),
              ),
              ListTile(
                // TODO remove this if we put the profile
                leading: Icon(Icons.person),
                title: Text('My Profile'),
                selected: _selectedDestination == 2,
                onTap: () => selectDestination(2),
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Friends'),
                selected: _selectedDestination == 3,
                onTap: () => selectDestination(3),
              ),
            ],
          ),
        ),
        body: ListView.builder(
          // Let the ListView know how many items it needs to build.
          itemCount: items.length,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (context, index) {
            final ListItem item = items[index];

            return ListTile(
              title: item.buildTitle(context),
              subtitle: item.buildSubtitle(context),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListViewRoute(item)
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => {
            // TODO implement list creation logic
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
