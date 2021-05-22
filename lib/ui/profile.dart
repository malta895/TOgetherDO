import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/ui/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ProfilePage extends StatefulWidget {
  static final String routeName = "/profile";

  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final String title = 'My profile';
  final int drawerSelectedDestination = 0;

  //TODO fetch actual data from backend
  //TODO implement password

  Widget _buildProfile(BuildContext context) {
    final _currentUser = context.read<ListAppAuthProvider>().loggedInUser;
    List<Tuple2<String, String>> _elements = [
      Tuple2('Name', _currentUser?.displayName ?? ''),
      Tuple2('Email', _currentUser?.email ?? ''),
      // Tuple2('Username', _currentUser!.displayName)
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
                  // TODO replace with profile image
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
        itemCount: _elements.length,
        itemBuilder: (context, i) {
          return _buildRow(context, _elements[i].item1, _elements[i].item2);
        },
      ))
    ]));
  }

  Widget _buildRow(BuildContext context, String key, String value) {
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
              key,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.pinkAccent[700]),
            ),
            subtitle: Text(value,
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
        drawer: ListAppDrawer(ProfilePage.routeName),
        body: _buildProfile(context));
  }
}
