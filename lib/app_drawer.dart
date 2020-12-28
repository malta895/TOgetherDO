import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Drawer a_drawer(_selectedDestination, selectDestination) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        InkWell(
          onTap: () {
            print("tapped"); // TODO: add navigation to profile page
          },
          child: DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'http://www.bbk.ac.uk/mce/wp-content/uploads/2015/03/8327142885_9b447935ff.jpg'),
                    radius: 40.0,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'John Reed',
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight + Alignment(0, .3),
                  child: Text(
                    'john.reed@mail.com',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          leading: Icon(Icons.people),
          title: Text('Friends'),
          selected: _selectedDestination == 2,
          onTap: () => selectDestination(2),
        ),
      ],
    ),
  );
}
