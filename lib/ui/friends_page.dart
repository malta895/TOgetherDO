import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_applications/models/exception.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/notification_badge.dart';
import 'package:mobile_applications/ui/widgets/empty_list_widget.dart';
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
    _loggedInListAppUser!.friends = (await ListAppUserManager.instance
            .getByUid(_loggedInListAppUser!.databaseId!))!
        .friends;

    Map<ListAppUser, bool> friendsAsUsers = {};

    // synchronously await each user in the map
    for (final friendUid in _loggedInListAppUser!.friends.keys) {
      final friend = await ListAppUserManager.instance.getByUid(friendUid);
      if (friend != null)
        friendsAsUsers[friend] = _loggedInListAppUser!.friends[friendUid]!;
    }

    return friendsAsUsers;
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
                      if (EmailValidator.validate(_emailUsername)) {
                        // the user provided an email
                        await ListAppUserManager.instance.addFriendByEmail(
                            _emailUsername, _loggedInListAppUser!);
                      } else {
                        // the user provided an username
                        await ListAppUserManager.instance.addFriendByUsername(
                            _emailUsername, _loggedInListAppUser!);
                      }

                      // update the state to show the new friend
                      setState(() {});

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
                    } on ListAppException catch (e) {
                      await Fluttertoast.showToast(
                        msg: e.message,
                        toastLength: Toast.LENGTH_LONG,
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
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
                final friends = snapshot.data!;

                return friends.isEmpty
                    ? const EmptyListRefreshable(
                        "You don't have any friends.\nYou can add a new one with the button below.",
                      )
                    : ListView(
                        children: friends.entries.map((entry) {
                        return _buildFriendRow(context, entry.key, entry.value);
                      }).toList());
            }
          }),
    );
  }

  Widget _buildFriendRow(
    BuildContext context,
    ListAppUser friend,
    bool requestAccepted,
  ) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: Colors.grey,
        width: 0.8,
      ))),
      child: Dismissible(
        key: Key("dismissible_friend_${friend.databaseId!}"),
        confirmDismiss: (DismissDirection direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Are you sure you wish to remove ${friend.fullName} from your friends? "
                  "You will automatically leave all him/hers lists, and he/she will be automatically removed from yours.",
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(primary: Colors.red),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('CONFIRM'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("CANCEL"),
                  ),
                ],
              );
            },
          );
        },
        dismissThresholds: {DismissDirection.startToEnd: 0.3},
        direction: DismissDirection.startToEnd,
        onDismissed: (_) async {
          await ListAppUserManager.instance
              .removeFriend(_loggedInListAppUser!, friend);
          await _refreshPage();
        },
        background: Container(
          color: Colors.red,
          child: Align(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  width: 20,
                ),
                const Icon(
                  Icons.person_remove_alt_1_rounded,
                ),
              ],
            ),
            alignment: Alignment.centerLeft,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: friend.profilePictureURL == null
                ? const AssetImage('assets/sample-profile.png') as ImageProvider
                : NetworkImage(friend.profilePictureURL!),
            radius: 25.0,
          ),
          title: Text(
            friend.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(friend.username),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: requestAccepted
                ? const [
                    Icon(Icons.supervisor_account_rounded),
                    Padding(
                      padding: EdgeInsets.only(left: 18.0, right: 18.0),
                      child: Text(
                        "Accepted",
                        textScaleFactor: 0.9,
                      ),
                    ),
                  ]
                : [
                    Stack(
                      children: [
                        const Icon(Icons.person),
                        Positioned(
                          bottom: .0,
                          right: .0,
                          child: Stack(
                            children: [
                              Icon(
                                Icons.brightness_1,
                                color: Theme.of(context).backgroundColor,
                                size: 13.0,
                              ),
                              const Icon(
                                Icons.watch_later,
                                size: 13.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "Request pending",
                      textScaleFactor: 0.9,
                    ),
                  ],
          ),
          onTap: () {
            print(friend.fullName);
            // TODO show friend modal
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          title,
          style: TextStyle(fontFamily: "Oswald"),
        ),
        actions: [NotificationBadge()],
      ),
      drawer: const ListAppNavDrawer(routeName: FriendsPage.routeName),
      body: _buildFriendsListView(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async => await _addNewFriend(context),
        icon: const Icon(Icons.person_add),
        label: const Text('ADD FRIEND'),
      ),
    );
  }
}
