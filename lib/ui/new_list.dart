import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/friendship_manager.dart';
import 'package:mobile_applications/services/list_manager.dart';
import 'package:provider/provider.dart';

class NewListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New list'),
      ),
      body: _NewListForm(),
    );
  }
}

class _NewListForm extends StatefulWidget {
  @override
  _NewListFormState createState() => _NewListFormState();
}

class _NewListDropdownMenu extends StatefulWidget {
  _NewListDropdownMenu({Key? key}) : super(key: key);

  @override
  _NewListDropdownMenuState createState() => _NewListDropdownMenuState();
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

  late List<ListAppUser> members = [];

  Widget _buildListTitleField() {
    return Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: _listTitleController,
          cursorColor: Theme.of(context).textTheme.headline1!.color!,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(5.0),
              filled: true,
              fillColor: Theme.of(context).splashColor,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.headline1!.color!,
                    width: 1.0),
              ),
              border: InputBorder.none,
              labelText: 'Enter the list title',
              labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.headline1!.color)),
          validator: (value) {
            if (value?.isEmpty == true) {
              return 'The title is required';
            }
            return null;
          },
        ));
  }

  Widget _buildListDescriptionField() {
    return Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          controller: _listDescriptionController,
          cursorColor: Theme.of(context).textTheme.headline1!.color!,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(5.0),
              filled: true,
              fillColor: Theme.of(context).splashColor,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.headline1!.color!,
                    width: 1.0),
              ),
              border: InputBorder.none,
              labelText: 'Enter a description for the list',
              labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.headline1!.color)),
          /*validator: (value) {
            if (value?.isEmpty == true) {
              return 'Please enter some text';
            }
            return null;
          },*/
        ));
  }

  Widget _buildListTypeSelector() {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: DropdownButtonFormField<ListType>(
        value: ListType.public,
        style: TextStyle(
          color: Theme.of(context).textTheme.headline1!.color,
          fontSize: 16.0,
        ),
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(
                  color: Theme.of(context).textTheme.headline1!.color!,
                  width: 1.0),
            ),
            contentPadding: EdgeInsets.all(5.0),
            filled: true,
            fillColor: Theme.of(context).splashColor,
            border: InputBorder.none,
            labelStyle:
                TextStyle(color: Theme.of(context).textTheme.headline1!.color)),
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        onChanged: (newValue) {
          setState(() {
            _listTypeValue = newValue ?? ListType.public;
          });
        },
        items: ListType.values.map((e) {
          return DropdownMenuItem<ListType>(
            value: e,
            child: Text(e.toReadableString()),
          );
        }).toList(),
      ),
    );
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
            );

            // If the form is valid, display a Snackbar.
            // TODO se abbiamo tempo sarebbe carino mettere l'animazione che c'é
            // sui bottoni al login (bisognerebbe copiarla dalla libreria)
            final snackBar = ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Uploading data')));

            final user = context.read<ListAppAuthProvider>().loggedInUser!;

            try {
              await ListAppListManager.instanceForUserUid(user.uid)
                  .saveToFirestore(newList);
              snackBar.close();
              Navigator.of(context).pop<ListAppList?>(newList);
              isUploading = false;
            } on Exception catch (e) {
              print(e);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error while creating list')));
              isUploading = false;
              rethrow;
            }
          }
        },
        child: Text('Submit'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildListTitleField(),
            _buildListDescriptionField(),
            _buildListTypeSelector(),
            _NewListDropdownMenu(),
            _AddMemberDialog(
              members: members,
            ),
            _buildSubmitButton()
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

    final Future<List<ListAppUser?>> friendsFrom = ListAppFriendshipManager
        .instance
        .getFriendsFromByUid(currentUser!.databaseId!);

    final Future<List<ListAppUser?>> friendsTo = ListAppFriendshipManager
        .instance
        .getFriendsToByUid(currentUser.databaseId!);

    return Padding(
        padding: EdgeInsets.only(top: 15),
        child: ListTile(
            contentPadding: EdgeInsets.all(5.0),
            title: Text(
              "Add participants",
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.headline1!.color),
            ),
            tileColor: Theme.of(context).splashColor,
            trailing: IconButton(
                icon: Icon(Icons.person_add,
                    color: Theme.of(context).accentColor),
                onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return FutureBuilder(
                            future: Future.wait([friendsFrom, friendsTo]),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<List<ListAppUser?>>>
                                    snapshot) {
                              if (snapshot.hasData) {
                                final allFriends =
                                    snapshot.data![0] + snapshot.data![1];

                                selectedFriendsValues = List<bool?>.filled(
                                    allFriends.length, false);
                                print(selectedFriendsValues);
                                return AlertDialog(
                                    title: Text("Choose members to add"),
                                    content: StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return Container(
                                          height: 300,
                                          width: 300,
                                          child: ListView.builder(
                                            itemCount: allFriends.length,
                                            itemBuilder: (context, i) {
                                              return Container(
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          bottom: BorderSide(
                                                    color: Colors.grey,
                                                    width: 0.8,
                                                  ))),
                                                  child: CheckboxListTile(
                                                      activeColor:
                                                          Theme.of(context)
                                                              .accentColor,
                                                      secondary: CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(allFriends
                                                                .elementAt(i)!
                                                                .profilePictureURL!),
                                                      ),
                                                      value:
                                                          selectedFriendsValues
                                                              .elementAt(i),
                                                      onChanged:
                                                          (bool? newValue) {
                                                        setState(() {
                                                          selectedFriendsValues[
                                                              i] = newValue;
                                                        });
                                                      },
                                                      title: Text(
                                                        allFriends
                                                                .elementAt(i)!
                                                                .firstName +
                                                            ' ' +
                                                            allFriends
                                                                .elementAt(i)!
                                                                .lastName,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )));
                                            },
                                          ));
                                    }),
                                    actions: <Widget>[
                                      TextButton(
                                          style: TextButton.styleFrom(
                                              primary: Theme.of(context)
                                                  .accentColor),
                                          onPressed: () => {
                                                for (var i = 0;
                                                    i < allFriends.length;
                                                    i++)
                                                  {
                                                    if (selectedFriendsValues[
                                                            i] ==
                                                        true)
                                                      {
                                                        widget.members
                                                            .add(allFriends[i])
                                                      }
                                                  },
                                                Navigator.of(context).pop(true)
                                              },
                                          child: const Text("ADD")),
                                    ]);
                              }
                              return Container();
                            });
                      });
                    }))));
  }
}

class _NewListDropdownMenuState extends State<_NewListDropdownMenu> {
  bool? _checkBoxValue = false;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 15),
            child: CheckboxListTile(
                contentPadding: EdgeInsets.all(5.0),
                title: Text(
                  'I am the only one who can add participants',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headline1!.color,
                    fontSize: 16.0,
                  ),
                ),
                value: _checkBoxValue,
                tileColor: Theme.of(context).splashColor,
                activeColor: Theme.of(context).accentColor,
                onChanged: (newValue) {
                  setState(() {
                    _checkBoxValue = newValue;
                  });
                }),
          ),
        ]);
  }
}
