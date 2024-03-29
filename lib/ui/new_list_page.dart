import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/list_manager.dart';
import 'package:mobile_applications/services/notification_manager.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:provider/provider.dart';

class NewListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New list'),
      ),
      body: _NewListForm(),
    );
  }
}

class _NewListForm extends StatefulWidget {
  @override
  _NewListFormState createState() => _NewListFormState();
}

class _NewListFormState extends State<_NewListForm> {
  final _formKey = GlobalKey<FormState>();

  ListType _listTypeValue = ListType.public;
  TextEditingController _listDescriptionController = TextEditingController();
  late TextEditingController _listTitleController;

  @override
  void initState() {
    super.initState();

    _listTitleController = TextEditingController();
  }

  List<ListAppUser> members = [];

  Widget _buildListTitleField() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: _listTitleController,
        cursorColor: Theme.of(context).textTheme.headline1!.color!,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(5.0),
            filled: true,
            fillColor: Theme.of(context).splashColor,
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.headline1!.color!,
                  width: 1.0),
            ),
            border: InputBorder.none,
            labelText: 'Enter the list title',
            labelStyle:
                TextStyle(color: Theme.of(context).textTheme.headline1!.color)),
        validator: (value) {
          if (value?.isEmpty == true) {
            return 'The title is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildListDescriptionField() {
    return Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          controller: _listDescriptionController,
          cursorColor: Theme.of(context).textTheme.headline1!.color!,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(5.0),
            filled: true,
            fillColor: Theme.of(context).splashColor,
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(
                color: Theme.of(context).textTheme.headline1!.color!,
                width: 1.0,
              ),
            ),
            border: InputBorder.none,
            labelText: 'Enter a description for the list',
            labelStyle:
                TextStyle(color: Theme.of(context).textTheme.headline1!.color),
          ),
        ));
  }

  Widget _buildListTypeSelector() {
    return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Column(
          children: ListType.values.map((builtListType) {
            return RadioListTile<ListType>(
              value: builtListType,
              title: Text(builtListType.toReadableString()),
              subtitle: Text(builtListType.getDescription()),
              groupValue: _listTypeValue,
              onChanged: (selectedListType) {
                if (selectedListType == null) return;
                setState(() {
                  _listTypeValue = selectedListType;
                });
              },
            );
          }).toList(),
        ));
  }

  Widget _buildSubmitButton() {
    bool isUploading = false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).accentColor,
        ),
        onPressed: () async {
          // exit when is uploading to avoid duplicates
          if (isUploading) return;
          isUploading = true;

          final currentUser =
              context.read<ListAppAuthProvider>().loggedInListAppUser;

          // Validate returns true if the form is valid, or false
          // otherwise.
          if (_formKey.currentState?.validate() == true) {
            final newList = ListAppList(
              name: _listTitleController.text,
              description: _listDescriptionController.text,
              listType: _listTypeValue,
              creatorUid: currentUser!.databaseId,
              membersAsUsers: members,
              listStatus: _listTypeValue == ListType.public
                  ? ListStatus.saved
                  : ListStatus.draft,
            );

            // If the form is valid, display a Snackbar.
            // TODO se abbiamo tempo sarebbe carino mettere l'animazione che c'é
            // sui bottoni al login (bisognerebbe copiarla dalla libreria)
            final snackBar = ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Uploading data')));

            final user = context.read<ListAppAuthProvider>().loggedInUser!;

            try {
              await ListAppListManager.instanceForUserUid(user.uid)
                  .saveToFirestore(newList);
              await ListAppListManager.instanceForUserUid(user.uid)
                  .populateObjects(newList);

              // create notifications for members
              // we don't need to await them since they are sent to other devices
              newList.members.forEach((userId, _) async {
                final notification = ListInviteNotification(
                  userToId: userId,
                  userFromId: currentUser.databaseId!,
                  listOwnerId: newList.databaseId!,
                  listId: newList.databaseId!,
                );

                await ListAppNotificationManager.instance
                    .saveToFirestore(notification);
              });

              // remove non-confirmed members from newList
              // otherwise they'd be shown as already members until the first refresh
              newList.membersAsUsers = [];

              snackBar.close();
              Navigator.of(context).pop<ListAppList?>(newList);
              isUploading = false;
            } on Exception catch (e) {
              print(e);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error while creating list')));
              isUploading = false;
              rethrow;
            }
          }
        },
        child: const Text('Submit'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(child: Divider()),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('List details'),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            Flexible(
              flex: 0,
              child: _buildListTitleField(),
            ),
            Flexible(
              flex: 0,
              child: _buildListDescriptionField(),
            ),
            Row(
              children: <Widget>[
                const Expanded(child: Divider()),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Choose the list type'),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            Flexible(
              flex: 0,
              child: _buildListTypeSelector(),
            ),
            const SizedBox(
              height: 20,
            ),
            Flexible(
              flex: 3,
              //fit: FlexFit.tight,
              child: _AddMemberDialog(
                members: members,
              ),
            ),
            Flexible(
              flex: 5,
              child: _buildSubmitButton(),
            )
          ],
        ),
      ),
    );
  }
}

