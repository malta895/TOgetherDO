import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/*class ProfilePage extends StatelessWidget {
  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your profile'),
        ),
        body: Column(children: <Widget>[
          Container(
              width: double.infinity,
              height: 220.0,
              color: Colors.cyan[700],
              child: Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cG9ydHJhaXR8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80',
                    ),
                    radius: 50.0,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    "John Reed",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  )
                ],
              ))),
          Container(
              width: double.infinity,
              child: Container(
                height: 80px,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Name",
                            style: TextStyle(
                              color: Colors.pinkAccent[700],
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "John Reed",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.create),
                            tooltip: 'Increase volume by 10')
                      ],
                    )
                  ])),
          Container(
              width: double.infinity,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Name",
                      style: TextStyle(
                        color: Colors.pinkAccent[700],
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "John Reed",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ])),
        ]));}} */

/* DIVISORE */

/* Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  child: Container(
                      width: double.infinity,
                      height: 220.0,
                      color: Colors.cyan[700],
                      child: Center(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cG9ydHJhaXR8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80',
                            ),
                            radius: 50.0,
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Text(
                            "John Reed",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          )
                        ],
                      )))),
              /* Padding(
                  padding: EdgeInsets.all(20.0),
                  child:  */

            //   ListView.separated(
            //     padding: const EdgeInsets.all(8),
            //     itemCount: entries.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       return Container(
            //         height: 50,
            //         color: Colors.amber[colorCodes[index]],
            //         child: Center(child: Text('Entry ${entries[index]}')),
            //       );
            //     },
            //     separatorBuilder: (BuildContext context, int index) =>
            //         const Divider(),
            //   )
            // ])); FINO A QUI FIRST DRAFT*/

/* Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Container(
                              width: double.infinity,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Name",
                                      style: TextStyle(
                                        color: Colors.pinkAccent[700],
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      "John Reed",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ])),
                          onTap: () {
                            print("Tapped on email");
                          },
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        InkWell(
                          child: Container(
                              width: double.infinity,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Email",
                                      style: TextStyle(
                                        color: Colors.pinkAccent[700],
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      "john.reed@mail.com",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ])),
                          onTap: () {
                            print("Tapped on email");
                          },
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        InkWell(
                          child: Container(
                              width: double.infinity,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Password",
                                      style: TextStyle(
                                        color: Colors.pinkAccent[700],
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      "**********",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ])),
                          onTap: () {
                            print("Tapped on password");
                          },
                        ),
                      ]))
            ]));
  }
}*/

import 'dart:ui';

import 'package:mobile_applications/ui/app_drawer.dart';
import 'package:mobile_applications/models/user.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final String title = 'My profile';
  // TODO modify this because in the drawer there isn't a destination for the profile
  int _selectedDestination = 4;

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
        drawer: appDrawer(_selectedDestination, selectDestination, context),
        body: _buildProfile(context));
  }

  void selectDestination(int index, route) {
    // Changes the state of the navigation drawer
    setState(() {
      _selectedDestination = index;
      Navigator.push(context, route);
    });
  }
}
