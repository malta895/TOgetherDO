import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_applications/models/exception.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/notification_badge.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = "/profile";

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String title = 'My profile';

  late ListAppUser _loggedInListAppUser;
  late String _currentUsername;
  late String _currentFirstName;
  late String _currentLastName;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loggedInListAppUser =
        context.read<ListAppAuthProvider>().loggedInListAppUser!;

    _currentUsername = _loggedInListAppUser.username ?? '';
    _currentFirstName = _loggedInListAppUser.firstName;
    _currentLastName = _loggedInListAppUser.lastName;
  }

  Future<void> _changeProfilePhoto(XFile? imageFile) async {
    if (imageFile == null) return;
    await ListAppUserManager.instance
        .changeProfilePicture(_loggedInListAppUser, imageFile);
  }

  Future<void> _changeUserName(BuildContext context) async {
    final textFieldController = TextEditingController(
        text:
            context.read<ListAppAuthProvider>().loggedInListAppUser?.username ??
                '');
    final oldUsername =
        context.read<ListAppAuthProvider>().loggedInListAppUser?.username;
    return await showDialog(
        context: context,
        builder: (context) {
          String _newUsername = '';
          // The stateful widget is necessary to keep updated the OK button enabled or disabled based on the current username value
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Enter a new username'),
              content: TextField(
                controller: textFieldController,
                decoration: const InputDecoration(hintText: "New name"),
                onChanged: (value) {
                  setDialogState(() {
                    _newUsername = value;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red, primary: Colors.white),
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor:
                          (_newUsername.isEmpty || _newUsername == oldUsername)
                              ? Colors.grey
                              : Colors.green,
                      primary: Colors.white),
                  child: const Text('OK'),
                  onPressed: () async {
                    if (_newUsername.isEmpty || _newUsername == oldUsername) {
                      return;
                    }

                    try {
                      await ListAppUserManager.instance
                          .updateUsername(_newUsername, _loggedInListAppUser);

                      setState(() {
                        _loggedInListAppUser.username = _newUsername;
                        _currentUsername = _newUsername;
                      });

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

  Future<void> _changeFirstName(BuildContext context) async {
    final textFieldController = TextEditingController(
        text: context
                .read<ListAppAuthProvider>()
                .loggedInListAppUser
                ?.firstName ??
            '');
    final oldFirstName =
        context.read<ListAppAuthProvider>().loggedInListAppUser?.firstName;
    return await showDialog(
        context: context,
        builder: (context) {
          String _newFirstName = '';
          // The stateful widget is necessary to keep updated the OK button enabled or disabled based on the current username value
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Enter a new first name'),
              content: TextField(
                controller: textFieldController,
                decoration: const InputDecoration(hintText: "New name"),
                onChanged: (value) {
                  setDialogState(() {
                    _newFirstName = value;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red, primary: Colors.white),
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: (_newFirstName.isEmpty ||
                              _newFirstName == oldFirstName)
                          ? Colors.grey
                          : Colors.green,
                      primary: Colors.white),
                  child: const Text('OK'),
                  onPressed: () async {
                    if (_newFirstName.isEmpty ||
                        _newFirstName == oldFirstName) {
                      return;
                    }

                    {
                      await ListAppUserManager.instance
                          .updateFirstName(_newFirstName, _loggedInListAppUser);

                      setState(() {
                        _loggedInListAppUser.displayName = null;
                        _loggedInListAppUser.firstName = _newFirstName;
                        _currentFirstName = _newFirstName;
                      });

                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          });
        });
  }

  Future<void> _changeLastName(BuildContext context) async {
    final textFieldController = TextEditingController(
        text:
            context.read<ListAppAuthProvider>().loggedInListAppUser?.lastName ??
                '');
    final oldLastName =
        context.read<ListAppAuthProvider>().loggedInListAppUser?.lastName;
    return await showDialog(
        context: context,
        builder: (context) {
          String _newLastName = '';
          // The stateful widget is necessary to keep updated the OK button enabled or disabled based on the current username value
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Enter a new Last name'),
              content: TextField(
                controller: textFieldController,
                decoration: const InputDecoration(hintText: "New name"),
                onChanged: (value) {
                  setDialogState(() {
                    _newLastName = value;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red, primary: Colors.white),
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor:
                          (_newLastName.isEmpty || _newLastName == oldLastName)
                              ? Colors.grey
                              : Colors.green,
                      primary: Colors.white),
                  child: const Text('OK'),
                  onPressed: () async {
                    if (_newLastName.isEmpty || _newLastName == oldLastName) {
                      return;
                    }

                    {
                      await ListAppUserManager.instance
                          .updateLastName(_newLastName, _loggedInListAppUser);

                      setState(() {
                        _loggedInListAppUser.displayName = null;
                        _loggedInListAppUser.lastName = _newLastName;
                        _currentLastName = _newLastName;
                      });

                      Navigator.pop(context);
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
    return Container(
        child: Column(children: <Widget>[
      Container(
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            //                   <--- left side
            color: Colors.grey,
            width: 0.8,
          ))),
          width: double.infinity,
          height: 220.0,
          /*decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset
                .bottomCenter, // 10% of the width, so there are ten blinds.
            colors: <Color>[
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ],
          )),*/
          //color: Colors.cyan[700],
          child: Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(alignment: const Alignment(1.3, 1.3), children: [
                _loggedInListAppUser.profilePictureURL == null
                    ? const CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/sample-profile.png'),
                        radius: 70.0,
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(
                            _loggedInListAppUser.profilePictureURL!),
                        radius: 70.0),
                IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    color: Theme.of(context).accentColor,
                    onPressed: () async {
                      final XFile? imageFile = await _imagePicker.pickImage(
                          source: ImageSource.gallery);

                      await _changeProfilePhoto(imageFile);
                      setState(() {});
                    }),
              ]),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius:
                        const BorderRadius.all(Radius.circular(12.0))),
                child: Text(
                  _loggedInListAppUser.displayName,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ))),
      Expanded(
          child: ListView(
        children: [
          _buildUsernameRow(context),
          _buildFirstNameRow(context),
          _buildLastNameRow(context),
          _buildEmailRow(context)
        ],
      ))
    ]));
  }

  Widget _buildUsernameRow(BuildContext context) {
    return _buildRow(
        context: context,
        title: 'Username',
        text: Text(_currentUsername,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.headline1!.color)),
        onModify: () {
          _changeUserName(context);
        });
  }

  Widget _buildFirstNameRow(BuildContext context) {
    return _buildRow(
        context: context,
        title: 'First name',
        text: Text(_currentFirstName,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.headline1!.color)),
        onModify: () {
          _changeFirstName(context);
        });
  }

  Widget _buildLastNameRow(BuildContext context) {
    return _buildRow(
        context: context,
        title: 'Last name',
        text: Text(_currentLastName,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.headline1!.color)),
        onModify: () {
          _changeLastName(context);
        });
  }

  Widget _buildEmailRow(BuildContext context) {
    return _buildRow(
      context: context,
      title: 'Email',
      text: Text(_loggedInListAppUser.email ?? '',
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.headline1!.color)),
    );
  }

  Widget _buildRow(
      {required BuildContext context,
      required String title,
      required Text text,
      Function()? onModify}) {
    return Container(
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
          //                   <--- left side
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.pinkAccent[700]),
          ),
          subtitle: text,
          trailing: IconButton(
            icon: const Icon(Icons.create),
            onPressed: onModify,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // leading: Icon(Icons.menu), // not needed, automatically added by Drawer
            title: Text(title),
            actions: [NotificationBadge()]),
        drawer: const ListAppNavDrawer(routeName: ProfilePage.routeName),
        body: _buildProfile(context));
  }
}
