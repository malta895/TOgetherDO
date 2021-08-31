import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/list_manager.dart';
import 'package:mobile_applications/services/notification_manager.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:provider/provider.dart';

class AddMemberDialog extends StatefulWidget {
  final ListAppList list;
  const AddMemberDialog(this.list);
  @override
  _AddMemberDialogState createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  late final Future<List<ListAppUser?>> _friendsFuture;
  late final ListAppUser _currentUser;

  @override
  void initState() {
    super.initState();

    _currentUser = context.read<ListAppAuthProvider>().loggedInListAppUser!;
    _friendsFuture = ListAppUserManager.instance.getFriends(_currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).disabledColor,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            Text(
              'Add new member...',
              style: TextStyle(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
        onTap: () async {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (context, setState) {
                  return FutureBuilder<List<ListAppUser?>>(
                      future: _friendsFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<ListAppUser?>> snapshot) {
                        if (snapshot.hasData) {
                          final onlyNonPresentFriends = snapshot.data!;

                          widget.list.members.forEach((userId, _) {
                            onlyNonPresentFriends
                                .removeWhere((e) => e!.databaseId == userId);
                          });

                          if (onlyNonPresentFriends.isNotEmpty) {
                            return AlertDialog(
                              title: const Text("Choose members to add"),
                              content: StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return Container(
                                    height: 300,
                                    width: 300,
                                    child: ListView.builder(
                                      itemCount: onlyNonPresentFriends.length,
                                      itemBuilder: (context, i) {
                                        final newMember =
                                            onlyNonPresentFriends.elementAt(i)!;

                                        return Container(
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                            color: Colors.grey,
                                            width: 0.8,
                                          ))),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: newMember
                                                          .profilePictureURL ==
                                                      null
                                                  ? const AssetImage(
                                                          'assets/sample-profile.png')
                                                      as ImageProvider
                                                  : NetworkImage(newMember
                                                      .profilePictureURL!),
                                            ),
                                            onTap: () {},
                                            title: Text(
                                              newMember.displayName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                Icons.person_add_alt_rounded,
                                              ),
                                              onPressed: () {
                                                ListAppListManager
                                                        .instanceForUserUid(
                                                  _currentUser.databaseId!,
                                                )
                                                    .addMemberToList(
                                                  widget.list.databaseId!,
                                                  newMember.databaseId!,
                                                )
                                                    .then((value) {
                                                  // create notification for the new member
                                                  final notification =
                                                      ListInviteNotification(
                                                    userToId:
                                                        newMember.databaseId!,
                                                    userFromId:
                                                        _currentUser.databaseId,
                                                    listOwnerId:
                                                        widget.list.creatorUid!,
                                                    listId:
                                                        widget.list.databaseId!,
                                                  );

                                                  ListAppNotificationManager
                                                      .instance
                                                      .saveToFirestore(
                                                          notification);
                                                });

                                                Navigator.pop(context);
                                                // not awaited because we let the dialog pop in the meantime
                                                Fluttertoast.showToast(
                                                  msg:
                                                      "${newMember.displayName} was required to join the list!",
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.green,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0,
                                                );

                                                onlyNonPresentFriends
                                                    .removeAt(i);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return AlertDialog(
                              title: const Text("Add new friends!"),
                              content: const Text(
                                "You don't have any friend left to add to this list. Add new friends first, then you will be able to add them.",
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 16),
                                      primary: Colors.white,
                                      backgroundColor:
                                          Theme.of(context).accentColor),
                                  child: const Text("Got it!"),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          }
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      });
                });
              });
        });
  }
}