// TODO sistemare quando avremo gli amici dal db
class _AddMemberDialog extends StatefulWidget {
  final List<ListAppUser?> members;
  const _AddMemberDialog({Key? key, required this.members}) : super(key: key);
  @override
  _AddMemberDialogState createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  late List<bool?> selectedFriendsValues;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<ListAppAuthProvider>().loggedInListAppUser;

    final Future<List<ListAppUser?>> friends =
        ListAppUserManager.instance.getFriends(currentUser!);

    /*final Future<List<ListAppUser?>> friendsFrom = ListAppFriendshipManager
        .instance
        .getFriendsFromByUid(currentUser!.databaseId!);

    final Future<List<ListAppUser?>> friendsTo = ListAppFriendshipManager
        .instance
        .getFriendsToByUid(currentUser.databaseId!);*/

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(5.0),
        title: const Text("Add participants"),
        tileColor: Theme.of(context).splashColor,
        trailing: IconButton(
          icon: Icon(Icons.person_add, color: Theme.of(context).accentColor),
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return FutureBuilder<List<ListAppUser?>>(
                      future: friends,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<ListAppUser?>> snapshot) {
                        if (snapshot.hasData) {
                          final allFriends = snapshot.data!;

                          selectedFriendsValues =
                              List<bool?>.filled(allFriends.length, false);

                          return AlertDialog(
                            title: const Text("Choose members to add"),
                            content: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Container(
                                  height: 300,
                                  width: 300,
                                  child: ListView.builder(
                                    itemCount: allFriends.length,
                                    itemBuilder: (context, i) {
                                      final currentFriend =
                                          allFriends.elementAt(i)!;
                                      return Container(
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                          color: Colors.grey,
                                          width: 0.8,
                                        ))),
                                        child: CheckboxListTile(
                                          activeColor:
                                              Theme.of(context).accentColor,
                                          secondary: currentFriend
                                                      .profilePictureURL ==
                                                  null
                                              ? const CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                      'assets/sample-profile.png'),
                                                  radius: 25.0,
                                                )
                                              : CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      currentFriend
                                                          .profilePictureURL!)),
                                          value: selectedFriendsValues
                                              .elementAt(i),
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              selectedFriendsValues[i] =
                                                  newValue;
                                            });
                                          },
                                          title: Text(
                                            allFriends.elementAt(i)!.firstName +
                                                ' ' +
                                                allFriends
                                                    .elementAt(i)!
                                                    .lastName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    },
                                  ));
                            }),
                            actions: <Widget>[
                              TextButton(
                                  style: TextButton.styleFrom(
                                      primary: Theme.of(context).accentColor),
                                  onPressed: () => {
                                        for (var i = 0;
                                            i < allFriends.length;
                                            i++)
                                          {
                                            if (selectedFriendsValues[i] ==
                                                true)
                                              {
                                                widget.members
                                                    .add(allFriends[i])
                                              }
                                          },
                                        Navigator.of(context).pop(true)
                                      },
                                  child: const Text("ADD")),
                            ],
                          );
                        }
                        return Container();
                      },
                    );
                  },
                );
              }),
        ),
      ),
    );
  }
}
