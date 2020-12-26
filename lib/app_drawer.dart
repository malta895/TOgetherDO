import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Drawer a_drawer(_selectedDestination, selectDestination) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          // TODO put little profile here?
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: Stack(children: <Widget>[
            Positioned(bottom: 80.0, left: 16.0, child: const FlutterLogo()),
            Positioned(
                bottom: 30.0,
                left: 16.0,
                child: Text("John Reed",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500))),
            Positioned(
                bottom: 10.0,
                left: 16.0,
                child: Text("john.reed@mail.com",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500))),
            Positioned(
                bottom: 100.0,
                left: 16.0,
                child: ListTile(
                  title: Text('ciao'),
                  selected: _selectedDestination == 2,
                  onTap: () => selectDestination(2),
                )),
          ]),
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
          selected: _selectedDestination == 3,
          onTap: () => selectDestination(3),
        ),
      ],
    ),
  );
}
