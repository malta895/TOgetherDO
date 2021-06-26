import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_applications/models/exception.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
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

  TextEditingController _textFieldController = TextEditingController();

  Future<void> _changeUserName(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          String _newUsername = '';
          // The stateful widget is necessary to keep updated the OK button enabled or disabled based on the current username value
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Enter a new username'),
              content: TextField(
                controller: _textFieldController,
                decoration: InputDecoration(hintText: "New name"),
                onChanged: (value) {
                  setState(() {
                    _newUsername = value;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red, primary: Colors.white),
                  child: Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor:
                          _newUsername.isEmpty ? Colors.grey : Colors.green,
                      primary: Colors.white),
                  child: Text('OK'),
                  onPressed: () async {
                    if (_newUsername.isEmpty) {
                      return;
                    }

                    try {
                      final currentUser =
                          context.read<ListAppAuthProvider>().loggedInUser;

                      await ListAppUserManager.instance
                          .updateUsername(_newUsername, currentUser?.uid);

                      Navigator.pop(context);
                    } on ListAppException catch (e) {
                      await Fluttertoast.showToast(
                          msg: e.message,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                ),
              ],
            );
          });
        });
  }


  //TODO implement password

  Widget _buildProfile(BuildContext context) {
    final listAppUser =
        context.read<ListAppAuthProvider>().loggedInListAppUser!;

    List<Tuple3<String, String, Function?>> _elements = [
      Tuple3('Username', listAppUser.username ?? '', _changeUserName),
      Tuple3('Email', listAppUser.email, null),
      // Tuple2('Username', _listAppUser!.displayName)
    ];

    return Container(
        child: Column(children: <Widget>[
      Container(
          width: double.infinity,
          height: 220.0,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset
                .bottomCenter, // 10% of the width, so there are ten blinds.
            colors: <Color>[
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ],
          )),
          //color: Colors.cyan[700],
          child: Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(alignment: const Alignment(1.2, 1.2), children: [
                listAppUser.profilePictureURL == null
                    ? CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/sample-profile.png'),
                        radius: 70.0,
                      )
                    : CircleAvatar(
                        backgroundImage:
                            NetworkImage(listAppUser.profilePictureURL!),
                        radius: 70.0),
                IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    color: Colors.white,
                    onPressed: () {
                      // TODO change propic
                      print("Photo pushed");
                    })
              ]),
              SizedBox(
                height: 30.0,
              ),
              Text(
                listAppUser.fullName,
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
          return _buildRow(context, _elements[i].item1, _elements[i].item2,
              _elements[i].item3);
        },
      ))
    ]));
  }

  Widget _buildRow(
      BuildContext context, String key, String value, Function? function) {
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
                  function?.call(context);
                })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // leading: Icon(Icons.menu), // not needed, automatically added by Drawer
            title: Text(title)),
        drawer: ListAppNavDrawer(ProfilePage.routeName),
        body: _buildProfile(context));
  }
}
