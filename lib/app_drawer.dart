import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Drawer a_drawer (_selectedDestination, selectDestination){
  return Drawer(
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
        );

}
