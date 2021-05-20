import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/ui/app_drawer.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final String title = 'My profile';
  final int drawerSelectedDestination = 0;

  //TODO fetch actual data from backend
  //TODO implement password

  final CurrentUser =
      User("John", "Reed", "john.redd@mail.com", "john.redd@mail.com");

  final List<String> Properties = ["Name", "Email", "Password"];

  List<String> Elements = [];

  Widget _buildProfile(BuildContext context) {
    Elements = [
      CurrentUser.firstName + " " + CurrentUser.lastName,
      CurrentUser.email,
      CurrentUser.firstName
    ];
    return Container(
        child: Column(children: <Widget>[
      Container(
          width: double.infinity,
          height: 220.0,
          color: Colors.cyan[700],
          child: Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(alignment: const Alignment(1.2, 1.2), children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cG9ydHJhaXR8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80',
                  ),
                  radius: 70.0,
                ),
                IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    color: Colors.white,
                    onPressed: () {
                      print("Photo pushed");
                    })
              ]),
              SizedBox(
                height: 30.0,
              ),
              Text(
                "John Reed",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            ],
          ))),
      Expanded(
          child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, i) {
          return _buildRow(context, Elements[i], Properties[i]);
        },
      ))
    ]));
  }

  Widget _buildRow(BuildContext context, String Element, String Property) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          //                   <--- left side
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
            title: Text(
              Property,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.pinkAccent[700]),
            ),
            subtitle: Text(Element,
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            trailing: IconButton(
                icon: const Icon(Icons.create),
                onPressed: () {
                  print("Name pushed");
                })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // leading: Icon(Icons.menu), // not needed, automatically added by Drawer
            title: Text(title)),
        drawer: ListAppDrawer(),
        body: _buildProfile(context));
  }
}
