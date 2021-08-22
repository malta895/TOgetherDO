import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_applications/models/exception.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/friendship_manager.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/notification_badge.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  static const String routeName = "/friends";

  const FriendsPage();

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsPage> {
  static const String title = 'Friends';

  Future<Map<ListAppUser, bool>>? _friendsFuture;
  late final ListAppUser? _loggedInListAppUser;

  @override
  void initState() {
    super.initState();

    context.read<ListAppAuthProvider>().getLoggedInListAppUser().then((value) {
      setState(() {
        _loggedInListAppUser = value;
        _friendsFuture = _fetchFriends();
      });
    });
  }

  Future<Map<ListAppUser, bool>> _fetchFriends() async {
    final acceptedFriends =
        await ListAppUserManager.instance.getFriends(_loggedInListAppUser!);

    final friends = Map<ListAppUser, bool>.fromIterable(
      acceptedFriends,
      value: (_) => true,
    );

    final pendingFriends = await ListAppUserManager.instance
        .getPendingFriends(_loggedInListAppUser!);

    return friends
      ..addAll(Map<ListAppUser, bool>.fromIterable(
        pendingFriends,
        value: (_) => false,
      ));
  }

  Future<void> _addNewFriend(BuildContext context) async {
    final addFriendTextFieldController = TextEditingController();
    final additionResult = await showDialog<bool>(
        context: context,
        builder: (context) {
          String _emailUsername = '';
          // The stateful widget is necessary to keep updated the OK button enabled or disabled based on the current username value
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add Friend',
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Type the email or the username of the person you want to add as a friend. A request will be sent and you will be notified when they will accept.",
                    textScaleFactor: 0.8,
                  ),
                  TextField(
                    enableSuggestions: false,
                    keyboardType: TextInputType.emailAddress,
                    controller: addFriendTextFieldController,
                    decoration:
                        const InputDecoration(hintText: "Email/Username"),
                    onChanged: (value) {
                      setDialogState(() {
                        _emailUsername = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red, primary: Colors.white),
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                TextButton(
                  key: const Key("add_friend_button"),
                  style: TextButton.styleFrom(
                      backgroundColor:
                          _emailUsername.isEmpty ? Colors.grey : Colors.green,
                      primary: Colors.white),
                  child: const Text('ADD'),
                  onPressed: () async {
                    if (_emailUsername.isEmpty) {
                      return;
                    }
                    try {
                      late final bool isUserFound;
                      if (EmailValidator.validate(_emailUsername)) {
                        // the user provided an email
                        isUserFound = await ListAppFriendshipManager.instance
                            .addFriendByEmail(_emailUsername,
                                _loggedInListAppUser!.databaseId!);
                      } else {
                        // the user provided an username
                        isUserFound = await ListAppFriendshipManager.instance
                            .addFriendByUsername(_emailUsername,
                                _loggedInListAppUser!.databaseId!);
                      }

                      if (isUserFound) {
                        // not awaited because we let the dialog pop in the meantime
                        Fluttertoast.showToast(
                          msg: "Friend request sent!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        Navigator.pop(context, true);
                      } else {
                        // not awaited because we let the dialog pop in the meantime
                        Fluttertoast.showToast(
                          msg: "The user has not been found.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    } on ListAppException catch (e) {
                      await Fluttertoast.showToast(
                        msg: e.message,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                ),
              ],
            );
          });
        });

    if (additionResult == true) {
      _refreshPage();
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      _friendsFuture = _fetchFriends();
    });
  }

  Widget _buildFriendsListView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPage,
      child: FutureBuilder<Map<ListAppUser, bool>>(
          future: _friendsFuture,
          builder: (BuildContext context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Container();
              case ConnectionState.done:
                final friends = snapshot.data!;

                return ListView(
                    children: friends.entries.map((entry) {
                  return _buildRow(context, entry.key, entry.value);
                }).toList());
            }
          }),
    );
  }

  Widget _buildRow(
      BuildContext context, ListAppUser friend, bool requestAccepted) {
    return Container(
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
          title: Text(
            friend.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(friend.username ?? ''),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: requestAccepted
                ? const [
                    Icon(Icons.supervisor_account_rounded),
                    // TODO switch on accepted/pending
                    Text(
                      "Accepted",
                      textScaleFactor: 0.9,
                    ),
                  ]
                : const [
                    Icon(Icons.supervised_user_circle_outlined),
                    Text(
                      "Request pending...",
                      textScaleFactor: 0.9,
                    ),
                  ],
          ),
          onTap: () {
            print(friend.fullName);
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Icon(Icons.menu), // not needed, automatically added by Drawer
        title: const Text(title),
        actions: [NotificationBadge()],
      ),
      drawer: const ListAppNavDrawer(routeName: FriendsPage.routeName),
      body: _buildFriendsListView(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async => await _addNewFriend(context),
        icon: const Icon(Icons.add),
        label: const Text('ADD FRIEND'),
      ),
    );
  }
}
