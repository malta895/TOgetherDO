import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
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
        onPressed: () {
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
                creatorUid: currentUser!.databaseId);

            // If the form is valid, display a Snackbar.
            // NOTE se abbiamo tempo sarebbe carino mettere l'animazione che c'é
            // sui bottoni al login (bisognerebbe copiarla dalla libreria)
            final snackBar = ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Uploading data')));

            final user = context.read<ListAppAuthProvider>().loggedInUser!;
            ListAppListManager.instanceForUserUid(user.uid)
                .saveInstance(newList)
                .then((_) {
              snackBar.close();
              Navigator.of(context).pop<ListAppList?>(newList);
              isUploading = false;
            }, onError: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error while creating list')));
              isUploading = false;
            });
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
            _AddMemberDialog(),
            _buildSubmitButton()
          ],
        ),
      ),
    );
  }
}

// TODO sistemare quando avremo gli amici dal db
class _AddMemberDialog extends StatefulWidget {
  @override
  _AddMemberDialogState createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final ListAppUser _user = ListAppUser(
      firstName: "Luca",
      lastName: "Maltagliati",
      email: "luca.malta@mail.com",
      username: "malta",
      friends: {
        ListAppUser(
            firstName: "Lorenzo",
            lastName: "Amici",
            email: "lorenzo.amici@mail.com",
            username: "lorenzo.amici@mail.com",
            databaseId: '',
            profilePictureURL:
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTVLqfekg_kitC_QJ5kgBUTh2tt5EIcxEnQDQ&usqp=CAU"),
        ListAppUser(
            firstName: "Mario",
            lastName: "Rossi",
            email: "mario.rossi@mail.com",
            username: "mario.rossi@mail.com",
            databaseId: '',
            profilePictureURL:
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTVLqfekg_kitC_QJ5kgBUTh2tt5EIcxEnQDQ&usqp=CAU"),
      },
      databaseId: '');

  @override
  Widget build(BuildContext context) {
    List<bool?> selectedFriendsValues =
        List<bool?>.filled(_user.friends.length, false);
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
            icon: Icon(Icons.person_add, color: Theme.of(context).accentColor),
            onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return AlertDialog(
                        title: Text("Choose members to add"),
                        content: StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return Container(
                              height: 300,
                              width: 300,
                              child: ListView.builder(
                                itemCount: _user.friends.length,
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
                                              Theme.of(context).accentColor,
                                          secondary: CircleAvatar(
                                            backgroundImage: NetworkImage(_user
                                                .friends
                                                .elementAt(i)
                                                .profilePictureURL!),
                                          ),
                                          value: selectedFriendsValues
                                              .elementAt(i),
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              selectedFriendsValues[i] =
                                                  newValue!;
                                            });
                                          },
                                          title: Text(
                                            _user.friends
                                                    .elementAt(i)
                                                    .firstName +
                                                ' ' +
                                                _user.friends
                                                    .elementAt(i)
                                                    .lastName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )));
                                },
                              ),
                            );
                          },
                        ),
                        actions: <Widget>[
                          TextButton(
                              style: TextButton.styleFrom(
                                  primary: Theme.of(context).accentColor),
                              onPressed: () => {
                                    for (var i = 0;
                                        i < _user.friends.length;
                                        i++)
                                      {
                                        if (selectedFriendsValues[i] == true)
                                          {
                                            print("Added " +
                                                _user.friends
                                                    .elementAt(i)
                                                    .displayName)
                                          }
                                      },
                                    Navigator.of(context).pop(true)
                                  },
                              child: const Text("ADD")),
                        ]);
                  });
                }),
          )),
    );
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
