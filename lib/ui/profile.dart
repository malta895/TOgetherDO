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
  static final String routeName = "/profile";

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String title = 'My profile';

  late ListAppUser _loggedInListAppUser;
  late String _currentUsername;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loggedInListAppUser =
        context.read<ListAppAuthProvider>().loggedInListAppUser!;

    _currentUsername = _loggedInListAppUser.username ?? '';
  }

  Future<void> _changeProfilePhoto(PickedFile? imageFile) async {
    if (imageFile == null) return;
    await ListAppUserManager.instance
        .changeProfilePicture(_loggedInListAppUser, imageFile);
  }

  Future<void> _changeUserName(BuildContext context) async {
    final textFieldController = TextEditingController(
        text:
            context.read<ListAppAuthProvider>().loggedInListAppUser?.username ??
                '');
    return await showDialog(
        context: context,
        builder: (context) {
          String _newUsername = '';
          // The stateful widget is necessary to keep updated the OK button enabled or disabled based on the current username value
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Enter a new username'),
              content: TextField(
                controller: textFieldController,
                decoration: InputDecoration(hintText: "New name"),
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

                      setState(() {
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

  //TODO implement password

  Widget _buildProfile(BuildContext context) {
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
                _loggedInListAppUser.profilePictureURL == null
                    ? CircleAvatar(
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
                    color: Colors.white,
                    onPressed: () async {
                      final PickedFile? imageFile = await _imagePicker.getImage(
                          source: ImageSource.gallery);

                      await _changeProfilePhoto(imageFile);
                      setState(() {});
                    }),
              ]),
              SizedBox(
                height: 30.0,
              ),
              Text(
                _loggedInListAppUser.fullName,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            ],
          ))),
      Expanded(
          child: ListView(
        children: [_buildUsernameRow(context), _buildEmailRow(context)],
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

  Widget _buildEmailRow(BuildContext context) {
    return _buildRow(
      context: context,
      title: 'Email',
      text: Text(_loggedInListAppUser.email,
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
        decoration: BoxDecoration(
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
        drawer: ListAppNavDrawer(ProfilePage.routeName),
        body: _buildProfile(context));
  }
}
