import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/list_manager.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:provider/provider.dart';

class AddMemberDialog extends StatefulWidget {
  final ListAppList list;
  const AddMemberDialog(this.list);
  @override
  _AddMemberDialogState createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<ListAppAuthProvider>().loggedInListAppUser;

    /* final Future<List<ListAppUser?>> friendsFrom = ListAppFriendshipManager
        .instance
        .getFriendsFromByUid(currentUser!.databaseId!);

    final Future<List<ListAppUser?>> friendsTo = ListAppFriendshipManager
        .instance
        .getFriendsToByUid(currentUser.databaseId!); */

    final Future<List<ListAppUser?>> friends =
        ListAppUserManager.instance.getFriends(currentUser!);

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
                      future: friends,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<ListAppUser?>> snapshot) {
                        if (snapshot.hasData) {
                          final onlyNonPresentFriends = snapshot.data!;

                          widget.list.membersAsUsers.forEach((element) {
                            onlyNonPresentFriends.removeWhere(
                                (e) => e!.username == element.username);
                          });

                          if (onlyNonPresentFriends.isNotEmpty) {
                            return AlertDialog(
                              title: const Text("Choose members to add"),
                              content: StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return Container(
                                    height: 300,
                                    width: 300,
                                    child: ListView.builder(
                                      itemCount: onlyNonPresentFriends.length,
                                      itemBuilder: (context, i) {
                                        return Container(
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                              color: Colors.grey,
                                              width: 0.8,
                                            ))),
                                            child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: onlyNonPresentFriends
                                                              .elementAt(i)!
                                                              .profilePictureURL ==
                                                          null
                                                      ? const AssetImage(
                                                              'assets/sample-profile.png')
                                                          as ImageProvider
                                                      : NetworkImage(
                                                          onlyNonPresentFriends
                                                              .elementAt(i)!
                                                              .profilePictureURL!),
                                                ),
                                                onTap: () {},
                                                title: Text(
                                                  onlyNonPresentFriends
                                                          .elementAt(i)!
                                                          .firstName +
                                                      ' ' +
                                                      onlyNonPresentFriends
                                                          .elementAt(i)!
                                                          .lastName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                trailing: IconButton(
                                                    icon: const Icon(
                                                      Icons
                                                          .person_add_alt_rounded,
                                                    ),
                                                    onPressed: () async {
                                                      await ListAppListManager
                                                              .instanceForUserUid(
                                                                  currentUser
                                                                      .databaseId!)
                                                          .addMemberToList(
                                                              widget.list
                                                                  .databaseId!,
                                                              onlyNonPresentFriends
                                                                  .elementAt(i)!
                                                                  .databaseId!);

                                                      Navigator.pop(context);
                                                      // not awaited because we let the dialog pop in the meantime
                                                      Fluttertoast.showToast(
                                                        msg: onlyNonPresentFriends
                                                                .elementAt(i)!
                                                                .fullName +
                                                            " was added to the list!",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.green,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0,
                                                      );

                                                      onlyNonPresentFriends
                                                          .removeAt(i);
                                                    })));
                                      },
                                    ));
                              }),
                            );
                          } else {
                            return AlertDialog(
                              title: const Text("Add new friends!"),
                              content: const Text(
                                  "You don't have any friend left to add to this list. Add new friends first, then you will be able to add them."),
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
                        return const AlertDialog(
                          title: Text("ALLA FINE"),
                        );
                      });
                });
              });
        });
  }
}
