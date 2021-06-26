import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:provider/provider.dart';

class NewList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New list'),
      ),
      body: MyCustomForm(),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class DropdownMenu extends StatefulWidget {
  DropdownMenu({Key? key}) : super(key: key);

  @override
  _DropdownMenuState createState() => _DropdownMenuState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String? dropdownValue = 'Public list';
    bool? checkBoxValue = false;

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: TextFormField(
                  cursorColor: Theme.of(context).textTheme.headline1!.color!,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(5.0),
                      filled: true,
                      fillColor: Theme.of(context).splashColor,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).textTheme.headline1!.color!,
                            width: 1.0),
                      ),
                      border: InputBorder.none,
                      labelText: 'Enter the list title',
                      labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.headline1!.color)),
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                )),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: DropdownButtonFormField<String>(
                value: dropdownValue,
                style: TextStyle(
                  color: Theme.of(context).textTheme.headline1!.color,
                  fontSize: 16.0,
                ),
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                          color: Theme.of(context).textTheme.headline1!.color!,
                          width: 1.0),
                    ),
                    contentPadding: EdgeInsets.all(5.0),
                    filled: true,
                    fillColor: Theme.of(context).splashColor,
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.headline1!.color)),
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>['Public list', 'Private list']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            DropdownMenu(),
            AddMember(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                ),
                onPressed: () {
                  // TODO: change this to add the item to the list

                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState?.validate() == true) {
                    // If the form is valid, display a Snackbar.
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddMember extends StatefulWidget {
  @override
  _AddMember createState() => _AddMember();
}

class _AddMember extends State<AddMember> {
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

  int? selectedRadio = 0;

  /*Widget _buildAlertDialogMembers(
      int membersNum, Set<ListAppUser> itemMembers) {
    return Container(
      height: 300,
      width: 300,
      child: ListView.builder(
        itemCount: membersNum,
        itemBuilder: (context, i) {
          return _buildMemberRow(context, itemMembers.elementAt(i));
        },
      ),
    );
  }

  Widget _buildMemberRow(BuildContext context, ListAppUser member) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey,
          width: 0.8,
        ))),
        child: CheckboxListTile(
            value: selected,
            onChanged: (bool? newValue) {
              print("Added " + member.displayName + " " + newValue.toString());
              setState(() {
                selected = newValue!;
              });
            },
            /*IconButton(
                icon: Icon(Icons.person_add),
                onPressed: () => print("Added" + member.displayName)),*/
            title: Text(
              member.firstName + ' ' + member.lastName,
              style: TextStyle(fontWeight: FontWeight.bold),
            )));
  }*/

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

class _DropdownMenuState extends State<DropdownMenu> {
  String? dropdownValue = 'Public list';
  bool? checkBoxValue = false;

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
                value: checkBoxValue,
                tileColor: Theme.of(context).splashColor,
                activeColor: Theme.of(context).accentColor,
                onChanged: (newValue) {
                  setState(() {
                    checkBoxValue = newValue;
                  });
                }),
          ),
        ]);
  }
}
