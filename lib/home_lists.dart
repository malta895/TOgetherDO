import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'list_view_page.dart';
import 'list_item.dart';
import 'app_drawer.dart';

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
  final String title = 'ListApp';
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
        drawer: a_drawer(_selectedDestination, selectDestination),
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
