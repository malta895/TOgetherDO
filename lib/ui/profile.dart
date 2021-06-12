import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
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
          return AlertDialog(
            title: Text('Enter a new name'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  newUserName = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "New name"),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.red, primary: Colors.white),
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.green, primary: Colors.white),
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc('Em8N2g4nu40EfOhQtwO0')
                        .update({
                      'firstName': newUserName!.split(" ")[0],
                      'lastName': newUserName!.split(" ")[1]
                    });
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _changeEmail(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter a new email'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  newEmail = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "New email"),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.red, primary: Colors.white),
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.green, primary: Colors.white),
                child: Text('OK'),
                onPressed: () {
                  /*setState(() {
                    if (EmailValidator.validate(newEmail!) == true) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc('Em8N2g4nu40EfOhQtwO0')
                          .update({'email': newEmail!});
                      Navigator.pop(context);
                    } else {}
                  })*/
                  ;
                },
              ),
            ],
          );
        });
  }

  String? newUserName;
  String? newEmail;

  //TODO fetch actual data from backend
  //TODO implement password

  Widget _buildProfile(BuildContext context) {
    //final _currentUser = context.read<ListAppAuthProvider>().loggedInUser;

    final firebaseUser = context.read<ListAppAuthProvider>().loggedInUser!;
    final Future<ListAppUser?> currentUserFuture =
        ListAppUserManager.instance.getUserByEmail(firebaseUser.email!);

    /* List<Tuple2<String, String>> _elements = [
      Tuple2('Name', _currentUser?.displayName ?? ''),
      Tuple2('Email', _currentUser?.email ?? ''),
      // Tuple2('Username', _currentUser!.displayName)
    ]; */

    return FutureBuilder<ListAppUser?>(
        future: currentUserFuture,
        builder: (BuildContext context, AsyncSnapshot<ListAppUser?> snapshot) {
          ListAppUser? currentUser = snapshot.data;
          List<Tuple3<String, String, Function>> _elements = [
            Tuple3('Name', currentUser!.fullName, _changeUserName),
            Tuple3('Email', currentUser.email, _changeEmail),
            // Tuple2('Username', _currentUser!.displayName)
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
                      currentUser.fullName,
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
                return _buildRow(context, _elements[i].item1,
                    _elements[i].item2, _elements[i].item3);
              },
            ))
          ]));
        });
  }

  Widget _buildRow(
      BuildContext context, String key, String value, Function function) {
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
                  function(context);
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
